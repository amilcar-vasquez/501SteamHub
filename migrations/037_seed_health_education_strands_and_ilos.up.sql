-- Migration: 037_seed_health_education_strands_and_ilos
-- Description: Seed Health Education strands and sample ILOs
-- Date: 2026-03-30

-- Insert Health Education strands
INSERT INTO strands (subject_id, name) VALUES
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Personal Health, Nutrition, and Disease Prevention'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Environmental Health and Safety'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Social and Emotional Health and Relationships'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Personal Safety and Substance Abuse'),
  ((SELECT id FROM subjects WHERE subject = 'Health Education'), 'Growth, Development, and Mental Well-being')
ON CONFLICT (subject_id, name) DO NOTHING;

-- Insert Health Education ILOs
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
  ),
  -- Infant 2 - Strand 1: Personal Health
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 2'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 1.1.3',
    'Discuss and practice the benefits of regular physical activity and rest.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 2'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 1.1.4',
    'Identify foods that provide energy and promote growth and development.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 2'),
    1,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Safety and Substance Abuse'),
    'HE 1.4.1',
    'Identify trusted adults and understand basic personal safety rules.'
  ),

  -- Standard 1 - Strand 1: Personal Health
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 1'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 2.1.1',
    'Analyze the relationship between nutrition, physical activity, and overall health.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 1'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Environmental Health and Safety'),
    'HE 2.2.1',
    'Develop safe practices in different environments and situations.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 1'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Social and Emotional Health and Relationships'),
    'HE 2.3.1',
    'Build positive relationships and develop healthy communication skills.'
  ),
  -- Standard 2 - Multiple strands
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 2'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 2.1.2',
    'Examine the impact of lifestyle choices on health and wellness.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 2'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Safety and Substance Abuse'),
    'HE 2.4.1',
    'Understand risks and consequences of substance abuse and peer pressure.'
  ),
  -- Standard 3 - Strand 5: Growth and Development
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 3'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Growth, Development, and Mental Well-being'),
    'HE 2.5.1',
    'Understand physical and emotional changes during puberty and adolescence.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 3'),
    2,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Social and Emotional Health and Relationships'),
    'HE 2.3.2',
    'Develop strategies for managing stress and maintaining mental health.'
  ),
  -- Standard 4 - Strand 1: Personal Health
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 4'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 3.1.1',
    'Evaluate dietary patterns and make informed nutritional choices.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 4'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Environmental Health and Safety'),
    'HE 3.2.1',
    'Analyze environmental health hazards and develop prevention strategies.'
  ),
  -- Standard 5 - Strand 4: Personal Safety
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 5'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Safety and Substance Abuse'),
    'HE 3.4.1',
    'Assess risks related to substance use and make responsible decisions.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 5'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Growth, Development, and Mental Well-being'),
    'HE 3.5.1',
    'Apply strategies for promoting sexual health, reproduction, and family planning.'
  ),
  -- Standard 6 - Multiple strands
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 6'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Social and Emotional Health and Relationships'),
    'HE 3.3.1',
    'Demonstrate healthy relationship skills and conflict resolution strategies.'
  ),
  (
    (SELECT id FROM subjects WHERE subject = 'Health Education'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Standard 6'),
    3,
    (SELECT id FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education') AND name = 'Personal Health, Nutrition, and Disease Prevention'),
    'HE 3.1.2',
    'Analyze the relationship between health behaviors and chronic disease prevention.'
  );
