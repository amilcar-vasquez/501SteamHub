-- UP: Resource ↔ Subject junction table
CREATE TABLE IF NOT EXISTS resource_subjects (
    resource_id INT          NOT NULL,
    subject     VARCHAR(150) NOT NULL,
    PRIMARY KEY (resource_id, subject),
    CONSTRAINT fk_resource_subjects_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_subjects_subject
        FOREIGN KEY (subject) REFERENCES subjects(subject) ON DELETE RESTRICT
);

CREATE INDEX idx_resource_subjects_resource ON resource_subjects (resource_id);
CREATE INDEX idx_resource_subjects_subject  ON resource_subjects (subject);
