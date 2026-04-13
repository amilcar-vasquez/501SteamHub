-- UP: Populate review queue with resources in review-pending statuses
-- Migration: 031_populate_test_data
-- This migration transitions some existing resources to review-pending statuses
-- so the Reviewer Dashboard can function and display sample data.

BEGIN;

-- Update 3 Draft resources to Submitted status for review queue
UPDATE resources 
SET status = 'Submitted'
WHERE resource_id IN (
  SELECT resource_id FROM resources WHERE status = 'Draft' LIMIT 3
);

-- Update 2 existing resources to UnderReview status
UPDATE resources 
SET status = 'UnderReview'
WHERE resource_id IN (
  SELECT resource_id FROM resources WHERE status = 'Approved' LIMIT 2
);

-- Update 1 Draft resource to NeedsRevision status for testing
UPDATE resources 
SET status = 'NeedsRevision'
WHERE resource_id IN (
  SELECT resource_id FROM resources WHERE status = 'Draft' LIMIT 1
);

COMMIT;
