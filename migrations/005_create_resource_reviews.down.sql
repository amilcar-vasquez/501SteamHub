DROP TABLE IF EXISTS resource_reviews CASCADE;
 -- Down: drop index then table
 DROP INDEX IF EXISTS idx_resource_reviews_resource_id;
 DROP TABLE IF EXISTS resource_reviews CASCADE;
