// filename: internal/data/fellow_applications.go

package data

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/lib/pq"
)

// FellowApplication represents a user's request to become a Fellow.
type FellowApplication struct {
	ID              int64          `json:"application_id"`
	UserID          int64          `json:"user_id"`
	FirstName       string         `json:"first_name"`
	LastName        string         `json:"last_name"`
	Organization    string         `json:"organization"`
	BemisNumber     string         `json:"bemis_number"`
	MoeDocPath      string         `json:"moe_doc_path,omitempty"` // Storage key for MOE verification document (NOT public URL)
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

// MarshalJSON includes a temporary moe_identifier alias for v1 API compatibility.
func (fa FellowApplication) MarshalJSON() ([]byte, error) {
	type fellowApplicationAlias FellowApplication

	return json.Marshal(struct {
		fellowApplicationAlias
		MoeIdentifier string `json:"moe_identifier,omitempty"`
	}{
		fellowApplicationAlias: fellowApplicationAlias(fa),
		MoeIdentifier:          fa.BemisNumber,
	})
}

type FellowApplicationModel struct {
	DB *sql.DB
}

// Insert creates a new fellow application.
func (m FellowApplicationModel) Insert(app *FellowApplication) error {
	identifierColumn := getApplicationIdentifierColumn(m.DB)

	query := `
		INSERT INTO fellow_applications
			(user_id, first_name, last_name, organization, %s, moe_doc_path, subjects, grade_levels,
			 experience_years, bio, credentials_link, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'Pending')
		RETURNING application_id, created_at`
	query = fmt.Sprintf(query, quoteIdentifier(identifierColumn))

	args := []any{
		app.UserID,
		app.FirstName,
		app.LastName,
		app.Organization,
		app.BemisNumber,
		app.MoeDocPath,
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

	identifierColumn := getApplicationIdentifierColumn(m.DB)

	query := `
		SELECT application_id, user_id, first_name, last_name, organization, %s, moe_doc_path, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications
		WHERE application_id = $1`
	query = fmt.Sprintf(query, quoteIdentifier(identifierColumn))

	var app FellowApplication

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&app.ID,
		&app.UserID,
		&app.FirstName,
		&app.LastName,
		&app.Organization,
		&app.BemisNumber,
		&app.MoeDocPath,
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
	identifierColumn := getApplicationIdentifierColumn(m.DB)

	query := `
		SELECT application_id, user_id, first_name, last_name, organization, %s, moe_doc_path, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1`
	query = fmt.Sprintf(query, quoteIdentifier(identifierColumn))

	var app FellowApplication

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&app.ID,
		&app.UserID,
		&app.FirstName,
		&app.LastName,
		&app.Organization,
		&app.BemisNumber,
		&app.MoeDocPath,
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
// It also creates a Fellow record in the fellows table if it doesn't already exist.
func (m FellowApplicationModel) Approve(id, reviewerID int64) error {
	identifierColumn := getApplicationIdentifierColumn(m.DB)
	verificationColumn := getFellowIdentifierColumn(m.DB)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 1. Fetch the application details (first_name, last_name, organization, BEMIS column).
	var userID int64
	var firstName, lastName, organization, bemisNumber string
	err = tx.QueryRowContext(ctx,
		fmt.Sprintf(`SELECT user_id, first_name, last_name, organization, %s FROM fellow_applications WHERE application_id = $1 AND status = 'Pending'`, quoteIdentifier(identifierColumn)),
		id,
	).Scan(&userID, &firstName, &lastName, &organization, &bemisNumber)
	if err != nil {
		if err == sql.ErrNoRows {
			return ErrRecordNotFound
		}
		return err
	}

	// 2. Update the application status to Approved.
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

	// 4. Check if fellow record already exists for this user.
	var existingFellowID int64
	err = tx.QueryRowContext(ctx,
		`SELECT fellow_id FROM fellows WHERE user_id = $1`,
		userID,
	).Scan(&existingFellowID)
	if err != nil && err != sql.ErrNoRows {
		return err
	}

	// 5. Only create if it doesn't already exist.
	if err == sql.ErrNoRows {
		query := fmt.Sprintf(`
			INSERT INTO fellows (user_id, first_name, last_name, %s, school, profile_status, source_application_id)
			VALUES ($1, $2, $3, $4, $5, $6, $7)`, quoteIdentifier(verificationColumn))
		_, err = tx.ExecContext(ctx, query,
			userID,
			firstName,
			lastName,
			bemisNumber,
			organization,
			"approved",
			id,
		)
		if err != nil {
			return err
		}
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
	identifierColumn := getApplicationIdentifierColumn(m.DB)

	query := `
		SELECT application_id, user_id, first_name, last_name, organization, %s, moe_doc_path, subjects, grade_levels,
		       experience_years, bio, COALESCE(credentials_link, ''), status, reviewed_by, reviewed_at, created_at
		FROM fellow_applications`
	query = fmt.Sprintf(query, quoteIdentifier(identifierColumn))

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
			&app.FirstName,
			&app.LastName,
			&app.Organization,
			&app.BemisNumber,
			&app.MoeDocPath,
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
