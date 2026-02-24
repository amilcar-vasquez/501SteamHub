-- UP: Fellow applications table (User → Fellow upgrade requests)
CREATE TABLE IF NOT EXISTS fellow_applications (
    application_id   SERIAL PRIMARY KEY,
    user_id          INT NOT NULL,
    full_name        VARCHAR(200) NOT NULL,
    organization     VARCHAR(200) NOT NULL,
    subjects         TEXT[]  NOT NULL DEFAULT '{}',
    grade_levels     TEXT[]  NOT NULL DEFAULT '{}',
    experience_years INT     NOT NULL DEFAULT 0,
    bio              TEXT    NOT NULL,
    credentials_link VARCHAR(500),
    status           VARCHAR(20) NOT NULL DEFAULT 'Pending',
    reviewed_by      INT,
    reviewed_at      TIMESTAMP,
    created_at       TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_fellow_applications_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_fellow_applications_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_fellow_applications_status
        CHECK (status IN ('Pending', 'Approved', 'Rejected'))
);

CREATE INDEX idx_fellow_applications_user_id ON fellow_applications (user_id);
CREATE INDEX idx_fellow_applications_status  ON fellow_applications (status);
