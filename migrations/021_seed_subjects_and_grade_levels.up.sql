-- UP: Seed subjects and grade levels lookup data

INSERT INTO subjects (subject) VALUES
    ('Computer Science'),
    ('Information Technology'),
    ('Science'),
    ('Engineering'),
    ('Robotics'),
    ('Arts'),
    ('Belizean History'),
    ('Mathematics'),
    ('English Language Arts'),
    ('Social Studies'),
    ('Physical Education')
ON CONFLICT (subject) DO NOTHING;

INSERT INTO grade_levels (grade_level) VALUES
    ('Preschool'),
    ('Infant 1'),
    ('Infant 2'),
    ('Standard 1'),
    ('Standard 2'),
    ('Standard 3'),
    ('Standard 4'),
    ('Standard 5'),
    ('Standard 6'),
    ('Mixed')
ON CONFLICT (grade_level) DO NOTHING;
