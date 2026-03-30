-- Migration: 034a_seed_strands
-- Description: Seed strand definitions for ILOs
-- Date: 2026-03-30

INSERT INTO strands (subject_id, name) VALUES
  ((SELECT id FROM subjects WHERE subject = 'Belizean History'), 'Identity in Belize'),
  ((SELECT id FROM subjects WHERE subject = 'Belizean History'), 'Civics Education'),
  ((SELECT id FROM subjects WHERE subject = 'Belizean History'), 'African and Maya History'),
  ((SELECT id FROM subjects WHERE subject = 'Expressive Arts'), 'Dance and Drama'),
  ((SELECT id FROM subjects WHERE subject = 'Expressive Arts'), 'Music'),
  ((SELECT id FROM subjects WHERE subject = 'Expressive Arts'), 'Creative Art Forms'),
  ((SELECT id FROM subjects WHERE subject = 'Expressive Arts'), 'Three-Dimensional Art'),
  ((SELECT id FROM subjects WHERE subject = 'Language Arts'), 'Reading Fluency & Accuracy'),
  ((SELECT id FROM subjects WHERE subject = 'Language Arts'), 'Comprehension'),
  ((SELECT id FROM subjects WHERE subject = 'Language Arts'), 'Production'),
  ((SELECT id FROM subjects WHERE subject = 'Language Arts'), 'Language Structure'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Numbers & Number Operations'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Patterns'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Addition & Subtraction'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Multiplication & Division'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Fraction and Decimals'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Geometry'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Measurement'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Sets'),
  ((SELECT id FROM subjects WHERE subject = 'Mathematics'), 'Data'),
  ((SELECT id FROM subjects WHERE subject = 'Physical Education'), 'Body Skills & Fitness'),
  ((SELECT id FROM subjects WHERE subject = 'Physical Education'), 'Football'),
  ((SELECT id FROM subjects WHERE subject = 'Science and Technology'), 'Energy Resources'),
  ((SELECT id FROM subjects WHERE subject = 'Science and Technology'), 'Relationships and Communications Plagiarism'),
  ((SELECT id FROM subjects WHERE subject = 'Science and Technology'), 'Plant Diversity')
ON CONFLICT (subject_id, name) DO NOTHING;
