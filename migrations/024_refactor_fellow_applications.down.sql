-- DOWN: Revert consolidated Fellow applications refactoring

-- Step 1: Drop indexes added in the up migration
DROP INDEX IF EXISTS unique_pending_application_per_user;
DROP INDEX IF EXISTS idx_fellows_verified;
DROP INDEX IF EXISTS idx_fellow_applications_moe_doc_path;

-- Step 2: Remove new columns from fellows table
ALTER TABLE fellows
DROP CONSTRAINT IF EXISTS fk_fellows_verified_by,
DROP CONSTRAINT IF EXISTS fk_fellows_source_application,
DROP COLUMN IF EXISTS source_application_id,
DROP COLUMN IF EXISTS moe_identifier_verified,
DROP COLUMN IF EXISTS verified_at,
DROP COLUMN IF EXISTS verified_by;

-- Step 3: Recreate full_name column in fellow_applications
ALTER TABLE fellow_applications
ADD COLUMN full_name VARCHAR(200);

-- Step 4: Migrate data back from first_name and last_name to full_name
UPDATE fellow_applications
SET full_name = CONCAT(first_name, ' ', last_name)
WHERE full_name IS NULL;

-- Step 5: Make full_name NOT NULL
ALTER TABLE fellow_applications
ALTER COLUMN full_name SET NOT NULL;

-- Step 6: Drop the split name columns and moe fields from fellow_applications
ALTER TABLE fellow_applications
DROP COLUMN IF EXISTS first_name,
DROP COLUMN IF EXISTS last_name,
DROP COLUMN IF EXISTS moe_identifier,
DROP COLUMN IF EXISTS moe_doc_path;
