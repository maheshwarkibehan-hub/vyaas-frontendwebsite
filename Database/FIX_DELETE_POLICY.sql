-- FIX FOR LOGOUT LOOP
-- Add missing DELETE policy for user_sessions table

DROP POLICY IF EXISTS "Allow public delete to user_sessions" ON user_sessions;
CREATE POLICY "Allow public delete to user_sessions"
ON user_sessions FOR DELETE
USING (true);
