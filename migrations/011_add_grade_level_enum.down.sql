-- DOWN

-- Revert resources table column back to VARCHAR
ALTER TABLE resources 
  ALTER COLUMN grade_level TYPE VARCHAR(50);

-- Drop the grade_level enum
DROP TYPE IF EXISTS grade_level;
