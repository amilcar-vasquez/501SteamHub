-- Seed default roles for the application
INSERT INTO roles (role_id, name, description) VALUES
(1, 'admin', 'System administrator with full access'),
(2, 'User', 'Default user with view, rate, and comment access'),
(3, 'Fellow', 'Fellow user who can submit and manage resources'),
(4, 'CEO', 'Chief Executive Officer'),
(5, 'DEC', 'Director of Educational Content'),
(6, 'TSC', 'Teacher Success Coach'),
(7, 'Secretary', 'Administrative Secretary')
ON CONFLICT (role_id) DO NOTHING;

-- Reset the sequence to start after the seeded roles
SELECT setval('roles_role_id_seq', (SELECT MAX(role_id) FROM roles));
