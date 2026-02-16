-- UP

-- Create subject enum with Belize-specific subjects
CREATE TYPE subject AS ENUM (
  'Computer Science',
  'Information Technology',
  'Science',
  'Engineering',
  'Robotics',
  'Arts',
  'Belizean History',
  'Mathematics',
  'English Language Arts',
  'Social Studies',
  'Physical Education'
);

-- Alter resources table to use the enum
ALTER TABLE resources 
  ALTER COLUMN subject TYPE subject USING subject::subject;
