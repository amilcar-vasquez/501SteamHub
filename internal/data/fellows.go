//filename: internal/data/fellows.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type Fellow struct {
	ID                    int64      `json:"fellow_id"`
	UserID                int64      `json:"user_id"`
	FirstName             string     `json:"first_name"`
	LastName              string     `json:"last_name"`
	MoeIdentifier         string     `json:"moe_identifier"`
	School                *string    `json:"school,omitempty"`
	SubjectSpecialization *string    `json:"subject_specialization,omitempty"`
	District              *string    `json:"district,omitempty"`
	ProfileStatus         string     `json:"profile_status"`
	SteamPoints           float64    `json:"steam_points"` // Accumulated 501 STEAM Points from contributions (FR-27)
	SourceApplicationID   *int64     `json:"source_application_id,omitempty"`
	MoeIdentifierVerified bool       `json:"moe_identifier_verified"`
	VerifiedAt            *time.Time `json:"verified_at,omitempty"`
	VerifiedBy            *int64     `json:"verified_by,omitempty"`
	CreatedAt             time.Time  `json:"created_at"`
}

type FellowModel struct {
	DB *sql.DB
}

// Insert a new fellow into the database
func (m FellowModel) Insert(fellow *Fellow) error {
	query := `
		INSERT INTO fellows (user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, source_application_id, moe_identifier_verified, verified_at, verified_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING fellow_id, created_at`

	args := []any{
		fellow.UserID,
		fellow.FirstName,
		fellow.LastName,
		fellow.MoeIdentifier,
		fellow.School,
		fellow.SubjectSpecialization,
		fellow.District,
		fellow.ProfileStatus,
		fellow.SourceApplicationID,
		fellow.MoeIdentifierVerified,
		fellow.VerifiedAt,
		fellow.VerifiedBy,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&fellow.ID, &fellow.CreatedAt)
}

// Get a fellow by ID
func (m FellowModel) Get(id int64) (*Fellow, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT fellow_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, steam_points, source_application_id, moe_identifier_verified, verified_at, verified_by, created_at
		FROM fellows
		WHERE fellow_id = $1`

	var fellow Fellow

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&fellow.ID,
		&fellow.UserID,
		&fellow.FirstName,
		&fellow.LastName,
		&fellow.MoeIdentifier,
		&fellow.School,
		&fellow.SubjectSpecialization,
		&fellow.District,
		&fellow.ProfileStatus,
		&fellow.SteamPoints,
		&fellow.SourceApplicationID,
		&fellow.MoeIdentifierVerified,
		&fellow.VerifiedAt,
		&fellow.VerifiedBy,
		&fellow.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &fellow, nil
}

// GetByUserID retrieves a fellow by user ID
func (m FellowModel) GetByUserID(userID int64) (*Fellow, error) {
	if userID < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT fellow_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, steam_points, source_application_id, moe_identifier_verified, verified_at, verified_by, created_at
		FROM fellows
		WHERE user_id = $1`

	var fellow Fellow

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&fellow.ID,
		&fellow.UserID,
		&fellow.FirstName,
		&fellow.LastName,
		&fellow.MoeIdentifier,
		&fellow.School,
		&fellow.SubjectSpecialization,
		&fellow.District,
		&fellow.ProfileStatus,
		&fellow.SteamPoints,
		&fellow.SourceApplicationID,
		&fellow.MoeIdentifierVerified,
		&fellow.VerifiedAt,
		&fellow.VerifiedBy,
		&fellow.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &fellow, nil
}

// Update a fellow
func (m FellowModel) Update(fellow *Fellow) error {
	query := `
		UPDATE fellows
		SET first_name = $1, last_name = $2, moe_identifier = $3, school = $4, subject_specialization = $5, district = $6, profile_status = $7, steam_points = $8, source_application_id = $9, moe_identifier_verified = $10, verified_at = $11, verified_by = $12
		WHERE fellow_id = $13
		RETURNING fellow_id`

	args := []any{
		fellow.FirstName,
		fellow.LastName,
		fellow.MoeIdentifier,
		fellow.School,
		fellow.SubjectSpecialization,
		fellow.District,
		fellow.ProfileStatus,
		fellow.SteamPoints,
		fellow.SourceApplicationID,
		fellow.MoeIdentifierVerified,
		fellow.VerifiedAt,
		fellow.VerifiedBy,
		fellow.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&fellow.ID)
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

// Delete a fellow
func (m FellowModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM fellows
		WHERE fellow_id = $1`

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

// UpdateSteamPoints adds the given points to a fellow's existing steam_points (FR-27 requirement).
// This is called when a contribution is scored using CalculateSteamPoints.
func (m FellowModel) UpdateSteamPoints(fellowID int64, pointsToAdd float64) error {
	if fellowID < 1 {
		return ErrRecordNotFound
	}

	query := `
		UPDATE fellows
		SET steam_points = steam_points + $1
		WHERE fellow_id = $2
		RETURNING steam_points`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var updatedPoints float64
	err := m.DB.QueryRowContext(ctx, query, pointsToAdd, fellowID).Scan(&updatedPoints)
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
