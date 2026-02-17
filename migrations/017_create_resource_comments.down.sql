-- DOWN

DROP TRIGGER IF EXISTS resource_comments_updated_at ON resource_comments;
DROP INDEX IF EXISTS idx_resource_comments_parent;
DROP INDEX IF EXISTS idx_resource_comments_user;
DROP INDEX IF EXISTS idx_resource_comments_resource;
DROP TABLE IF EXISTS resource_comments;
