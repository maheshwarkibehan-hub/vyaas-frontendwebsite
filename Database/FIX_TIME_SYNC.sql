-- Fix for Time Sync Issue in Force Logout
-- This ensures the invalidation time is set by the server, avoiding client clock skew issues.

ALTER TABLE user_sessions ALTER COLUMN invalidated_at SET DEFAULT NOW();
