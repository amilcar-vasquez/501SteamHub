package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	// Clear problematic postgres env variables from .envrc
	badVars := []string{
		"PGLOCALEDIR", "PGHASHDATADIR", "PGSYSCONFDIR",
		"PGDATADIR", "PGVERSION", "PGPATH",
	}
	for _, v := range badVars {
		os.Unsetenv(v)
	}

	// Connect to database
	dsn := "postgres://501SteamHub:STEAMAdmin501@localhost/501SteamHub?sslmode=disable"
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer db.Close()

	// Test connection
	if err := db.Ping(); err != nil {
		log.Fatalf("Connection failed: %v", err)
	}

	// Check tables
	fmt.Println("=== Database State ===")

	// Check for subjects table
	var subjectsExist bool
	err = db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM information_schema.tables 
			WHERE table_schema = 'public' AND table_name = 'subjects'
		)
	`).Scan(&subjectsExist)
	fmt.Printf("✓ Subjects table exists: %v\n", subjectsExist)

	// Check for grade_levels table
	var gradeLevelsExist bool
	err = db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM information_schema.tables 
			WHERE table_schema = 'public' AND table_name = 'grade_levels'
		)
	`).Scan(&gradeLevelsExist)
	fmt.Printf("✓ Grade levels table exists: %v\n", gradeLevelsExist)

	// Check resources count
	var resourceCount int
	db.QueryRow("SELECT COUNT(*) FROM resources").Scan(&resourceCount)
	fmt.Printf("✓ Resources count: %d\n", resourceCount)

	// Check resource_subjects count
	var rsCount int
	db.QueryRow("SELECT COUNT(*) FROM resource_subjects").Scan(&rsCount)
	fmt.Printf("✓ Resource subjects count: %d\n", rsCount)

	// Check migration history
	fmt.Println("\n=== Migration History ===")
	rows, _ := db.Query("SELECT version, dirty FROM schema_migrations ORDER BY version")
	defer rows.Close()
	for rows.Next() {
		var version int
		var dirty bool
		rows.Scan(&version, &dirty)
		dirtyStr := "clean"
		if dirty {
			dirtyStr = "DIRTY"
		}
		fmt.Printf("  Version %d: %s\n", version, dirtyStr)
	}

	// Clean up dirty migrations
	fmt.Println("\n=== Cleaning up ===")
	result, _ := db.Exec("DELETE FROM schema_migrations WHERE dirty = true")
	affected, _ := result.RowsAffected()
	if affected > 0 {
		fmt.Printf("✓ Removed %d dirty migrations\n", affected)
	}

	// Check again
	fmt.Println("\n=== Migration History (After Cleanup) ===")
	rows, _ = db.Query("SELECT version, dirty FROM schema_migrations ORDER BY version")
	defer rows.Close()
	for rows.Next() {
		var version int
		var dirty bool
		rows.Scan(&version, &dirty)
		fmt.Printf("  Version %d: %s\n", version, "clean")
	}
}
