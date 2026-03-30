-- DOWN: Remove SERIAL id columns from subjects and grade_levels
-- Rollback the addition of id columns and drop the sequences

ALTER TABLE subjects 
DROP COLUMN IF EXISTS id CASCADE;

ALTER TABLE grade_levels 
DROP COLUMN IF EXISTS id CASCADE;

DROP SEQUENCE IF EXISTS subjects_id_seq;
DROP SEQUENCE IF EXISTS grade_levels_id_seq;
