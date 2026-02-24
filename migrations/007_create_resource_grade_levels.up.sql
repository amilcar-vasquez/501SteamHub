-- UP: Resource ↔ Grade level junction table
CREATE TABLE IF NOT EXISTS resource_grade_levels (
    resource_id INT         NOT NULL,
    grade_level VARCHAR(50) NOT NULL,
    PRIMARY KEY (resource_id, grade_level),
    CONSTRAINT fk_resource_grade_levels_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_grade_levels_grade
        FOREIGN KEY (grade_level) REFERENCES grade_levels(grade_level) ON DELETE RESTRICT
);

CREATE INDEX idx_resource_grade_levels_resource ON resource_grade_levels (resource_id);
CREATE INDEX idx_resource_grade_levels_grade     ON resource_grade_levels (grade_level);
