-- DOWN: Revert fellows table back to teachers

-- Step 1: Restore block type 'fellow_notes' -> 'teacher_notes' and
--         visibility value 'fellow' -> 'teacher' in lessons JSON content
UPDATE lesson_versions
SET content = regexp_replace(
    regexp_replace(
        content,
        '"type"\s*:\s*"fellow_notes"',
        '"type":"teacher_notes"',
        'g'
    ),
    '"visibility"\s*:\s*"fellow"',
    '"visibility":"teacher"',
    'g'
)
WHERE content LIKE '%fellow_notes%' OR content LIKE '%"visibility":"fellow"%' OR content LIKE '%"visibility": "fellow"%';

UPDATE lessons
SET content = regexp_replace(
    regexp_replace(
        content,
        '"type"\s*:\s*"fellow_notes"',
        '"type":"teacher_notes"',
        'g'
    ),
    '"visibility"\s*:\s*"fellow"',
    '"visibility":"teacher"',
    'g'
)
WHERE content LIKE '%fellow_notes%' OR content LIKE '%"visibility":"fellow"%' OR content LIKE '%"visibility": "fellow"%';

-- Step 2: Restore sequences
ALTER SEQUENCE fellows_fellow_id_seq RENAME TO teachers_teacher_id_seq;

-- Step 3: Restore constraints
ALTER TABLE fellows RENAME CONSTRAINT fellows_pkey TO teachers_pkey;
ALTER TABLE fellows RENAME CONSTRAINT fk_fellows_user TO fk_teachers_user;

-- Step 4: Restore column name
ALTER TABLE fellows RENAME COLUMN fellow_id TO teacher_id;

-- Step 5: Restore table name
ALTER TABLE fellows RENAME TO teachers;
