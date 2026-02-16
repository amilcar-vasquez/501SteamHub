-- DOWN

BEGIN;

-- Drop dependent tables first
DROP TABLE IF EXISTS lesson_versions;
DROP TABLE IF EXISTS resource_comments;
DROP TABLE IF EXISTS lessons;
DROP TABLE IF EXISTS resource_grade_levels;
DROP TABLE IF EXISTS resource_subjects;

-- Drop triggers and functions
DROP TRIGGER IF EXISTS resources_updated_at ON resources;
DROP TRIGGER IF EXISTS resource_comments_updated_at ON resource_comments;
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Remove added columns
ALTER TABLE resources 
  DROP COLUMN IF EXISTS slug,
  DROP COLUMN IF EXISTS summary,
  DROP COLUMN IF EXISTS updated_at;

-- Recreate original columns (basic fallback)
ALTER TABLE resources 
  ADD COLUMN subject VARCHAR(150),
  ADD COLUMN grade_level VARCHAR(50),
  ADD COLUMN ilo TEXT;

-- Recreate indexes
CREATE INDEX IF NOT EXISTS idx_resources_subject ON resources (subject);
CREATE INDEX IF NOT EXISTS idx_resources_grade_level ON resources (grade_level);

COMMIT;
