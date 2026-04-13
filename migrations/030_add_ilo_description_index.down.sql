-- Rollback Migration: 030_add_ilo_description_index
-- Description: Drop description index

DROP INDEX IF EXISTS idx_ilos_description;
