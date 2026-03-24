-- DOWN: Remove MOE document path column from fellow_applications

DROP INDEX IF EXISTS idx_fellow_applications_moe_doc_path;

ALTER TABLE fellow_applications
DROP COLUMN IF EXISTS moe_doc_path;
