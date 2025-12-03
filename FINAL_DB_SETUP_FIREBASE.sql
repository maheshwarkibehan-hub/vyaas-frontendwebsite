-- ==========================================
-- VYAAS AI FINAL DATABASE SETUP (FIREBASE AUTH COMPATIBLE)
-- ==========================================
-- This script sets up the entire database schema with permissive RLS policies
-- designed for Firebase Auth (where auth.uid() is NULL in Supabase).
--
-- INCLUDES:
-- 1. Core Tables (Users, Sessions, etc.)
-- 2. Feature Tables (Notifications, Chat, Payments)
-- 3. Winter Event Tables (Streaks, Bosses, Market)
-- 4. Functions & Triggers
-- 5. Real-time Setup
-- 6. Permissive RLS Policies (Public Read/Write)
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. TABLES SETUP
-- ==========================================

-- USERS TABLE
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY, -- TEXT to match Firebase UID
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

-- USER SESSIONS
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    session_token TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    invalidated_by TEXT,
    invalidated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- USER NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.user_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info',
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

-- PAYMENT REQUESTS
CREATE TABLE IF NOT EXISTS public.payment_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    user_email TEXT,
    amount DECIMAL(10, 2) NOT NULL,
    plan_type TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    transaction_id TEXT,
    screenshot_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TRANSACTIONS
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
    action_type TEXT,
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
    cost_type TEXT NOT NULL,
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
-- 2. ENABLE RLS
-- ==========================================
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

-- ==========================================
-- 3. PERMISSIVE POLICIES (PUBLIC READ/WRITE)
-- ==========================================
-- Helper macro to create public policies for a table
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'users', 'user_sessions', 'user_notifications', 'chat_history', 
        'payment_requests', 'transactions', 'credit_logs', 'activity_logs',
        'events', 'user_streaks', 'boss_fights', 'market_items', 'user_inventory'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        -- DROP EXISTING POLICIES
        EXECUTE format('DROP POLICY IF EXISTS "Public read %I" ON public.%I', t, t);
        EXECUTE format('DROP POLICY IF EXISTS "Public insert %I" ON public.%I', t, t);
        EXECUTE format('DROP POLICY IF EXISTS "Public update %I" ON public.%I', t, t);
        EXECUTE format('DROP POLICY IF EXISTS "Public delete %I" ON public.%I', t, t);
        
        -- CREATE NEW PERMISSIVE POLICIES
        EXECUTE format('CREATE POLICY "Public read %I" ON public.%I FOR SELECT USING (true)', t, t);
        EXECUTE format('CREATE POLICY "Public insert %I" ON public.%I FOR INSERT WITH CHECK (true)', t, t);
        EXECUTE format('CREATE POLICY "Public update %I" ON public.%I FOR UPDATE USING (true)', t, t);
        EXECUTE format('CREATE POLICY "Public delete %I" ON public.%I FOR DELETE USING (true)', t, t);
    END LOOP;
END $$;

-- ==========================================
-- 4. FUNCTIONS & TRIGGERS
-- ==========================================

-- Handle New User
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

-- Safe Balance Deduction
CREATE OR REPLACE FUNCTION public.deduct_balance(user_id_param TEXT, column_name TEXT, amount INTEGER)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('UPDATE public.users SET %I = %I - $1 WHERE id = $2 AND %I >= $1', column_name, column_name, column_name)
    USING amount, user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment Boss Damage
CREATE OR REPLACE FUNCTION public.increment_boss_damage(user_id_param TEXT, damage_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE public.users 
    SET boss_damage_dealt = boss_damage_dealt + damage_amount 
    WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- 5. INITIAL DATA
-- ==========================================

-- Winter Event
INSERT INTO public.events (name, description, is_active, config)
VALUES (
    'Crazy Winter', 
    'Winter special event with 3D Spin Wheel rewards', 
    TRUE, 
    '{"cooldown_hours": 5, "rewards": ["coupon_40", "coupon_60", "coupon_75", "coupon_80", "coupon_90", "coupon_98", "image_token", "code_token"]}'::JSONB
)
ON CONFLICT DO NOTHING;

-- Boss
INSERT INTO public.boss_fights (name, max_hp, current_hp, status, rewards)
VALUES ('The Abominable Yeti', 5000, 5000, 'active', '["1000 Snowflakes", "50 Winter Tokens"]')
ON CONFLICT DO NOTHING;

-- Market Items
INSERT INTO public.market_items (name, description, cost_amount, cost_type, is_active)
VALUES 
('Frost Avatar Frame', 'A cool icy frame for your profile.', 500, 'snowflakes', TRUE),
('Winter Theme', 'Unlock the exclusive Winter UI theme.', 1000, 'snowflakes', TRUE),
('Code Token Bundle', 'Get 5 Code Tokens.', 200, 'ice_coins', TRUE),
('Image Token Bundle', 'Get 5 Image Tokens.', 200, 'ice_coins', TRUE),
('XP Boost (1h)', 'Double XP for 1 hour.', 50, 'winter_tokens', TRUE)
ON CONFLICT DO NOTHING;

-- ==========================================
-- 6. REALTIME SETUP
-- ==========================================

DO $$ 
BEGIN
    -- Add tables to realtime publication
    -- We use a loop or individual statements to handle potential errors gracefully
    
    -- Users
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
    EXCEPTION WHEN duplicate_object THEN NULL; END;
    
    -- Payment Requests
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.payment_requests;
    EXCEPTION WHEN duplicate_object THEN NULL; END;
    
    -- User Notifications (CRITICAL FOR INBOX)
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.user_notifications;
    EXCEPTION WHEN duplicate_object THEN NULL; END;
    
    -- Boss Fights
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.boss_fights;
    EXCEPTION WHEN duplicate_object THEN NULL; END;
    
END $$;

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Grant usage to anon and authenticated roles (since we are using public policies)
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
