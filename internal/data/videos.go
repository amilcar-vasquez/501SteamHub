// filename: internal/data/videos.go

package data

import (
	"context"
	"database/sql"
	"time"

	"github.com/lib/pq"
)

// VideoMetadata holds the YouTube-specific metadata for a Video resource.
// One row exists per Video resource; linked by resource_id.
type VideoMetadata struct {
	ID                 int64          `json:"id"`
	ResourceID         int64          `json:"resource_id"`
	YouTubeTitle       string         `json:"youtube_title"`
	YouTubeDescription string         `json:"youtube_description"`
	Tags               pq.StringArray `json:"tags"`
	PrivacyStatus      string         `json:"privacy_status"`
	MadeForKids        bool           `json:"made_for_kids"`
	CategoryID         int            `json:"category_id"`
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
}

type VideoModel struct {
	DB *sql.DB
}

// Insert saves a new VideoMetadata row.  Use InsertTx when you need to run
// inside an existing database transaction.
func (m VideoModel) Insert(vm *VideoMetadata) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if err = insertVideoMetadataTx(ctx, tx, vm); err != nil {
		return err
	}
	return tx.Commit()
}

// InsertTx inserts VideoMetadata within the given transaction.  The caller is
// responsible for committing or rolling back the transaction.
func (m VideoModel) InsertTx(ctx context.Context, tx *sql.Tx, vm *VideoMetadata) error {
	return insertVideoMetadataTx(ctx, tx, vm)
}

// insertVideoMetadataTx is the shared SQL logic used by Insert and InsertTx.
func insertVideoMetadataTx(ctx context.Context, tx *sql.Tx, vm *VideoMetadata) error {
	query := `
		INSERT INTO video_metadata
			(resource_id, youtube_title, youtube_description, tags, privacy_status, made_for_kids, category_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`

	args := []any{
		vm.ResourceID,
		vm.YouTubeTitle,
		vm.YouTubeDescription,
		vm.Tags,
		vm.PrivacyStatus,
		vm.MadeForKids,
		vm.CategoryID,
	}

	return tx.QueryRowContext(ctx, query, args...).Scan(&vm.ID, &vm.CreatedAt, &vm.UpdatedAt)
}

// GetByResource fetches the VideoMetadata for a given resource.
// Returns ErrRecordNotFound when no row exists (i.e. the resource is not a Video).
func (m VideoModel) GetByResource(resourceID int64) (*VideoMetadata, error) {
	query := `
		SELECT id, resource_id, youtube_title, youtube_description, tags,
		       privacy_status, made_for_kids, category_id, created_at, updated_at
		FROM video_metadata
		WHERE resource_id = $1`

	var vm VideoMetadata

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, resourceID).Scan(
		&vm.ID,
		&vm.ResourceID,
		&vm.YouTubeTitle,
		&vm.YouTubeDescription,
		&vm.Tags,
		&vm.PrivacyStatus,
		&vm.MadeForKids,
		&vm.CategoryID,
		&vm.CreatedAt,
		&vm.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}
	return &vm, nil
}

// Update modifies an existing VideoMetadata row.
func (m VideoModel) Update(vm *VideoMetadata) error {
	query := `
		UPDATE video_metadata
		SET youtube_title       = $1,
		    youtube_description = $2,
		    tags                = $3,
		    privacy_status      = $4,
		    made_for_kids       = $5,
		    category_id         = $6,
		    updated_at          = NOW()
		WHERE resource_id = $7
		RETURNING updated_at`

	args := []any{
		vm.YouTubeTitle,
		vm.YouTubeDescription,
		vm.Tags,
		vm.PrivacyStatus,
		vm.MadeForKids,
		vm.CategoryID,
		vm.ResourceID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&vm.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return ErrRecordNotFound
		}
		return err
	}
	return nil
}
