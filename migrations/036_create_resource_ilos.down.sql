-- Migration: 035_create_resource_ilos (ROLLBACK)
-- Description: Drop resource_ilos junction table

DROP TABLE IF EXISTS resource_ilos CASCADE;
