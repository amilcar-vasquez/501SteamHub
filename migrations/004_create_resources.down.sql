-- Down: drop indexes then table
DROP INDEX IF EXISTS idx_resources_contributor_id;
DROP INDEX IF EXISTS idx_resources_grade_level;
DROP INDEX IF EXISTS idx_resources_subject;
DROP INDEX IF EXISTS idx_resources_status;
DROP TABLE IF EXISTS resources;
