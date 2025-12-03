-- ============================================
-- VYAAS AI - Analytics & Transactions Schema
-- ============================================

-- 1. Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR',
    plan_type TEXT NOT NULL, -- 'basic', 'pro', 'enterprise', 'credit_pack'
    status TEXT NOT NULL DEFAULT 'completed', -- 'completed', 'pending', 'failed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    payment_method TEXT, -- 'stripe', 'razorpay', 'manual'
    transaction_id TEXT -- External payment ID
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);

-- 2. RLS Policies for Transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public insert to transactions" ON transactions;
CREATE POLICY "Allow public insert to transactions"
ON transactions FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read to transactions" ON transactions;
CREATE POLICY "Allow public read to transactions"
ON transactions FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public update to transactions" ON transactions;
CREATE POLICY "Allow public update to transactions"
ON transactions FOR UPDATE
USING (true);
