-- UP

-- Add new columns to resources table
ALTER TABLE resources 
  ADD COLUMN slug VARCHAR(255) UNIQUE,
  ADD COLUMN summary TEXT,
  ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER resources_updated_at
BEFORE UPDATE ON resources
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create resource_subjects junction table (many-to-many)
CREATE TABLE resource_subjects (
  resource_id INT NOT NULL,
  subject subject NOT NULL,
  PRIMARY KEY (resource_id, subject),
  CONSTRAINT fk_resource_subjects_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_subjects_resource ON resource_subjects (resource_id);
CREATE INDEX idx_resource_subjects_subject ON resource_subjects (subject);

-- Create resource_grade_levels junction table (many-to-many)
CREATE TABLE resource_grade_levels (
  resource_id INT NOT NULL,
  grade_level grade_level NOT NULL,
  PRIMARY KEY (resource_id, grade_level),
  CONSTRAINT fk_resource_grade_levels_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_grade_levels_resource ON resource_grade_levels (resource_id);
CREATE INDEX idx_resource_grade_levels_grade ON resource_grade_levels (grade_level);

-- Migrate existing data to junction tables
-- Only migrate rows with valid non-empty enum values using CASE to avoid casting empty strings
INSERT INTO resource_subjects (resource_id, subject)
SELECT resource_id, 
  CASE 
    WHEN subject = 'Computer Science' THEN 'Computer Science'::subject
    WHEN subject = 'Information Technology' THEN 'Information Technology'::subject
    WHEN subject = 'Science' THEN 'Science'::subject
    WHEN subject = 'Engineering' THEN 'Engineering'::subject
    WHEN subject = 'Robotics' THEN 'Robotics'::subject
    WHEN subject = 'Arts' THEN 'Arts'::subject
    WHEN subject = 'Belizean History' THEN 'Belizean History'::subject
    WHEN subject = 'Mathematics' THEN 'Mathematics'::subject
    WHEN subject = 'English Language Arts' THEN 'English Language Arts'::subject
    WHEN subject = 'Social Studies' THEN 'Social Studies'::subject
    WHEN subject = 'Physical Education' THEN 'Physical Education'::subject
  END as subject
FROM resources 
WHERE subject IN ('Computer Science', 'Information Technology', 'Science', 'Engineering', 'Robotics', 'Arts', 'Belizean History', 'Mathematics', 'English Language Arts', 'Social Studies', 'Physical Education');

INSERT INTO resource_grade_levels (resource_id, grade_level)
SELECT resource_id,
  CASE
    WHEN grade_level = 'Preschool' THEN 'Preschool'::grade_level
    WHEN grade_level = 'Infant 1' THEN 'Infant 1'::grade_level
    WHEN grade_level = 'Infant 2' THEN 'Infant 2'::grade_level
    WHEN grade_level = 'Standard 1' THEN 'Standard 1'::grade_level
    WHEN grade_level = 'Standard 2' THEN 'Standard 2'::grade_level
    WHEN grade_level = 'Standard 3' THEN 'Standard 3'::grade_level
    WHEN grade_level = 'Standard 4' THEN 'Standard 4'::grade_level
    WHEN grade_level = 'Standard 5' THEN 'Standard 5'::grade_level
    WHEN grade_level = 'Standard 6' THEN 'Standard 6'::grade_level
    WHEN grade_level = 'Mixed' THEN 'Mixed'::grade_level
  END as grade_level
FROM resources 
WHERE grade_level IN ('Preschool', 'Infant 1', 'Infant 2', 'Standard 1', 'Standard 2', 'Standard 3', 'Standard 4', 'Standard 5', 'Standard 6', 'Mixed');

-- Create lessons table for structured lesson plans
CREATE TABLE lessons (
  lesson_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  lesson_number INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  duration_minutes INT,
  objectives TEXT[],
  materials TEXT[],
  content TEXT NOT NULL,
  assessment TEXT,
  differentiation TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lessons_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT uq_lessons_resource_number UNIQUE (resource_id, lesson_number)
);

CREATE INDEX idx_lessons_resource ON lessons (resource_id);

-- Create lesson_versions table for version control
CREATE TABLE lesson_versions (
  version_id SERIAL PRIMARY KEY,
  lesson_id INT NOT NULL,
  version_number INT NOT NULL,
  content TEXT NOT NULL,
  change_description TEXT,
  changed_by INT NOT NULL,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lesson_versions_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_versions_user FOREIGN KEY (changed_by) REFERENCES users(user_id),
  CONSTRAINT uq_lesson_versions UNIQUE (lesson_id, version_number)
);

CREATE INDEX idx_lesson_versions_lesson ON lesson_versions (lesson_id);
CREATE INDEX idx_lesson_versions_changed_by ON lesson_versions (changed_by);

-- Create resource_comments table
CREATE TABLE resource_comments (
  comment_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  user_id INT NOT NULL,
  parent_comment_id INT,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resource_comments_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT fk_resource_comments_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_resource_comments_parent FOREIGN KEY (parent_comment_id) REFERENCES resource_comments(comment_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_comments_resource ON resource_comments (resource_id);
CREATE INDEX idx_resource_comments_user ON resource_comments (user_id);
CREATE INDEX idx_resource_comments_parent ON resource_comments (parent_comment_id);

CREATE TRIGGER resource_comments_updated_at
BEFORE UPDATE ON resource_comments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Drop old single-value columns from resources (now using junction tables)
ALTER TABLE resources 
  DROP COLUMN subject,
  DROP COLUMN grade_level,
  DROP COLUMN ilo;
