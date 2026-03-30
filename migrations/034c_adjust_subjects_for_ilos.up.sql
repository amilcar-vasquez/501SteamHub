-- Migration: 034c_adjust_subjects_for_ilos
-- Description: Rename subjects to match ILO curriculum names and add Health Education
-- Date: 2026-03-30

UPDATE subjects SET subject = 'Science and Technology' WHERE subject = 'Science';
UPDATE subjects SET subject = 'Expressive Arts' WHERE subject = 'Arts';
UPDATE subjects SET subject = 'Language Arts' WHERE subject = 'English Language Arts';

INSERT INTO subjects (subject) VALUES
  ('Health Education')
ON CONFLICT (subject) DO NOTHING;
