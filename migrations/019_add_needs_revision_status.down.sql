-- DOWN

-- NOTE: PostgreSQL does not support removing enum values directly.
-- To reverse this migration you would need to recreate the enum type
-- without 'NeedsRevision', which requires migrating all existing data first.
-- This is intentionally left as a no-op; apply with caution in production.

SELECT 1; -- no-op placeholder
