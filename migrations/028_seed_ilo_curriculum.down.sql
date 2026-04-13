-- Rollback Migration: 028_seed_ilo_curriculum
-- Reverses: 034_seed_strands + 034c_adjust_subjects_for_ilos + 035_seed_ilos + 037_seed_health_education_strands_and_ilos
-- Note: Reverse order of operations to handle FK dependencies

-- Part 4: Delete Health Education ILOs (from 037)
DELETE FROM ilos 
WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education')
  AND ilo_code LIKE 'HE %';

-- Part 3: Delete all other seeded ILOs (from 035)
DELETE FROM ilos 
WHERE ilo_code IN (
  'BS 1.1', 'BS 1.2', 'BS 1.4', 'BS 1.5', 'BS 1.6', 'BS 1.7', 'BS 1.8', 'BS 1.9', 'BS 1.10',
  'BS 1.11', 'BS 1.12', 'BS 1.13', 'BS 1.14', 'BS 1.15', 'BS 1.16', 'BS 1.17', 'BS 1.18', 'BS 1.19'
);

-- Part 2: Delete all seeded strands (from 034 and 037)
DELETE FROM strands 
WHERE name IN (
  'Identity in Belize',
  'Civics Education',
  'African and Maya History',
  'Dance and Drama',
  'Music',
  'Creative Art Forms',
  'Three-Dimensional Art',
  'Reading Fluency & Accuracy',
  'Comprehension',
  'Production',
  'Language Structure',
  'Numbers & Number Operations',
  'Patterns',
  'Addition & Subtraction',
  'Multiplication & Division',
  'Fraction and Decimals',
  'Geometry',
  'Measurement',
  'Sets',
  'Data',
  'Body Skills & Fitness',
  'Football',
  'Energy Resources',
  'Relationships and Communications Plagiarism',
  'Plant Diversity',
  'Personal Health, Nutrition, and Disease Prevention',
  'Environmental Health and Safety',
  'Social and Emotional Health and Relationships',
  'Personal Safety and Substance Abuse',
  'Growth, Development, and Mental Well-being'
);

-- Part 1: Revert subject changes and remove Health Education (from 034c)
UPDATE subjects SET subject = 'Science' WHERE subject = 'Science and Technology';
UPDATE subjects SET subject = 'Arts' WHERE subject = 'Expressive Arts';
UPDATE subjects SET subject = 'English Language Arts' WHERE subject = 'Language Arts';

DELETE FROM subjects WHERE subject = 'Health Education';
