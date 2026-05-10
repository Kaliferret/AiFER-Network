-- ============================================
-- Migration: Rename Chad to FERChat
-- Description: Updates database schema from Chad to FERChat branding
-- Dependencies: Existing chad_conversations and chad_messages tables
-- ============================================

-- 1. RENAME TABLES (Child first to avoid FK constraint issues)
ALTER TABLE public.chad_messages RENAME TO ferchat_messages;
ALTER TABLE public.chad_conversations RENAME TO ferchat_conversations;

-- 2. RENAME INDEXES
ALTER INDEX public.idx_chad_conversations_user_id RENAME TO idx_ferchat_conversations_user_id;
ALTER INDEX public.chad_conversations_pkey RENAME TO ferchat_conversations_pkey;
ALTER INDEX public.idx_chad_messages_conversation_id RENAME TO idx_ferchat_messages_conversation_id;
ALTER INDEX public.chad_messages_pkey RENAME TO ferchat_messages_pkey;
ALTER INDEX public.idx_chad_messages_created_at RENAME TO idx_ferchat_messages_created_at;

-- 3. RENAME COLUMNS (Update specific Chad-related column names)
ALTER TABLE public.ferchat_conversations RENAME COLUMN is_chad_conversation TO is_ferchat_conversation;
ALTER TABLE public.ferchat_messages RENAME COLUMN is_from_chad TO is_from_ferchat;
ALTER TABLE public.ferchat_messages RENAME COLUMN chad_response_data TO ferchat_response_data;

-- 4. UPDATE FOREIGN KEY CONSTRAINT NAMES
ALTER TABLE public.ferchat_messages RENAME CONSTRAINT chad_messages_conversation_id_fkey TO ferchat_messages_conversation_id_fkey;
ALTER TABLE public.ferchat_messages RENAME CONSTRAINT chad_messages_sender_id_fkey TO ferchat_messages_sender_id_fkey;
ALTER TABLE public.ferchat_conversations RENAME CONSTRAINT chad_conversations_user_id_fkey TO ferchat_conversations_user_id_fkey;

-- 5. DROP OLD RLS POLICIES
DROP POLICY IF EXISTS "users_manage_own_chad_conversations" ON public.ferchat_conversations;
DROP POLICY IF EXISTS "users_view_chad_messages_in_own_conversations" ON public.ferchat_messages;
DROP POLICY IF EXISTS "users_insert_chad_messages_in_own_conversations" ON public.ferchat_messages;
DROP POLICY IF EXISTS "users_update_own_chad_messages" ON public.ferchat_messages;

-- 6. CREATE NEW RLS POLICIES WITH FERCHAT NAMES
CREATE POLICY "users_manage_own_ferchat_conversations" ON public.ferchat_conversations
FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_ferchat_messages_in_own_conversations" ON public.ferchat_messages
FOR SELECT TO authenticated
USING (conversation_id IN (
    SELECT id FROM public.ferchat_conversations WHERE user_id = auth.uid()
));

CREATE POLICY "users_insert_ferchat_messages_in_own_conversations" ON public.ferchat_messages
FOR INSERT TO authenticated
WITH CHECK (conversation_id IN (
    SELECT id FROM public.ferchat_conversations WHERE user_id = auth.uid()
));

CREATE POLICY "users_update_own_ferchat_messages" ON public.ferchat_messages
FOR UPDATE TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

-- 7. UPDATE EXISTING DATA (Change Chad references to FERChat)
UPDATE public.ferchat_messages 
SET content = REPLACE(content, 'Chad', 'FERChat')
WHERE content LIKE '%Chad%';

UPDATE public.ferchat_conversations 
SET name = REPLACE(name, 'Chad', 'FERChat')
WHERE name LIKE '%Chad%';

UPDATE public.ferchat_conversations 
SET last_message = REPLACE(last_message, 'Chad', 'FERChat')
WHERE last_message LIKE '%Chad%';

-- 8. SUCCESS NOTIFICATION
DO $$
BEGIN
    RAISE NOTICE 'Successfully renamed Chad tables to FERChat';
    RAISE NOTICE 'Updated table names: chad_conversations → ferchat_conversations';
    RAISE NOTICE 'Updated table names: chad_messages → ferchat_messages';
    RAISE NOTICE 'Updated column names and RLS policies';
    RAISE NOTICE 'Updated existing data references from Chad to FERChat';
END $$;