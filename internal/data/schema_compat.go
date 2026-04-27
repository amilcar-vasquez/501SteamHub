package data

import (
	"context"
	"database/sql"
	"fmt"
	"sync"
	"time"
)

var (
	fellowIdentifierOnce        sync.Once
	fellowIdentifierColumn      string
	fellowVerificationOnce      sync.Once
	fellowVerificationColumn    string
	applicationIdentifierOnce   sync.Once
	applicationIdentifierColumn string
)

func getFellowIdentifierColumn(db *sql.DB) string {
	fellowIdentifierOnce.Do(func() {
		fellowIdentifierColumn = resolveColumnName(db, "fellows", []string{"bemis_number", "moe_identifier"}, "bemis_number")
	})

	return fellowIdentifierColumn
}

func getFellowVerificationColumn(db *sql.DB) string {
	fellowVerificationOnce.Do(func() {
		fellowVerificationColumn = resolveColumnName(db, "fellows", []string{"bemis_number_verified", "moe_identifier_verified"}, "bemis_number_verified")
	})

	return fellowVerificationColumn
}

func getApplicationIdentifierColumn(db *sql.DB) string {
	applicationIdentifierOnce.Do(func() {
		applicationIdentifierColumn = resolveColumnName(db, "fellow_applications", []string{"bemis_number", "moe_identifier"}, "bemis_number")
	})

	return applicationIdentifierColumn
}

func resolveColumnName(db *sql.DB, tableName string, candidates []string, fallback string) string {
	if db == nil {
		return fallback
	}

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	for _, candidate := range candidates {
		var exists bool
		err := db.QueryRowContext(ctx, `
			SELECT EXISTS (
				SELECT 1
				FROM information_schema.columns
				WHERE table_name = $1 AND column_name = $2
			)
		`, tableName, candidate).Scan(&exists)
		if err == nil && exists {
			return candidate
		}
	}

	return fallback
}

func quoteIdentifier(name string) string {
	return fmt.Sprintf("\"%s\"", name)
}
