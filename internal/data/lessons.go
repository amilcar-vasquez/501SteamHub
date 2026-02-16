//filename: internal/data/lessons.go

package data

import (
	"context"
	"database/sql"
	"time"

	"github.com/lib/pq"
)

type Lesson struct {
	ID              int64          `json:"lesson_id"`
	ResourceID      int64          `json:"resource_id"`
	LessonNumber    int            `json:"lesson_number"`
	Title           string         `json:"title"`
	DurationMinutes *int           `json:"duration_minutes,omitempty"`
	Objectives      pq.StringArray `json:"objectives,omitempty"`
	Materials       pq.StringArray `json:"materials,omitempty"`
	Content         string         `json:"content"`
	Assessment      *string        `json:"assessment,omitempty"`
	Differentiation *string        `json:"differentiation,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
}

type LessonVersion struct {
	ID                int64     `json:"version_id"`
	LessonID          int64     `json:"lesson_id"`
	VersionNumber     int       `json:"version_number"`
	Content           string    `json:"content"`
	ChangeDescription *string   `json:"change_description,omitempty"`
	ChangedBy         int64     `json:"changed_by"`
	ChangedAt         time.Time `json:"changed_at"`
}

type LessonModel struct {
	DB *sql.DB
}

// Insert a new lesson
func (m LessonModel) Insert(lesson *Lesson) error {
	query := `
		INSERT INTO lessons (resource_id, lesson_number, title, duration_minutes, objectives, materials, content, assessment, differentiation)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING lesson_id, created_at`

	args := []any{
		lesson.ResourceID,
		lesson.LessonNumber,
		lesson.Title,
		lesson.DurationMinutes,
		lesson.Objectives,
		lesson.Materials,
		lesson.Content,
		lesson.Assessment,
		lesson.Differentiation,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&lesson.ID, &lesson.CreatedAt)
}

// Get a lesson by ID
func (m LessonModel) Get(id int64) (*Lesson, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT lesson_id, resource_id, lesson_number, title, duration_minutes, objectives, materials, content, assessment, differentiation, created_at
		FROM lessons
		WHERE lesson_id = $1`

	var lesson Lesson

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&lesson.ID,
		&lesson.ResourceID,
		&lesson.LessonNumber,
		&lesson.Title,
		&lesson.DurationMinutes,
		&lesson.Objectives,
		&lesson.Materials,
		&lesson.Content,
		&lesson.Assessment,
		&lesson.Differentiation,
		&lesson.CreatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &lesson, nil
}

// GetByResource returns all lessons for a resource
func (m LessonModel) GetByResource(resourceID int64) ([]*Lesson, error) {
	query := `
		SELECT lesson_id, resource_id, lesson_number, title, duration_minutes, objectives, materials, content, assessment, differentiation, created_at
		FROM lessons
		WHERE resource_id = $1
		ORDER BY lesson_number`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	lessons := []*Lesson{}
	for rows.Next() {
		var lesson Lesson
		err := rows.Scan(
			&lesson.ID,
			&lesson.ResourceID,
			&lesson.LessonNumber,
			&lesson.Title,
			&lesson.DurationMinutes,
			&lesson.Objectives,
			&lesson.Materials,
			&lesson.Content,
			&lesson.Assessment,
			&lesson.Differentiation,
			&lesson.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		lessons = append(lessons, &lesson)
	}

	return lessons, rows.Err()
}

// Update a lesson
func (m LessonModel) Update(lesson *Lesson) error {
	query := `
		UPDATE lessons
		SET title = $1, duration_minutes = $2, objectives = $3, materials = $4, content = $5, assessment = $6, differentiation = $7
		WHERE lesson_id = $8
		RETURNING lesson_id`

	args := []any{
		lesson.Title,
		lesson.DurationMinutes,
		lesson.Objectives,
		lesson.Materials,
		lesson.Content,
		lesson.Assessment,
		lesson.Differentiation,
		lesson.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&lesson.ID)
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

// Delete a lesson
func (m LessonModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `DELETE FROM lessons WHERE lesson_id = $1`

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

// CreateVersion creates a new version of a lesson
func (m LessonModel) CreateVersion(version *LessonVersion) error {
	query := `
		INSERT INTO lesson_versions (lesson_id, version_number, content, change_description, changed_by)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING version_id, changed_at`

	args := []any{
		version.LessonID,
		version.VersionNumber,
		version.Content,
		version.ChangeDescription,
		version.ChangedBy,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&version.ID, &version.ChangedAt)
}

// GetVersions returns all versions of a lesson
func (m LessonModel) GetVersions(lessonID int64) ([]*LessonVersion, error) {
	query := `
		SELECT version_id, lesson_id, version_number, content, change_description, changed_by, changed_at
		FROM lesson_versions
		WHERE lesson_id = $1
		ORDER BY version_number DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, lessonID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	versions := []*LessonVersion{}
	for rows.Next() {
		var version LessonVersion
		err := rows.Scan(
			&version.ID,
			&version.LessonID,
			&version.VersionNumber,
			&version.Content,
			&version.ChangeDescription,
			&version.ChangedBy,
			&version.ChangedAt,
		)
		if err != nil {
			return nil, err
		}
		versions = append(versions, &version)
	}

	return versions, rows.Err()
}
