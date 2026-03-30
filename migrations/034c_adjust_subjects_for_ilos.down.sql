-- Migration: 034c_adjust_subjects_for_ilos (ROLLBACK)
-- Description: Revert subject name changes and remove Health Education

UPDATE subjects SET subject = 'Science' WHERE subject = 'Science and Technology';
UPDATE subjects SET subject = 'Arts' WHERE subject = 'Expressive Arts';
UPDATE subjects SET subject = 'English Language Arts' WHERE subject = 'Language Arts';

DELETE FROM subjects WHERE subject = 'Health Education';
