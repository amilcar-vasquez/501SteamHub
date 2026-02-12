-- UP

CREATE TABLE teachers (
  teacher_id SERIAL PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  moe_identifier VARCHAR(50) UNIQUE NOT NULL,
  school VARCHAR(150),
  subject_specialization VARCHAR(100),
  district VARCHAR(100),
  CONSTRAINT fk_teachers_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- DOWN

DROP TABLE IF EXISTS teachers;
