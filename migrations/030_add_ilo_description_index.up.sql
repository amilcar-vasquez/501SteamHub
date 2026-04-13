-- Migration: 030_add_ilo_description_index
-- Description: Add index on ilos.description for improved keyword search performance
-- Date: 2026-03-30

-- Create B-tree index for description (efficient for ILIKE searches)
CREATE INDEX IF NOT EXISTS idx_ilos_description ON ilos (description);
