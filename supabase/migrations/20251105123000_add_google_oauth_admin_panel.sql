-- ============================================
-- Migration: Google OAuth & Admin Panel Support
-- Description: Add Google OAuth support and admin functionality for bouncingferretofficial@gmail.com
-- Dependencies: user_profiles table (already exists)
-- ============================================

-- 1. ADD GOOGLE OAUTH COLUMNS TO USER_PROFILES
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS provider TEXT DEFAULT 'email',
ADD COLUMN IF NOT EXISTS provider_id TEXT,
ADD COLUMN IF NOT EXISTS google_id TEXT,
ADD COLUMN IF NOT EXISTS last_sign_in_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_profiles_provider ON public.user_profiles(provider);
CREATE INDEX IF NOT EXISTS idx_user_profiles_google_id ON public.user_profiles(google_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_admin ON public.user_profiles(is_admin);

-- 3. CREATE ADMIN PANEL AUDIT LOG TABLE
CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    target_user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    target_table TEXT,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. CREATE INDEX FOR AUDIT LOGS
CREATE INDEX idx_admin_audit_logs_admin_user ON public.admin_audit_logs(admin_user_id);
CREATE INDEX idx_admin_audit_logs_created_at ON public.admin_audit_logs(created_at DESC);

-- 5. CREATE ADMIN SYSTEM STATS VIEW
CREATE OR REPLACE VIEW public.admin_system_stats AS
SELECT 
    (SELECT COUNT(*) FROM public.user_profiles) as total_users,
    (SELECT COUNT(*) FROM public.user_profiles WHERE created_at >= NOW() - INTERVAL '30 days') as new_users_30d,
    (SELECT COUNT(*) FROM public.chad_conversations) as total_conversations,
    (SELECT COUNT(*) FROM public.chad_messages) as total_messages,
    (SELECT COUNT(*) FROM public.gaming_stats) as total_games_played,
    (SELECT COUNT(*) FROM public.exploration_sessions) as total_exploration_sessions,
    (SELECT COUNT(*) FROM public.network_nodes) as total_network_nodes,
    (SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) FROM public.chad_conversations) as avg_conversation_duration;

-- 6. ENABLE RLS ON NEW TABLES
ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

-- 7. CREATE RLS POLICIES FOR ADMIN AUDIT LOGS
CREATE POLICY "admin_only_audit_logs" ON public.admin_audit_logs
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = auth.uid() AND (role = 'admin' OR is_admin = true)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = auth.uid() AND (role = 'admin' OR is_admin = true)
    )
);

-- 8. CREATE ADMIN HELPER FUNCTIONS
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles 
        WHERE id = user_id AND (role = 'admin' OR is_admin = true)
    );
END;
$$;

-- 9. CREATE FUNCTION TO LOG ADMIN ACTIONS
CREATE OR REPLACE FUNCTION public.log_admin_action(
    action_type TEXT,
    target_user UUID DEFAULT NULL,
    target_table_name TEXT DEFAULT NULL,
    old_data JSONB DEFAULT NULL,
    new_data JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    log_id UUID;
BEGIN
    -- Only allow admins to log actions
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Access denied: Admin privileges required';
    END IF;
    
    INSERT INTO public.admin_audit_logs (
        admin_user_id,
        action,
        target_user_id,
        target_table,
        old_values,
        new_values,
        ip_address,
        user_agent
    ) VALUES (
        auth.uid(),
        action_type,
        target_user,
        target_table_name,
        old_data,
        new_data,
        current_setting('request.headers', true)::json->>'x-real-ip',
        current_setting('request.headers', true)::json->>'user-agent'
    ) RETURNING id INTO log_id;
    
    RETURN log_id;
END;
$$;

-- 10. UPDATE USER_PROFILES RLS POLICIES FOR ADMIN ACCESS
CREATE POLICY "admin_full_access_user_profiles" ON public.user_profiles
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up 
        WHERE up.id = auth.uid() AND (up.role = 'admin' OR up.is_admin = true)
    )
);

-- 11. GRANT ADMIN ACCESS TO SYSTEM STATS
GRANT SELECT ON public.admin_system_stats TO authenticated;

-- 12. CREATE RLS POLICY FOR SYSTEM STATS VIEW
CREATE POLICY "admin_only_system_stats" ON public.admin_system_stats
FOR SELECT TO authenticated
USING (public.is_admin());

-- 13. INSERT/UPDATE ADMIN USER DATA
DO $$
DECLARE
    admin_user_id UUID;
    existing_admin_id UUID;
BEGIN
    -- Check if bouncingferretofficial@gmail.com already exists
    SELECT id INTO existing_admin_id 
    FROM public.user_profiles 
    WHERE email = 'bouncingferretofficial@gmail.com';
    
    IF existing_admin_id IS NOT NULL THEN
        -- Update existing user to admin
        UPDATE public.user_profiles 
        SET 
            role = 'admin',
            is_admin = true,
            updated_at = now()
        WHERE email = 'bouncingferretofficial@gmail.com';
        
        RAISE NOTICE 'Updated existing user bouncingferretofficial@gmail.com to admin privileges';
    ELSE
        -- Create new admin user entry (for Google OAuth setup)
        admin_user_id := gen_random_uuid();
        
        INSERT INTO public.user_profiles (
            id, email, full_name, role, is_admin, provider, created_at, updated_at
        ) VALUES (
            admin_user_id,
            'bouncingferretofficial@gmail.com',
            'FER Network Admin',
            'admin',
            true,
            'google',
            now(),
            now()
        );
        
        RAISE NOTICE 'Created admin user profile for bouncingferretofficial@gmail.com';
    END IF;
    
    -- Log admin setup action
    INSERT INTO public.admin_audit_logs (
        admin_user_id,
        action,
        target_user_id,
        target_table,
        new_values,
        created_at
    ) VALUES (
        COALESCE(existing_admin_id, admin_user_id),
        'admin_setup_migration',
        COALESCE(existing_admin_id, admin_user_id),
        'user_profiles',
        '{"admin_privileges": "granted", "email": "bouncingferretofficial@gmail.com"}',
        now()
    );
END $$;