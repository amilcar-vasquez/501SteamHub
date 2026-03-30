-- DOWN: Rollback resource_grade_levels to use grade_level (VARCHAR) FK instead of grade_level_id (INT)
-- This reverses the migration 029 changes

-- Step 1: Drop the new foreign key constraint and primary key
ALTER TABLE resource_grade_levels 
DROP CONSTRAINT fk_resource_grade_levels_grade_level_id;

ALTER TABLE resource_grade_levels 
DROP CONSTRAINT resource_grade_levels_pkey;

-- Step 2: Add back the old grade_level varchar column
ALTER TABLE resource_grade_levels 
ADD COLUMN grade_level VARCHAR(50);

-- Step 3: Populate grade_level by joining with grade_levels table
UPDATE resource_grade_levels rgl
SET grade_level = gl.grade_level
FROM grade_levels gl
WHERE rgl.grade_level_id = gl.id;

-- Step 4: Make grade_level NOT NULL
ALTER TABLE resource_grade_levels 
ALTER COLUMN grade_level SET NOT NULL;

-- Step 5: Add back the old primary key
ALTER TABLE resource_grade_levels 
ADD PRIMARY KEY (resource_id, grade_level);

-- Step 6: Add back the old foreign key constraint
ALTER TABLE resource_grade_levels 
ADD CONSTRAINT fk_resource_grade_levels_grade
FOREIGN KEY (grade_level) REFERENCES grade_levels(grade_level) ON DELETE RESTRICT;

-- Step 7: Drop grade_level_id column
ALTER TABLE resource_grade_levels 
DROP COLUMN grade_level_id;

-- Step 8: Recreate old index
DROP INDEX IF EXISTS idx_resource_grade_levels_grade_level_id;

CREATE INDEX idx_resource_grade_levels_grade ON resource_grade_levels (grade_level);
