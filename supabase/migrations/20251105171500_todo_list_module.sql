-- ============================================
-- Migration: Todo List Module
-- Description: Creates comprehensive todo management system with categories and tasks
-- Dependencies: user_profiles (existing table)
-- ============================================

-- 1. CREATE ENUM TYPES
CREATE TYPE public.todo_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE public.todo_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- 2. CREATE CATEGORIES TABLE
CREATE TABLE public.todo_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (length(name) > 0 AND length(name) <= 100),
    description TEXT CHECK (length(description) <= 500),
    color_hex TEXT DEFAULT '#6366f1' CHECK (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
    icon_name TEXT DEFAULT 'folder',
    is_system_category BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    UNIQUE(user_id, name)
);

-- 3. CREATE TODOS TABLE
CREATE TABLE public.todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.todo_categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL CHECK (length(title) > 0 AND length(title) <= 200),
    description TEXT CHECK (length(description) <= 1000),
    priority public.todo_priority NOT NULL DEFAULT 'medium',
    status public.todo_status NOT NULL DEFAULT 'pending',
    is_completed BOOLEAN NOT NULL DEFAULT false,
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    tags TEXT[] DEFAULT '{}',
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    CHECK (
        (is_completed = true AND status = 'completed' AND completed_at IS NOT NULL) OR
        (is_completed = false AND status != 'completed' AND completed_at IS NULL)
    )
);

-- 4. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX idx_todo_categories_user_id ON public.todo_categories(user_id);
CREATE INDEX idx_todo_categories_user_sort ON public.todo_categories(user_id, sort_order);
CREATE INDEX idx_todo_categories_system ON public.todo_categories(is_system_category) WHERE is_system_category = true;

CREATE INDEX idx_todos_user_id ON public.todos(user_id);
CREATE INDEX idx_todos_category_id ON public.todos(category_id);
CREATE INDEX idx_todos_user_status ON public.todos(user_id, status);
CREATE INDEX idx_todos_user_priority ON public.todos(user_id, priority);
CREATE INDEX idx_todos_user_completed ON public.todos(user_id, is_completed);
CREATE INDEX idx_todos_due_date ON public.todos(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX idx_todos_user_sort ON public.todos(user_id, sort_order);

-- 5. CREATE FUNCTIONS
CREATE OR REPLACE FUNCTION public.update_todo_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        NEW.is_completed = true;
        NEW.completed_at = now();
    ELSIF NEW.status != 'completed' AND OLD.status = 'completed' THEN
        NEW.is_completed = false;
        NEW.completed_at = null;
    END IF;
    
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.update_category_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.todo_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- 7. CREATE RLS POLICIES

-- Todo Categories Policies
CREATE POLICY "users_own_categories" 
ON public.todo_categories 
FOR ALL 
TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- Todos Policies  
CREATE POLICY "users_own_todos"
ON public.todos
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. CREATE TRIGGERS
CREATE TRIGGER trigger_update_todo_completion
    BEFORE UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_todo_completion();

CREATE TRIGGER trigger_update_category_timestamp
    BEFORE UPDATE ON public.todo_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.update_category_updated_at();

-- 9. INSERT MOCK DATA
DO $$
DECLARE
    existing_user_id UUID;
    work_category_id UUID := gen_random_uuid();
    personal_category_id UUID := gen_random_uuid();
    health_category_id UUID := gen_random_uuid();
    completion_time TIMESTAMPTZ := now() - interval '2 hours';
BEGIN
    -- Get existing user from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Insert default categories
        INSERT INTO public.todo_categories (id, user_id, name, description, color_hex, icon_name, is_system_category, sort_order) VALUES
            (work_category_id, existing_user_id, 'Work', 'Professional tasks and projects', '#3b82f6', 'briefcase', true, 1),
            (personal_category_id, existing_user_id, 'Personal', 'Personal life and activities', '#10b981', 'user', true, 2),
            (health_category_id, existing_user_id, 'Health & Fitness', 'Health goals and fitness activities', '#ef4444', 'heart', true, 3);
        
        -- Insert non-completed todos first
        INSERT INTO public.todos (user_id, category_id, title, description, priority, status, due_date, tags, sort_order) VALUES
            (existing_user_id, work_category_id, 'Complete project proposal', 'Finish the Q4 project proposal for client presentation', 'high', 'in_progress', now() + interval '3 days', ARRAY['urgent', 'client'], 1),
            (existing_user_id, work_category_id, 'Review team code', 'Code review for the new feature implementation', 'medium', 'pending', now() + interval '1 day', ARRAY['development', 'review'], 2),
            (existing_user_id, personal_category_id, 'Buy groceries', 'Weekly grocery shopping for the family', 'medium', 'pending', now() + interval '2 days', ARRAY['shopping', 'family'], 1),
            (existing_user_id, personal_category_id, 'Plan vacation', 'Research and book summer vacation destination', 'low', 'pending', now() + interval '1 month', ARRAY['travel', 'family'], 2),
            (existing_user_id, health_category_id, 'Schedule dental checkup', 'Book appointment for bi-annual dental cleaning', 'medium', 'pending', now() + interval '1 week', ARRAY['health', 'appointment'], 2);
        
        -- Insert completed todos with proper completion data
        INSERT INTO public.todos (user_id, category_id, title, description, priority, status, is_completed, completed_at, due_date, tags, sort_order) VALUES
            (existing_user_id, work_category_id, 'Prepare weekly report', 'Compile weekly progress report for management', 'low', 'completed', true, completion_time, now() - interval '1 day', ARRAY['reporting'], 3),
            (existing_user_id, health_category_id, 'Morning workout', 'Complete 30-minute cardio session', 'high', 'completed', true, completion_time, now(), ARRAY['exercise', 'cardio'], 1);
        
        RAISE NOTICE 'Todo system created successfully with % categories and % todos', 
            (SELECT COUNT(*) FROM public.todo_categories WHERE user_id = existing_user_id),
            (SELECT COUNT(*) FROM public.todos WHERE user_id = existing_user_id);
    ELSE
        RAISE NOTICE 'No users found - run auth migration first';
    END IF;
END $$;