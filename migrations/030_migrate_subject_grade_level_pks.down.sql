-- DOWN: Rollback primary key migration for subjects and grade_levels
-- Restore old VARCHAR PKs and remove id as PRIMARY KEY

-- Step 1: Restore original VARCHAR primary keys

-- For subjects table
ALTER TABLE subjects 
DROP CONSTRAINT subjects_pkey;

ALTER TABLE subjects 
DROP CONSTRAINT subjects_subject_unique;

ALTER TABLE subjects 
ADD PRIMARY KEY (subject);

-- For grade_levels table
ALTER TABLE grade_levels 
DROP CONSTRAINT grade_levels_pkey;

ALTER TABLE grade_levels 
DROP CONSTRAINT grade_levels_grade_level_unique;

ALTER TABLE grade_levels 
ADD PRIMARY KEY (grade_level);
