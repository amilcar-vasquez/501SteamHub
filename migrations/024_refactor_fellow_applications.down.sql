-- [LEGACY MIGRATION - CONSOLIDATED INTO 019 AND 003]
-- This down migration is idempotent and safe for systems that have already migrated.
-- For fresh deployments: No rollback needed (changes are part of table creation)
-- For existing systems: This provides rollback compatibility

DO $$
BEGIN
    -- Reverse the consolidation only if already applied
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='fellow_applications' AND column_name='full_name'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='fellow_applications' AND column_name='first_name'
    ) THEN
        -- Drop indexes added in up migration
        DROP INDEX IF EXISTS unique_pending_application_per_user;
        DROP INDEX IF EXISTS idx_fellows_verified;
        DROP INDEX IF EXISTS idx_fellow_applications_moe_doc_path;
        
        -- Remove verification columns from fellows table
        ALTER TABLE fellows
        DROP CONSTRAINT IF EXISTS fk_fellows_verified_by,
        DROP CONSTRAINT IF EXISTS fk_fellows_source_application,
        DROP COLUMN IF EXISTS source_application_id,
        DROP COLUMN IF EXISTS moe_identifier_verified,
        DROP COLUMN IF EXISTS verified_at,
        DROP COLUMN IF EXISTS verified_by;
        
        -- Recreate full_name column and migrate data back
        ALTER TABLE fellow_applications
        ADD COLUMN full_name VARCHAR(200);
        
        UPDATE fellow_applications
        SET full_name = CONCAT(first_name, ' ', last_name)
        WHERE full_name IS NULL AND first_name IS NOT NULL;
        
        ALTER TABLE fellow_applications
        ALTER COLUMN full_name SET NOT NULL;
        
        -- Drop the split name columns and moe fields
        ALTER TABLE fellow_applications
        DROP COLUMN IF EXISTS first_name,
        DROP COLUMN IF EXISTS last_name,
        DROP COLUMN IF EXISTS moe_identifier,
        DROP COLUMN IF EXISTS moe_doc_path;
    END IF;
END
$$;
