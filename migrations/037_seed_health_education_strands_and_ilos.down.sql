-- Rollback Migration: 037_seed_health_education_strands_and_ilos
-- Description: Remove Health Education strands and ILOs

-- Delete Health Education ILOs
DELETE FROM ilos WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education');

-- Delete Health Education strands
DELETE FROM strands WHERE subject_id = (SELECT id FROM subjects WHERE subject = 'Health Education');
