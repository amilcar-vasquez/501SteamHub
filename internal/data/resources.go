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
	Slug          *string   `json:"slug,omitempty"`
	Summary       *string   `json:"summary,omitempty"`
	DriveLink     *string   `json:"drive_link,omitempty"`
	Status        string    `json:"status"`
	PublishedURL  *string   `json:"published_url,omitempty"`
	ContributorID int64     `json:"contributor_id"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	Subjects      []string  `json:"subjects,omitempty"`
	GradeLevels   []string  `json:"grade_levels,omitempty"`
}

type ResourceModel struct {
	DB *sql.DB
}

// Insert a new resource into the database
func (m ResourceModel) Insert(resource *Resource) error {
	query := `
		INSERT INTO resources (title, category, slug, summary, drive_link, status, published_url, contributor_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING resource_id, created_at, updated_at`

	args := []any{
		resource.Title,
		resource.Category,
		resource.Slug,
		resource.Summary,
		resource.DriveLink,
		resource.Status,
		resource.PublishedURL,
		resource.ContributorID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&resource.ID, &resource.CreatedAt, &resource.UpdatedAt)
}

// InsertWithVideoMetadata inserts a resource and its VideoMetadata atomically
// in a single transaction.  Use this whenever Category == "Video".
func (m ResourceModel) InsertWithVideoMetadata(resource *Resource, vm *VideoMetadata) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Insert the resource row first to obtain the resource_id.
	resourceQuery := `
		INSERT INTO resources (title, category, slug, summary, drive_link, status, published_url, contributor_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING resource_id, created_at, updated_at`

	resourceArgs := []any{
		resource.Title,
		resource.Category,
		resource.Slug,
		resource.Summary,
		resource.DriveLink,
		resource.Status,
		resource.PublishedURL,
		resource.ContributorID,
	}

	err = tx.QueryRowContext(ctx, resourceQuery, resourceArgs...).Scan(
		&resource.ID, &resource.CreatedAt, &resource.UpdatedAt,
	)
	if err != nil {
		return err
	}

	// Bind the new resource_id to the video metadata and insert it.
	vm.ResourceID = resource.ID
	vmModel := VideoModel{DB: m.DB}
	if err = vmModel.InsertTx(ctx, tx, vm); err != nil {
		return err
	}

	return tx.Commit()
}

// Get a resource by ID
func (m ResourceModel) Get(id int64) (*Resource, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT resource_id, title, category, slug, summary, drive_link, status, published_url, contributor_id, created_at, updated_at
		FROM resources
		WHERE resource_id = $1`

	var resource Resource

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&resource.ID,
		&resource.Title,
		&resource.Category,
		&resource.Slug,
		&resource.Summary,
		&resource.DriveLink,
		&resource.Status,
		&resource.PublishedURL,
		&resource.ContributorID,
		&resource.CreatedAt,
		&resource.UpdatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	// Load subjects and grade levels
	resource.Subjects, err = m.GetSubjects(id)
	if err != nil {
		return nil, err
	}

	resource.GradeLevels, err = m.GetGradeLevels(id)
	if err != nil {
		return nil, err
	}

	return &resource, nil
}

// GetBySlug retrieves a resource by its slug
func (m ResourceModel) GetBySlug(slug string) (*Resource, error) {
	if slug == "" {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT resource_id, title, category, slug, summary, drive_link, status, published_url, contributor_id, created_at, updated_at
		FROM resources
		WHERE slug = $1`

	var resource Resource

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, slug).Scan(
		&resource.ID,
		&resource.Title,
		&resource.Category,
		&resource.Slug,
		&resource.Summary,
		&resource.DriveLink,
		&resource.Status,
		&resource.PublishedURL,
		&resource.ContributorID,
		&resource.CreatedAt,
		&resource.UpdatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	// Load subjects and grade levels
	resource.Subjects, err = m.GetSubjects(resource.ID)
	if err != nil {
		return nil, err
	}

	resource.GradeLevels, err = m.GetGradeLevels(resource.ID)
	if err != nil {
		return nil, err
	}

	return &resource, nil
}

// Get all resources with optional filters
func (m ResourceModel) GetAll(status string, subject string, gradeLevel string, filters Filters) ([]*Resource, Metadata, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var totalRecords int
	var query string
	var countQuery string
	var args []any

	if subject != "" || gradeLevel != "" {
		// Count query with joins
		countQuery = `
			SELECT COUNT(DISTINCT r.resource_id)
			FROM resources r
			LEFT JOIN resource_subjects rs ON r.resource_id = rs.resource_id
			LEFT JOIN resource_grade_levels rgl ON r.resource_id = rgl.resource_id
			WHERE ($1 = '' OR r.status = $1::resource_status)
			AND ($2 = '' OR rs.subject::text = $2)
			AND ($3 = '' OR rgl.grade_level::text = $3)`

		// Main query with joins
		query = `
			SELECT DISTINCT r.resource_id, r.title, r.category, r.slug, r.summary, r.drive_link, r.status, r.published_url, r.contributor_id, r.created_at, r.updated_at
			FROM resources r
			LEFT JOIN resource_subjects rs ON r.resource_id = rs.resource_id
			LEFT JOIN resource_grade_levels rgl ON r.resource_id = rgl.resource_id
			WHERE ($1 = '' OR r.status = $1::resource_status)
			AND ($2 = '' OR rs.subject::text = $2)
			AND ($3 = '' OR rgl.grade_level::text = $3)
			ORDER BY r.created_at DESC
			LIMIT $4 OFFSET $5`

		args = []any{status, subject, gradeLevel, filters.limit(), filters.offset()}

		// Get total count
		err := m.DB.QueryRowContext(ctx, countQuery, status, subject, gradeLevel).Scan(&totalRecords)
		if err != nil {
			return nil, Metadata{}, err
		}
	} else {
		// Simple count query
		countQuery = `
			SELECT COUNT(*)
			FROM resources
			WHERE ($1 = '' OR status = $1::resource_status)`

		// Simple main query
		query = `
			SELECT resource_id, title, category, slug, summary, drive_link, status, published_url, contributor_id, created_at, updated_at
			FROM resources
			WHERE ($1 = '' OR status = $1::resource_status)
			ORDER BY created_at DESC
			LIMIT $2 OFFSET $3`

		args = []any{status, filters.limit(), filters.offset()}

		// Get total count
		err := m.DB.QueryRowContext(ctx, countQuery, status).Scan(&totalRecords)
		if err != nil {
			return nil, Metadata{}, err
		}
	}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, Metadata{}, err
	}
	defer rows.Close()

	resources := []*Resource{}

	for rows.Next() {
		var resource Resource
		err := rows.Scan(
			&resource.ID,
			&resource.Title,
			&resource.Category,
			&resource.Slug,
			&resource.Summary,
			&resource.DriveLink,
			&resource.Status,
			&resource.PublishedURL,
			&resource.ContributorID,
			&resource.CreatedAt,
			&resource.UpdatedAt,
		)
		if err != nil {
			return nil, Metadata{}, err
		}

		// Load subjects and grade levels for each resource
		resource.Subjects, _ = m.GetSubjects(resource.ID)
		resource.GradeLevels, _ = m.GetGradeLevels(resource.ID)

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
		SET title = $1, category = $2, slug = $3, summary = $4, drive_link = $5, status = $6, published_url = $7
		WHERE resource_id = $8
		RETURNING resource_id`

	args := []any{
		resource.Title,
		resource.Category,
		resource.Slug,
		resource.Summary,
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

// GetSubjects returns all subjects for a resource
// ResourceStatusCounts holds the count of resources per review-relevant status.
type ResourceStatusCounts struct {
	Submitted     int64 `json:"submitted"`
	UnderReview   int64 `json:"under_review"`
	NeedsRevision int64 `json:"needs_revision"`
	Approved      int64 `json:"approved"`
	Published     int64 `json:"published"`
}

// GetStatusCounts returns a single-row summary of resource counts grouped by
// review-relevant status values.  The query runs in one round-trip.
func (m ResourceModel) GetStatusCounts() (*ResourceStatusCounts, error) {
	query := `
		SELECT
			COUNT(*) FILTER (WHERE status = 'Submitted')     AS submitted,
			COUNT(*) FILTER (WHERE status = 'UnderReview')   AS under_review,
			COUNT(*) FILTER (WHERE status = 'NeedsRevision') AS needs_revision,
			COUNT(*) FILTER (WHERE status = 'Approved')      AS approved,
			COUNT(*) FILTER (WHERE status = 'Published')     AS published
		FROM resources`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var c ResourceStatusCounts
	err := m.DB.QueryRowContext(ctx, query).Scan(
		&c.Submitted,
		&c.UnderReview,
		&c.NeedsRevision,
		&c.Approved,
		&c.Published,
	)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (m ResourceModel) GetSubjects(resourceID int64) ([]string, error) {
	query := `
		SELECT subject FROM resource_subjects
		WHERE resource_id = $1
		ORDER BY subject`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	subjects := []string{}
	for rows.Next() {
		var subject string
		if err := rows.Scan(&subject); err != nil {
			return nil, err
		}
		subjects = append(subjects, subject)
	}

	return subjects, rows.Err()
}

// GetGradeLevels returns all grade levels for a resource
func (m ResourceModel) GetGradeLevels(resourceID int64) ([]string, error) {
	query := `
		SELECT grade_level FROM resource_grade_levels
		WHERE resource_id = $1
		ORDER BY grade_level`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	gradeLevels := []string{}
	for rows.Next() {
		var gradeLevel string
		if err := rows.Scan(&gradeLevel); err != nil {
			return nil, err
		}
		gradeLevels = append(gradeLevels, gradeLevel)
	}

	return gradeLevels, rows.Err()
}

// SetSubjects replaces all subjects for a resource
func (m ResourceModel) SetSubjects(resourceID int64, subjects []string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	// Start transaction
	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Delete existing subjects
	_, err = tx.ExecContext(ctx, "DELETE FROM resource_subjects WHERE resource_id = $1", resourceID)
	if err != nil {
		return err
	}

	// Insert new subjects
	for _, subject := range subjects {
		_, err = tx.ExecContext(ctx,
			"INSERT INTO resource_subjects (resource_id, subject) VALUES ($1, $2)",
			resourceID, subject)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// SetGradeLevels replaces all grade levels for a resource
func (m ResourceModel) SetGradeLevels(resourceID int64, gradeLevels []string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	// Start transaction
	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Delete existing grade levels
	_, err = tx.ExecContext(ctx, "DELETE FROM resource_grade_levels WHERE resource_id = $1", resourceID)
	if err != nil {
		return err
	}

	// Insert new grade levels
	for _, gradeLevel := range gradeLevels {
		_, err = tx.ExecContext(ctx,
			"INSERT INTO resource_grade_levels (resource_id, grade_level) VALUES ($1, $2)",
			resourceID, gradeLevel)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}
