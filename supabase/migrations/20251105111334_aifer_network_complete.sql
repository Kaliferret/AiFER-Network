-- ============================================
-- Migration: AiFER Network Complete System
-- Description: Complete database schema for AiFER Network ecosystem
-- Dependencies: Fresh Supabase project
-- ============================================

-- 1. CREATE ENUMS AND TYPES
CREATE TYPE user_role AS ENUM ('admin', 'user', 'moderator');
CREATE TYPE device_status AS ENUM ('active', 'inactive', 'maintenance');
CREATE TYPE game_status AS ENUM ('active', 'inactive', 'in_progress', 'completed');
CREATE TYPE message_status AS ENUM ('sent', 'delivered', 'read', 'failed');
CREATE TYPE package_type AS ENUM ('.AiF', '.AiFp', '.FERg');

-- 2. USER PROFILES TABLE (Auth Integration)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    role user_role DEFAULT 'user',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. DEVICE SETTINGS TABLE
CREATE TABLE public.device_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_name TEXT NOT NULL,
    mesh_network_enabled BOOLEAN DEFAULT true,
    blockchain_sync_enabled BOOLEAN DEFAULT true,
    emergency_mode_enabled BOOLEAN DEFAULT false,
    auto_discovery_enabled BOOLEAN DEFAULT true,
    battery_saver_mode BOOLEAN DEFAULT false,
    quantum_encryption BOOLEAN DEFAULT true,
    voice_commands BOOLEAN DEFAULT false,
    biometric_auth BOOLEAN DEFAULT true,
    selected_frequency TEXT DEFAULT '2.4GHz',
    transmission_power INTEGER DEFAULT 75 CHECK (transmission_power >= 0 AND transmission_power <= 100),
    max_connections INTEGER DEFAULT 10 CHECK (max_connections >= 5 AND max_connections <= 50),
    node_role TEXT DEFAULT 'mesh_node',
    gaming_mode_enabled BOOLEAN DEFAULT false,
    low_latency_mode BOOLEAN DEFAULT false,
    gaming_priority INTEGER DEFAULT 50 CHECK (gaming_priority >= 0 AND gaming_priority <= 100),
    auto_lock_enabled BOOLEAN DEFAULT true,
    lock_timeout_minutes INTEGER DEFAULT 5,
    remote_wipe_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. NETWORK NODES TABLE
CREATE TABLE public.network_nodes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    node_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    distance_meters DECIMAL(10,2),
    signal_strength INTEGER CHECK (signal_strength >= 0 AND signal_strength <= 100),
    latency_ms DECIMAL(8,2),
    status device_status DEFAULT 'active',
    coordinates JSONB,
    connections INTEGER DEFAULT 0,
    bandwidth TEXT,
    uptime_percentage DECIMAL(5,2),
    last_seen TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. GAMING HUB TABLES
CREATE TABLE public.games (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    image_semantic_label TEXT,
    max_players INTEGER DEFAULT 4,
    min_players INTEGER DEFAULT 1,
    rating DECIMAL(3,2) DEFAULT 0.0,
    status game_status DEFAULT 'active',
    package_type package_type DEFAULT '.FERg',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.game_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    host_user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_name TEXT,
    status game_status DEFAULT 'active',
    max_players INTEGER DEFAULT 4,
    current_players INTEGER DEFAULT 1,
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ,
    session_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.game_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT now(),
    left_at TIMESTAMPTZ,
    score INTEGER DEFAULT 0,
    participant_data JSONB,
    UNIQUE(session_id, user_id)
);

CREATE TABLE public.gaming_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    games_played INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    total_score INTEGER DEFAULT 0,
    best_score INTEGER DEFAULT 0,
    total_playtime_minutes INTEGER DEFAULT 0,
    last_played TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, game_id)
);

-- 6. CHAD MESSAGES SYSTEM
CREATE TABLE public.chad_conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    avatar_semantic_label TEXT,
    last_message TEXT,
    last_message_at TIMESTAMPTZ DEFAULT now(),
    unread_count INTEGER DEFAULT 0,
    conversation_type TEXT DEFAULT 'standard',
    package_type package_type DEFAULT '.AiF',
    is_chad_conversation BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.chad_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID NOT NULL REFERENCES public.chad_conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text',
    package_type package_type DEFAULT '.AiF',
    status message_status DEFAULT 'sent',
    is_from_chad BOOLEAN DEFAULT false,
    chad_response_data JSONB,
    blockchain_hash TEXT,
    destruct_timer INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. FEREXPLORER TABLES
CREATE TABLE public.blockchain_nodes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    node_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    blocks_validated INTEGER DEFAULT 0,
    stake_amount TEXT,
    reward_rate DECIMAL(5,2),
    status device_status DEFAULT 'active',
    last_block_time TIMESTAMPTZ,
    node_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.data_streams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    stream_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    data_rate TEXT,
    packet_count INTEGER DEFAULT 0,
    quality TEXT DEFAULT 'good',
    encryption_type TEXT,
    stream_data JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.exploration_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_name TEXT,
    exploration_radius INTEGER DEFAULT 500,
    discovered_nodes INTEGER DEFAULT 0,
    real_time_mode BOOLEAN DEFAULT true,
    session_data JSONB,
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_device_settings_user_id ON public.device_settings(user_id);
CREATE INDEX idx_network_nodes_status ON public.network_nodes(status);
CREATE INDEX idx_network_nodes_type ON public.network_nodes(type);
CREATE INDEX idx_games_status ON public.games(status);
CREATE INDEX idx_game_sessions_status ON public.game_sessions(status);
CREATE INDEX idx_game_participants_user_id ON public.game_participants(user_id);
CREATE INDEX idx_gaming_stats_user_id ON public.gaming_stats(user_id);
CREATE INDEX idx_chad_conversations_user_id ON public.chad_conversations(user_id);
CREATE INDEX idx_chad_messages_conversation_id ON public.chad_messages(conversation_id);
CREATE INDEX idx_chad_messages_created_at ON public.chad_messages(created_at DESC);
CREATE INDEX idx_blockchain_nodes_status ON public.blockchain_nodes(status);
CREATE INDEX idx_data_streams_active ON public.data_streams(is_active);
CREATE INDEX idx_exploration_sessions_user_id ON public.exploration_sessions(user_id);

-- 9. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gaming_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chad_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chad_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exploration_sessions ENABLE ROW LEVEL SECURITY;

-- 10. TRIGGER FUNCTION FOR USER PROFILES
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, avatar_url, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'user')::user_role
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. CREATE TRIGGER FOR AUTO USER PROFILE CREATION
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 12. RLS POLICIES FOR USER PROFILES
CREATE POLICY "users_view_own_profile" 
ON public.user_profiles 
FOR SELECT 
TO authenticated 
USING (id = auth.uid());

CREATE POLICY "users_update_own_profile" 
ON public.user_profiles 
FOR UPDATE 
TO authenticated 
USING (id = auth.uid()) 
WITH CHECK (id = auth.uid());

-- 13. RLS POLICIES FOR DEVICE SETTINGS
CREATE POLICY "users_manage_own_device_settings" 
ON public.device_settings 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 14. RLS POLICIES FOR NETWORK NODES (PUBLIC READ)
CREATE POLICY "public_read_network_nodes" 
ON public.network_nodes 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "authenticated_manage_network_nodes" 
ON public.network_nodes 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 15. RLS POLICIES FOR GAMES (PUBLIC READ)
CREATE POLICY "public_read_games" 
ON public.games 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "authenticated_manage_games" 
ON public.games 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 16. RLS POLICIES FOR GAME SESSIONS
CREATE POLICY "users_view_game_sessions" 
ON public.game_sessions 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "users_create_game_sessions" 
ON public.game_sessions 
FOR INSERT 
TO authenticated 
WITH CHECK (host_user_id = auth.uid());

CREATE POLICY "hosts_manage_own_game_sessions" 
ON public.game_sessions 
FOR ALL 
TO authenticated 
USING (host_user_id = auth.uid()) 
WITH CHECK (host_user_id = auth.uid());

-- 17. RLS POLICIES FOR GAME PARTICIPANTS
CREATE POLICY "users_view_game_participants" 
ON public.game_participants 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "users_manage_own_participation" 
ON public.game_participants 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 18. RLS POLICIES FOR GAMING STATS
CREATE POLICY "users_view_own_gaming_stats" 
ON public.gaming_stats 
FOR SELECT 
TO authenticated 
USING (user_id = auth.uid());

CREATE POLICY "users_manage_own_gaming_stats" 
ON public.gaming_stats 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 19. RLS POLICIES FOR CHAD CONVERSATIONS
CREATE POLICY "users_manage_own_chad_conversations" 
ON public.chad_conversations 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 20. RLS POLICIES FOR CHAD MESSAGES
CREATE POLICY "users_view_chad_messages_in_own_conversations" 
ON public.chad_messages 
FOR SELECT 
TO authenticated 
USING (conversation_id IN (SELECT id FROM public.chad_conversations WHERE user_id = auth.uid()));

CREATE POLICY "users_insert_chad_messages_in_own_conversations" 
ON public.chad_messages 
FOR INSERT 
TO authenticated 
WITH CHECK (conversation_id IN (SELECT id FROM public.chad_conversations WHERE user_id = auth.uid()));

CREATE POLICY "users_update_own_chad_messages" 
ON public.chad_messages 
FOR UPDATE 
TO authenticated 
USING (sender_id = auth.uid()) 
WITH CHECK (sender_id = auth.uid());

-- 21. RLS POLICIES FOR BLOCKCHAIN NODES (PUBLIC READ)
CREATE POLICY "public_read_blockchain_nodes" 
ON public.blockchain_nodes 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "authenticated_manage_blockchain_nodes" 
ON public.blockchain_nodes 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 22. RLS POLICIES FOR DATA STREAMS (PUBLIC READ)
CREATE POLICY "public_read_data_streams" 
ON public.data_streams 
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "authenticated_manage_data_streams" 
ON public.data_streams 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 23. RLS POLICIES FOR EXPLORATION SESSIONS
CREATE POLICY "users_manage_own_exploration_sessions" 
ON public.exploration_sessions 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- 24. INSERT MOCK DATA FOR TESTING
DO $$
DECLARE
    demo_user_id UUID := gen_random_uuid();
    admin_user_id UUID := gen_random_uuid();
    chad_conv_id UUID := gen_random_uuid();
    fergame_id UUID := gen_random_uuid();
BEGIN
    -- Insert demo auth users with profile data
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, created_at, updated_at, raw_user_meta_data,
        raw_app_meta_data, is_sso_user, is_anonymous
    ) VALUES (
        admin_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated',
        'authenticated', 'admin@aifer.network', crypt('admin123', gen_salt('bf')),
        now(), now(), now(), 
        '{"full_name": "AiFER Admin", "avatar_url": "https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg", "role": "admin"}'::jsonb,
        '{"provider": "email"}'::jsonb, false, false
    ), (
        demo_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated',
        'authenticated', 'demo@fernetwork.nl', crypt('demo123', gen_salt('bf')),
        now(), now(), now(),
        '{"full_name": "FER Demo User", "avatar_url": "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg", "role": "user"}'::jsonb,
        '{"provider": "email"}'::jsonb, false, false
    );

    -- Insert sample network nodes
    INSERT INTO public.network_nodes (node_id, name, type, distance_meters, signal_strength, latency_ms, status, coordinates, connections, bandwidth, uptime_percentage) VALUES
    ('node_001', 'Gateway Alpha', 'gateway', 45.2, 92, 8.1, 'active', '{"lat": 52.3676, "lng": 4.9041}'::jsonb, 12, '100Mbps', 99.8),
    ('node_002', 'Mesh Relay Beta', 'relay', 128.7, 78, 15.3, 'active', '{"lat": 52.3702, "lng": 4.8952}'::jsonb, 8, '50Mbps', 97.2),
    ('node_003', 'Edge Node Gamma', 'edge', 234.1, 65, 28.7, 'active', '{"lat": 52.3588, "lng": 4.9130}'::jsonb, 4, '25Mbps', 95.6),
    ('node_004', 'Quantum Hub Delta', 'quantum', 89.3, 88, 4.2, 'active', '{"lat": 52.3731, "lng": 4.8907}'::jsonb, 15, '1Gbps', 99.9),
    ('node_005', 'Backup Node Epsilon', 'backup', 187.6, 43, 45.8, 'maintenance', '{"lat": 52.3542, "lng": 4.9203}'::jsonb, 2, '10Mbps', 89.3);

    -- Insert sample games
    INSERT INTO public.games (id, name, type, description, image_url, image_semantic_label, max_players, rating, package_type) VALUES
    (fergame_id, 'FERChain Battles', 'strategy', 'Real-time strategy game powered by FERChain', 'https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg', 'Futuristic strategy game interface with blockchain elements', 4, 4.8, '.FERg'),
    (gen_random_uuid(), 'Mesh Network Racing', 'racing', 'High-speed racing through mesh network nodes', 'https://images.pexels.com/photos/1637437/pexels-photo-1637437.jpeg', 'High-speed racing cars on futuristic neon-lit track', 6, 4.6, '.FERg'),
    (gen_random_uuid(), 'Quantum Puzzles', 'puzzle', 'Mind-bending puzzles using quantum mechanics', 'https://images.pexels.com/photos/1181677/pexels-photo-1181677.jpeg', 'Abstract quantum-inspired puzzle with geometric patterns', 2, 4.9, '.FERg'),
    (gen_random_uuid(), 'Chad Combat Arena', 'action', 'AI-powered combat simulation arena', 'https://images.pexels.com/photos/1202723/pexels-photo-1202723.jpeg', 'Futuristic combat arena with AI-powered robots', 8, 4.7, '.FERg');

    -- Insert blockchain nodes
    INSERT INTO public.blockchain_nodes (node_id, name, type, blocks_validated, stake_amount, reward_rate, status, last_block_time) VALUES
    ('chain_001', 'Genesis Validator', 'validator', 15847, '1,250,000 FER', 12.5, 'active', now() - interval '2 minutes'),
    ('chain_002', 'Chad Consensus Node', 'consensus', 8923, '750,000 FER', 10.8, 'active', now() - interval '45 seconds'),
    ('chain_003', 'Smart Contract Hub', 'contract', 6741, '500,000 FER', 9.2, 'active', now() - interval '5 minutes');

    -- Insert data streams
    INSERT INTO public.data_streams (stream_id, name, type, data_rate, packet_count, quality, encryption_type, is_active) VALUES
    ('stream_001', 'IoT Sensor Network', 'sensor_data', '150 KB/s', 45892, 'excellent', 'AES-256', true),
    ('stream_002', 'Gaming Telemetry', 'gaming', '2.3 MB/s', 128467, 'good', 'Quantum', true),
    ('stream_003', 'Media Streaming', 'media', '15.7 MB/s', 892156, 'excellent', 'ChaCha20', true);

    RAISE NOTICE 'AiFER Network demo data created successfully';
    RAISE NOTICE 'Demo credentials: admin@aifer.network/admin123, demo@fernetwork.nl/demo123';
    RAISE NOTICE 'Chad assistant conversations available';
END $$;