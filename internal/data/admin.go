// filename: internal/data/admin.go

package data

import (
	"context"
	"database/sql"
	"time"
)

// AdminMetrics holds dashboard-level aggregate counts for the admin panel.
type AdminMetrics struct {
	TotalUsers     int64 `json:"total_users"`
	TotalResources int64 `json:"total_resources"`
	Submitted      int64 `json:"submitted"`
	Approved       int64 `json:"approved"`
	Published      int64 `json:"published"`
	Archived       int64 `json:"archived"`
}

// AdminModel provides database operations used exclusively by the admin panel.
type AdminModel struct {
	DB *sql.DB
}

// GetMetrics returns aggregate counts across users and resources in one query.
func (m AdminModel) GetMetrics() (*AdminMetrics, error) {
	query := `
		SELECT
			(SELECT COUNT(*) FROM users)          AS total_users,
			COUNT(*)                               AS total_resources,
			COUNT(*) FILTER (WHERE status = 'Submitted')  AS submitted,
			COUNT(*) FILTER (WHERE status = 'Approved')   AS approved,
			COUNT(*) FILTER (WHERE status = 'Published')  AS published,
			COUNT(*) FILTER (WHERE status = 'Archived')   AS archived
		FROM resources`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var metrics AdminMetrics
	err := m.DB.QueryRowContext(ctx, query).Scan(
		&metrics.TotalUsers,
		&metrics.TotalResources,
		&metrics.Submitted,
		&metrics.Approved,
		&metrics.Published,
		&metrics.Archived,
	)
	if err != nil {
		return nil, err
	}
	return &metrics, nil
}
