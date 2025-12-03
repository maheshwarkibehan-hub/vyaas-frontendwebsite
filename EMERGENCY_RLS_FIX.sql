-- EMERGENCY FIX: RLS Policies for Payment Requests and Admin Access
-- Run this in Supabase SQL Editor to fix the issues

-- 1. Fix Payment Requests - Allow users to create their own requests
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can create requests" ON public.payment_requests;
    CREATE POLICY "Users can create requests" 
    ON public.payment_requests 
    FOR INSERT 
    WITH CHECK (true); -- Allow anyone to insert (we validate user_id in the app)
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Fix Admin Access - Allow service role to view all users
DO $$ BEGIN
    DROP POLICY IF EXISTS "Service role can view all users" ON public.users;
    CREATE POLICY "Service role can view all users" 
    ON public.users 
    FOR SELECT 
    USING (true); -- This allows the service role key to see all users
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 3. Fix Admin Access - Allow service role to view all payment requests
DO $$ BEGIN
    DROP POLICY IF EXISTS "Service role can view all requests" ON public.payment_requests;
    CREATE POLICY "Service role can view all requests" 
    ON public.payment_requests 
    FOR SELECT 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 4. Fix Admin Access - Allow service role to update payment requests
DO $$ BEGIN
    DROP POLICY IF EXISTS "Service role can update requests" ON public.payment_requests;
    CREATE POLICY "Service role can update requests" 
    ON public.payment_requests 
    FOR UPDATE 
    USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
