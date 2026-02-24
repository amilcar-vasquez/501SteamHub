-- UP: Rename teachers table to fellows and update all related naming

-- Step 1: Rename the table
ALTER TABLE teachers RENAME TO fellows;

-- Step 2: Rename the primary key column
ALTER TABLE fellows RENAME COLUMN teacher_id TO fellow_id;

-- Step 3: Rename the foreign key constraint
ALTER TABLE fellows RENAME CONSTRAINT fk_teachers_user TO fk_fellows_user;

-- Step 4: Rename the primary key constraint (if it was auto-named)
-- PostgreSQL auto-names primary key constraints as <table>_pkey
ALTER TABLE fellows RENAME CONSTRAINT teachers_pkey TO fellows_pkey;

-- Step 5: Update any sequences that referenced the old table name
-- (PostgreSQL sequences from SERIAL are named <table>_<column>_seq)
ALTER SEQUENCE teachers_teacher_id_seq RENAME TO fellows_fellow_id_seq;

-- Step 6: Update block type 'teacher_notes' -> 'fellow_notes' and
--         visibility value 'teacher' -> 'fellow' in lessons JSON content
UPDATE lessons
SET content = regexp_replace(
    regexp_replace(
        content,
        '"type"\s*:\s*"teacher_notes"',
        '"type":"fellow_notes"',
        'g'
    ),
    '"visibility"\s*:\s*"teacher"',
    '"visibility":"fellow"',
    'g'
)
WHERE content LIKE '%teacher_notes%' OR content LIKE '%"visibility":"teacher"%' OR content LIKE '%"visibility": "teacher"%';

-- Step 7: Same update for lesson_versions content
UPDATE lesson_versions
SET content = regexp_replace(
    regexp_replace(
        content,
        '"type"\s*:\s*"teacher_notes"',
        '"type":"fellow_notes"',
        'g'
    ),
    '"visibility"\s*:\s*"teacher"',
    '"visibility":"fellow"',
    'g'
)
WHERE content LIKE '%teacher_notes%' OR content LIKE '%"visibility":"teacher"%' OR content LIKE '%"visibility": "teacher"%';
