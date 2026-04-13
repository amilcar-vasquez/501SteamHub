-- Rollback Migration: 027_create_ilo_infrastructure
-- Reverses: 031_create_cycles + 032_create_strands + 033_create_ilos + 036_create_resource_ilos
-- Note: Reverse order due to FK dependencies

-- Drop in reverse order of FK dependencies:

-- Part 4: Drop resource_ilos first (depends on ilos and resources)
DROP TABLE IF EXISTS resource_ilos CASCADE;

-- Part 3: Drop ilos (depends on cycles, strands, subjects, grade_levels)
DROP TRIGGER IF EXISTS ilos_updated_at ON ilos CASCADE;
DROP TABLE IF EXISTS ilos CASCADE;
DROP SEQUENCE IF EXISTS ilos_id_seq CASCADE;

-- Part 2: Drop strands (depends on subjects)
DROP TABLE IF EXISTS strands CASCADE;
DROP SEQUENCE IF EXISTS strands_id_seq CASCADE;

-- Part 1: Drop cycles (no dependencies from other tables)
DROP TABLE IF EXISTS cycles CASCADE;
DROP SEQUENCE IF EXISTS cycles_id_seq CASCADE;
