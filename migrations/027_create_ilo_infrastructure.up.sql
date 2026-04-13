-- Consolidated Migration: 027_create_ilo_infrastructure
-- Combines: 031_create_cycles + 032_create_strands + 033_create_ilos + 036_create_resource_ilos
-- Purpose: Create complete ILO (Intended Learning Outcomes) infrastructure

-- ============================================================================
-- Part 1: From 031_create_cycles - Reference table for curriculum cycles
-- ============================================================================
CREATE TABLE IF NOT EXISTS cycles (
    id SERIAL PRIMARY KEY,
    cycle_number INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert standard cycles (1-4)
INSERT INTO cycles (id, cycle_number) VALUES (1,1), (2,2), (3,3), (4,4) 
ON CONFLICT (cycle_number) DO NOTHING;

-- Ensure sequence is set to max ID
SELECT setval('cycles_id_seq', (SELECT MAX(id) FROM cycles));

-- ============================================================================
-- Part 2: From 032_create_strands - Subject-specific learning strands
-- ============================================================================
CREATE TABLE IF NOT EXISTS strands (
    id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_strands_subject_id 
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CONSTRAINT uq_strands_subject_id_name 
        UNIQUE (subject_id, name)
);

CREATE INDEX IF NOT EXISTS idx_strands_subject_id ON strands (subject_id);

-- ============================================================================
-- Part 3: From 033_create_ilos - ILO definitions with subject/grade/cycle/strand
-- ============================================================================
CREATE TABLE IF NOT EXISTS ilos (
    id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    grade_level_id INT NOT NULL,
    cycle_id INT NOT NULL,
    strand_id INT NOT NULL,
    ilo_code TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ilos_subject_id
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CONSTRAINT fk_ilos_grade_level_id
        FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id) ON DELETE CASCADE,
    CONSTRAINT fk_ilos_cycle_id
        FOREIGN KEY (cycle_id) REFERENCES cycles(id) ON DELETE CASCADE,
    CONSTRAINT fk_ilos_strand_id
        FOREIGN KEY (strand_id) REFERENCES strands(id) ON DELETE CASCADE,
    CONSTRAINT uq_ilos_subject_grade_cycle_code
        UNIQUE (subject_id, grade_level_id, cycle_id, ilo_code)
);

-- Create indexes for efficient lookups and filtering
CREATE INDEX IF NOT EXISTS idx_ilos_subject_id ON ilos (subject_id);
CREATE INDEX IF NOT EXISTS idx_ilos_grade_level_id ON ilos (grade_level_id);
CREATE INDEX IF NOT EXISTS idx_ilos_cycle_id ON ilos (cycle_id);
CREATE INDEX IF NOT EXISTS idx_ilos_strand_id ON ilos (strand_id);
CREATE INDEX IF NOT EXISTS idx_ilos_ilo_code ON ilos (ilo_code);

-- Composite index for common filter: subject + grade + cycle
CREATE INDEX IF NOT EXISTS idx_ilos_subject_grade_cycle ON ilos (subject_id, grade_level_id, cycle_id);

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS ilos_updated_at ON ilos;
CREATE TRIGGER ilos_updated_at
BEFORE UPDATE ON ilos
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Part 4: From 036_create_resource_ilos - Junction table: resources to ILOs
-- ============================================================================
CREATE TABLE IF NOT EXISTS resource_ilos (
    id SERIAL PRIMARY KEY,
    resource_id INT NOT NULL 
        REFERENCES resources(resource_id) ON DELETE CASCADE,
    ilo_id INT NOT NULL 
        REFERENCES ilos(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(resource_id, ilo_id)
);

CREATE INDEX IF NOT EXISTS idx_resource_ilos_resource_id ON resource_ilos(resource_id);
CREATE INDEX IF NOT EXISTS idx_resource_ilos_ilo_id ON resource_ilos(ilo_id);
