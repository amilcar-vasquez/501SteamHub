//filename: internal/data/comments.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type ResourceComment struct {
	ID              int64     `json:"comment_id"`
	ResourceID      int64     `json:"resource_id"`
	UserID          int64     `json:"user_id"`
	ParentCommentID *int64    `json:"parent_comment_id,omitempty"`
	Content         string    `json:"content"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type ResourceCommentModel struct {
	DB *sql.DB
}

// Insert a new comment
func (m ResourceCommentModel) Insert(comment *ResourceComment) error {
	query := `
		INSERT INTO resource_comments (resource_id, user_id, parent_comment_id, content)
		VALUES ($1, $2, $3, $4)
		RETURNING comment_id, created_at, updated_at`

	args := []any{
		comment.ResourceID,
		comment.UserID,
		comment.ParentCommentID,
		comment.Content,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&comment.ID, &comment.CreatedAt, &comment.UpdatedAt)
}

// Get a comment by ID
func (m ResourceCommentModel) Get(id int64) (*ResourceComment, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT comment_id, resource_id, user_id, parent_comment_id, content, created_at, updated_at
		FROM resource_comments
		WHERE comment_id = $1`

	var comment ResourceComment

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&comment.ID,
		&comment.ResourceID,
		&comment.UserID,
		&comment.ParentCommentID,
		&comment.Content,
		&comment.CreatedAt,
		&comment.UpdatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &comment, nil
}

// GetByResource returns all comments for a resource
func (m ResourceCommentModel) GetByResource(resourceID int64) ([]*ResourceComment, error) {
	query := `
		SELECT comment_id, resource_id, user_id, parent_comment_id, content, created_at, updated_at
		FROM resource_comments
		WHERE resource_id = $1
		ORDER BY created_at ASC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	comments := []*ResourceComment{}
	for rows.Next() {
		var comment ResourceComment
		err := rows.Scan(
			&comment.ID,
			&comment.ResourceID,
			&comment.UserID,
			&comment.ParentCommentID,
			&comment.Content,
			&comment.CreatedAt,
			&comment.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		comments = append(comments, &comment)
	}

	return comments, rows.Err()
}

// GetReplies returns all replies to a comment
func (m ResourceCommentModel) GetReplies(commentID int64) ([]*ResourceComment, error) {
	query := `
		SELECT comment_id, resource_id, user_id, parent_comment_id, content, created_at, updated_at
		FROM resource_comments
		WHERE parent_comment_id = $1
		ORDER BY created_at ASC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, commentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	comments := []*ResourceComment{}
	for rows.Next() {
		var comment ResourceComment
		err := rows.Scan(
			&comment.ID,
			&comment.ResourceID,
			&comment.UserID,
			&comment.ParentCommentID,
			&comment.Content,
			&comment.CreatedAt,
			&comment.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		comments = append(comments, &comment)
	}

	return comments, rows.Err()
}

// Update a comment
func (m ResourceCommentModel) Update(comment *ResourceComment) error {
	query := `
		UPDATE resource_comments
		SET content = $1
		WHERE comment_id = $2
		RETURNING comment_id, updated_at`

	args := []any{
		comment.Content,
		comment.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&comment.ID, &comment.UpdatedAt)
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

// Delete a comment
func (m ResourceCommentModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `DELETE FROM resource_comments WHERE comment_id = $1`

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
