-- UP: Create ilos table
-- ILOs (Intended Learning Outcomes) are tied to specific subjects, grade levels, cycles, and strands
-- Each ILO has a unique code and description

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
CREATE INDEX idx_ilos_subject_id ON ilos (subject_id);
CREATE INDEX idx_ilos_grade_level_id ON ilos (grade_level_id);
CREATE INDEX idx_ilos_cycle_id ON ilos (cycle_id);
CREATE INDEX idx_ilos_strand_id ON ilos (strand_id);
CREATE INDEX idx_ilos_ilo_code ON ilos (ilo_code);

-- Composite index for common filter: subject + grade + cycle
CREATE INDEX idx_ilos_subject_grade_cycle ON ilos (subject_id, grade_level_id, cycle_id);

-- Create trigger to auto-update updated_at
CREATE TRIGGER ilos_updated_at
BEFORE UPDATE ON ilos
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
