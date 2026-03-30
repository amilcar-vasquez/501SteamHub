-- UP: Create strands table
-- Strands represent sub-categories or learning strands within a subject
-- Example: Arts subject has strands like "Dance and Drama", "Music", "Creative Art Forms"

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

-- Create indexes for efficient lookups
CREATE INDEX idx_strands_subject_id ON strands (subject_id);
CREATE INDEX idx_strands_name ON strands (name);
