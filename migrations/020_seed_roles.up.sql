-- UP: Seed application roles
INSERT INTO roles (role_id, name, description) VALUES
    (1, 'admin',         'System administrator with full access'),
    (2, 'User',          'Default user with view, rate, and comment access'),
    (3, 'Fellow',        'Fellow who can submit and manage resources'),
    (4, 'SubjectExpert', 'Can review and approve resources in their subject area'),
    (5, 'TeamLead',      'Can review and approve resources across all subjects and manage fellows'),
    (6, 'DSC',           'Director of Science and Technology, oversees all content and user management'),
    (7, 'Secretary',     'Administrative Secretary')
ON CONFLICT (role_id) DO NOTHING;

-- Ensure the sequence is ahead of the seeded IDs
SELECT setval('roles_role_id_seq', (SELECT MAX(role_id) FROM roles));
