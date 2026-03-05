// filename: internal/data/resource_status_history.go

package data

import (
	"context"
	"database/sql"
	"time"
)

// ResourceStatusHistory records every status transition for a resource.
type ResourceStatusHistory struct {
	ID         int64     `json:"history_id"`
	ResourceID int64     `json:"resource_id"`
	OldStatus  *string   `json:"old_status,omitempty"`
	NewStatus  string    `json:"new_status"`
	ChangedBy  *int64    `json:"changed_by,omitempty"`
	ChangedAt  time.Time `json:"changed_at"`
}

type ResourceStatusHistoryModel struct {
	DB *sql.DB
}

// Insert records a new status-change event.
func (m ResourceStatusHistoryModel) Insert(h *ResourceStatusHistory) error {
	query := `
		INSERT INTO resource_status_history
			(resource_id, old_status, new_status, changed_by)
		VALUES ($1, $2, $3, $4)
		RETURNING history_id, changed_at`

	args := []any{
		h.ResourceID,
		h.OldStatus,
		h.NewStatus,
		h.ChangedBy,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&h.ID, &h.ChangedAt)
}

// GetByResourceID returns the full status history for a resource, newest first.
func (m ResourceStatusHistoryModel) GetByResourceID(resourceID int64) ([]*ResourceStatusHistory, error) {
	query := `
		SELECT history_id, resource_id, old_status, new_status, changed_by, changed_at
		FROM   resource_status_history
		WHERE  resource_id = $1
		ORDER  BY changed_at DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var history []*ResourceStatusHistory

	for rows.Next() {
		var h ResourceStatusHistory
		err := rows.Scan(
			&h.ID,
			&h.ResourceID,
			&h.OldStatus,
			&h.NewStatus,
			&h.ChangedBy,
			&h.ChangedAt,
		)
		if err != nil {
			return nil, err
		}
		history = append(history, &h)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	if history == nil {
		history = []*ResourceStatusHistory{}
	}

	return history, nil
}
