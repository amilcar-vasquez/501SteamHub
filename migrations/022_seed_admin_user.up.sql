-- UP: Seed default admin user
-- Default credentials:  username: admin   password: Admin@501steam
-- Change the password immediately after first login.
--
-- The password_hash below is a bcrypt cost-12 hash of "Admin@501steam".
-- Generated with: bcrypt.GenerateFromPassword([]byte("Admin@501steam"), 12)

INSERT INTO users (username, email, password_hash, role_id, is_active)
VALUES (
    'admin',
    'admin@501steamhub.org',
    '$2a$12$U1/ifgjcl0WtBHk4h8CUDu5vwpKSlu4SNesUdPQKsQ88NvqX7bVSy',
    1,      -- role_id 1 = admin (seeded in 020_seed_roles)
    TRUE
)
ON CONFLICT (username) DO NOTHING;
