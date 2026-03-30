-- UP: Create cycles table and seed with cycle 1-4
-- Cycles represent the four cycles of the school year

CREATE TABLE IF NOT EXISTS cycles (
    id SERIAL PRIMARY KEY,
    cycle_number INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed cycles 1, 2, 3, 4
INSERT INTO cycles (id, cycle_number) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4)
ON CONFLICT (cycle_number) DO NOTHING;

-- Reset sequence to avoid conflicts with manually inserted IDs
SELECT setval('cycles_id_seq', (SELECT MAX(id) FROM cycles));
