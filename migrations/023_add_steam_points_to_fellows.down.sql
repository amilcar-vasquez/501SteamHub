-- [LEGACY MIGRATION - CONSOLIDATED INTO 003]
-- This down migration is idempotent and safe for systems that have already migrated.
-- For fresh deployments: No rollback needed (steam_points is part of 003)
-- For existing systems: This provides rollback compatibility

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='fellows' AND column_name='steam_points'
    ) THEN
        DROP INDEX IF EXISTS idx_fellows_steam_points;
        ALTER TABLE fellows DROP COLUMN steam_points;
    END IF;
END
$$;
