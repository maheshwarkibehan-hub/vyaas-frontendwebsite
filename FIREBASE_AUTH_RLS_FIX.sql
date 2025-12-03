-- COMPREHENSIVE RLS FIX FOR FIREBASE AUTH
-- Since we're using Firebase Auth (not Supabase Auth), auth.uid() returns NULL
-- We need to make policies more permissive while still maintaining some security

-- ==========================================
-- 1. USERS TABLE - Allow public read/write
-- ==========================================
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can read users" ON public.users;
    CREATE POLICY "Public can read users" 
    ON public.users 
    FOR SELECT 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can update users" ON public.users;
    CREATE POLICY "Public can update users" 
    ON public.users 
    FOR UPDATE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can insert users" ON public.users;
    CREATE POLICY "Public can insert users" 
    ON public.users 
    FOR INSERT 
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================
-- 2. PAYMENT REQUESTS - Allow public access
-- ==========================================
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can read payment requests" ON public.payment_requests;
    CREATE POLICY "Public can read payment requests" 
    ON public.payment_requests 
    FOR SELECT 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can create payment requests" ON public.payment_requests;
    CREATE POLICY "Public can create payment requests" 
    ON public.payment_requests 
    FOR INSERT 
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can update payment requests" ON public.payment_requests;
    CREATE POLICY "Public can update payment requests" 
    ON public.payment_requests 
    FOR UPDATE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================
-- 3. NOTIFICATIONS - Allow public access
-- ==========================================
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can read notifications" ON public.user_notifications;
    CREATE POLICY "Public can read notifications" 
    ON public.user_notifications 
    FOR SELECT 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can insert notifications" ON public.user_notifications;
    CREATE POLICY "Public can insert notifications" 
    ON public.user_notifications 
    FOR INSERT 
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can update notifications" ON public.user_notifications;
    CREATE POLICY "Public can update notifications" 
    ON public.user_notifications 
    FOR UPDATE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can delete notifications" ON public.user_notifications;
    CREATE POLICY "Public can delete notifications" 
    ON public.user_notifications 
    FOR DELETE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================
-- 4. CHAT HISTORY - Allow public access
-- ==========================================
DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can read chat history" ON public.chat_history;
    CREATE POLICY "Public can read chat history" 
    ON public.chat_history 
    FOR SELECT 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can insert chat history" ON public.chat_history;
    CREATE POLICY "Public can insert chat history" 
    ON public.chat_history 
    FOR INSERT 
    WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can update chat history" ON public.chat_history;
    CREATE POLICY "Public can update chat history" 
    ON public.chat_history 
    FOR UPDATE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Public can delete chat history" ON public.chat_history;
    CREATE POLICY "Public can delete chat history" 
    ON public.chat_history 
    FOR DELETE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================
-- NOTES:
-- ==========================================
-- WARNING: These policies allow public access to all data!
-- This is necessary because we're using Firebase Auth instead of Supabase Auth.
-- 
-- Security is now handled at the APPLICATION LEVEL:
-- - Firebase Auth validates users
-- - Client-side code filters data by user_id
-- - Admin functions check email === 'maheshwarkibehan@gmail.com'
--
-- For production, you should either:
-- 1. Use Supabase Auth instead of Firebase Auth, OR
-- 2. Set up a custom JWT bridge between Firebase and Supabase
