-- UP: Fellows profile table (stores extended profile for Fellow-role users)
-- Consolidated: Includes steam_points from original 023_add_steam_points_to_fellows (FR-27 contribution valuation)
-- Consolidated: Includes verification fields from original 024_refactor_fellow_applications
CREATE TABLE IF NOT EXISTS fellows (
    fellow_id                 SERIAL PRIMARY KEY,
    user_id                   INT UNIQUE NOT NULL,
    first_name                VARCHAR(100) NOT NULL,
    last_name                 VARCHAR(100) NOT NULL,
    bemis_number            VARCHAR(50) UNIQUE NOT NULL,
    school                    VARCHAR(150),
    subject_specialization    VARCHAR(100),
    district                  VARCHAR(100),
    profile_status            VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    steam_points              NUMERIC(10, 2) DEFAULT 0.0,  -- Cumulative STEAM Points earned through contributions
    source_application_id     BIGINT,  -- Link to fellow_applications for traceability (FK added in migration 020)
    bemis_number_verified   BOOLEAN DEFAULT FALSE,  -- Whether BEMIS number has been verified
    verified_at               TIMESTAMP,  -- When verification occurred
    verified_by               INT,  -- Which user verified the identifier
    created_at                TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_fellows_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_fellows_verified_by FOREIGN KEY (verified_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create indexes for potentially querying/sorting by steam points and verification status
CREATE INDEX idx_fellows_steam_points ON fellows (steam_points DESC);
CREATE INDEX idx_fellows_verified ON fellows (bemis_number_verified, verified_at);
