-- UP: Add MOE document path column to fellow_applications
-- Stores storage key reference (NOT public URL) for MOE verification documents

ALTER TABLE fellow_applications
ADD COLUMN moe_doc_path TEXT;

CREATE INDEX idx_fellow_applications_moe_doc_path ON fellow_applications (moe_doc_path);
