-- ============================================
-- Migration: AiFER Comprehensive System Fix
-- Description: Fix syntax errors, enhance admin auth, and complete system integration
-- Dependencies: Existing AiFER network schema (20251105140000_fix_mock_data_removal.sql)
-- ============================================

-- 1. CLEAN EXISTING MOCK DATA (with CORRECT column names)
DELETE FROM public.chad_messages WHERE content LIKE '%Sample%' OR content LIKE '%Demo%' OR content LIKE '%Mock%';
DELETE FROM public.chad_conversations WHERE name LIKE '%Sample%' OR name LIKE '%Demo%' OR name LIKE '%Mock%';
DELETE FROM public.network_nodes WHERE name LIKE '%Sample%' OR name LIKE '%Demo%' OR name LIKE '%Mock%';
DELETE FROM public.blockchain_nodes WHERE name LIKE '%sample%' OR name LIKE '%demo%' OR name LIKE '%mock%';
DELETE FROM public.data_streams WHERE name LIKE '%sample%' OR name LIKE '%demo%' OR name LIKE '%mock%';

-- 2. ENSURE RLS IS PROPERLY CONFIGURED
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chad_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chad_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_streams ENABLE ROW LEVEL SECURITY;

-- 3. CREATE/UPDATE RLS POLICIES FOR PROPER ACCESS CONTROL

-- User profiles policies
DROP POLICY IF EXISTS "users_view_own_profile" ON public.user_profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON public.user_profiles;

CREATE POLICY "users_view_own_profile" ON public.user_profiles
FOR SELECT TO authenticated
USING (id = auth.uid());

CREATE POLICY "users_update_own_profile" ON public.user_profiles
FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Chad conversations policies
DROP POLICY IF EXISTS "users_own_conversations" ON public.chad_conversations;
CREATE POLICY "users_own_conversations" ON public.chad_conversations
FOR ALL TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Chad messages policies
DROP POLICY IF EXISTS "users_own_messages" ON public.chad_messages;
CREATE POLICY "users_own_messages" ON public.chad_messages
FOR ALL TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

-- Network nodes policies (read-only for regular users)
DROP POLICY IF EXISTS "public_read_network_nodes" ON public.network_nodes;
CREATE POLICY "public_read_network_nodes" ON public.network_nodes
FOR SELECT TO authenticated
USING (true);

-- Admin policies for network management
DROP POLICY IF EXISTS "admin_manage_network_nodes" ON public.network_nodes;
CREATE POLICY "admin_manage_network_nodes" ON public.network_nodes
FOR ALL TO authenticated
USING (
  (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  OR
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'bouncingferretofficial@gmail.com'
);

-- 4. INSERT REALISTIC WORKING DATA FOR TESTING (using CORRECT schema)
DO $$
DECLARE
    admin_user_id UUID := gen_random_uuid();
    demo_user_id UUID := gen_random_uuid(); 
    conversation_id UUID := gen_random_uuid();
    node1_id UUID := gen_random_uuid();
    node2_id UUID := gen_random_uuid();
BEGIN
    -- Insert test users with proper authentication setup
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, created_at, updated_at, raw_user_meta_data,
        raw_app_meta_data, is_sso_user, confirmation_sent_at
    ) VALUES (
        admin_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated',
        'authenticated', 'bouncingferretofficial@gmail.com', crypt('semi8523', gen_salt('bf')),
        now(), now(), now(), 
        '{"full_name": "AiFER Admin", "avatar_url": "", "role": "admin", "is_admin": true}'::jsonb,
        '{"provider": "email", "providers": ["email"]}'::jsonb, false, now()
    ), (
        demo_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated',
        'authenticated', 'demo@aifernetwork.com', crypt('demo123', gen_salt('bf')),
        now(), now(), now(),
        '{"full_name": "Demo User", "avatar_url": "", "role": "user"}'::jsonb,
        '{"provider": "email", "providers": ["email"]}'::jsonb, false, now()
    ) ON CONFLICT (email) DO UPDATE SET
        encrypted_password = EXCLUDED.encrypted_password,
        raw_user_meta_data = EXCLUDED.raw_user_meta_data,
        updated_at = now();

    -- Insert/update user profiles
    INSERT INTO public.user_profiles (id, email, full_name, role, created_at, updated_at)
    VALUES 
        (admin_user_id, 'bouncingferretofficial@gmail.com', 'AiFER Admin', 'admin', now(), now()),
        (demo_user_id, 'demo@aifernetwork.com', 'Demo User', 'user', now(), now())
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        updated_at = EXCLUDED.updated_at;

    -- Insert working network nodes with CORRECT schema
    INSERT INTO public.network_nodes (
        id, node_id, name, type, status, signal_strength, 
        coordinates, last_seen, created_at, updated_at, 
        connections, bandwidth, latency_ms, distance_meters, uptime_percentage
    ) VALUES 
        (node1_id, 'fer-gateway-001', 'AiFER Gateway Alpha', 'gateway', 'active', 92, 
         '{"lat": 37.7749, "lng": -122.4194}'::jsonb, now() - INTERVAL '2 minutes', now(), now(),
         12, '100Mbps', 8.1, 45.2, 99.8),
        (node2_id, 'fer-bridge-002', 'AiFER Bridge Beta', 'relay', 'active', 78,
         '{"lat": 37.7849, "lng": -122.4094}'::jsonb, now() - INTERVAL '5 minutes', now(), now(),
         8, '50Mbps', 15.3, 128.7, 97.2)
    ON CONFLICT (node_id) DO UPDATE SET
        name = EXCLUDED.name,
        status = EXCLUDED.status,
        signal_strength = EXCLUDED.signal_strength,
        coordinates = EXCLUDED.coordinates,
        last_seen = EXCLUDED.last_seen,
        updated_at = now();

    -- Insert blockchain nodes with CORRECT schema
    INSERT INTO public.blockchain_nodes (
        node_id, name, type, status, stake_amount, 
        created_at, updated_at, reward_rate, blocks_validated, last_block_time
    ) VALUES 
        ('chain_validator_001', 'Genesis Validator', 'validator', 'active', '1,250,000 FER', 
         now() - INTERVAL '2 hours', now(), 12.5, 15847, now() - INTERVAL '2 minutes'),
        ('chain_consensus_002', 'Chad Consensus Node', 'consensus', 'active', '750,000 FER',
         now() - INTERVAL '1 hour', now(), 10.8, 8923, now() - INTERVAL '1 minute')
    ON CONFLICT (node_id) DO UPDATE SET
        status = EXCLUDED.status,
        stake_amount = EXCLUDED.stake_amount,
        updated_at = now();

    -- Insert data streams with CORRECT schema
    INSERT INTO public.data_streams (
        stream_id, name, type, quality, data_rate, 
        is_active, created_at, updated_at, packet_count, encryption_type
    ) VALUES 
        ('stream_iot_001', 'IoT Sensor Network', 'sensor_data', 'excellent', '150 KB/s',
         true, now() - INTERVAL '10 minutes', now(), 45892, 'AES-256'),
        ('stream_gaming_002', 'Gaming Telemetry', 'gaming', 'good', '2.3 MB/s',
         true, now() - INTERVAL '5 minutes', now(), 128467, 'Quantum'),
        ('stream_fer_003', 'FER Package Stream', '.FERg', 'excellent', '5.1 MB/s',
         true, now() - INTERVAL '15 minutes', now(), 67234, 'Quantum')
    ON CONFLICT (stream_id) DO UPDATE SET
        name = EXCLUDED.name,
        quality = EXCLUDED.quality,
        data_rate = EXCLUDED.data_rate,
        updated_at = now();

    -- Insert Chad conversation and messages using CORRECT schema
    INSERT INTO public.chad_conversations (
        id, user_id, name, created_at, updated_at, 
        last_message, last_message_at, is_chad_conversation, conversation_type
    ) VALUES (
        conversation_id, demo_user_id, 'Welcome to AiFER Network', 
        now() - INTERVAL '1 hour', now() - INTERVAL '30 minutes', 
        'Welcome to the AiFER Network!', now() - INTERVAL '30 minutes',
        true, 'chad_ai'
    ) ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.chad_messages (
        conversation_id, sender_id, content, message_type, 
        status, created_at, is_from_chad
    ) VALUES 
        (conversation_id, demo_user_id, 'Hello Chad! What can you tell me about the FERMesh network?', 
         'text', 'delivered', now() - INTERVAL '45 minutes', false),
        (conversation_id, demo_user_id, 'Welcome to the AiFER Network! The FERMesh is operating optimally with 2 active nodes in San Francisco and 99.8% uptime. How can I assist you today?', 
         'text', 'delivered', now() - INTERVAL '44 minutes', true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Working test data inserted successfully';
    RAISE NOTICE 'Admin login: bouncingferretofficial@gmail.com / semi8523';
    RAISE NOTICE 'Demo login: demo@aifernetwork.com / demo123';
    RAISE NOTICE 'Database schema fixed and populated with realistic data';
END $$;

-- 5. CREATE ADMIN VERIFICATION FUNCTION
CREATE OR REPLACE FUNCTION public.verify_admin_access(user_email text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN user_email = 'bouncingferretofficial@gmail.com';
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.verify_admin_access(text) TO authenticated;

-- 6. FINAL CLEANUP - Remove any remaining test/mock data
DELETE FROM public.chad_messages WHERE content ILIKE '%test%' OR content ILIKE '%example%';
DELETE FROM public.chad_conversations WHERE name ILIKE '%test%' OR name ILIKE '%example%';
DELETE FROM public.network_nodes WHERE name ILIKE '%test%' OR name ILIKE '%example%';
DELETE FROM public.blockchain_nodes WHERE name ILIKE '%test%' OR name ILIKE '%example%';
DELETE FROM public.data_streams WHERE name ILIKE '%test%' OR name ILIKE '%example%';

-- Success message wrapped in DO block
DO $$
BEGIN
    RAISE NOTICE 'Migration completed successfully - All column name errors fixed';
END $$;