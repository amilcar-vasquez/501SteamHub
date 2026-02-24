-- UP: Fellows profile table (stores extended profile for Fellow-role users)
CREATE TABLE IF NOT EXISTS fellows (
    fellow_id            SERIAL PRIMARY KEY,
    user_id              INT UNIQUE NOT NULL,
    first_name           VARCHAR(100) NOT NULL,
    last_name            VARCHAR(100) NOT NULL,
    moe_identifier       VARCHAR(50) UNIQUE NOT NULL,
    school               VARCHAR(150),
    subject_specialization VARCHAR(100),
    district             VARCHAR(100),
    profile_status       VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    created_at           TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_fellows_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
