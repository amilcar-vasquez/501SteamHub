-- UP

-- Migrate existing subject data to junction table
-- Only migrate rows with non-empty subject values
INSERT INTO resource_subjects (resource_id, subject)
SELECT resource_id, subject
FROM resources 
WHERE subject IS NOT NULL AND subject != '';

-- Migrate existing grade_level data to junction table
-- Only migrate rows with non-empty grade_level values
INSERT INTO resource_grade_levels (resource_id, grade_level)
SELECT resource_id, grade_level
FROM resources 
WHERE grade_level IS NOT NULL AND grade_level != '';

-- Drop old single-value columns from resources table
ALTER TABLE resources 
  DROP COLUMN subject,
  DROP COLUMN grade_level,
  DROP COLUMN ilo;

-- Drop old indexes (they should have been dropped with columns, but just to be safe)
DROP INDEX IF EXISTS idx_resources_subject;
DROP INDEX IF EXISTS idx_resources_grade_level;
