-- [LEGACY MIGRATION - CONSOLIDATED INTO 019 AND 003]
-- This migration was consolidated into 019_create_fellow_applications and 003_create_fellows for fresh deployments.
-- It is retained here for backward compatibility with existing systems.
--
-- Original purpose: Refactor fellow applications to use first_name/last_name instead of full_name,
-- add BEMIS number tracking, and add verification fields to fellows table.
-- For fresh deployments: All changes are part of 019 and 003 creation.
-- For existing systems: This migration provides upgrade path from pre-consolidated schemas.

-- Idempotent: Only migrate if full_name column still exists
DO $$
BEGIN
    -- Add new columns to fellow_applications if they don't exist
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='fellow_applications' AND column_name='full_name'
    ) THEN
        ALTER TABLE fellow_applications
        ADD COLUMN IF NOT EXISTS first_name VARCHAR(100),
        ADD COLUMN IF NOT EXISTS last_name VARCHAR(100),
        ADD COLUMN IF NOT EXISTS bemis_number VARCHAR(50),
        ADD COLUMN IF NOT EXISTS moe_doc_path TEXT;
        
        -- Migrate data from full_name to first_name and last_name
        UPDATE fellow_applications
        SET 
          first_name = CASE 
            WHEN full_name LIKE '% %' THEN SUBSTRING(full_name FROM 1 FOR POSITION(' ' IN full_name) - 1)
            ELSE full_name
          END,
          last_name = CASE 
            WHEN full_name LIKE '% %' THEN SUBSTRING(full_name FROM POSITION(' ' IN full_name) + 1)
            ELSE ''
          END
        WHERE first_name IS NULL OR last_name IS NULL;
        
        -- Provide default BEMIS numbers for existing records
        UPDATE fellow_applications
        SET bemis_number = 'BEMIS_' || application_id::text
        WHERE bemis_number IS NULL;
        
        -- Make new columns NOT NULL (after migration)
        ALTER TABLE fellow_applications
        ALTER COLUMN first_name SET NOT NULL,
        ALTER COLUMN last_name SET NOT NULL,
        ALTER COLUMN bemis_number SET NOT NULL;
        
        -- Drop full_name column after successful migration
        ALTER TABLE fellow_applications DROP COLUMN full_name;
        
        -- Add verification columns to fellows if they don't exist
        ALTER TABLE fellows
        ADD COLUMN IF NOT EXISTS source_application_id BIGINT,
        ADD COLUMN IF NOT EXISTS bemis_number_verified BOOLEAN DEFAULT FALSE,
        ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP,
        ADD COLUMN IF NOT EXISTS verified_by BIGINT;
        
        -- Add foreign key constraint if it doesn't exist (using DROP IF EXISTS pattern for safety)
        BEGIN
            ALTER TABLE fellows
            ADD CONSTRAINT fk_fellows_source_application
              FOREIGN KEY (source_application_id) REFERENCES fellow_applications(application_id) ON DELETE SET NULL;
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
        
        BEGIN
            ALTER TABLE fellows
            ADD CONSTRAINT fk_fellows_verified_by
              FOREIGN KEY (verified_by) REFERENCES users(user_id) ON DELETE SET NULL;
        EXCEPTION WHEN duplicate_object THEN
            NULL;
        END;
        
        -- Create indexes if they don't exist
        CREATE INDEX IF NOT EXISTS unique_pending_application_per_user
        ON fellow_applications(user_id)
        WHERE status = 'Pending';
        
        CREATE INDEX IF NOT EXISTS idx_fellows_verified ON fellows (bemis_number_verified, verified_at);
        CREATE INDEX IF NOT EXISTS idx_fellow_applications_moe_doc_path ON fellow_applications (moe_doc_path);
    END IF;
END
$$;
