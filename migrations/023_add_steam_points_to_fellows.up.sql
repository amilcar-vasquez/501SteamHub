-- UP: Add 501_steam_points column to fellows table for FR-27 contribution valuation
-- Stores cumulative STEAM Points earned by fellows through contribution submissions
ALTER TABLE fellows
ADD COLUMN steam_points NUMERIC(10, 2) DEFAULT 0.0;

-- Create index for potentially querying/sorting by points
CREATE INDEX idx_fellows_steam_points ON fellows (steam_points DESC);
