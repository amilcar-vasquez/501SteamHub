-- Rollback: Remove slugs that were added by the migration
-- Note: This doesn't distinguish between slugs added by the migration
-- and slugs added by the application after the migration ran

-- If you want to be safe, you can just leave slugs in place
-- UPDATE resources SET slug = NULL WHERE slug IS NOT NULL;

-- Or do nothing (recommended)
SELECT 1;
