-- UP: Complete the primary key migration for subjects and grade_levels
-- Drop old VARCHAR PKs and make id (INT) the new PRIMARY KEY
-- This is the critical step - all dependent references have been updated in previous migrations
-- Uses exception handling for operations that might have already been done

DO $$
BEGIN
    -- For subjects table
    -- Try to drop old PK first
    BEGIN
        ALTER TABLE subjects 
        DROP CONSTRAINT subjects_pkey;
    EXCEPTION WHEN undefined_object THEN
        -- Constraint doesn't exist, continue
        NULL;
    END;
    
    -- Make id the primary key if it isn't already
    BEGIN
        ALTER TABLE subjects 
        ADD PRIMARY KEY (id);
    EXCEPTION WHEN duplicate_object THEN
        -- PK already exists
        NULL;
    END;
    
    -- Add UNIQUE constraint on subject varchar for lookups
    BEGIN
        ALTER TABLE subjects 
        ADD CONSTRAINT subjects_subject_unique UNIQUE (subject);
    EXCEPTION WHEN duplicate_object THEN
        -- Constraint already exists
        NULL;
    END;
    
    -- For grade_levels table
    -- Try to drop old PK first
    BEGIN
        ALTER TABLE grade_levels 
        DROP CONSTRAINT grade_levels_pkey;
    EXCEPTION WHEN undefined_object THEN
        -- Constraint doesn't exist, continue
        NULL;
    END;
    
    -- Make id the primary key if it isn't already
    BEGIN
        ALTER TABLE grade_levels 
        ADD PRIMARY KEY (id);
    EXCEPTION WHEN duplicate_object THEN
        -- PK already exists
        NULL;
    END;
    
    -- Add UNIQUE constraint on grade_level varchar for lookups
    BEGIN
        ALTER TABLE grade_levels 
        ADD CONSTRAINT grade_levels_grade_level_unique UNIQUE (grade_level);
    EXCEPTION WHEN duplicate_object THEN
        -- Constraint already exists
        NULL;
    END;
    
END $$;
