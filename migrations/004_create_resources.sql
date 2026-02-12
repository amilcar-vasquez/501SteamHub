-- UP

CREATE TABLE resources (
  resource_id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category resource_category NOT NULL,
  subject VARCHAR(150) NOT NULL,
  grade_level VARCHAR(50) NOT NULL,
  ilo TEXT NOT NULL,
  drive_link TEXT,
  status resource_status NOT NULL DEFAULT 'Draft',
  published_url TEXT,
  contributor_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resources_contributor FOREIGN KEY (contributor_id) REFERENCES users(user_id),
  CONSTRAINT chk_published_url_required CHECK (
    status NOT IN ('Published', 'Indexed', 'Archived') OR published_url IS NOT NULL
  )
);

CREATE INDEX idx_resources_status ON resources (status);
CREATE INDEX idx_resources_subject ON resources (subject);
CREATE INDEX idx_resources_grade_level ON resources (grade_level);
CREATE INDEX idx_resources_contributor_id ON resources (contributor_id);

-- DOWN

DROP INDEX IF EXISTS idx_resources_contributor_id;
DROP INDEX IF EXISTS idx_resources_grade_level;
DROP INDEX IF EXISTS idx_resources_subject;
DROP INDEX IF EXISTS idx_resources_status;
DROP TABLE IF EXISTS resources;
