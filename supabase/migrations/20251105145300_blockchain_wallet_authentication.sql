-- ============================================
-- Migration: Blockchain Wallet Authentication
-- Description: Add blockchain wallet support to existing user authentication system for offline access
-- Dependencies: Existing user_profiles table
-- ============================================

-- 1. CREATE BLOCKCHAIN WALLET AUTHENTICATION TABLE
CREATE TABLE public.blockchain_wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    wallet_address TEXT NOT NULL UNIQUE,
    public_key TEXT NOT NULL,
    encrypted_private_key TEXT NOT NULL,
    wallet_name TEXT NOT NULL DEFAULT 'AiFER Wallet',
    wallet_type TEXT NOT NULL DEFAULT 'FER' CHECK (wallet_type IN ('FER', 'ETH', 'BTC')),
    recovery_phrase_hash TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT true,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    offline_access_enabled BOOLEAN NOT NULL DEFAULT true,
    last_verification_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. CREATE OFFLINE AUTHENTICATION SESSIONS TABLE
CREATE TABLE public.offline_auth_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES public.blockchain_wallets(id) ON DELETE CASCADE,
    session_token TEXT NOT NULL UNIQUE,
    challenge_signature TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    device_fingerprint TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. ADD BLOCKCHAIN WALLET COLUMNS TO USER_PROFILES (extend existing table)
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS wallet_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS preferred_wallet_id UUID REFERENCES public.blockchain_wallets(id),
ADD COLUMN IF NOT EXISTS offline_auth_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS last_wallet_verification TIMESTAMPTZ;

-- 4. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX idx_blockchain_wallets_user_id ON public.blockchain_wallets(user_id);
CREATE INDEX idx_blockchain_wallets_address ON public.blockchain_wallets(wallet_address);
CREATE INDEX idx_blockchain_wallets_verified ON public.blockchain_wallets(is_verified) WHERE is_verified = true;
CREATE INDEX idx_offline_sessions_user_id ON public.offline_auth_sessions(user_id);
CREATE INDEX idx_offline_sessions_token ON public.offline_auth_sessions(session_token);
CREATE INDEX idx_offline_sessions_active ON public.offline_auth_sessions(is_active) WHERE is_active = true;

-- 5. ENABLE RLS (Row Level Security)
ALTER TABLE public.blockchain_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_auth_sessions ENABLE ROW LEVEL SECURITY;

-- 6. CREATE BLOCKCHAIN WALLET VERIFICATION FUNCTION
CREATE OR REPLACE FUNCTION public.verify_wallet_signature(
    wallet_address TEXT,
    message TEXT,
    signature TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Simplified signature verification for demo
    -- In production, implement proper cryptographic verification
    RETURN length(signature) > 64 AND wallet_address IS NOT NULL;
END;
$$;

-- 7. CREATE OFFLINE SESSION GENERATOR FUNCTION
CREATE OR REPLACE FUNCTION public.create_offline_session(
    p_user_id UUID,
    p_wallet_address TEXT,
    p_signature TEXT,
    p_device_fingerprint TEXT DEFAULT NULL
) RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_wallet_id UUID;
    v_session_token TEXT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Get wallet ID
    SELECT id INTO v_wallet_id 
    FROM public.blockchain_wallets 
    WHERE user_id = p_user_id AND wallet_address = p_wallet_address AND is_verified = true;
    
    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Wallet not found or not verified';
    END IF;
    
    -- Generate session token
    v_session_token := encode(gen_random_bytes(32), 'hex');
    v_expires_at := now() + INTERVAL '7 days';
    
    -- Create offline session
    INSERT INTO public.offline_auth_sessions (
        user_id, wallet_id, session_token, challenge_signature, 
        expires_at, device_fingerprint
    ) VALUES (
        p_user_id, v_wallet_id, v_session_token, p_signature,
        v_expires_at, p_device_fingerprint
    );
    
    RETURN v_session_token;
END;
$$;

-- 8. CREATE RLS POLICIES
-- Wallet policies - users can only see their own wallets
CREATE POLICY "users_own_wallets" ON public.blockchain_wallets
FOR ALL TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Offline session policies - users can only see their own sessions
CREATE POLICY "users_own_offline_sessions" ON public.offline_auth_sessions
FOR ALL TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 9. CREATE ADMIN WALLET MANAGEMENT POLICIES
CREATE POLICY "admin_manage_wallets" ON public.blockchain_wallets
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id = auth.uid() 
        AND email = 'bouncingferretofficial@gmail.com'
    )
);

-- 10. INSERT DEMO BLOCKCHAIN WALLETS FOR TESTING
DO $$
DECLARE
    admin_user_id UUID;
    demo_user_id UUID;
BEGIN
    -- Get existing users
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@aifer.network' LIMIT 1;
    SELECT id INTO demo_user_id FROM public.user_profiles WHERE email = 'demo@fernetwork.nl' LIMIT 1;
    
    -- Create admin wallet if admin user exists
    IF admin_user_id IS NOT NULL THEN
        INSERT INTO public.blockchain_wallets (
            user_id, wallet_address, public_key, encrypted_private_key,
            wallet_name, wallet_type, recovery_phrase_hash, is_verified, offline_access_enabled
        ) VALUES (
            admin_user_id,
            'FER0xAdmin123456789AbCdEf0123456789AbCdEf',
            'admin_public_key_hash_placeholder',
            'encrypted_admin_private_key_placeholder',
            'Admin AiFER Wallet',
            'FER',
            'admin_recovery_phrase_hash',
            true,
            true
        ) ON CONFLICT (wallet_address) DO NOTHING;
        
        -- Update admin profile with wallet info
        UPDATE public.user_profiles 
        SET wallet_enabled = true, offline_auth_enabled = true, last_wallet_verification = now()
        WHERE id = admin_user_id;
    END IF;
    
    -- Create demo wallet if demo user exists
    IF demo_user_id IS NOT NULL THEN
        INSERT INTO public.blockchain_wallets (
            user_id, wallet_address, public_key, encrypted_private_key,
            wallet_name, wallet_type, recovery_phrase_hash, is_verified, offline_access_enabled
        ) VALUES (
            demo_user_id,
            'FER0xDemo987654321FeDcBa9876543210FeDcBa',
            'demo_public_key_hash_placeholder',
            'encrypted_demo_private_key_placeholder',
            'Demo FER Wallet',
            'FER',
            'demo_recovery_phrase_hash',
            true,
            true
        ) ON CONFLICT (wallet_address) DO NOTHING;
        
        -- Update demo profile with wallet info
        UPDATE public.user_profiles 
        SET wallet_enabled = true, offline_auth_enabled = true, last_wallet_verification = now()
        WHERE id = demo_user_id;
    END IF;
END $$;

-- 11. GRANT PERMISSIONS
GRANT EXECUTE ON FUNCTION public.verify_wallet_signature(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_offline_session(UUID, TEXT, TEXT, TEXT) TO authenticated;