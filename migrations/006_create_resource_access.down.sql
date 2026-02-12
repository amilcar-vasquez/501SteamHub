DROP TABLE IF EXISTS resource_access CASCADE;
 -- Down: drop index then table
 DROP INDEX IF EXISTS idx_resource_access_resource_id;
 DROP TABLE IF EXISTS resource_access CASCADE;
