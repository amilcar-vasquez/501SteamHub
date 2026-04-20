-- [LEGACY MIGRATION - CONSOLIDATED INTO 003]
-- This migration was consolidated into 003_create_fellows for fresh deployments.
-- It is retained here for backward compatibility with existing systems at version 23+
-- 
-- Original purpose: Add 501_steam_points column to fellows table for FR-27 contribution valuation
-- For fresh deployments: steam_points is created directly in migration 003
-- For existing systems: This migration provides upgrade path from pre-consolidated schemas

-- Idempotent: Only alter if column doesn't already exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='fellows' AND column_name='steam_points'
    ) THEN
        ALTER TABLE fellows
        ADD COLUMN steam_points NUMERIC(10, 2) DEFAULT 0.0;
        
        CREATE INDEX idx_fellows_steam_points ON fellows (steam_points DESC);
    END IF;
END
$$;
