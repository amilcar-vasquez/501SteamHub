-- UP: Lessons table (structured lesson-plan blocks for LessonPlan resources)
CREATE TABLE IF NOT EXISTS lessons (
    lesson_id         SERIAL PRIMARY KEY,
    resource_id       INT NOT NULL,
    lesson_number     INT NOT NULL,
    title             VARCHAR(255) NOT NULL,
    duration_minutes  INT,
    objectives        TEXT[],
    materials         TEXT[],
    content           TEXT NOT NULL,
    assessment        TEXT,
    differentiation   TEXT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lessons_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT uq_lessons_resource_number
        UNIQUE (resource_id, lesson_number)
);

CREATE INDEX idx_lessons_resource ON lessons (resource_id);
