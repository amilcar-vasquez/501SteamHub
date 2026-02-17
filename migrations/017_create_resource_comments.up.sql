-- UP

CREATE TABLE resource_comments (
  comment_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  user_id INT NOT NULL,
  parent_comment_id INT,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resource_comments_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT fk_resource_comments_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_resource_comments_parent FOREIGN KEY (parent_comment_id) REFERENCES resource_comments(comment_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_comments_resource ON resource_comments (resource_id);
CREATE INDEX idx_resource_comments_user ON resource_comments (user_id);
CREATE INDEX idx_resource_comments_parent ON resource_comments (parent_comment_id);

-- Apply update_updated_at_column() trigger (function was created in 004_create_resources)
CREATE TRIGGER resource_comments_updated_at
BEFORE UPDATE ON resource_comments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
