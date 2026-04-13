-- UP: Consolidate Fellow applications refactoring (024 + 025)
-- Refactor Fellow onboarding system to improve data integrity
-- Replace FullName duplication with FirstName/LastName
-- Add MOE Identifier and MOE document tracking
-- Add traceability and verification tracking to fellows

-- Step 1: Add new columns to fellow_applications
ALTER TABLE fellow_applications
ADD COLUMN first_name VARCHAR(100),
ADD COLUMN last_name VARCHAR(100),
ADD COLUMN moe_identifier VARCHAR(50),
ADD COLUMN moe_doc_path TEXT;

-- Step 2: Migrate data from full_name to first_name and last_name
-- This handles existing records by splitting on space
UPDATE fellow_applications
SET 
  first_name = CASE 
    WHEN full_name LIKE '% %' THEN SUBSTRING(full_name FROM 1 FOR POSITION(' ' IN full_name) - 1)
    ELSE full_name
  END,
  last_name = CASE 
    WHEN full_name LIKE '% %' THEN SUBSTRING(full_name FROM POSITION(' ' IN full_name) + 1)
    ELSE ''
  END
WHERE first_name IS NULL OR last_name IS NULL;

-- Step 2.5: Provide default MOE identifiers for existing records
UPDATE fellow_applications
SET moe_identifier = 'MOE_' || application_id::text
WHERE moe_identifier IS NULL;

-- Step 3: Remove full_name column from fellow_applications
ALTER TABLE fellow_applications
DROP COLUMN full_name;

-- Step 4: Make new columns NOT NULL (after migration)
ALTER TABLE fellow_applications
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL,
ALTER COLUMN moe_identifier SET NOT NULL;

-- Step 5: Add traceability to fellows table
ALTER TABLE fellows
ADD COLUMN source_application_id BIGINT,
ADD COLUMN moe_identifier_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN verified_at TIMESTAMP,
ADD COLUMN verified_by BIGINT,
ADD CONSTRAINT fk_fellows_source_application
  FOREIGN KEY (source_application_id) REFERENCES fellow_applications(application_id) ON DELETE SET NULL,
ADD CONSTRAINT fk_fellows_verified_by
  FOREIGN KEY (verified_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- Step 6: Create unique index for pending applications per user
CREATE UNIQUE INDEX unique_pending_application_per_user
ON fellow_applications(user_id)
WHERE status = 'Pending';

-- Step 7: Indexes for verification lookups and moe_doc_path
CREATE INDEX idx_fellows_verified ON fellows (moe_identifier_verified, verified_at);
CREATE INDEX idx_fellow_applications_moe_doc_path ON fellow_applications (moe_doc_path);
