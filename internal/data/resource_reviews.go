//filename: internal/data/resource_reviews.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type ResourceReview struct {
	ID             int64     `json:"review_id"`
	ResourceID     int64     `json:"resource_id"`
	ReviewerID     int64     `json:"reviewer_id"`
	ReviewerRoleID int64     `json:"reviewer_role_id"`
	Decision       string    `json:"decision"`
	CommentSummary string    `json:"comment_summary,omitempty"`
	ReviewedAt     time.Time `json:"reviewed_at"`
}

type ResourceReviewModel struct {
	DB *sql.DB
}

// Insert a new resource review into the database
func (m ResourceReviewModel) Insert(review *ResourceReview) error {
	query := `
		INSERT INTO resource_reviews (resource_id, reviewer_id, reviewer_role_id, decision, comment_summary)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING review_id, reviewed_at`

	args := []any{
		review.ResourceID,
		review.ReviewerID,
		review.ReviewerRoleID,
		review.Decision,
		review.CommentSummary,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&review.ID, &review.ReviewedAt)
}

// Get a resource review by ID
func (m ResourceReviewModel) Get(id int64) (*ResourceReview, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT review_id, resource_id, reviewer_id, reviewer_role_id, decision, comment_summary, reviewed_at
		FROM resource_reviews
		WHERE review_id = $1`

	var review ResourceReview

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&review.ID,
		&review.ResourceID,
		&review.ReviewerID,
		&review.ReviewerRoleID,
		&review.Decision,
		&review.CommentSummary,
		&review.ReviewedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &review, nil
}

// Get all reviews for a specific resource
func (m ResourceReviewModel) GetByResourceID(resourceID int64) ([]*ResourceReview, error) {
	query := `
		SELECT review_id, resource_id, reviewer_id, reviewer_role_id, decision, comment_summary, reviewed_at
		FROM resource_reviews
		WHERE resource_id = $1
		ORDER BY reviewed_at DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	reviews := []*ResourceReview{}

	for rows.Next() {
		var review ResourceReview
		err := rows.Scan(
			&review.ID,
			&review.ResourceID,
			&review.ReviewerID,
			&review.ReviewerRoleID,
			&review.Decision,
			&review.CommentSummary,
			&review.ReviewedAt,
		)
		if err != nil {
			return nil, err
		}
		reviews = append(reviews, &review)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return reviews, nil
}

// Update a resource review
func (m ResourceReviewModel) Update(review *ResourceReview) error {
	query := `
		UPDATE resource_reviews
		SET decision = $1, comment_summary = $2
		WHERE review_id = $3
		RETURNING review_id`

	args := []any{
		review.Decision,
		review.CommentSummary,
		review.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&review.ID)
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

// Delete a resource review
func (m ResourceReviewModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM resource_reviews
		WHERE review_id = $1`

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
