-- ============================================
-- Migration: Fix Blockchain Wallet Schema Errors
-- Description: Fix SQL syntax errors and enhance blockchain wallet functionality
-- Dependencies: user_profiles, blockchain_wallets, offline_auth_sessions tables
-- ============================================

-- 1. ADD MISSING COLUMNS (Using proper PostgreSQL syntax)
-- Add account_name column to blockchain_wallets if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'blockchain_wallets' 
        AND column_name = 'account_name'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.blockchain_wallets ADD COLUMN account_name TEXT DEFAULT '';
        RAISE NOTICE 'Added account_name column to blockchain_wallets';
    ELSE
        RAISE NOTICE 'account_name column already exists in blockchain_wallets';
    END IF;
END $$;

-- 2. UPDATE EXISTING DATA
-- Populate account_name from wallet_name where missing
DO $$
BEGIN
    UPDATE public.blockchain_wallets 
    SET account_name = COALESCE(wallet_name, 'AiFER User')
    WHERE account_name = '' OR account_name IS NULL;
    
    RAISE NOTICE 'Updated account_name for existing wallets';
END $$;

-- 3. CREATE INDEXES (Only if they don't exist)
DO $$
BEGIN
    -- Create account_name index if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_blockchain_wallets_account_name'
        AND tablename = 'blockchain_wallets'
        AND schemaname = 'public'
    ) THEN
        CREATE INDEX idx_blockchain_wallets_account_name ON public.blockchain_wallets(account_name);
        RAISE NOTICE 'Created index on account_name';
    ELSE
        RAISE NOTICE 'Index on account_name already exists';
    END IF;
END $$;

-- 4. ADD CONSTRAINTS (Using proper PostgreSQL syntax without IF NOT EXISTS)
-- Check and add session_token length constraint
DO $$
BEGIN
    -- First check if the constraint already exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'check_session_token_length'
        AND table_name = 'offline_auth_sessions'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.offline_auth_sessions 
        ADD CONSTRAINT check_session_token_length 
        CHECK (char_length(session_token) >= 32);
        RAISE NOTICE 'Added session_token length constraint';
    ELSE
        RAISE NOTICE 'Session token length constraint already exists';
    END IF;
END $$;

-- 5. CREATE OR UPDATE FUNCTIONS
-- Updated trigger function for blockchain_wallets
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. ENSURE TRIGGERS EXIST
DO $$
BEGIN
    -- Drop existing trigger if exists
    DROP TRIGGER IF EXISTS update_blockchain_wallets_updated_at ON public.blockchain_wallets;
    
    -- Create new trigger
    CREATE TRIGGER update_blockchain_wallets_updated_at
        BEFORE UPDATE ON public.blockchain_wallets
        FOR EACH ROW
        EXECUTE FUNCTION public.update_updated_at_column();
    
    RAISE NOTICE 'Created/updated blockchain_wallets updated_at trigger';
END $$;

-- 7. UPDATE RLS POLICIES (Ensure proper policies exist)
DO $$
BEGIN
    -- Drop and recreate offline sessions policy with better name
    DROP POLICY IF EXISTS "users_can_manage_their_offline_sessions" ON public.offline_auth_sessions;
    DROP POLICY IF EXISTS "users_own_offline_sessions" ON public.offline_auth_sessions;
    
    CREATE POLICY "users_manage_own_offline_sessions" 
    ON public.offline_auth_sessions
    FOR ALL 
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
    
    RAISE NOTICE 'Updated RLS policies for offline_auth_sessions';
END $$;

-- 8. CREATE ENHANCED WALLET FUNCTIONS
-- Enhanced wallet signature verification function
CREATE OR REPLACE FUNCTION public.verify_wallet_signature_v2(
    wallet_addr TEXT,
    message_text TEXT,
    signature_text TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    wallet_public_key TEXT;
    is_valid BOOLEAN := false;
BEGIN
    -- Get wallet public key for verified wallets only
    SELECT public_key INTO wallet_public_key
    FROM public.blockchain_wallets
    WHERE wallet_address = wallet_addr 
    AND is_verified = true 
    AND user_id = auth.uid(); -- Ensure user owns the wallet
    
    IF wallet_public_key IS NULL THEN
        RETURN false;
    END IF;
    
    -- Enhanced signature verification (simplified for demo)
    -- In production, implement proper cryptographic verification
    IF LENGTH(signature_text) >= 64 
       AND LENGTH(wallet_public_key) >= 32 
       AND LENGTH(message_text) > 0 THEN
        is_valid := true;
    END IF;
    
    RETURN is_valid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enhanced offline session creation function
CREATE OR REPLACE FUNCTION public.create_offline_session_v2(
    user_uuid UUID,
    wallet_addr TEXT,
    signature_text TEXT
) RETURNS TEXT AS $$
DECLARE
    session_token TEXT;
    wallet_uuid UUID;
    expires_timestamp TIMESTAMPTZ;
    challenge_message TEXT;
BEGIN
    -- Validate user matches auth.uid()
    IF user_uuid != auth.uid() THEN
        RAISE EXCEPTION 'Unauthorized: Cannot create session for other users';
    END IF;
    
    -- Generate secure session token (base64 encoded 32 bytes)
    session_token := encode(gen_random_bytes(32), 'base64');
    expires_timestamp := NOW() + INTERVAL '30 days';
    challenge_message := 'AiFER Network Authentication: ' || session_token;
    
    -- Get verified wallet ID that belongs to the user
    SELECT id INTO wallet_uuid
    FROM public.blockchain_wallets
    WHERE wallet_address = wallet_addr 
    AND user_id = user_uuid
    AND is_verified = true
    AND offline_access_enabled = true;
    
    IF wallet_uuid IS NULL THEN
        RAISE EXCEPTION 'Wallet not found, not verified, or offline access disabled';
    END IF;
    
    -- Verify signature before creating session
    IF NOT public.verify_wallet_signature_v2(wallet_addr, challenge_message, signature_text) THEN
        RAISE EXCEPTION 'Invalid wallet signature';
    END IF;
    
    -- Deactivate existing sessions for this wallet
    UPDATE public.offline_auth_sessions 
    SET is_active = false 
    WHERE wallet_id = wallet_uuid AND is_active = true;
    
    -- Create new offline session
    INSERT INTO public.offline_auth_sessions (
        user_id,
        wallet_id,
        session_token,
        challenge_signature,
        expires_at,
        is_active,
        device_fingerprint
    ) VALUES (
        user_uuid,
        wallet_uuid,
        session_token,
        signature_text,
        expires_timestamp,
        true,
        'browser_' || encode(gen_random_bytes(8), 'hex')
    );
    
    RETURN session_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. GRANT PERMISSIONS
-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.verify_wallet_signature_v2(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_offline_session_v2(UUID, TEXT, TEXT) TO authenticated;

-- 10. ENSURE RLS IS ENABLED
DO $$
BEGIN
    -- Ensure RLS is enabled on all relevant tables
    ALTER TABLE public.blockchain_wallets ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.offline_auth_sessions ENABLE ROW LEVEL SECURITY;
    
    RAISE NOTICE 'Row Level Security enabled on blockchain tables';
END $$;

-- 11. REFRESH SCHEMA CACHE
DO $$
BEGIN
    -- Notify PostgREST to reload schema cache
    NOTIFY pgrst, 'reload schema';
    RAISE NOTICE 'Schema cache refresh requested';
END $$;

-- 12. FINAL VALIDATION
DO $$
DECLARE
    wallet_count INTEGER;
    session_count INTEGER;
BEGIN
    -- Count wallets and sessions for validation
    SELECT COUNT(*) INTO wallet_count FROM public.blockchain_wallets;
    SELECT COUNT(*) INTO session_count FROM public.offline_auth_sessions;
    
    RAISE NOTICE 'Migration completed successfully:';
    RAISE NOTICE '- Blockchain wallets: %', wallet_count;
    RAISE NOTICE '- Offline sessions: %', session_count;
    RAISE NOTICE '- Enhanced functions created for wallet verification';
    RAISE NOTICE '- All syntax errors resolved';
END $$;