-- ============================================
-- VYAAS AI - Premium Features Database Schema (COMPLETE & UPDATED)
-- ============================================

-- 1. User Notifications Table (Existing System - Credit updates etc)
CREATE TABLE IF NOT EXISTS user_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- 'credit_deduction', 'credit_addition', 'reward', 'warning', 'info'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON user_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON user_notifications(is_read);

-- 1.5. Broadcast Notifications Table (NEW - For Admin Broadcast & User Inbox)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_broadcast_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_broadcast_notifications_created_at ON notifications(created_at DESC);

-- 2. Daily Rewards Table
CREATE TABLE IF NOT EXISTS daily_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reward_type TEXT NOT NULL, -- 'credits' or 'coupon'
    reward_value INTEGER NOT NULL, -- credit amount or discount %
    coupon_code TEXT UNIQUE,
    claimed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    streak_day INTEGER DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_daily_rewards_user_id ON daily_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_rewards_claimed_at ON daily_rewards(claimed_at DESC);

-- 3. Coupons Table
CREATE TABLE IF NOT EXISTS coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    discount_percent INTEGER NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    used_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_user_id ON coupons(user_id);

-- 4. Activity Logs Table
CREATE TABLE IF NOT EXISTS activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type TEXT NOT NULL, -- 'login', 'credit_use', 'reward_claim', 'session_start', 'session_end', 'coupon_use', 'history_delete', 'force_logout'
    details JSONB,
    credits_used INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON activity_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action_type ON activity_logs(action_type);

-- 5. User Sessions Table (for force logout)
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token TEXT UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    invalidated_by TEXT, -- admin user id who forced logout
    invalidated_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_is_active ON user_sessions(is_active);

-- 6. Update Users Table
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_reward_claim TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reward_streak INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_rewards_claimed INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_credits_used INTEGER DEFAULT 0;

-- 7. Update Credit Logs Table
ALTER TABLE credit_logs ADD COLUMN IF NOT EXISTS admin_id TEXT;
ALTER TABLE credit_logs ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE credit_logs ADD COLUMN IF NOT EXISTS action_type TEXT DEFAULT 'manual'; -- 'manual', 'reward', 'purchase', 'deduction', 'session_use'

-- ============================================
-- Row Level Security Policies
-- ============================================

-- Notifications policies (Existing system)
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to notifications" ON user_notifications;
CREATE POLICY "Allow public insert to notifications"
ON user_notifications FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to notifications" ON user_notifications;
CREATE POLICY "Allow public read to notifications"
ON user_notifications FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public update to notifications" ON user_notifications;
CREATE POLICY "Allow public update to notifications"
ON user_notifications FOR UPDATE
USING (true);

-- Broadcast Notifications Policies (NEW)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read notifications" ON notifications;
CREATE POLICY "Allow public read notifications" ON notifications
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public update notifications" ON notifications;
CREATE POLICY "Allow public update notifications" ON notifications
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public delete notifications" ON notifications;
CREATE POLICY "Allow public delete notifications" ON notifications
  FOR DELETE USING (true);

-- Daily rewards policies
ALTER TABLE daily_rewards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to daily_rewards" ON daily_rewards;
CREATE POLICY "Allow public insert to daily_rewards"
ON daily_rewards FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to daily_rewards" ON daily_rewards;
CREATE POLICY "Allow public read to daily_rewards"
ON daily_rewards FOR SELECT
USING (true);

-- Coupons policies
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to coupons" ON coupons;
CREATE POLICY "Allow public insert to coupons"
ON coupons FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to coupons" ON coupons;
CREATE POLICY "Allow public read to coupons"
ON coupons FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public update to coupons" ON coupons;
CREATE POLICY "Allow public update to coupons"
ON coupons FOR UPDATE
USING (true);

-- Activity logs policies
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to activity_logs" ON activity_logs;
CREATE POLICY "Allow public insert to activity_logs"
ON activity_logs FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to activity_logs" ON activity_logs;
CREATE POLICY "Allow public read to activity_logs"
ON activity_logs FOR SELECT
USING (true);

-- Sessions policies
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to user_sessions" ON user_sessions;
CREATE POLICY "Allow public insert to user_sessions"
ON user_sessions FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to user_sessions" ON user_sessions;
CREATE POLICY "Allow public read to user_sessions"
ON user_sessions FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public update to user_sessions" ON user_sessions;
CREATE POLICY "Allow public update to user_sessions"
ON user_sessions FOR UPDATE
USING (true);

DROP POLICY IF EXISTS "Allow public delete to user_sessions" ON user_sessions;
CREATE POLICY "Allow public delete to user_sessions"
ON user_sessions FOR DELETE
USING (true);
