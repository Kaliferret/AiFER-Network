-- ============================================
-- Migration: Blockchain Wallets with Offline Verification Support
-- Description: Creates blockchain wallets table for user wallet management and offline account verification
-- Dependencies: user_profiles table (existing)
-- ============================================

-- 1. CREATE ENUM TYPE for wallet types
CREATE TYPE public.wallet_type AS ENUM ('stellar', 'sui', 'ethereum');

-- 2. CREATE BLOCKCHAIN WALLETS TABLE
CREATE TABLE public.blockchain_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    account_name TEXT NOT NULL CHECK (length(account_name) >= 3 AND length(account_name) <= 32),
    wallet_address TEXT NOT NULL CHECK (length(wallet_address) >= 20),
    wallet_type public.wallet_type NOT NULL DEFAULT 'stellar',
    public_key TEXT NOT NULL,
    encrypted_private_key TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    verification_method TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. CREATE INDEXES (for performance)
CREATE INDEX idx_blockchain_wallets_user_id ON public.blockchain_wallets(user_id);
CREATE INDEX idx_blockchain_wallets_account_name ON public.blockchain_wallets(account_name);
CREATE INDEX idx_blockchain_wallets_wallet_address ON public.blockchain_wallets(wallet_address);
CREATE INDEX idx_blockchain_wallets_wallet_type ON public.blockchain_wallets(wallet_type);
CREATE INDEX idx_blockchain_wallets_verified ON public.blockchain_wallets(is_verified);
CREATE UNIQUE INDEX idx_blockchain_wallets_unique_account ON public.blockchain_wallets(account_name, wallet_address);

-- 4. CREATE ACCOUNT VERIFICATION LOG TABLE (for audit trail)
CREATE TABLE public.account_verification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID REFERENCES public.blockchain_wallets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    account_name TEXT NOT NULL,
    wallet_address TEXT NOT NULL,
    verification_method TEXT NOT NULL,
    verification_result BOOLEAN NOT NULL,
    verification_details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_verification_log_user_id ON public.account_verification_log(user_id);
CREATE INDEX idx_verification_log_wallet_id ON public.account_verification_log(wallet_id);
CREATE INDEX idx_verification_log_created_at ON public.account_verification_log(created_at DESC);

-- 5. ENABLE RLS (security)
ALTER TABLE public.blockchain_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_verification_log ENABLE ROW LEVEL SECURITY;

-- 6. CREATE RLS POLICIES (access control)

-- Blockchain wallets policies
CREATE POLICY "users_own_wallets" ON public.blockchain_wallets
FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "public_read_verified_wallets" ON public.blockchain_wallets
FOR SELECT TO public
USING (is_verified = true);

-- Verification log policies  
CREATE POLICY "users_own_verification_logs" ON public.account_verification_log
FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 7. CREATE FUNCTIONS for wallet management

-- Function to verify wallet account
CREATE OR REPLACE FUNCTION public.verify_wallet_account(
    p_account_name TEXT,
    p_wallet_address TEXT,
    p_verification_method TEXT DEFAULT 'manual'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_wallet_id UUID;
    v_is_valid BOOLEAN := false;
BEGIN
    -- Get current user
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN false;
    END IF;

    -- Basic validation
    IF length(p_account_name) < 3 OR length(p_wallet_address) < 20 THEN
        RETURN false;
    END IF;

    -- Check wallet format based on address
    IF p_wallet_address LIKE 'G%' AND length(p_wallet_address) = 56 THEN
        v_is_valid := true; -- Stellar format
    ELSIF p_wallet_address LIKE '0x%' AND length(p_wallet_address) = 42 THEN
        v_is_valid := true; -- Ethereum format  
    ELSIF length(p_wallet_address) >= 32 AND length(p_wallet_address) <= 64 THEN
        v_is_valid := true; -- SUI format
    END IF;

    -- Find wallet if exists
    SELECT id INTO v_wallet_id 
    FROM public.blockchain_wallets 
    WHERE account_name = p_account_name 
    AND wallet_address = p_wallet_address 
    AND user_id = v_user_id;

    -- Update verification status if wallet exists
    IF v_wallet_id IS NOT NULL AND v_is_valid THEN
        UPDATE public.blockchain_wallets 
        SET is_verified = true,
            verification_method = p_verification_method,
            updated_at = now()
        WHERE id = v_wallet_id;
    END IF;

    -- Log verification attempt
    INSERT INTO public.account_verification_log (
        wallet_id, user_id, account_name, wallet_address,
        verification_method, verification_result, verification_details
    ) VALUES (
        v_wallet_id, v_user_id, p_account_name, p_wallet_address,
        p_verification_method, v_is_valid, 
        jsonb_build_object('timestamp', now(), 'method', p_verification_method)
    );

    RETURN v_is_valid;
END;
$$;

-- Function to get user wallet statistics
CREATE OR REPLACE FUNCTION public.get_user_wallet_stats(p_user_id UUID DEFAULT auth.uid())
RETURNS TABLE(
    total_wallets INTEGER,
    verified_wallets INTEGER,
    stellar_wallets INTEGER,
    ethereum_wallets INTEGER,
    sui_wallets INTEGER,
    last_created TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_wallets,
        COUNT(CASE WHEN is_verified THEN 1 END)::INTEGER as verified_wallets,
        COUNT(CASE WHEN wallet_type = 'stellar' THEN 1 END)::INTEGER as stellar_wallets,
        COUNT(CASE WHEN wallet_type = 'ethereum' THEN 1 END)::INTEGER as ethereum_wallets,
        COUNT(CASE WHEN wallet_type = 'sui' THEN 1 END)::INTEGER as sui_wallets,
        MAX(created_at) as last_created
    FROM public.blockchain_wallets 
    WHERE user_id = COALESCE(p_user_id, auth.uid());
END;
$$;

-- 8. CREATE TRIGGERS for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_blockchain_wallets_updated_at
    BEFORE UPDATE ON public.blockchain_wallets
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 9. INSERT MOCK DATA for testing
DO $$
DECLARE
    existing_user_id UUID;
    demo_wallet_id UUID := gen_random_uuid();
    admin_wallet_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles WHERE email LIKE '%demo%' LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Insert demo blockchain wallets
        INSERT INTO public.blockchain_wallets (
            id, user_id, account_name, wallet_address, wallet_type, 
            public_key, is_verified, verification_method, metadata
        ) VALUES 
        (
            demo_wallet_id, existing_user_id, 'demo_stellar_account', 
            'GCKFBEIYTKP33BZQHRJVIKGXI5C4KW2HFEX7YSSSW7ALNWAPKKYM', 
            'stellar', 'PUB_KEY_STELLAR_DEMO_123456789', true, 'cryptographic',
            jsonb_build_object('generation_method', 'demo', 'offline_verified', true)
        ),
        (
            admin_wallet_id, existing_user_id, 'demo_ethereum_account',
            '0x742d35Dc6C6832caC3aDb0B3FE8eB8Cd8C4c4DC9',
            'ethereum', 'PUB_KEY_ETHEREUM_DEMO_123456789', true, 'manual',
            jsonb_build_object('generation_method', 'demo', 'offline_verified', true)
        );

        -- Insert verification logs
        INSERT INTO public.account_verification_log (
            wallet_id, user_id, account_name, wallet_address,
            verification_method, verification_result, verification_details
        ) VALUES 
        (
            demo_wallet_id, existing_user_id, 'demo_stellar_account',
            'GCKFBEIYTKP33BZQHRJVIKGXI5C4KW2HFEX7YSSSW7ALNWAPKKYM',
            'cryptographic', true,
            jsonb_build_object('timestamp', now(), 'method', 'cryptographic', 'source', 'demo_data')
        ),
        (
            admin_wallet_id, existing_user_id, 'demo_ethereum_account',
            '0x742d35Dc6C6832caC3aDb0B3FE8eB8Cd8C4c4DC9',
            'manual', true,
            jsonb_build_object('timestamp', now(), 'method', 'manual', 'source', 'demo_data')
        );

        RAISE NOTICE 'Demo blockchain wallets created with offline verification support';
        RAISE NOTICE 'Stellar wallet: demo_stellar_account - GCKFBEIYTKP33BZQHRJVIKGXI5C4KW2HFEX7YSSSW7ALNWAPKKYM';
        RAISE NOTICE 'Ethereum wallet: demo_ethereum_account - 0x742d35Dc6C6832caC3aDb0B3FE8eB8Cd8C4c4DC9';
    ELSE
        RAISE NOTICE 'No demo user found - blockchain wallets not created';
    END IF;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Blockchain wallets migration completed successfully';
    RAISE NOTICE 'Tables created: blockchain_wallets, account_verification_log';
    RAISE NOTICE 'Functions available: verify_wallet_account(), get_user_wallet_stats()';
    RAISE NOTICE 'Offline verification and account name validation enabled';
END $$;