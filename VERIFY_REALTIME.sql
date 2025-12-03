-- VERIFY AND ENABLE REALTIME FOR USER_NOTIFICATIONS
-- Run this to ensure real-time updates work for inbox

-- Check if user_notifications is in realtime publication
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'user_notifications';

-- If not found, add it:
DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_notifications;
EXCEPTION WHEN duplicate_object THEN 
    RAISE NOTICE 'Table already in publication';
END $$;

-- Verify it was added:
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'user_notifications';
