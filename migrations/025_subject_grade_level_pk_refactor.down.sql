-- Rollback Migration: 025_subject_grade_level_pk_refactor
-- Reverses: 027_migrate_subject_grade_level_pks + 028_refactor_resource_subjects + 029_refactor_resource_grade_levels + 030_complete_pk_migration
-- WARNING: This rollback is complex and should only be executed if the migration failed
-- Note: Some data loss may occur if this migration had partial success

BEGIN;

-- ============================================================================
-- Reverse Phase 4: Revert subjects and grade_levels PKs
-- ============================================================================
-- For subjects: Revert back to VARCHAR PK
ALTER TABLE subjects DROP CONSTRAINT IF EXISTS subjects_pkey CASCADE;
ALTER TABLE subjects DROP CONSTRAINT IF EXISTS uq_subjects_subject;
ALTER TABLE subjects ADD PRIMARY KEY (subject);

-- For grade_levels: Revert back to VARCHAR PK
ALTER TABLE grade_levels DROP CONSTRAINT IF EXISTS grade_levels_pkey CASCADE;
ALTER TABLE grade_levels DROP CONSTRAINT IF EXISTS uq_grade_levels_grade_level;
ALTER TABLE grade_levels ADD PRIMARY KEY (grade_level);

-- ============================================================================
-- Reverse Phase 3: Revert resource_grade_levels
-- ============================================================================
-- Drop new INTEGER column constraint
ALTER TABLE resource_grade_levels DROP CONSTRAINT IF EXISTS fk_resource_grade_levels_grade_level_id;
DROP INDEX IF EXISTS idx_resource_grade_levels_grade_level_id;

-- Restore grade_level VARCHAR column
ALTER TABLE resource_grade_levels ADD COLUMN grade_level VARCHAR(100);
UPDATE resource_grade_levels rgl
SET grade_level = gl.grade_level
FROM grade_levels gl
WHERE rgl.grade_level_id = gl.id;

-- Drop INTEGER column
ALTER TABLE resource_grade_levels DROP COLUMN IF EXISTS grade_level_id;

-- ============================================================================
-- Reverse Phase 2: Revert resource_subjects
-- ============================================================================
-- Drop new INTEGER column constraint
ALTER TABLE resource_subjects DROP CONSTRAINT IF EXISTS fk_resource_subjects_subject_id;
DROP INDEX IF EXISTS idx_resource_subjects_subject_id;

-- Restore subject VARCHAR column
ALTER TABLE resource_subjects ADD COLUMN subject VARCHAR(100);
UPDATE resource_subjects rs
SET subject = s.subject
FROM subjects s
WHERE rs.subject_id = s.id;

-- Drop INTEGER column
ALTER TABLE resource_subjects DROP COLUMN IF EXISTS subject_id;

-- ============================================================================
-- Reverse Phase 1: Drop new INTEGER id columns
-- ============================================================================
-- Drop indices on the old VARCHAR PK columns
DROP INDEX IF EXISTS idx_subjects_subject;
DROP INDEX IF EXISTS idx_grade_levels_grade_level;

-- Drop id columns
ALTER TABLE subjects DROP COLUMN IF EXISTS id CASCADE;
ALTER TABLE grade_levels DROP COLUMN IF EXISTS id CASCADE;

COMMIT;
    
    ALTER TABLE resource_grade_levels DROP COLUMN grade_level_id;
    ALTER TABLE resource_grade_levels ADD CONSTRAINT resource_grade_levels_ibfk_2
        FOREIGN KEY (grade_level) REFERENCES grade_levels(grade_level) ON DELETE RESTRICT;
    DROP INDEX IF EXISTS idx_resource_grade_levels_grade_level_id;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not revert resource_grade_levels: %', SQLERRM;
END $$;

-- Phase 2 Reverse: Revert resource_subjects
DO $$
BEGIN
    ALTER TABLE resource_subjects DROP CONSTRAINT IF EXISTS fk_resource_subjects_subject_id;
    ALTER TABLE resource_subjects ADD COLUMN subject VARCHAR(100);
    
    -- Restore subject values from subjects table
    UPDATE resource_subjects rs
    SET subject = s.subject
    FROM subjects s
    WHERE rs.subject_id = s.id;
    
    ALTER TABLE resource_subjects DROP COLUMN subject_id;
    ALTER TABLE resource_subjects ADD CONSTRAINT resource_subjects_ibfk_2
        FOREIGN KEY (subject) REFERENCES subjects(subject) ON DELETE RESTRICT;
    DROP INDEX IF EXISTS idx_resource_subjects_subject_id;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not revert resource_subjects: %', SQLERRM;
END $$;

-- Phase 1 Reverse: Remove id columns (these will cause issues if dependent data exists)
-- Only drop if there are no dependent records
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM resource_ilos WHERE ilo_id IN (SELECT id FROM ilos)) = 0 THEN
        ALTER TABLE subjects DROP COLUMN IF EXISTS id CASCADE;
        ALTER TABLE grade_levels DROP COLUMN IF EXISTS id CASCADE;
    ELSE
        RAISE NOTICE 'Cannot drop id columns - dependent ILO records exist. Manual cleanup may be required.';
    END IF;
    
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not drop id columns: %', SQLERRM;
END $$;

COMMIT;
