-- DOWN

-- Recreate the original columns
ALTER TABLE resources 
  ADD COLUMN subject VARCHAR(150),
  ADD COLUMN grade_level VARCHAR(50),
  ADD COLUMN ilo TEXT;

-- Recreate indexes
CREATE INDEX idx_resources_subject ON resources (subject);
CREATE INDEX idx_resources_grade_level ON resources (grade_level);

-- Migrate data back from junction tables to single-value columns
-- Note: This will only restore the first subject/grade_level for each resource
-- if there were multiple values (data loss is expected on downgrade)
UPDATE resources r
SET subject = (
  SELECT rs.subject 
  FROM resource_subjects rs 
  WHERE rs.resource_id = r.resource_id 
  LIMIT 1
);

UPDATE resources r
SET grade_level = (
  SELECT rgl.grade_level 
  FROM resource_grade_levels rgl 
  WHERE rgl.resource_id = r.resource_id 
  LIMIT 1
);
