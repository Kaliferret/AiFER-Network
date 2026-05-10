-- Migration to fix compilation errors and update blockchain wallet functionality
-- File: 20251105160000_fix_compilation_errors_update.sql

-- Update blockchain wallets table to ensure compatibility
ALTER TABLE public.blockchain_wallets 
ADD COLUMN IF NOT EXISTS account_name text DEFAULT '';

-- Update existing wallets to have account_name from wallet_name
UPDATE public.blockchain_wallets 
SET account_name = wallet_name 
WHERE account_name = '' OR account_name IS NULL;

-- Create index for account_name if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_blockchain_wallets_account_name 
ON public.blockchain_wallets(account_name);

-- Ensure offline_auth_sessions table has proper constraints
ALTER TABLE public.offline_auth_sessions 
ADD CONSTRAINT IF NOT EXISTS check_session_token_length 
CHECK (char_length(session_token) >= 32);

-- Add updated_at trigger for blockchain_wallets if not exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_blockchain_wallets_updated_at ON public.blockchain_wallets;
CREATE TRIGGER update_blockchain_wallets_updated_at
    BEFORE UPDATE ON public.blockchain_wallets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Ensure RLS policies are properly set for new functionality
DROP POLICY IF EXISTS "users_can_manage_their_offline_sessions" ON public.offline_auth_sessions;
CREATE POLICY "users_can_manage_their_offline_sessions" 
ON public.offline_auth_sessions
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Create function for wallet signature verification if not exists
CREATE OR REPLACE FUNCTION verify_wallet_signature_v2(
    wallet_addr text,
    message_text text,
    signature_text text
) RETURNS boolean AS $$
DECLARE
    wallet_public_key text;
    is_valid boolean := false;
BEGIN
    -- Get wallet public key
    SELECT public_key INTO wallet_public_key
    FROM public.blockchain_wallets
    WHERE wallet_address = wallet_addr AND is_verified = true;
    
    IF wallet_public_key IS NULL THEN
        RETURN false;
    END IF;
    
    -- Simplified signature verification for demo
    -- In production, use proper cryptographic verification
    IF length(signature_text) > 32 AND wallet_public_key IS NOT NULL THEN
        is_valid := true;
    END IF;
    
    RETURN is_valid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function for creating offline sessions
CREATE OR REPLACE FUNCTION create_offline_session_v2(
    user_uuid uuid,
    wallet_addr text,
    signature_text text
) RETURNS text AS $$
DECLARE
    session_token text;
    wallet_uuid uuid;
    expires_timestamp timestamp with time zone;
BEGIN
    -- Generate session token
    session_token := encode(gen_random_bytes(32), 'base64');
    expires_timestamp := NOW() + INTERVAL '30 days';
    
    -- Get wallet ID
    SELECT id INTO wallet_uuid
    FROM public.blockchain_wallets
    WHERE wallet_address = wallet_addr AND user_id = user_uuid;
    
    IF wallet_uuid IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user';
    END IF;
    
    -- Insert offline session
    INSERT INTO public.offline_auth_sessions (
        user_id,
        wallet_id,
        session_token,
        challenge_signature,
        expires_at,
        is_active
    ) VALUES (
        user_uuid,
        wallet_uuid,
        session_token,
        signature_text,
        expires_timestamp,
        true
    );
    
    RETURN session_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION verify_wallet_signature_v2(text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION create_offline_session_v2(uuid, text, text) TO authenticated;

-- Update sample data to include account_name if missing
UPDATE public.blockchain_wallets 
SET account_name = COALESCE(account_name, wallet_name, 'AiFER User')
WHERE account_name = '' OR account_name IS NULL;

-- Refresh RLS policies
ALTER TABLE public.blockchain_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_auth_sessions ENABLE ROW LEVEL SECURITY;

NOTIFY pgrst, 'reload schema';