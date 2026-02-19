-- UP

CREATE TABLE IF NOT EXISTS resource_status_history (
  history_id  SERIAL PRIMARY KEY,
  resource_id INT NOT NULL,
  old_status  resource_status,
  new_status  resource_status NOT NULL,
  changed_by  INT,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_rsh_resource
    FOREIGN KEY (resource_id)
    REFERENCES resources(resource_id) ON DELETE CASCADE
);

CREATE INDEX idx_resource_status_history_resource
  ON resource_status_history(resource_id);
