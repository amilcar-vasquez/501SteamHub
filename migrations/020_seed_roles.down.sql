-- DOWN: Remove seeded roles
DELETE FROM roles WHERE role_id IN (1, 2, 3, 4, 5, 6, 7);
