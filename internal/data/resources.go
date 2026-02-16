//filename: internal/data/resources.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type Resource struct {
	ID            int64     `json:"resource_id"`
	Title         string    `json:"title"`
	Category      string    `json:"category"`
	Subject       string    `json:"subject"`
	GradeLevel    string    `json:"grade_level"`
	ILO           string    `json:"ilo"`
	DriveLink     *string   `json:"drive_link,omitempty"`
	Status        string    `json:"status"`
	PublishedURL  *string   `json:"published_url,omitempty"`
	ContributorID int64     `json:"contributor_id"`
	CreatedAt     time.Time `json:"created_at"`
}

type ResourceModel struct {
	DB *sql.DB
}

// Insert a new resource into the database
func (m ResourceModel) Insert(resource *Resource) error {
	query := `
		INSERT INTO resources (title, category, subject, grade_level, ilo, drive_link, status, published_url, contributor_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING resource_id, created_at`

	args := []any{
		resource.Title,
		resource.Category,
		resource.Subject,
		resource.GradeLevel,
		resource.ILO,
		resource.DriveLink,
		resource.Status,
		resource.PublishedURL,
		resource.ContributorID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&resource.ID, &resource.CreatedAt)
}

// Get a resource by ID
func (m ResourceModel) Get(id int64) (*Resource, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT resource_id, title, category, subject, grade_level, ilo, drive_link, status, published_url, contributor_id, created_at
		FROM resources
		WHERE resource_id = $1`

	var resource Resource

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&resource.ID,
		&resource.Title,
		&resource.Category,
		&resource.Subject,
		&resource.GradeLevel,
		&resource.ILO,
		&resource.DriveLink,
		&resource.Status,
		&resource.PublishedURL,
		&resource.ContributorID,
		&resource.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &resource, nil
}

// Get all resources with optional filters
func (m ResourceModel) GetAll(status string, subject string, gradeLevel string, filters Filters) ([]*Resource, Metadata, error) {
	query := `
		SELECT COUNT(*) OVER(), resource_id, title, category, subject, grade_level, ilo, drive_link, status, published_url, contributor_id, created_at
		FROM resources
		WHERE ($1 = '' OR status = $1::resource_status)
		AND ($2 = '' OR subject = $2::subject)
		AND ($3 = '' OR grade_level = $3::grade_level)
		ORDER BY created_at DESC
		LIMIT $4 OFFSET $5`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{status, subject, gradeLevel, filters.limit(), filters.offset()}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, Metadata{}, err
	}
	defer rows.Close()

	totalRecords := 0
	resources := []*Resource{}

	for rows.Next() {
		var resource Resource
		err := rows.Scan(
			&totalRecords,
			&resource.ID,
			&resource.Title,
			&resource.Category,
			&resource.Subject,
			&resource.GradeLevel,
			&resource.ILO,
			&resource.DriveLink,
			&resource.Status,
			&resource.PublishedURL,
			&resource.ContributorID,
			&resource.CreatedAt,
		)
		if err != nil {
			return nil, Metadata{}, err
		}
		resources = append(resources, &resource)
	}

	if err = rows.Err(); err != nil {
		return nil, Metadata{}, err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return resources, metadata, nil
}

// Update a resource
func (m ResourceModel) Update(resource *Resource) error {
	query := `
		UPDATE resources
		SET title = $1, category = $2, subject = $3, grade_level = $4, ilo = $5, drive_link = $6, status = $7, published_url = $8
		WHERE resource_id = $9
		RETURNING resource_id`

	args := []any{
		resource.Title,
		resource.Category,
		resource.Subject,
		resource.GradeLevel,
		resource.ILO,
		resource.DriveLink,
		resource.Status,
		resource.PublishedURL,
		resource.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&resource.ID)
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

// Delete a resource
func (m ResourceModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM resources
		WHERE resource_id = $1`

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
