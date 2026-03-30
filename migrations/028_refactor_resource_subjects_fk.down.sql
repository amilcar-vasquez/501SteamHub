-- DOWN: Rollback resource_subjects to use subject (VARCHAR) FK instead of subject_id (INT)
-- This reverses the migration 028 changes

-- Step 1: Drop the new foreign key constraint and primary key
ALTER TABLE resource_subjects 
DROP CONSTRAINT fk_resource_subjects_subject_id;

ALTER TABLE resource_subjects 
DROP CONSTRAINT resource_subjects_pkey;

-- Step 2: Add back the old subject varchar column
ALTER TABLE resource_subjects 
ADD COLUMN subject VARCHAR(150);

-- Step 3: Populate subject by joining with subjects table
UPDATE resource_subjects rs
SET subject = s.subject
FROM subjects s
WHERE rs.subject_id = s.id;

-- Step 4: Make subject NOT NULL
ALTER TABLE resource_subjects 
ALTER COLUMN subject SET NOT NULL;

-- Step 5: Add back the old primary key
ALTER TABLE resource_subjects 
ADD PRIMARY KEY (resource_id, subject);

-- Step 6: Add back the old foreign key constraint
ALTER TABLE resource_subjects 
ADD CONSTRAINT fk_resource_subjects_subject
FOREIGN KEY (subject) REFERENCES subjects(subject) ON DELETE RESTRICT;

-- Step 7: Drop subject_id column
ALTER TABLE resource_subjects 
DROP COLUMN subject_id;

-- Step 8: Recreate old index
DROP INDEX IF EXISTS idx_resource_subjects_subject_id;

CREATE INDEX idx_resource_subjects_subject ON resource_subjects (subject);
