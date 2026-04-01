//filename: internal/data/resource_links.go

package data

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// LinkedResource represents a resource that is linked from another resource
type LinkedResource struct {
	ResourceID       int64   `json:"resource_id"`
	Title            string  `json:"title"`
	Category         string  `json:"category"`
	Slug             *string `json:"slug,omitempty"`
	Summary          *string `json:"summary,omitempty"`
	RelationshipType string  `json:"relationship_type"`
	ContributorID    int64   `json:"contributor_id"`
	ContributorName  string  `json:"contributor_name,omitempty"`
}

// ResourceLink represents a relationship between two resources
type ResourceLink struct {
	LinkID           int64     `json:"link_id"`
	ParentID         int64     `json:"parent_resource_id"`
	LinkedID         int64     `json:"linked_resource_id"`
	RelationshipType string    `json:"relationship_type"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// ResourceLinksModel handles operations on resource links
type ResourceLinksModel struct {
	DB *sql.DB
}

// Insert creates a new resource link
func (m ResourceLinksModel) Insert(parentID int64, linkedID int64, relationshipType string) error {
	query := `
		INSERT INTO resource_links (parent_resource_id, linked_resource_id, relationship_type)
		VALUES ($1, $2, $3)
		RETURNING link_id, created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var linkID int64
	var createdAt, updatedAt time.Time

	err := m.DB.QueryRowContext(ctx, query, parentID, linkedID, relationshipType).Scan(&linkID, &createdAt, &updatedAt)
	if err != nil {
		return err
	}

	return nil
}

// GetByParent retrieves all linked resources for a given parent resource
func (m ResourceLinksModel) GetByParent(parentID int64) ([]*LinkedResource, error) {
	query := `
		SELECT r.resource_id, r.title, r.category, r.slug, r.summary, r.contributor_id,
		       COALESCE(f.first_name || ' ' || f.last_name, u.username, 'Unknown') AS contributor_name,
		       rl.relationship_type
		FROM resource_links rl
		JOIN resources r ON rl.linked_resource_id = r.resource_id
		LEFT JOIN fellows f ON f.user_id = r.contributor_id
		LEFT JOIN users u ON u.user_id = r.contributor_id
		WHERE rl.parent_resource_id = $1
		ORDER BY rl.created_at DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, parentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	linkedResources := []*LinkedResource{}

	for rows.Next() {
		var linked LinkedResource
		err := rows.Scan(
			&linked.ResourceID,
			&linked.Title,
			&linked.Category,
			&linked.Slug,
			&linked.Summary,
			&linked.ContributorID,
			&linked.ContributorName,
			&linked.RelationshipType,
		)
		if err != nil {
			return nil, err
		}
		linkedResources = append(linkedResources, &linked)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return linkedResources, nil
}

// GetByLinked retrieves all parent resources for a given linked resource
// This is useful for finding all resources that link TO this resource
func (m ResourceLinksModel) GetByLinked(linkedID int64) ([]*LinkedResource, error) {
	query := `
		SELECT r.resource_id, r.title, r.category, r.slug, r.summary, r.contributor_id,
		       COALESCE(f.first_name || ' ' || f.last_name, u.username, 'Unknown') AS contributor_name,
		       rl.relationship_type
		FROM resource_links rl
		JOIN resources r ON rl.parent_resource_id = r.resource_id
		LEFT JOIN fellows f ON f.user_id = r.contributor_id
		LEFT JOIN users u ON u.user_id = r.contributor_id
		WHERE rl.linked_resource_id = $1
		ORDER BY rl.created_at DESC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, linkedID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	linkedResources := []*LinkedResource{}

	for rows.Next() {
		var linked LinkedResource
		err := rows.Scan(
			&linked.ResourceID,
			&linked.Title,
			&linked.Category,
			&linked.Slug,
			&linked.Summary,
			&linked.ContributorID,
			&linked.ContributorName,
			&linked.RelationshipType,
		)
		if err != nil {
			return nil, err
		}
		linkedResources = append(linkedResources, &linked)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return linkedResources, nil
}

// Delete removes a resource link
func (m ResourceLinksModel) Delete(parentID int64, linkedID int64) error {
	query := `
		DELETE FROM resource_links
		WHERE parent_resource_id = $1 AND linked_resource_id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, parentID, linkedID)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("no link found between parent_resource_id %d and linked_resource_id %d", parentID, linkedID)
	}

	return nil
}

// Exists checks if a link already exists between two resources
func (m ResourceLinksModel) Exists(parentID int64, linkedID int64) (bool, error) {
	query := `
		SELECT 1 FROM resource_links
		WHERE parent_resource_id = $1 AND linked_resource_id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var exists int
	err := m.DB.QueryRowContext(ctx, query, parentID, linkedID).Scan(&exists)
	if err != nil {
		if err == sql.ErrNoRows {
			return false, nil
		}
		return false, err
	}

	return true, nil
}
