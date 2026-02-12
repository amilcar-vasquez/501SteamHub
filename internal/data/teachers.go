//filename: internal/data/teachers.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type Teacher struct {
	ID                    int64     `json:"teacher_id"`
	UserID                int64     `json:"user_id"`
	FirstName             string    `json:"first_name"`
	LastName              string    `json:"last_name"`
	MoeIdentifier         string    `json:"moe_identifier"`
	School                string    `json:"school,omitempty"`
	SubjectSpecialization string    `json:"subject_specialization,omitempty"`
	District              string    `json:"district,omitempty"`
	ProfileStatus         string    `json:"profile_status"`
	CreatedAt             time.Time `json:"created_at"`
}

type TeacherModel struct {
	DB *sql.DB
}

// Insert a new teacher into the database
func (m TeacherModel) Insert(teacher *Teacher) error {
	query := `
		INSERT INTO teachers (user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING teacher_id, created_at`

	args := []any{
		teacher.UserID,
		teacher.FirstName,
		teacher.LastName,
		teacher.MoeIdentifier,
		teacher.School,
		teacher.SubjectSpecialization,
		teacher.District,
		teacher.ProfileStatus,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&teacher.ID, &teacher.CreatedAt)
}

// Get a teacher by ID
func (m TeacherModel) Get(id int64) (*Teacher, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT teacher_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, created_at
		FROM teachers
		WHERE teacher_id = $1`

	var teacher Teacher

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&teacher.ID,
		&teacher.UserID,
		&teacher.FirstName,
		&teacher.LastName,
		&teacher.MoeIdentifier,
		&teacher.School,
		&teacher.SubjectSpecialization,
		&teacher.District,
		&teacher.ProfileStatus,
		&teacher.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &teacher, nil
}

// Get a teacher by user ID
func (m TeacherModel) GetByUserID(userID int64) (*Teacher, error) {
	if userID < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT teacher_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, created_at
		FROM teachers
		WHERE user_id = $1`

	var teacher Teacher

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&teacher.ID,
		&teacher.UserID,
		&teacher.FirstName,
		&teacher.LastName,
		&teacher.MoeIdentifier,
		&teacher.School,
		&teacher.SubjectSpecialization,
		&teacher.District,
		&teacher.ProfileStatus,
		&teacher.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &teacher, nil
}

// Update a teacher
func (m TeacherModel) Update(teacher *Teacher) error {
	query := `
		UPDATE teachers
		SET first_name = $1, last_name = $2, moe_identifier = $3, school = $4, subject_specialization = $5, district = $6, profile_status = $7
		WHERE teacher_id = $8
		RETURNING teacher_id`

	args := []any{
		teacher.FirstName,
		teacher.LastName,
		teacher.MoeIdentifier,
		teacher.School,
		teacher.SubjectSpecialization,
		teacher.District,
		teacher.ProfileStatus,
		teacher.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&teacher.ID)
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

// Delete a teacher
func (m TeacherModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM teachers
		WHERE teacher_id = $1`

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
