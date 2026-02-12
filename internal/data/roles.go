//filename: internal/data/roles.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type Role struct {
	ID          int64  `json:"role_id"`
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
}

type RoleModel struct {
	DB *sql.DB
}

// Insert a new role into the database
func (m RoleModel) Insert(role *Role) error {
	query := `
		INSERT INTO roles (name, description)
		VALUES ($1, $2)
		RETURNING role_id`

	args := []any{role.Name, role.Description}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&role.ID)
}

// Get a role by ID
func (m RoleModel) Get(id int64) (*Role, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT role_id, name, description
		FROM roles
		WHERE role_id = $1`

	var role Role

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&role.ID,
		&role.Name,
		&role.Description,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &role, nil
}

// Get a role by name
func (m RoleModel) GetByName(name string) (*Role, error) {
	query := `
		SELECT role_id, name, description
		FROM roles
		WHERE name = $1`

	var role Role

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, name).Scan(
		&role.ID,
		&role.Name,
		&role.Description,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &role, nil
}

// Get all roles
func (m RoleModel) GetAll() ([]*Role, error) {
	query := `
		SELECT role_id, name, description
		FROM roles
		ORDER BY role_id`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	roles := []*Role{}

	for rows.Next() {
		var role Role
		err := rows.Scan(
			&role.ID,
			&role.Name,
			&role.Description,
		)
		if err != nil {
			return nil, err
		}
		roles = append(roles, &role)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return roles, nil
}

// Update a role
func (m RoleModel) Update(role *Role) error {
	query := `
		UPDATE roles
		SET name = $1, description = $2
		WHERE role_id = $3
		RETURNING role_id`

	args := []any{
		role.Name,
		role.Description,
		role.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&role.ID)
	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return ErrRecordNotFound
		default:
			return err
		}
	}

	return nil
}

// Delete a role
func (m RoleModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM roles
		WHERE role_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}
