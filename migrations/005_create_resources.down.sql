-- DOWN: Drop resources table and shared trigger function
DROP TABLE IF EXISTS resources;
DROP FUNCTION IF EXISTS update_updated_at_column();
