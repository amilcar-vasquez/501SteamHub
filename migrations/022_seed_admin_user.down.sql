-- DOWN: Remove the seeded admin user
DELETE FROM users WHERE username = 'admin' AND email = 'admin@501steamhub.org';
