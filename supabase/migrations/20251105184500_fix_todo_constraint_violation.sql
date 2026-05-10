-- ============================================
-- Migration: Fix Todo List Constraint Violation
-- Description: Corrects the check constraint violation in todos table mock data
-- Dependencies: user_profiles (existing table), todo_categories, todos (existing)
-- ============================================

-- 1. FIX EXISTING CONSTRAINT VIOLATION
-- First, fix any existing todos that violate the constraint
UPDATE public.todos 
SET is_completed = true, completed_at = now() - interval '2 hours'
WHERE status = 'completed' AND (is_completed = false OR completed_at IS NULL);

-- 2. INSERT ADDITIONAL MOCK DATA WITH PROPER CONSTRAINT COMPLIANCE
DO $$
DECLARE
    existing_user_id UUID;
    work_category_id UUID;
    personal_category_id UUID;
    health_category_id UUID;
    completion_time TIMESTAMPTZ := now() - interval '1 hour';
BEGIN
    -- Get existing user and categories
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO work_category_id FROM public.todo_categories WHERE name = 'Work' LIMIT 1;
    SELECT id INTO personal_category_id FROM public.todo_categories WHERE name = 'Personal' LIMIT 1;
    SELECT id INTO health_category_id FROM public.todo_categories WHERE name = 'Health & Fitness' LIMIT 1;
    
    IF existing_user_id IS NOT NULL AND work_category_id IS NOT NULL THEN
        -- Insert non-completed todos first
        INSERT INTO public.todos (user_id, category_id, title, description, priority, status, due_date, tags, sort_order, is_completed, completed_at) VALUES
            (existing_user_id, work_category_id, 'Update project documentation', 'Review and update all project documentation for clarity', 'medium', 'pending', now() + interval '5 days', ARRAY['documentation', 'review'], 4, false, null),
            (existing_user_id, work_category_id, 'Setup CI/CD pipeline', 'Configure automated testing and deployment', 'high', 'in_progress', now() + interval '2 days', ARRAY['devops', 'automation'], 5, false, null),
            (existing_user_id, personal_category_id, 'Read monthly book', 'Finish reading the productivity book', 'low', 'in_progress', now() + interval '2 weeks', ARRAY['reading', 'personal'], 3, false, null),
            (existing_user_id, health_category_id, 'Track water intake', 'Maintain daily water consumption tracking', 'medium', 'pending', now() + interval '1 day', ARRAY['health', 'hydration'], 3, false, null);
        
        -- Insert completed todos with proper constraint values
        INSERT INTO public.todos (user_id, category_id, title, description, priority, status, due_date, tags, sort_order, is_completed, completed_at) VALUES
            (existing_user_id, work_category_id, 'Daily standup meeting', 'Attended team daily standup', 'low', 'completed', now() - interval '4 hours', ARRAY['meeting', 'daily'], 6, true, completion_time),
            (existing_user_id, personal_category_id, 'Pay utility bills', 'Monthly electricity and water bill payment', 'high', 'completed', now() - interval '2 days', ARRAY['bills', 'finance'], 4, true, completion_time),
            (existing_user_id, health_category_id, 'Evening walk', '30-minute neighborhood walk', 'medium', 'completed', now() - interval '1 day', ARRAY['exercise', 'walking'], 4, true, completion_time);
        
        RAISE NOTICE 'Additional todo items created successfully with proper constraint compliance';
        RAISE NOTICE 'Total todos: %', (SELECT COUNT(*) FROM public.todos WHERE user_id = existing_user_id);
    ELSE
        RAISE NOTICE 'Unable to create additional todos - missing user or categories';
    END IF;
END $$;

-- 3. VERIFY CONSTRAINT COMPLIANCE
DO $$
DECLARE
    violation_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO violation_count 
    FROM public.todos 
    WHERE (status = 'completed' AND (is_completed = false OR completed_at IS NULL)) 
       OR (status != 'completed' AND (is_completed = true OR completed_at IS NOT NULL));
    
    IF violation_count > 0 THEN
        RAISE EXCEPTION 'Constraint violations still exist: % rows', violation_count;
    ELSE
        RAISE NOTICE 'All todos now comply with completion constraints';
    END IF;
END $$;