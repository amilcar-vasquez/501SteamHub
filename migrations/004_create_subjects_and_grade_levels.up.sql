-- UP: Subject and grade_level lookup tables
CREATE TABLE IF NOT EXISTS subjects (
    subject VARCHAR(150) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS grade_levels (
    grade_level VARCHAR(50) PRIMARY KEY
);
