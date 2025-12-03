-- Fix RLS Policy for Block Status Check
-- This allows users to check if they are blocked without full profile access

-- Add a new policy that allows users to check their own block status
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can check own block status" ON public.users;
    CREATE POLICY "Users can check own block status" 
    ON public.users 
    FOR SELECT 
    USING (auth.uid()::text = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Alternative: If the above doesn't work, we can make is_blocked publicly readable
-- Uncomment this if needed:
-- ALTER TABLE public.users ALTER COLUMN is_blocked SET DEFAULT false;
