-- Migration: 035_create_resource_ilos
-- Description: Create junction table to link resources to ILOs
-- Date: 2026-03-30

CREATE TABLE IF NOT EXISTS resource_ilos (
  id SERIAL PRIMARY KEY,
  resource_id INT NOT NULL REFERENCES resources(resource_id) ON DELETE CASCADE,
  ilo_id INT NOT NULL REFERENCES ilos(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(resource_id, ilo_id)
);

CREATE INDEX IF NOT EXISTS idx_resource_ilos_resource_id ON resource_ilos(resource_id);
CREATE INDEX IF NOT EXISTS idx_resource_ilos_ilo_id ON resource_ilos(ilo_id);
