-- DOWN: Remove steam_points column and index from fellows table
DROP INDEX IF EXISTS idx_fellows_steam_points;

ALTER TABLE fellows
DROP COLUMN IF EXISTS steam_points;
