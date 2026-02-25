-- =============================================================================
-- 501 STEAM Hub — Full Database Schema
-- =============================================================================
-- This file is the single-file equivalent of all migrations run in order.
-- Use it to bootstrap the database when a migration tool is not available:
--
--   psql -U <user> -d <dbname> -f schema.sql
--
-- To recreate from scratch:
--   psql -U <user> -d <dbname> -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
--   psql -U <user> -d <dbname> -f schema.sql
--
-- Default admin credentials: username=admin  password=Admin@501steam
-- CHANGE the password immediately after first login.
-- =============================================================================


-- =============================================================================
-- ENUMs
-- =============================================================================

CREATE TYPE resource_status AS ENUM (
    'Draft',
    'Submitted',
    'UnderReview',
    'NeedsRevision',
    'Rejected',
    'Approved',
    'DesignCurate',
    'Published',
    'Indexed',
    'Archived'
);

CREATE TYPE resource_category AS ENUM (
    'LessonPlan',
    'Video',
    'Slideshow',
    'Assessment',
    'Other'
);

CREATE TYPE review_decision AS ENUM (
    'Approved',
    'Rejected'
);


-- =============================================================================
-- LOOKUP TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS roles (
    role_id     SERIAL PRIMARY KEY,
    name        VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS subjects (
    subject VARCHAR(150) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS grade_levels (
    grade_level VARCHAR(50) PRIMARY KEY
);


-- =============================================================================
-- CORE TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    user_id       SERIAL PRIMARY KEY,
    username      VARCHAR(100) UNIQUE NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id       INT REFERENCES roles(role_id) ON DELETE SET NULL,
    is_active     BOOLEAN   DEFAULT TRUE,
    last_login    TIMESTAMP,
    created_at    TIMESTAMP DEFAULT NOW(),
    created_by    INT REFERENCES users(user_id) ON DELETE SET NULL,
    updated_at    TIMESTAMP DEFAULT NOW(),
    updated_by    INT REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS fellows (
    fellow_id              SERIAL PRIMARY KEY,
    user_id                INT UNIQUE NOT NULL,
    first_name             VARCHAR(100) NOT NULL,
    last_name              VARCHAR(100) NOT NULL,
    moe_identifier         VARCHAR(50) UNIQUE NOT NULL,
    school                 VARCHAR(150),
    subject_specialization VARCHAR(100),
    district               VARCHAR(100),
    profile_status         VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    created_at             TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_fellows_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Trigger function: auto-update updated_at on any table that uses it
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS resources (
    resource_id    SERIAL PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    slug           VARCHAR(255) UNIQUE,
    summary        TEXT,
    category       resource_category NOT NULL,
    drive_link     TEXT,
    status         resource_status NOT NULL DEFAULT 'Draft',
    published_url  TEXT,
    contributor_id INT NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_resources_contributor
        FOREIGN KEY (contributor_id) REFERENCES users(user_id),
    CONSTRAINT chk_published_url_required
        CHECK (status NOT IN ('Published', 'Indexed', 'Archived') OR published_url IS NOT NULL)
);

CREATE INDEX idx_resources_status         ON resources (status);
CREATE INDEX idx_resources_contributor_id ON resources (contributor_id);

CREATE TRIGGER resources_updated_at
BEFORE UPDATE ON resources
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- RESOURCE JUNCTION TABLES
-- =============================================================================

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


-- =============================================================================
-- REVIEW & ACCESS TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS resource_reviews (
    review_id        SERIAL PRIMARY KEY,
    resource_id      INT NOT NULL,
    reviewer_id      INT NOT NULL,
    reviewer_role_id INT NOT NULL,
    decision         review_decision NOT NULL,
    comment_summary  TEXT,
    reviewed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rr_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_rr_reviewer
        FOREIGN KEY (reviewer_id) REFERENCES users(user_id),
    CONSTRAINT fk_rr_reviewer_role
        FOREIGN KEY (reviewer_role_id) REFERENCES roles(role_id),
    CONSTRAINT uniq_resource_review_role
        UNIQUE (resource_id, reviewer_role_id)
);

CREATE INDEX idx_resource_reviews_resource_id ON resource_reviews (resource_id);

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

CREATE TABLE IF NOT EXISTS resource_access (
    access_id   SERIAL PRIMARY KEY,
    resource_id INT NOT NULL,
    user_id     INT NOT NULL,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ra_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_ra_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_resource_access_resource_id ON resource_access (resource_id);

CREATE TABLE IF NOT EXISTS resource_status_history (
    history_id  SERIAL PRIMARY KEY,
    resource_id INT NOT NULL,
    old_status  resource_status,
    new_status  resource_status NOT NULL,
    changed_by  INT,
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rsh_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_status_history_resource ON resource_status_history (resource_id);


-- =============================================================================
-- CONTENT TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS lessons (
    lesson_id        SERIAL PRIMARY KEY,
    resource_id      INT NOT NULL,
    lesson_number    INT NOT NULL,
    title            VARCHAR(255) NOT NULL,
    duration_minutes INT,
    objectives       TEXT[],
    materials        TEXT[],
    content          TEXT NOT NULL,
    assessment       TEXT,
    differentiation  TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lessons_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT uq_lessons_resource_number
        UNIQUE (resource_id, lesson_number)
);

CREATE INDEX idx_lessons_resource ON lessons (resource_id);

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

CREATE TABLE IF NOT EXISTS video_metadata (
    id                  BIGSERIAL PRIMARY KEY,
    resource_id         BIGINT NOT NULL UNIQUE
                            REFERENCES resources(resource_id) ON DELETE CASCADE,
    youtube_title       VARCHAR(100) NOT NULL,
    youtube_description TEXT         NOT NULL DEFAULT '',
    tags                TEXT[]       NOT NULL DEFAULT '{}',
    privacy_status      VARCHAR(20)  NOT NULL DEFAULT 'unlisted'
                            CHECK (privacy_status IN ('public', 'private', 'unlisted')),
    made_for_kids       BOOLEAN      NOT NULL DEFAULT FALSE,
    category_id         INT          NOT NULL DEFAULT 27,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- =============================================================================
-- COMMENTS
-- =============================================================================

CREATE TABLE IF NOT EXISTS resource_comments (
    comment_id        SERIAL PRIMARY KEY,
    resource_id       INT NOT NULL,
    user_id           INT NOT NULL,
    parent_comment_id INT,
    content           TEXT NOT NULL,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_resource_comments_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_comments_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_comments_parent
        FOREIGN KEY (parent_comment_id) REFERENCES resource_comments(comment_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_comments_resource ON resource_comments (resource_id);
CREATE INDEX idx_resource_comments_user     ON resource_comments (user_id);
CREATE INDEX idx_resource_comments_parent   ON resource_comments (parent_comment_id);

CREATE TRIGGER resource_comments_updated_at
BEFORE UPDATE ON resource_comments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- =============================================================================
-- AUTH & NOTIFICATIONS
-- =============================================================================

CREATE TABLE IF NOT EXISTS auth_tokens (
    token_id   SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token      BYTEA UNIQUE NOT NULL,
    scope      VARCHAR(100),
    expires_at TIMESTAMP(0) WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP(0) WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_id ON auth_tokens (user_id);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id         INT REFERENCES users(user_id) ON DELETE CASCADE,
    message         TEXT NOT NULL,
    channel         VARCHAR(50) DEFAULT 'email',
    sent_at         TIMESTAMP DEFAULT NOW(),
    read            BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);


-- =============================================================================
-- CONTRIBUTIONS & FELLOW APPLICATIONS
-- =============================================================================

CREATE TABLE IF NOT EXISTS contributions (
    contribution_id SERIAL PRIMARY KEY,
    resource_id     INT UNIQUE NOT NULL,
    score           NUMERIC(6,2) NOT NULL,
    calculated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_contributions_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE
);

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


-- =============================================================================
-- SEED DATA
-- =============================================================================

-- Roles
INSERT INTO roles (role_id, name, description) VALUES
    (1, 'admin',         'System administrator with full access'),
    (2, 'User',          'Default user with view, rate, and comment access'),
    (3, 'Fellow',        'Fellow who can submit and manage resources'),
    (4, 'SubjectExpert', 'Can review and approve resources in their subject area'),
    (5, 'TeamLead',      'Can review and approve resources across all subjects and manage fellows'),
    (6, 'DSC',           'Director of Science and Technology, oversees all content and user management'),
    (7, 'Secretary',     'Administrative Secretary')
ON CONFLICT (role_id) DO NOTHING;

SELECT setval('roles_role_id_seq', (SELECT MAX(role_id) FROM roles));

-- Subjects
INSERT INTO subjects (subject) VALUES
    ('Computer Science'),
    ('Information Technology'),
    ('Science'),
    ('Engineering'),
    ('Robotics'),
    ('Arts'),
    ('Belizean History'),
    ('Mathematics'),
    ('English Language Arts'),
    ('Social Studies'),
    ('Physical Education')
ON CONFLICT (subject) DO NOTHING;

-- Grade levels
INSERT INTO grade_levels (grade_level) VALUES
    ('Preschool'),
    ('Infant 1'),
    ('Infant 2'),
    ('Standard 1'),
    ('Standard 2'),
    ('Standard 3'),
    ('Standard 4'),
    ('Standard 5'),
    ('Standard 6'),
    ('Mixed')
ON CONFLICT (grade_level) DO NOTHING;

-- Default admin user  (username: admin  /  password: Admin@501steam)
-- !! Change this password immediately after first login !!
INSERT INTO users (username, email, password_hash, role_id, is_active)
VALUES (
    'admin',
    'admin@501steamhub.org',
    '$2a$12$U1/ifgjcl0WtBHk4h8CUDu5vwpKSlu4SNesUdPQKsQ88NvqX7bVSy',
    1,
    TRUE
)
ON CONFLICT (username) DO NOTHING;
