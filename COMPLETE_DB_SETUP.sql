-- ==========================================
-- VYAAS AI COMPLETE DATABASE SETUP
-- ==========================================
-- This script sets up the entire database schema, including:
-- 1. Core User Tables & Profiles
-- 2. Payment & Subscription Systems
-- 3. Notifications & Chat History
-- 4. Admin Logs & Analytics
-- 5. Winter Event System (Bosses, Market, Inventory)
-- 6. Real-time Configurations
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. CORE TABLES
-- ==========================================

-- USERS TABLE (Using TEXT for id to match Firebase Auth)
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    
    -- Subscription & Credits
    credits INTEGER DEFAULT 0,
    plan_type TEXT DEFAULT 'free',
    
    -- Status
    is_blocked BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Tokens (Standard)
    image_tokens INTEGER DEFAULT 0,
    code_tokens INTEGER DEFAULT 0,
    last_spin_time TIMESTAMP WITH TIME ZONE,
    
    -- Winter Event Stats
    snowflakes INTEGER DEFAULT 0,
    ice_coins INTEGER DEFAULT 0,
    winter_tokens INTEGER DEFAULT 0,
    xp_multiplier DECIMAL(3, 2) DEFAULT 1.0,
    last_dice_roll TIMESTAMP WITH TIME ZONE,
    boss_damage_dealt INTEGER DEFAULT 0,
    
    -- Engagement Stats
    call_count INTEGER DEFAULT 0,
    reward_streak INTEGER DEFAULT 0,
    total_rewards_claimed INTEGER DEFAULT 0,
    total_credits_used INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER SESSIONS (For Force Logout)
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    session_token TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    invalidated_by TEXT, -- Admin ID
    invalidated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 2. COMMUNICATION & HISTORY
-- ==========================================

-- USER NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.user_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info', -- info, success, warning, error, credit_deduction, credit_addition
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CHAT HISTORY
CREATE TABLE IF NOT EXISTS public.chat_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT,
    messages JSONB DEFAULT '[]'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 3. PAYMENTS & LOGS
-- ==========================================

-- PAYMENT REQUESTS
CREATE TABLE IF NOT EXISTS public.payment_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    user_email TEXT,
    amount DECIMAL(10, 2) NOT NULL,
    plan_type TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, approved, rejected
    transaction_id TEXT,
    screenshot_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TRANSACTIONS (Analytics)
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR',
    plan_type TEXT,
    status TEXT DEFAULT 'completed',
    payment_method TEXT,
    transaction_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CREDIT LOGS
CREATE TABLE IF NOT EXISTS public.credit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    reason TEXT,
    admin_id TEXT,
    action_type TEXT, -- deduction, manual, reward
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ACTIVITY LOGS
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    action_type TEXT NOT NULL,
    details JSONB DEFAULT '{}'::JSONB,
    credits_used INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 4. WINTER EVENT SYSTEM
-- ==========================================

-- EVENTS CONFIG
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    config JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER STREAKS
CREATE TABLE IF NOT EXISTS public.user_streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    last_login_date TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- BOSS FIGHTS
CREATE TABLE IF NOT EXISTS public.boss_fights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    max_hp INTEGER NOT NULL,
    current_hp INTEGER NOT NULL,
    status TEXT DEFAULT 'active',
    rewards JSONB DEFAULT '[]'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MARKET ITEMS
CREATE TABLE IF NOT EXISTS public.market_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    cost_amount INTEGER NOT NULL,
    cost_type TEXT NOT NULL, -- snowflakes, ice_coins, winter_tokens
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER INVENTORY
CREATE TABLE IF NOT EXISTS public.user_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    item_id UUID REFERENCES public.market_items(id),
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.boss_fights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;

-- USERS POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
    CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid()::text = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
    CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid()::text = id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- NOTIFICATIONS POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own notifications" ON public.user_notifications;
    CREATE POLICY "Users can view own notifications" ON public.user_notifications FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can update read status" ON public.user_notifications;
    CREATE POLICY "Users can update read status" ON public.user_notifications FOR UPDATE USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can delete own notifications" ON public.user_notifications;
    CREATE POLICY "Users can delete own notifications" ON public.user_notifications FOR DELETE USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CHAT HISTORY POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own chat history" ON public.chat_history;
    CREATE POLICY "Users can view own chat history" ON public.chat_history FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can insert chat history" ON public.chat_history;
    CREATE POLICY "Users can insert chat history" ON public.chat_history FOR INSERT WITH CHECK (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can update chat history" ON public.chat_history;
    CREATE POLICY "Users can update chat history" ON public.chat_history FOR UPDATE USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can delete chat history" ON public.chat_history;
    CREATE POLICY "Users can delete chat history" ON public.chat_history FOR DELETE USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- PAYMENT & LOGS POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own requests" ON public.payment_requests;
    CREATE POLICY "Users can view own requests" ON public.payment_requests FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can create requests" ON public.payment_requests;
    CREATE POLICY "Users can create requests" ON public.payment_requests FOR INSERT WITH CHECK (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own transactions" ON public.transactions;
    CREATE POLICY "Users can view own transactions" ON public.transactions FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own credit logs" ON public.credit_logs;
    CREATE POLICY "Users can view own credit logs" ON public.credit_logs FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own activity" ON public.activity_logs;
    CREATE POLICY "Users can view own activity" ON public.activity_logs FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- WINTER EVENT POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS "Anyone can view events" ON public.events;
    CREATE POLICY "Anyone can view events" ON public.events FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own streaks" ON public.user_streaks;
    CREATE POLICY "Users can view own streaks" ON public.user_streaks FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can update own streaks" ON public.user_streaks;
    CREATE POLICY "Users can update own streaks" ON public.user_streaks FOR UPDATE USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can insert own streaks" ON public.user_streaks;
    CREATE POLICY "Users can insert own streaks" ON public.user_streaks FOR INSERT WITH CHECK (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Anyone can view boss fights" ON public.boss_fights;
    CREATE POLICY "Anyone can view boss fights" ON public.boss_fights FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Authenticated users can update boss" ON public.boss_fights;
    CREATE POLICY "Authenticated users can update boss" ON public.boss_fights FOR UPDATE USING (auth.role() = 'authenticated');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Anyone can view market items" ON public.market_items;
    CREATE POLICY "Anyone can view market items" ON public.market_items FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can view own inventory" ON public.user_inventory;
    CREATE POLICY "Users can view own inventory" ON public.user_inventory FOR SELECT USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    DROP POLICY IF EXISTS "Users can insert own inventory" ON public.user_inventory;
    CREATE POLICY "Users can insert own inventory" ON public.user_inventory FOR INSERT WITH CHECK (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================
-- 6. FUNCTIONS & TRIGGERS
-- ==========================================

-- Handle New User Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, avatar_url)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Safe Balance Deduction RPC
CREATE OR REPLACE FUNCTION public.deduct_balance(user_id_param TEXT, column_name TEXT, amount INTEGER)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('UPDATE public.users SET %I = %I - $1 WHERE id = $2 AND %I >= $1', column_name, column_name, column_name)
    USING amount, user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment Boss Damage RPC
CREATE OR REPLACE FUNCTION public.increment_boss_damage(user_id_param TEXT, damage_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE public.users 
    SET boss_damage_dealt = boss_damage_dealt + damage_amount 
    WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- 7. INITIAL DATA & CONFIG
-- ==========================================

-- Insert Crazy Winter Event
INSERT INTO public.events (name, description, is_active, config)
VALUES (
    'Crazy Winter', 
    'Winter special event with 3D Spin Wheel rewards', 
    TRUE, 
    '{"cooldown_hours": 5, "rewards": ["coupon_40", "coupon_60", "coupon_75", "coupon_80", "coupon_90", "coupon_98", "image_token", "code_token"]}'::JSONB
)
ON CONFLICT DO NOTHING;

-- Insert Initial Boss
INSERT INTO public.boss_fights (name, max_hp, current_hp, status, rewards)
VALUES ('The Abominable Yeti', 5000, 5000, 'active', '["1000 Snowflakes", "50 Winter Tokens"]')
ON CONFLICT DO NOTHING;

-- Insert Market Items
INSERT INTO public.market_items (name, description, cost_amount, cost_type, is_active)
VALUES 
('Frost Avatar Frame', 'A cool icy frame for your profile.', 500, 'snowflakes', TRUE),
('Winter Theme', 'Unlock the exclusive Winter UI theme.', 1000, 'snowflakes', TRUE),
('Code Token Bundle', 'Get 5 Code Tokens.', 200, 'ice_coins', TRUE),
('Image Token Bundle', 'Get 5 Image Tokens.', 200, 'ice_coins', TRUE),
('XP Boost (1h)', 'Double XP for 1 hour.', 50, 'winter_tokens', TRUE)
ON CONFLICT DO NOTHING;

-- ==========================================
-- 8. REALTIME SETUP
-- ==========================================

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.payment_requests;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_notifications;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.boss_fights;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
