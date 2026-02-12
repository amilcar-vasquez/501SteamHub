-- UP

CREATE TABLE IF NOT EXISTS resource_access (
  access_id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  user_id INT NOT NULL,
  accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ra_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
  CONSTRAINT fk_ra_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_resource_access_resource_id ON resource_access (resource_id);
