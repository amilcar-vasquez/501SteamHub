//filename: internal/data/contributions.go

package data

import (
	"context"
	"database/sql"
	"time"
)

type Contribution struct {
	ID           int64     `json:"contribution_id"`
	ResourceID   int64     `json:"resource_id"`
	Score        float64   `json:"score"`
	CalculatedAt time.Time `json:"calculated_at"`
}

type ContributionModel struct {
	DB *sql.DB
}

// Insert a new contribution into the database
func (m ContributionModel) Insert(contribution *Contribution) error {
	query := `
		INSERT INTO contributions (resource_id, score)
		VALUES ($1, $2)
		RETURNING contribution_id, calculated_at`

	args := []any{
		contribution.ResourceID,
		contribution.Score,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&contribution.ID, &contribution.CalculatedAt)
}

// Get a contribution by ID
func (m ContributionModel) Get(id int64) (*Contribution, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT contribution_id, resource_id, score, calculated_at
		FROM contributions
		WHERE contribution_id = $1`

	var contribution Contribution

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&contribution.ID,
		&contribution.ResourceID,
		&contribution.Score,
		&contribution.CalculatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &contribution, nil
}

// Get a contribution by resource ID
func (m ContributionModel) GetByResourceID(resourceID int64) (*Contribution, error) {
	if resourceID < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT contribution_id, resource_id, score, calculated_at
		FROM contributions
		WHERE resource_id = $1`

	var contribution Contribution

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, resourceID).Scan(
		&contribution.ID,
		&contribution.ResourceID,
		&contribution.Score,
		&contribution.CalculatedAt,
	)

	if err != nil {
		switch {
		case err == sql.ErrNoRows:
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &contribution, nil
}

// Update a contribution
func (m ContributionModel) Update(contribution *Contribution) error {
	query := `
		UPDATE contributions
		SET score = $1, calculated_at = CURRENT_TIMESTAMP
		WHERE resource_id = $2
		RETURNING contribution_id, calculated_at`

	args := []any{
		contribution.Score,
		contribution.ResourceID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&contribution.ID, &contribution.CalculatedAt)
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

// Delete a contribution
func (m ContributionModel) Delete(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM contributions
		WHERE contribution_id = $1`

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

// Get all contributions ordered by score
func (m ContributionModel) GetAll(filters Filters) ([]*Contribution, Metadata, error) {
	query := `
		SELECT COUNT(*) OVER(), contribution_id, resource_id, score, calculated_at
		FROM contributions
		ORDER BY score DESC
		LIMIT $1 OFFSET $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{filters.limit(), filters.offset()}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, Metadata{}, err
	}
	defer rows.Close()

	totalRecords := 0
	contributions := []*Contribution{}

	for rows.Next() {
		var contribution Contribution
		err := rows.Scan(
			&totalRecords,
			&contribution.ID,
			&contribution.ResourceID,
			&contribution.Score,
			&contribution.CalculatedAt,
		)
		if err != nil {
			return nil, Metadata{}, err
		}
		contributions = append(contributions, &contribution)
	}

	if err = rows.Err(); err != nil {
		return nil, Metadata{}, err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return contributions, metadata, nil
}
