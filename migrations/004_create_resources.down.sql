-- Down: drop trigger, indexes, table, and function
DROP TRIGGER IF EXISTS resources_updated_at ON resources;
DROP INDEX IF EXISTS idx_resources_contributor_id;
DROP INDEX IF EXISTS idx_resources_grade_level;
DROP INDEX IF EXISTS idx_resources_subject;
DROP INDEX IF EXISTS idx_resources_status;
DROP TABLE IF EXISTS resources;
DROP FUNCTION IF EXISTS update_updated_at_column();
