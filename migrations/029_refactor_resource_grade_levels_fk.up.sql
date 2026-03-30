-- UP: Refactor resource_grade_levels to use grade_level_id (INT) FK instead of grade_level (VARCHAR)
-- This migration safely updates the foreign key relationship
-- Uses IF NOT EXISTS checks for idempotency

-- Step 1: Add new grade_level_id column to resource_grade_levels if it doesn't exist
ALTER TABLE resource_grade_levels 
ADD COLUMN IF NOT EXISTS grade_level_id INT;

-- Step 2: Populate grade_level_id by joining with grade_levels table (only if not already populated)
-- Cast grade_level to text to handle potential type mismatch  
UPDATE resource_grade_levels rgl
SET grade_level_id = gl.id
FROM grade_levels gl
WHERE rgl.grade_level::text = gl.grade_level
AND rgl.grade_level_id IS NULL;

-- Step 3: If grade_level column exists and grade_level_id is populated, update the FK
DO $$
DECLARE
    col_exists BOOLEAN;
    fk_exists BOOLEAN;
BEGIN
    -- Check if grade_level column still exists
    SELECT EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'resource_grade_levels' AND column_name = 'grade_level'
    ) INTO col_exists;
    
    -- Check if old FK constraint exists
    SELECT EXISTS(
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'resource_grade_levels' 
        AND constraint_name = 'fk_resource_grade_levels_grade'
    ) INTO fk_exists;
    
    IF col_exists AND fk_exists THEN
        -- Remove the old foreign key constraint
        ALTER TABLE resource_grade_levels 
        DROP CONSTRAINT fk_resource_grade_levels_grade;
    END IF;
    
    -- Drop grade_level column if it exists and grade_level_id is fully populated
    IF col_exists THEN
        ALTER TABLE resource_grade_levels 
        DROP COLUMN grade_level;
    END IF;
END $$;

-- Step 5: Make grade_level_id NOT NULL now that it's fully populated
ALTER TABLE resource_grade_levels 
ALTER COLUMN grade_level_id SET NOT NULL;

-- Step 6: Add new foreign key constraint if it doesn't exist
DO $$
BEGIN
    BEGIN
        ALTER TABLE resource_grade_levels 
        ADD CONSTRAINT fk_resource_grade_levels_grade_level_id
        FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id) ON DELETE RESTRICT;
    EXCEPTION WHEN duplicate_object THEN
        -- Constraint already exists
        NULL;
    END;
END $$;

-- Step 7: Update primary key from (resource_id, grade_level) to (resource_id, grade_level_id)
-- Only if the old PK still exists
DO $$
BEGIN
    -- Try to drop old PK
    BEGIN
        ALTER TABLE resource_grade_levels 
        DROP CONSTRAINT resource_grade_levels_pkey;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
    
    -- Try to add new PK
    BEGIN
        ALTER TABLE resource_grade_levels 
        ADD PRIMARY KEY (resource_id, grade_level_id);
    EXCEPTION WHEN duplicate_object THEN
        -- PK already exists
        NULL;
    END;
END $$;

-- Step 8: Update indexes
DROP INDEX IF EXISTS idx_resource_grade_levels_grade;
CREATE INDEX IF NOT EXISTS idx_resource_grade_levels_grade_level_id ON resource_grade_levels (grade_level_id);
