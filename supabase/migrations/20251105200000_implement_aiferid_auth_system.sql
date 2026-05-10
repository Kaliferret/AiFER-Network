-- ============================================
-- Migration: AiFERiD Authentication System
-- Description: Remove Google OAuth dependency and implement wallet-based authentication using AiFERiD
-- Dependencies: Extends existing blockchain_wallets and user_profiles tables
-- ============================================

-- 1. ADD AIFERID COLUMN TO BLOCKCHAIN_WALLETS (wallet address becomes AiFERiD)
ALTER TABLE public.blockchain_wallets 
ADD COLUMN IF NOT EXISTS aiferid TEXT GENERATED ALWAYS AS (
    CASE 
        WHEN wallet_type = 'FER' THEN wallet_address
        ELSE 'AiFER' || SUBSTRING(wallet_address, 1, 8) || '...' || SUBSTRING(wallet_address, -8)
    END
) STORED;

-- 2. CREATE UNIQUE INDEX ON AIFERID
CREATE UNIQUE INDEX IF NOT EXISTS idx_blockchain_wallets_aiferid ON public.blockchain_wallets(aiferid);

-- 3. ADD AIFERID AUTHENTICATION FIELDS TO USER_PROFILES  
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS primary_aiferid TEXT,
ADD COLUMN IF NOT EXISTS aiferid_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS last_aiferid_login TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS authentication_method TEXT DEFAULT 'aiferid',
ADD COLUMN IF NOT EXISTS google_oauth_removed BOOLEAN DEFAULT true;

-- 4. CREATE AIFERID AUTHENTICATION FUNCTION
CREATE OR REPLACE FUNCTION public.authenticate_with_aiferid(
    input_aiferid TEXT,
    signature_proof TEXT
) RETURNS TABLE(
    user_id UUID,
    success BOOLEAN,
    message TEXT,
    wallet_data JSONB
) 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    wallet_record RECORD;
    user_record RECORD;
    session_token TEXT;
BEGIN
    -- Find wallet by AiFERiD
    SELECT bw.*, up.id as profile_id, up.email, up.full_name
    INTO wallet_record
    FROM public.blockchain_wallets bw
    LEFT JOIN public.user_profiles up ON bw.user_id = up.id
    WHERE bw.aiferid = input_aiferid AND bw.is_verified = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID, 
            false, 
            'AiFERiD not found or not verified'::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Verify signature (simplified for demo - implement proper crypto verification in production)
    IF LENGTH(signature_proof) < 10 THEN
        RETURN QUERY SELECT 
            NULL::UUID, 
            false, 
            'Invalid signature proof'::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Update last login time
    UPDATE public.user_profiles 
    SET last_aiferid_login = now(),
        primary_aiferid = input_aiferid,
        aiferid_verified = true
    WHERE id = wallet_record.user_id;
    
    -- Return success with wallet data
    RETURN QUERY SELECT 
        wallet_record.user_id,
        true,
        'Authentication successful'::TEXT,
        jsonb_build_object(
            'aiferid', input_aiferid,
            'wallet_address', wallet_record.wallet_address,
            'wallet_type', wallet_record.wallet_type,
            'account_name', wallet_record.account_name,
            'user_email', wallet_record.email,
            'full_name', wallet_record.full_name,
            'verified', true
        );
END;
$$;

-- 5. CREATE AIFERID GENERATION FUNCTION (for new users)
CREATE OR REPLACE FUNCTION public.generate_aiferid_account(
    account_name TEXT,
    user_email TEXT,
    full_name TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    aiferid TEXT,
    wallet_address TEXT,
    user_id UUID,
    message TEXT
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    new_user_id UUID;
    new_wallet_id UUID;
    generated_address TEXT;
    generated_aiferid TEXT;
BEGIN
    -- Generate new user ID
    new_user_id := gen_random_uuid();
    
    -- Generate FER wallet address (AiFERiD format)
    generated_address := 'FER' || encode(gen_random_bytes(16), 'hex');
    generated_aiferid := generated_address; -- For FER wallets, AiFERiD = wallet_address
    
    -- Create user profile
    INSERT INTO public.user_profiles (
        id, email, full_name, authentication_method, 
        primary_aiferid, aiferid_verified, created_at
    ) VALUES (
        new_user_id, user_email, COALESCE(full_name, account_name), 
        'aiferid', generated_aiferid, false, now()
    );
    
    -- Create blockchain wallet
    INSERT INTO public.blockchain_wallets (
        id, user_id, wallet_address, wallet_name, account_name,
        wallet_type, public_key, encrypted_private_key, 
        recovery_phrase_hash, is_verified, created_at
    ) VALUES (
        gen_random_uuid(), new_user_id, generated_address, account_name, account_name,
        'FER', encode(gen_random_bytes(32), 'hex'), encode(gen_random_bytes(64), 'hex'),
        encode(sha256(gen_random_bytes(32)), 'hex'), true, now()
    ) RETURNING id INTO new_wallet_id;
    
    -- Update user profile with preferred wallet
    UPDATE public.user_profiles 
    SET preferred_wallet_id = new_wallet_id,
        wallet_enabled = true,
        aiferid_verified = true
    WHERE id = new_user_id;
    
    RETURN QUERY SELECT 
        true,
        generated_aiferid,
        generated_address, 
        new_user_id,
        'AiFERiD account created successfully'::TEXT;
        
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 
        false,
        ''::TEXT,
        ''::TEXT,
        NULL::UUID,
        ('Account creation failed: ' || SQLERRM)::TEXT;
END;
$$;

-- 6. CREATE AIFERID LOOKUP FUNCTION
CREATE OR REPLACE FUNCTION public.lookup_aiferid(search_term TEXT)
RETURNS TABLE(
    aiferid TEXT,
    account_name TEXT,
    wallet_type TEXT,
    is_verified BOOLEAN,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bw.aiferid,
        bw.account_name,
        bw.wallet_type,
        bw.is_verified,
        bw.created_at
    FROM public.blockchain_wallets bw
    WHERE bw.aiferid ILIKE '%' || search_term || '%'
       OR bw.account_name ILIKE '%' || search_term || '%'
       OR bw.wallet_address ILIKE '%' || search_term || '%'
    ORDER BY bw.is_verified DESC, bw.created_at DESC
    LIMIT 10;
END;
$$;

-- 7. CREATE AIFERID VERIFICATION FUNCTION 
CREATE OR REPLACE FUNCTION public.verify_aiferid_ownership(
    input_aiferid TEXT,
    challenge_message TEXT,
    signature TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    wallet_public_key TEXT;
BEGIN
    -- Get wallet public key
    SELECT public_key INTO wallet_public_key
    FROM public.blockchain_wallets
    WHERE aiferid = input_aiferid;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Verify signature (simplified - implement proper cryptographic verification)
    -- In production, use proper signature verification libraries
    IF LENGTH(signature) >= 64 AND LENGTH(challenge_message) > 0 THEN
        -- Update verification status
        UPDATE public.blockchain_wallets 
        SET is_verified = true, last_verification_at = now()
        WHERE aiferid = input_aiferid;
        
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$;

-- 8. UPDATE EXISTING WALLETS TO HAVE AIFERID VERIFIED STATUS
UPDATE public.blockchain_wallets 
SET is_verified = true 
WHERE wallet_type = 'FER' AND is_verified = false;

-- 9. UPDATE USER PROFILES TO USE AIFERID AUTHENTICATION
UPDATE public.user_profiles up
SET authentication_method = 'aiferid',
    primary_aiferid = bw.aiferid,
    aiferid_verified = true,
    google_oauth_removed = true
FROM public.blockchain_wallets bw 
WHERE up.id = bw.user_id AND bw.is_primary = true;

-- 10. REMOVE GOOGLE OAUTH DEPENDENCIES (Update RLS policies)
DROP POLICY IF EXISTS "google_oauth_users" ON public.user_profiles;
DROP POLICY IF EXISTS "oauth_provider_access" ON public.blockchain_wallets;

-- 11. CREATE AIFERID-BASED RLS POLICIES
CREATE POLICY "aiferid_authenticated_users" ON public.user_profiles
FOR ALL TO authenticated 
USING (
    id = auth.uid() OR 
    (authentication_method = 'aiferid' AND aiferid_verified = true)
)
WITH CHECK (
    id = auth.uid() OR 
    (authentication_method = 'aiferid' AND aiferid_verified = true)
);

CREATE POLICY "aiferid_wallet_access" ON public.blockchain_wallets  
FOR ALL TO authenticated
USING (
    user_id = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.user_profiles up 
        WHERE up.id = user_id 
        AND up.authentication_method = 'aiferid' 
        AND up.aiferid_verified = true
    )
)
WITH CHECK (
    user_id = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.user_profiles up 
        WHERE up.id = user_id 
        AND up.authentication_method = 'aiferid' 
        AND up.aiferid_verified = true
    )
);

-- 12. INSERT DEMO AIFERID ACCOUNTS
DO $$
DECLARE
    demo_user_id UUID;
    admin_user_id UUID;
    demo_wallet_id UUID;
    admin_wallet_id UUID;
BEGIN
    -- Create Demo AiFERiD User
    SELECT id INTO demo_user_id FROM public.user_profiles WHERE email = 'demo@fernetwork.nl';
    
    IF demo_user_id IS NOT NULL THEN
        -- Update existing demo user for AiFERiD
        UPDATE public.user_profiles 
        SET authentication_method = 'aiferid',
            primary_aiferid = 'FER0xDemo987654321FeDcBa9876543210FeDcBa',
            aiferid_verified = true,
            google_oauth_removed = true
        WHERE id = demo_user_id;
        
        -- Update existing wallet to have proper AiFERiD
        UPDATE public.blockchain_wallets
        SET account_name = 'Demo AiFERiD Wallet',
            wallet_name = 'Demo AiFERiD Wallet', 
            is_verified = true
        WHERE user_id = demo_user_id;
        
        RAISE NOTICE 'Updated Demo User - AiFERiD: FER0xDemo987654321FeDcBa9876543210FeDcBa';
    END IF;
    
    -- Create Admin AiFERiD User  
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@aifer.network';
    
    IF admin_user_id IS NOT NULL THEN
        -- Update existing admin user for AiFERiD
        UPDATE public.user_profiles 
        SET authentication_method = 'aiferid',
            primary_aiferid = 'FER0xAdmin123456789AbCdEf0123456789AbCdEf',
            aiferid_verified = true,
            google_oauth_removed = true
        WHERE id = admin_user_id;
        
        -- Update existing wallet to have proper AiFERiD
        UPDATE public.blockchain_wallets
        SET account_name = 'Admin AiFERiD Wallet',
            wallet_name = 'Admin AiFERiD Wallet',
            is_verified = true
        WHERE user_id = admin_user_id;
        
        RAISE NOTICE 'Updated Admin User - AiFERiD: FER0xAdmin123456789AbCdEf0123456789AbCdEf';
    END IF;
    
    RAISE NOTICE '=== AiFERiD AUTHENTICATION SYSTEM READY ===';
    RAISE NOTICE 'Demo AiFERiD: FER0xDemo987654321FeDcBa9876543210FeDcBa';  
    RAISE NOTICE 'Admin AiFERiD: FER0xAdmin123456789AbCdEf0123456789AbCdEf';
    RAISE NOTICE 'Google OAuth has been disabled - use AiFERiD wallet addresses for authentication';
END $$;