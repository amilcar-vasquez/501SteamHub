-- Rollback Migration: 028_seed_ilo_curriculum
-- Reverses: consolidated curriculum seed data from this migration
-- Note: Reverse order of operations to handle FK dependencies

-- Part 4: Delete Health Education ILOs
DELETE FROM ilos
WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education')
  AND ilo_code LIKE 'HE %';

-- Part 3: Delete all seeded ILOs from the consolidated dataset (629 records)
DELETE FROM ilos
WHERE subject_id IN (
  SELECT id FROM subjects
  WHERE subject IN (
    'Belizean History',
    'Expressive Arts',
    'Language Arts',
    'Mathematics',
    'Physical Education',
    'Science and Technology'
  )
)
AND (
  ilo_code LIKE 'BS %'
  OR ilo_code LIKE 'EA %'
  OR ilo_code LIKE 'LA %'
  OR ilo_code LIKE 'MA %'
  OR ilo_code LIKE 'PE %'
  OR ilo_code LIKE 'SC %'
  OR ilo_code LIKE 'TC %'
);

-- Part 2: Delete all seeded strands
DELETE FROM strands
WHERE name IN (
  'Identity in Belize',
  'Civics Education',
  'African and Maya History',
  'Sustainable Development and Climate Change',
  'Financial Education',
  'Road and Personal Safety',
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
  'Running, Jumping & Throwing',
  'Games with Bats, Balls & Nets',
  'Benefits and Burdens of Science and Technology',
  'Energy Conversions',
  'Changes in an Ecosystem',
  'Energy Resources',
  'Relationships and Communications Plagiarism',
  'Plant Diversity',
  'Heredity and Human Reproduction',
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
