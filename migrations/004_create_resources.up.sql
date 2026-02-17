-- UP

-- Create trigger function for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS resources (
  resource_id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE,
  summary TEXT,
  category resource_category NOT NULL,
  subject VARCHAR(150) NOT NULL,
  grade_level VARCHAR(50) NOT NULL,
  ilo TEXT NOT NULL,
  drive_link TEXT,
  status resource_status NOT NULL DEFAULT 'Draft',
  published_url TEXT,
  contributor_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resources_contributor FOREIGN KEY (contributor_id) REFERENCES users(user_id),
  CONSTRAINT chk_published_url_required CHECK (
    status NOT IN ('Published', 'Indexed', 'Archived') OR published_url IS NOT NULL
  )
);

CREATE INDEX idx_resources_status ON resources (status);
CREATE INDEX idx_resources_subject ON resources (subject);
CREATE INDEX idx_resources_grade_level ON resources (grade_level);
CREATE INDEX idx_resources_contributor_id ON resources (contributor_id);

-- Create trigger to auto-update updated_at
CREATE TRIGGER resources_updated_at
BEFORE UPDATE ON resources
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
