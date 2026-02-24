-- UP: Lesson versions table (audit trail for lesson content edits)
CREATE TABLE IF NOT EXISTS lesson_versions (
    version_id         SERIAL PRIMARY KEY,
    lesson_id          INT NOT NULL,
    version_number     INT NOT NULL,
    content            TEXT NOT NULL,
    change_description TEXT,
    changed_by         INT NOT NULL,
    changed_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lesson_versions_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_versions_user
        FOREIGN KEY (changed_by) REFERENCES users(user_id),
    CONSTRAINT uq_lesson_versions
        UNIQUE (lesson_id, version_number)
);

CREATE INDEX idx_lesson_versions_lesson     ON lesson_versions (lesson_id);
CREATE INDEX idx_lesson_versions_changed_by ON lesson_versions (changed_by);
