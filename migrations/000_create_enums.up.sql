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

CREATE TYPE review_decision AS ENUM (
  'Approved',
  'Rejected'
);
