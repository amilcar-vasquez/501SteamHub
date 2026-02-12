-- UP

CREATE TABLE resource_reviews (
  review_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  reviewer_id INT NOT NULL,
  reviewer_role user_role NOT NULL,
  decision review_decision NOT NULL,
  comment_summary TEXT,
  reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rr_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(user_id),
  CONSTRAINT chk_reviewer_role_allowed CHECK (reviewer_role IN ('ContentExpert', 'TeamLead')),
  CONSTRAINT uniq_resource_review_role UNIQUE (resource_id, reviewer_role)
);

CREATE INDEX idx_resource_reviews_resource_id ON resource_reviews (resource_id);

-- DOWN

DROP INDEX IF EXISTS idx_resource_reviews_resource_id;
DROP TABLE IF EXISTS resource_reviews;
