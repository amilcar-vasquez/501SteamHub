-- UP

-- Create subjects lookup table
CREATE TABLE subjects (
  subject VARCHAR(150) PRIMARY KEY
);

-- Seed valid subjects
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
  ('Physical Education');

-- Create grade_levels lookup table
CREATE TABLE grade_levels (
  grade_level VARCHAR(50) PRIMARY KEY
);

-- Seed valid grade levels
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
  ('Mixed');
