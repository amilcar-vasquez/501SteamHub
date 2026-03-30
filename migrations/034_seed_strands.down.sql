-- Migration: 034a_seed_strands (ROLLBACK)
-- Description: Remove seeded strand definitions

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
  'Plant Diversity'
);
