-- WINTER EVENTS EXPANSION DB SETUP (UPDATED FOR FIREBASE AUTH)
-- Run this script in your Supabase SQL Editor to add the necessary tables and columns for the Winter Events.

-- 1. Add New Columns to Users Table (Idempotent)
DO $$
BEGIN
    -- Currency & Stats
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='snowflakes') THEN
        ALTER TABLE public.users ADD COLUMN snowflakes INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='ice_coins') THEN
        ALTER TABLE public.users ADD COLUMN ice_coins INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='winter_tokens') THEN
        ALTER TABLE public.users ADD COLUMN winter_tokens INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='xp_multiplier') THEN
        ALTER TABLE public.users ADD COLUMN xp_multiplier DECIMAL(3, 2) DEFAULT 1.0;
    END IF;
    
    -- Event Tracking
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='last_dice_roll') THEN
        ALTER TABLE public.users ADD COLUMN last_dice_roll TIMESTAMP WITH TIME ZONE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='boss_damage_dealt') THEN
        ALTER TABLE public.users ADD COLUMN boss_damage_dealt INTEGER DEFAULT 0;
    END IF;
END $$;

-- 2. Create User Streaks Table (Using TEXT for user_id to match Firebase UID)
CREATE TABLE IF NOT EXISTS public.user_streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    last_login_date TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;

-- 3. Create Boss Fights Table
CREATE TABLE IF NOT EXISTS public.boss_fights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    max_hp INTEGER NOT NULL,
    current_hp INTEGER NOT NULL,
    status TEXT DEFAULT 'active', -- active, defeated
    rewards JSONB DEFAULT '[]'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.boss_fights ENABLE ROW LEVEL SECURITY;

-- Insert Initial Boss (The Yeti)
INSERT INTO public.boss_fights (name, max_hp, current_hp, status, rewards)
VALUES ('The Abominable Yeti', 5000, 5000, 'active', '["1000 Snowflakes", "50 Winter Tokens"]')
ON CONFLICT DO NOTHING;

-- 4. Create Market Items Table
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
ALTER TABLE public.market_items ENABLE ROW LEVEL SECURITY;

-- Insert Initial Market Items
INSERT INTO public.market_items (name, description, cost_amount, cost_type, is_active)
VALUES 
('Frost Avatar Frame', 'A cool icy frame for your profile.', 500, 'snowflakes', TRUE),
('Winter Theme', 'Unlock the exclusive Winter UI theme.', 1000, 'snowflakes', TRUE),
('Code Token Bundle', 'Get 5 Code Tokens.', 200, 'ice_coins', TRUE),
('Image Token Bundle', 'Get 5 Image Tokens.', 200, 'ice_coins', TRUE),
('XP Boost (1h)', 'Double XP for 1 hour.', 50, 'winter_tokens', TRUE);

-- 5. Create User Inventory Table (Using TEXT for user_id)
CREATE TABLE IF NOT EXISTS public.user_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
    item_id UUID REFERENCES public.market_items(id),
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;

-- 6. RPC Functions for Safe Updates (Using TEXT for user_id)
CREATE OR REPLACE FUNCTION public.deduct_balance(user_id_param TEXT, column_name TEXT, amount INTEGER)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('UPDATE public.users SET %I = %I - $1 WHERE id = $2 AND %I >= $1', column_name, column_name, column_name)
    USING amount, user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.increment_boss_damage(user_id_param TEXT, damage_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE public.users 
    SET boss_damage_dealt = boss_damage_dealt + damage_amount 
    WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. RLS POLICIES (ADJUSTED FOR FIREBASE AUTH)
-- Since we are using Firebase Auth, Supabase auth.uid() is NULL.
-- We must allow public access for now, OR rely on client-side security (not ideal but necessary without custom JWT).
-- Ideally, you should set up a custom JWT bridge, but for this setup:

-- Allow public read/write for demo purposes (WARNING: NOT SECURE FOR PRODUCTION)
-- A better approach without JWT is to use a Service Role on the backend, but we are client-side here.

-- Users
DROP POLICY IF EXISTS "Public read users" ON public.users;
CREATE POLICY "Public read users" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public update users" ON public.users;
CREATE POLICY "Public update users" ON public.users FOR UPDATE USING (true);

-- Streaks
DROP POLICY IF EXISTS "Public read streaks" ON public.user_streaks;
CREATE POLICY "Public read streaks" ON public.user_streaks FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public update streaks" ON public.user_streaks;
CREATE POLICY "Public update streaks" ON public.user_streaks FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public insert streaks" ON public.user_streaks;
CREATE POLICY "Public insert streaks" ON public.user_streaks FOR INSERT WITH CHECK (true);

-- Boss Fights
DROP POLICY IF EXISTS "Public read boss" ON public.boss_fights;
CREATE POLICY "Public read boss" ON public.boss_fights FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public update boss" ON public.boss_fights;
CREATE POLICY "Public update boss" ON public.boss_fights FOR UPDATE USING (true);

-- Market & Inventory
DROP POLICY IF EXISTS "Public read market" ON public.market_items;
CREATE POLICY "Public read market" ON public.market_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read inventory" ON public.user_inventory;
CREATE POLICY "Public read inventory" ON public.user_inventory FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert inventory" ON public.user_inventory;
CREATE POLICY "Public insert inventory" ON public.user_inventory FOR INSERT WITH CHECK (true);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.boss_fights;
