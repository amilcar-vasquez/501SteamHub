-- Add slugs to existing resources that don't have them
-- This uses the resource title and a short hash to generate unique slugs

DO $$
DECLARE
    resource_record RECORD;
    base_slug TEXT;
    final_slug TEXT;
    short_hash TEXT;
    attempt INT;
BEGIN
    -- Loop through all resources without slugs
    FOR resource_record IN 
        SELECT resource_id, title 
        FROM resources 
        WHERE slug IS NULL
    LOOP
        -- Generate base slug from title
        base_slug := LOWER(REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(resource_record.title, '[^a-zA-Z0-9\s-]', '', 'g'),
                '\s+', '-', 'g'
            ),
            '-+', '-', 'g'
        ));
        
        -- Trim hyphens from start and end
        base_slug := TRIM(BOTH '-' FROM base_slug);
        
        -- Limit length to 100 characters
        IF LENGTH(base_slug) > 100 THEN
            base_slug := SUBSTRING(base_slug FROM 1 FOR 100);
            base_slug := TRIM(BOTH '-' FROM base_slug);
        END IF;
        
        -- Generate short hash from resource_id
        short_hash := SUBSTRING(MD5(resource_record.resource_id::TEXT) FROM 1 FOR 8);
        
        -- Combine base slug with hash
        final_slug := base_slug || '-' || short_hash;
        
        -- Ensure uniqueness (try up to 10 times with different hashes)
        attempt := 0;
        WHILE EXISTS (SELECT 1 FROM resources WHERE slug = final_slug) AND attempt < 10 LOOP
            attempt := attempt + 1;
            short_hash := SUBSTRING(MD5(resource_record.resource_id::TEXT || attempt::TEXT) FROM 1 FOR 8);
            final_slug := base_slug || '-' || short_hash;
        END LOOP;
        
        -- Update the resource with the generated slug
        UPDATE resources 
        SET slug = final_slug 
        WHERE resource_id = resource_record.resource_id;
        
        RAISE NOTICE 'Generated slug for resource %: %', resource_record.resource_id, final_slug;
    END LOOP;
END $$;
