-- UP: Refactor resource_subjects to use subject_id (INT) FK instead of subject (VARCHAR)
-- This migration safely updates the foreign key relationship
-- Uses IF NOT EXISTS checks for idempotency

-- Step 1: Add new subject_id column to resource_subjects if it doesn't exist
ALTER TABLE resource_subjects 
ADD COLUMN IF NOT EXISTS subject_id INT;

-- Step 2: Populate subject_id by joining with subjects table (only if not already populated)
-- Cast subject to text to handle potential type mismatch
UPDATE resource_subjects rs
SET subject_id = s.id
FROM subjects s
WHERE rs.subject::text = s.subject
AND rs.subject_id IS NULL;

-- Step 3: If subject column exists and subject_id is populated, update the FK
DO $$
DECLARE
    col_exists BOOLEAN;
    fk_exists BOOLEAN;
BEGIN
    -- Check if subject column still exists
    SELECT EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'resource_subjects' AND column_name = 'subject'
    ) INTO col_exists;
    
    -- Check if old FK constraint exists
    SELECT EXISTS(
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'resource_subjects' 
        AND constraint_name = 'fk_resource_subjects_subject'
    ) INTO fk_exists;
    
    IF col_exists AND fk_exists THEN
        -- Remove the old foreign key constraint
        ALTER TABLE resource_subjects 
        DROP CONSTRAINT fk_resource_subjects_subject;
    END IF;
    
    -- Drop subject column if it exists and subject_id is fully populated
    IF col_exists THEN
        ALTER TABLE resource_subjects 
        DROP COLUMN subject;
    END IF;
END $$;

-- Step 5: Make subject_id NOT NULL now that it's fully populated
ALTER TABLE resource_subjects 
ALTER COLUMN subject_id SET NOT NULL;

-- Step 6: Add new foreign key constraint if it doesn't exist
DO $$
BEGIN
    BEGIN
        ALTER TABLE resource_subjects 
        ADD CONSTRAINT fk_resource_subjects_subject_id
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE RESTRICT;
    EXCEPTION WHEN duplicate_object THEN
        -- Constraint already exists
        NULL;
    END;
END $$;

-- Step 7: Update primary key from (resource_id, subject) to (resource_id, subject_id)
-- Only if the old PK still exists
DO $$
BEGIN
    -- Try to drop old PK
    BEGIN
        ALTER TABLE resource_subjects 
        DROP CONSTRAINT resource_subjects_pkey;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
    
    -- Try to add new PK
    BEGIN
        ALTER TABLE resource_subjects 
        ADD PRIMARY KEY (resource_id, subject_id);
    EXCEPTION WHEN duplicate_object THEN
        -- PK already exists
        NULL;
    END;
END $$;

-- Step 8: Update indexes
DROP INDEX IF EXISTS idx_resource_subjects_subject;
CREATE INDEX IF NOT EXISTS idx_resource_subjects_subject_id ON resource_subjects (subject_id);
