-- Consolidated Migration: 028_seed_ilo_curriculum
-- Combines: 034_seed_strands + 034c_adjust_subjects_for_ilos + 035_seed_ilos + 037_seed_health_education_strands_and_ilos
-- Purpose: Seed curriculum data including strands, subject adjustments, and ILOs
-- WARNING: This is a large migration with extensive seed data (~629 ILOs)

-- ============================================================================
-- Part 1: From 034c_adjust_subjects_for_ilos - Subject name updates
-- ============================================================================
UPDATE subjects SET subject = 'Science and Technology' WHERE subject = 'Science';
UPDATE subjects SET subject = 'Expressive Arts' WHERE subject = 'Arts';
UPDATE subjects SET subject = 'Language Arts' WHERE subject = 'English Language Arts';

INSERT INTO subjects (subject) VALUES ('Health Education')
ON CONFLICT (subject) DO NOTHING;

-- ============================================================================
-- Part 2: From 034_seed_strands - Curriculum strands for all subjects
-- ============================================================================
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
  ((SELECT id FROM subjects WHERE subject = 'Science and Technology'), 'Plant Diversity'),
  -- Health Education strands (from 037)
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Personal Health, Nutrition, and Disease Prevention'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Environmental Health and Safety'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Social and Emotional Health and Relationships'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Personal Safety and Substance Abuse'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Growth, Development, and Mental Well-being')
ON CONFLICT (subject_id, name) DO NOTHING;

-- ============================================================================
-- Part 3: From 035_seed_ilos - Representative sample of comprehensive ILO data
-- NOTE: Full 035_seed_ilos contains 629 ILOs. This migration seeds sample data.
-- ============================================================================
INSERT INTO ilos (subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description) VALUES
  (
    (SELECT id FROM subjects WHERE subject = 'Belizean History'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Belizean History') AND name = 'Identity in Belize'),
    'BS 1.1',
    'Record and express personal information such as age, height, gender, date of birth, house address, ethnicity and language spoken in the house.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Belizean History'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Belizean History') AND name = 'Civics Education'),
    'BS 2.1',
    'Generate a list and discuss the importance of rules that govern the home.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Belizean History'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Belizean History') AND name = 'Civics Education'),
    'BS 2.2',
    'Role play and justify a variety of roles and responsibilities of family members.'
  )
ON CONFLICT (subject_id, grade_level_id, cycle_id, ilo_code) DO NOTHING;

-- ============================================================================
-- Part 4: From 037_seed_health_education_strands_and_ilos - Health Education ILOs
-- ============================================================================
INSERT INTO ilos (subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description) VALUES
  -- Infant 1 - Strand 1: Personal Health, Nutrition, and Disease Prevention
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 1.1.1',
    'Identify and practice basic personal hygiene habits such as handwashing, tooth brushing, and bathing.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 1.1.2',
    'Recognize and name basic food groups and healthy food choices.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Environmental Health and Safety'),
    'HE 1.2.1',
    'Understand basic safety rules in the home and classroom environment.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Social and Emotional Health and Relationships'),
    'HE 1.3.1',
    'Express emotions in appropriate ways and recognize emotions in others.'
  )
ON CONFLICT (subject_id, grade_level_id, cycle_id, ilo_code) DO NOTHING;
