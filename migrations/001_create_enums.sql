-- UP

CREATE TYPE resource_status AS ENUM (
  'Draft',
  'Submitted',
  'UnderReview',
  'Rejected',
  'Approved',
  'DesignCurate',
  'Published',
  'Indexed',
  'Archived'
);

CREATE TYPE resource_category AS ENUM (
  'LessonPlan',
  'Video',
  'Slideshow',
  'Assessment',
  'Other'
);

CREATE TYPE user_role AS ENUM (
  'Teacher',
  'STEAMFellow',
  'ContentExpert',
  'TeamLead',
  'Administrator',
  'SystemAdmin',
  'MinistryPersonnel'
);

CREATE TYPE review_decision AS ENUM (
  'Approved',
  'Rejected'
);

-- DOWN

-- Drop in reverse order of creation to avoid dependency issues
DROP TYPE IF EXISTS review_decision;
DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS resource_category;
DROP TYPE IF EXISTS resource_status;
