-- UP: Fellow applications table (User → Fellow upgrade requests)
-- Consolidated: Includes refactoring from original 024_refactor_fellow_applications
-- Uses first_name/last_name (not full_name) and includes MOE tracking from inception
CREATE TABLE IF NOT EXISTS fellow_applications (
    application_id       SERIAL PRIMARY KEY,
    user_id              INT NOT NULL,
    first_name           VARCHAR(100) NOT NULL,  -- Split from full_name in consolidated design
    last_name            VARCHAR(100) NOT NULL,  -- Split from full_name in consolidated design
    moe_identifier       VARCHAR(50) NOT NULL,  -- Ministry of Education identifier
    moe_doc_path         TEXT,  -- Path to MOE documentation
    organization         VARCHAR(200) NOT NULL,
    subjects             TEXT[]  NOT NULL DEFAULT '{}',
    grade_levels         TEXT[]  NOT NULL DEFAULT '{}',
    experience_years     INT     NOT NULL DEFAULT 0,
    bio                  TEXT    NOT NULL,
    credentials_link     VARCHAR(500),
    status               VARCHAR(20) NOT NULL DEFAULT 'Pending',
    reviewed_by          INT,
    reviewed_at          TIMESTAMP,
    created_at           TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_fellow_applications_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_fellow_applications_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_fellow_applications_status
        CHECK (status IN ('Pending', 'Approved', 'Rejected'))
);

CREATE INDEX idx_fellow_applications_user_id ON fellow_applications (user_id);
CREATE INDEX idx_fellow_applications_status  ON fellow_applications (status);
CREATE UNIQUE INDEX unique_pending_application_per_user ON fellow_applications(user_id) WHERE status = 'Pending';
CREATE INDEX idx_fellow_applications_moe_doc_path ON fellow_applications (moe_doc_path);
