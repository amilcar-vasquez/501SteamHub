-- UP

CREATE TABLE IF NOT EXISTS resource_reviews (
  review_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  reviewer_id INT NOT NULL,
  reviewer_role_id INT NOT NULL,
  decision review_decision NOT NULL,
  comment_summary TEXT,
  reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rr_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(user_id),
  CONSTRAINT fk_rr_reviewer_role FOREIGN KEY (reviewer_role_id) REFERENCES roles(role_id),
  CONSTRAINT uniq_resource_review_role UNIQUE (resource_id, reviewer_role_id)
);

CREATE INDEX idx_resource_reviews_resource_id ON resource_reviews (resource_id);
