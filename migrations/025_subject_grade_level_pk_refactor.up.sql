-- Consolidated Migration: 025_subject_grade_level_pk_refactor
-- Combines: 027_migrate_subject_grade_level_pks + 028_refactor_resource_subjects + 029_refactor_resource_grade_levels + 030_complete_pk_migration
-- Purpose: Refactor primary keys for subjects and grade_levels from VARCHAR to INTEGER
-- CRITICAL: This migration enables the ILO infrastructure which depends on subjects.id and grade_levels.id as INTEGER PKs

-- ============================================================================
-- Phase 1: Add new id columns to subjects and grade_levels (From 027)
-- ============================================================================
ALTER TABLE IF EXISTS subjects ADD COLUMN id SERIAL;
ALTER TABLE subjects ADD CONSTRAINT uq_subjects_id UNIQUE (id);

ALTER TABLE IF EXISTS grade_levels ADD COLUMN id SERIAL;
ALTER TABLE grade_levels ADD CONSTRAINT uq_grade_levels_id UNIQUE (id);

-- ============================================================================
-- Phase 2: Refactor resource_subjects to use subject_id (From 028)
-- ============================================================================
BEGIN;

-- Modify resource_subjects to use subject_id FK to subjects.id
ALTER TABLE resource_subjects DROP CONSTRAINT IF EXISTS resource_subjects_ibfk_2;
ALTER TABLE resource_subjects ADD COLUMN IF NOT EXISTS subject_id INT;

-- Populate subject_id based on subject lookup
UPDATE resource_subjects rs
SET subject_id = s.id
FROM subjects s
WHERE rs.subject = s.subject;

-- Add FK constraint if not already present
ALTER TABLE resource_subjects DROP COLUMN IF EXISTS subject CASCADE;
ALTER TABLE resource_subjects ADD CONSTRAINT fk_resource_subjects_subject_id 
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_resource_subjects_subject_id ON resource_subjects(subject_id);

COMMIT;

-- ============================================================================
-- Phase 3: Refactor resource_grade_levels to use grade_level_id (From 029)
-- ============================================================================
BEGIN;

-- Modify resource_grade_levels to use grade_level_id FK to grade_levels.id
ALTER TABLE resource_grade_levels DROP CONSTRAINT IF EXISTS resource_grade_levels_ibfk_2;
ALTER TABLE resource_grade_levels ADD COLUMN IF NOT EXISTS grade_level_id INT;

-- Populate grade_level_id based on grade_level lookup
UPDATE resource_grade_levels rgl
SET grade_level_id = gl.id
FROM grade_levels gl
WHERE rgl.grade_level = gl.grade_level;

-- Add FK constraint if not already present
ALTER TABLE resource_grade_levels DROP COLUMN IF EXISTS grade_level CASCADE;
ALTER TABLE resource_grade_levels ADD CONSTRAINT fk_resource_grade_levels_grade_level_id 
    FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_resource_grade_levels_grade_level_id ON resource_grade_levels(grade_level_id);

COMMIT;

-- ============================================================================
-- Phase 4: Complete PK migration - Make subject and grade_level not primary keys (From 030)
-- ============================================================================
BEGIN;

-- For subjects: Make id the PRIMARY KEY and subject UNIQUE (not PRIMARY)
ALTER TABLE subjects DROP CONSTRAINT IF EXISTS subjects_pkey;
ALTER TABLE subjects ADD PRIMARY KEY (id);
ALTER TABLE subjects ADD CONSTRAINT uq_subjects_subject UNIQUE (subject);

-- For grade_levels: Make id the PRIMARY KEY and grade_level UNIQUE (not PRIMARY)
ALTER TABLE grade_levels DROP CONSTRAINT IF EXISTS grade_levels_pkey;
ALTER TABLE grade_levels ADD PRIMARY KEY (id);
ALTER TABLE grade_levels ADD CONSTRAINT uq_grade_levels_grade_level UNIQUE (grade_level);

COMMIT;

-- ============================================================================
-- Verification: Ensure indices and constraints are properly set
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_subjects_subject ON subjects(subject);
CREATE INDEX IF NOT EXISTS idx_grade_levels_grade_level ON grade_levels(grade_level);
