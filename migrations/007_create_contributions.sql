-- UP

CREATE TABLE contributions (
  contribution_id SERIAL PRIMARY KEY,
  resource_id INT UNIQUE NOT NULL,
  score NUMERIC(6,2) NOT NULL,
  calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contributions_resource FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE
);

-- DOWN

DROP TABLE IF EXISTS contributions;
