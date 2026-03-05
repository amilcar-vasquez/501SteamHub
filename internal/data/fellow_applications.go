// filename: internal/data/fellow_applications.go

package data

import (
	"context"
	"database/sql"
	"time"

	"github.com/lib/pq"
)

// FellowApplication represents a user's request to become a Fellow.
type FellowApplication struct {
	ID              int64          `json:"application_id"`
	UserID          int64          `json:"user_id"`
	FullName        string         `json:"full_name"`
	Organization    string         `json:"organization"`
	Subjects        pq.StringArray `json:"subjects"`
	GradeLevels     pq.StringArray `json:"grade_levels"`
	ExperienceYears int            `json:"experience_years"`
	Bio             string         `json:"bio"`
	CredentialsLink string         `json:"credentials_link,omitempty"`
	Status          string         `json:"status"` // Pending | Approved | Rejected
	ReviewedBy      *int64         `json:"reviewed_by,omitempty"`
	ReviewedAt      *time.Time     `json:"reviewed_at,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
}

type FellowApplicationModel struct {
	DB *sql.DB
}

// Insert creates a new fellow application.
func (m FellowApplicationModel) Insert(app *FellowApplication) error {
	query := `
		INSERT INTO fellow_applications
			(user_id, full_name, organization, subjects, grade_levels,
			 experience_years, bio, credentials_link, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'Pending')
		RETURNING application_id, created_at`

	args := []any{
		app.UserID,
		app.FullName,
		app.Organization,
		pq.Array(app.Subjects),
		pq.Array(app.GradeLevels),
		app.ExperienceYears,
		app.Bio,
		app.CredentialsLink,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&app.ID, &app.CreatedAt)
}

// Get retrieves a single application by application_id.
func (m FellowApplicationModel) Get(id int64) (*FellowApplication, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT application_id, user_id, full_name, organization, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications
		WHERE application_id = $1`

	var app FellowApplication

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&app.ID,
		&app.UserID,
		&app.FullName,
		&app.Organization,
		&app.Subjects,
		&app.GradeLevels,
		&app.ExperienceYears,
		&app.Bio,
		&app.CredentialsLink,
		&app.Status,
		&app.ReviewedBy,
		&app.ReviewedAt,
		&app.CreatedAt,
	)
	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &app, nil
}

// GetByUserID retrieves the most-recent application for a given user.
func (m FellowApplicationModel) GetByUserID(userID int64) (*FellowApplication, error) {
	query := `
		SELECT application_id, user_id, full_name, organization, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1`

	var app FellowApplication

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&app.ID,
		&app.UserID,
		&app.FullName,
		&app.Organization,
		&app.Subjects,
		&app.GradeLevels,
		&app.ExperienceYears,
		&app.Bio,
		&app.CredentialsLink,
		&app.Status,
		&app.ReviewedBy,
		&app.ReviewedAt,
		&app.CreatedAt,
	)
	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &app, nil
}

// HasPendingApplication returns true when the user already has an unresolved
// pending application.
func (m FellowApplicationModel) HasPendingApplication(userID int64) (bool, error) {
	query := `
		SELECT EXISTS (
			SELECT 1 FROM fellow_applications
			WHERE user_id = $1 AND status = 'Pending'
		)`

	var exists bool

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(&exists)
	if err != nil {
		return false, err
	}

	return exists, nil
}

// Approve sets an application's status to Approved, records the reviewer, and
// promotes the applicant to the Fellow role (role_id = 3).
func (m FellowApplicationModel) Approve(id, reviewerID int64) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 1. Fetch the application so we can get the applicant's user_id.
	var userID int64
	err = tx.QueryRowContext(ctx,
		`SELECT user_id FROM fellow_applications WHERE application_id = $1 AND status = 'Pending'`,
		id,
	).Scan(&userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return ErrRecordNotFound
		}
		return err
	}

	// 2. Update the application status.
	_, err = tx.ExecContext(ctx, `
		UPDATE fellow_applications
		SET status = 'Approved', reviewed_by = $1, reviewed_at = NOW()
		WHERE application_id = $2`,
		reviewerID, id,
	)
	if err != nil {
		return err
	}

	// 3. Promote the user to Fellow (role_id = 3).
	_, err = tx.ExecContext(ctx,
		`UPDATE users SET role_id = 3 WHERE user_id = $1`,
		userID,
	)
	if err != nil {
		return err
	}

	return tx.Commit()
}

// Reject sets an application's status to Rejected and records the reviewer.
func (m FellowApplicationModel) Reject(id, reviewerID int64) error {
	query := `
		UPDATE fellow_applications
		SET status = 'Rejected', reviewed_by = $1, reviewed_at = NOW()
		WHERE application_id = $2 AND status = 'Pending'`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, reviewerID, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrRecordNotFound
	}

	return nil
}

// GetAll returns all applications, optionally filtered by status.
func (m FellowApplicationModel) GetAll(statusFilter string) ([]*FellowApplication, error) {
	query := `
		SELECT application_id, user_id, full_name, organization, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications`

	args := []any{}
	if statusFilter != "" {
		query += ` WHERE status = $1`
		args = append(args, statusFilter)
	}

	query += ` ORDER BY created_at DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var apps []*FellowApplication
	for rows.Next() {
		var app FellowApplication
		err := rows.Scan(
			&app.ID,
			&app.UserID,
			&app.FullName,
			&app.Organization,
			&app.Subjects,
			&app.GradeLevels,
			&app.ExperienceYears,
			&app.Bio,
			&app.CredentialsLink,
			&app.Status,
			&app.ReviewedBy,
			&app.ReviewedAt,
			&app.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		apps = append(apps, &app)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return apps, nil
}
