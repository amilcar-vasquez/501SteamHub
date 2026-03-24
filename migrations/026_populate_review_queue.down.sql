-- DOWN: Revert review queue population
-- This migration reverts the status changes made in the up migration.

BEGIN;

-- Revert Submitted resources back to Draft (first 3)
UPDATE resources 
SET status = 'Draft'
WHERE status = 'Submitted'
LIMIT 3;

-- Revert UnderReview resources back to Approved (2)
UPDATE resources 
SET status = 'Approved'
WHERE status = 'UnderReview'
LIMIT 2;

-- Revert NeedsRevision resources back to Draft (1)
UPDATE resources 
SET status = 'Draft'
WHERE status = 'NeedsRevision'
LIMIT 1;

COMMIT;
