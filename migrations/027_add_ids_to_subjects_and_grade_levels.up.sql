-- UP: Add SERIAL id columns to subjects and grade_levels tables
-- This migration adds integer primary keys while keeping the varchar values intact
-- for backward compatibility during the transition period.

-- Ensure subjects table exists (safety check - should already exist from migration 004)
CREATE TABLE IF NOT EXISTS subjects (
    subject VARCHAR(150) PRIMARY KEY
);

-- Ensure grade_levels table exists (safety check - should already exist from migration 004)
CREATE TABLE IF NOT EXISTS grade_levels (
    grade_level VARCHAR(50) PRIMARY KEY
);

-- Add id SERIAL columns if they don't already exist
ALTER TABLE subjects 
ADD COLUMN IF NOT EXISTS id SERIAL UNIQUE NOT NULL;

ALTER TABLE grade_levels 
ADD COLUMN IF NOT EXISTS id SERIAL UNIQUE NOT NULL;

-- Create sequences if they don't exist (backup)
CREATE SEQUENCE IF NOT EXISTS subjects_id_seq;
CREATE SEQUENCE IF NOT EXISTS grade_levels_id_seq;

-- Set default values for id columns
ALTER TABLE subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq');
ALTER TABLE grade_levels ALTER COLUMN id SET DEFAULT nextval('grade_levels_id_seq');
