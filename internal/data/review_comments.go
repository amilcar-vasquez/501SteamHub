// filename: internal/data/review_comments.go

package data

import (
	"context"
	"database/sql"
	"time"
)

// ReviewComment represents a granular reviewer comment on a specific section of a resource.
// section maps to lesson JSON block types (objectives, activity, assessment, etc.)
// block_index maps to the array index inside lesson_content.blocks.
type ReviewComment struct {
	ID         int64      `json:"comment_id"`
	ResourceID int64      `json:"resource_id"`
	ReviewerID int64      `json:"reviewer_id"`
	Section    *string    `json:"section,omitempty"`
	BlockIndex *int       `json:"block_index,omitempty"`
	Comment    string     `json:"comment"`
	Resolved   bool       `json:"resolved"`
	CreatedAt  time.Time  `json:"created_at"`
	ResolvedAt *time.Time `json:"resolved_at,omitempty"`
}

type ReviewCommentModel struct {
	DB *sql.DB
}

// Insert adds a new review comment to the database.
func (m ReviewCommentModel) Insert(rc *ReviewComment) error {
	query := `
		INSERT INTO review_comments
			(resource_id, reviewer_id, section, block_index, comment)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING comment_id, resolved, created_at`

	args := []any{
		rc.ResourceID,
		rc.ReviewerID,
		rc.Section,
		rc.BlockIndex,
		rc.Comment,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(
		&rc.ID,
		&rc.Resolved,
		&rc.CreatedAt,
	)
}

// Get retrieves a single review comment by its ID.
func (m ReviewCommentModel) Get(id int64) (*ReviewComment, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT comment_id, resource_id, reviewer_id, section, block_index,
		       comment, resolved, created_at, resolved_at
		FROM review_comments
		WHERE comment_id = $1`

	var rc ReviewComment

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&rc.ID,
		&rc.ResourceID,
		&rc.ReviewerID,
		&rc.Section,
		&rc.BlockIndex,
		&rc.Comment,
		&rc.Resolved,
		&rc.CreatedAt,
		&rc.ResolvedAt,
	)
	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &rc, nil
}

// GetByResourceID returns all review comments for a resource, ordered by creation time.
func (m ReviewCommentModel) GetByResourceID(resourceID int64) ([]*ReviewComment, error) {
	query := `
		SELECT comment_id, resource_id, reviewer_id, section, block_index,
		       comment, resolved, created_at, resolved_at
		FROM review_comments
		WHERE resource_id = $1
		ORDER BY created_at ASC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var comments []*ReviewComment

	for rows.Next() {
		var rc ReviewComment
		err := rows.Scan(
			&rc.ID,
			&rc.ResourceID,
			&rc.ReviewerID,
			&rc.Section,
			&rc.BlockIndex,
			&rc.Comment,
			&rc.Resolved,
			&rc.CreatedAt,
			&rc.ResolvedAt,
		)
		if err != nil {
			return nil, err
		}
		comments = append(comments, &rc)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	if comments == nil {
		comments = []*ReviewComment{}
	}

	return comments, nil
}

// Resolve marks a review comment as resolved and records the resolution timestamp.
func (m ReviewCommentModel) Resolve(id int64) (*ReviewComment, error) {
	query := `
		UPDATE review_comments
		SET    resolved = TRUE,
		       resolved_at = NOW()
		WHERE  comment_id = $1
		  AND  resolved = FALSE
		RETURNING comment_id, resource_id, reviewer_id, section, block_index,
		          comment, resolved, created_at, resolved_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var rc ReviewComment
	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&rc.ID,
		&rc.ResourceID,
		&rc.ReviewerID,
		&rc.Section,
		&rc.BlockIndex,
		&rc.Comment,
		&rc.Resolved,
		&rc.CreatedAt,
		&rc.ResolvedAt,
	)
	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &rc, nil
}
