-- UP

-- Create grade_level enum with Belize-specific grade levels
CREATE TYPE grade_level AS ENUM (
  'Preschool',
  'Infant 1',
  'Infant 2',
  'Standard 1',
  'Standard 2',
  'Standard 3',
  'Standard 4',
  'Standard 5',
  'Standard 6',
  'Mixed'
);

-- Alter resources table to use the enum
-- First, we need to convert existing data (if any) to match the enum values
-- For safety, we'll drop and recreate the column since this is early in development
ALTER TABLE resources 
  ALTER COLUMN grade_level TYPE grade_level USING grade_level::grade_level;
