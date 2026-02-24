-- UP: Review comments table (inline reviewer feedback on lesson blocks)
CREATE TABLE IF NOT EXISTS review_comments (
    comment_id  SERIAL PRIMARY KEY,
    resource_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    section     VARCHAR(100),   -- lesson block type (objectives, activity, etc.)
    block_index INT,            -- index inside lesson_content.blocks
    comment     TEXT NOT NULL,
    resolved    BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    CONSTRAINT fk_rc_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_rc_reviewer
        FOREIGN KEY (reviewer_id) REFERENCES users(user_id)
);

CREATE INDEX idx_review_comments_resource ON review_comments (resource_id);
