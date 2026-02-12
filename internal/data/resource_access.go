//filename: internal/data/resource_access.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type ResourceAccess struct {
	ID         int64     `json:"access_id"`
	ResourceID int64     `json:"resource_id"`
	UserID     int64     `json:"user_id"`
	AccessedAt time.Time `json:"accessed_at"`
}

type ResourceAccessModel struct {
	DB *sql.DB
}

// Insert a new resource access record into the database
func (m ResourceAccessModel) Insert(access *ResourceAccess) error {
	query := `
		INSERT INTO resource_access (resource_id, user_id)
		VALUES ($1, $2)
		RETURNING access_id, accessed_at`

	args := []any{
		access.ResourceID,
		access.UserID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&access.ID, &access.AccessedAt)
}

// Get a resource access record by ID
func (m ResourceAccessModel) Get(id int64) (*ResourceAccess, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT access_id, resource_id, user_id, accessed_at
		FROM resource_access
		WHERE access_id = $1`

	var access ResourceAccess

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&access.ID,
		&access.ResourceID,
		&access.UserID,
		&access.AccessedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &access, nil
}

// Get all access records for a specific resource
func (m ResourceAccessModel) GetByResourceID(resourceID int64, filters Filters) ([]*ResourceAccess, Metadata, error) {
	query := `
		SELECT COUNT(*) OVER(), access_id, resource_id, user_id, accessed_at
		FROM resource_access
		WHERE resource_id = $1
		ORDER BY accessed_at DESC
		LIMIT $2 OFFSET $3`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{resourceID, filters.limit(), filters.offset()}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, Metadata{}, err
	}
	defer rows.Close()

	totalRecords := 0
	accessRecords := []*ResourceAccess{}

	for rows.Next() {
		var access ResourceAccess
		err := rows.Scan(
			&totalRecords,
			&access.ID,
			&access.ResourceID,
			&access.UserID,
			&access.AccessedAt,
		)
		if err != nil {
			return nil, Metadata{}, err
		}
		accessRecords = append(accessRecords, &access)
	}

	if err = rows.Err(); err != nil {
		return nil, Metadata{}, err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return accessRecords, metadata, nil
}

// Get all access records for a specific user
func (m ResourceAccessModel) GetByUserID(userID int64, filters Filters) ([]*ResourceAccess, Metadata, error) {
	query := `
		SELECT COUNT(*) OVER(), access_id, resource_id, user_id, accessed_at
		FROM resource_access
		WHERE user_id = $1
		ORDER BY accessed_at DESC
		LIMIT $2 OFFSET $3`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{userID, filters.limit(), filters.offset()}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, Metadata{}, err
	}
	defer rows.Close()

	totalRecords := 0
	accessRecords := []*ResourceAccess{}

	for rows.Next() {
		var access ResourceAccess
		err := rows.Scan(
			&totalRecords,
			&access.ID,
			&access.ResourceID,
			&access.UserID,
			&access.AccessedAt,
		)
		if err != nil {
			return nil, Metadata{}, err
		}
		accessRecords = append(accessRecords, &access)
	}

	if err = rows.Err(); err != nil {
		return nil, Metadata{}, err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return accessRecords, metadata, nil
}

// Delete a resource access record
func (m ResourceAccessModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM resource_access
		WHERE access_id = $1`

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
