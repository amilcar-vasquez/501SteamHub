-- DOWN

-- Revert resources table column back to VARCHAR
ALTER TABLE resources 
  ALTER COLUMN subject TYPE VARCHAR(150);

-- Drop the subject enum
DROP TYPE IF EXISTS subject;
