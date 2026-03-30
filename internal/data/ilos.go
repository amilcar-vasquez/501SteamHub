package data

import (
	"database/sql"
	"errors"
	"fmt"
)

// ILO represents an Intended Learning Outcome
type ILO struct {
	ID           int    `json:"id"`
	SubjectID    int    `json:"subject_id"`
	Subject      string `json:"subject"`
	GradeLevelID int    `json:"grade_level_id"`
	GradeLevel   string `json:"grade_level"`
	CycleID      int    `json:"cycle_id"`
	Cycle        int    `json:"cycle"`
	StrandID     int    `json:"strand_id"`
	Strand       string `json:"strand"`
	ILOCode      string `json:"ilo_code"`
	Description  string `json:"description"`
	CreatedAt    string `json:"created_at"`
	UpdatedAt    string `json:"updated_at"`
}

// ILOFilter holds filtering criteria for ILO queries
type ILOFilter struct {
	Subject    string
	GradeLevel string
	Cycle      int
	Strand     string
}

// ILOModel handles database operations for ILOs
type ILOModel struct {
	DB *sql.DB
}

// GetAllILOs returns all ILOs with optional filtering
func (m *ILOModel) GetAllILOs(filter *ILOFilter) ([]*ILO, error) {
	query := `
		SELECT 
			i.id, 
			i.subject_id, 
			s.subject, 
			i.grade_level_id, 
			gl.grade_level, 
			i.cycle_id, 
			i.cycle_id AS cycle,
			i.strand_id, 
			st.name AS strand, 
			i.ilo_code, 
			i.description, 
			i.created_at, 
			i.updated_at
		FROM ilos i
		JOIN subjects s ON i.subject_id = s.id
		JOIN grade_levels gl ON i.grade_level_id = gl.id
		JOIN strands st ON i.strand_id = st.id
		WHERE 1=1
	`

	var args []interface{}
	argCount := 1

	// Apply filters
	if filter != nil {
		if filter.Subject != "" {
			query += fmt.Sprintf(" AND s.subject = $%d", argCount)
			args = append(args, filter.Subject)
			argCount++
		}
		if filter.GradeLevel != "" {
			query += fmt.Sprintf(" AND gl.grade_level = $%d", argCount)
			args = append(args, filter.GradeLevel)
			argCount++
		}
		if filter.Cycle > 0 {
			query += fmt.Sprintf(" AND i.cycle_id = $%d", argCount)
			args = append(args, filter.Cycle)
			argCount++
		}
		if filter.Strand != "" {
			query += fmt.Sprintf(" AND st.name = $%d", argCount)
			args = append(args, filter.Strand)
			argCount++
		}
	}

	query += " ORDER BY s.subject, gl.grade_level, i.cycle_id, st.name, i.ilo_code"

	rows, err := m.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ilos []*ILO
	for rows.Next() {
		ilo := &ILO{}
		err := rows.Scan(
			&ilo.ID,
			&ilo.SubjectID,
			&ilo.Subject,
			&ilo.GradeLevelID,
			&ilo.GradeLevel,
			&ilo.CycleID,
			&ilo.Cycle,
			&ilo.StrandID,
			&ilo.Strand,
			&ilo.ILOCode,
			&ilo.Description,
			&ilo.CreatedAt,
			&ilo.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		ilos = append(ilos, ilo)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return ilos, nil
}

// GetILOByID returns a single ILO by its ID
func (m *ILOModel) GetILOByID(id int) (*ILO, error) {
	query := `
		SELECT 
			i.id, 
			i.subject_id, 
			s.subject, 
			i.grade_level_id, 
			gl.grade_level, 
			i.cycle_id, 
			i.cycle_id AS cycle,
			i.strand_id, 
			st.name AS strand, 
			i.ilo_code, 
			i.description, 
			i.created_at, 
			i.updated_at
		FROM ilos i
		JOIN subjects s ON i.subject_id = s.id
		JOIN grade_levels gl ON i.grade_level_id = gl.id
		JOIN strands st ON i.strand_id = st.id
		WHERE i.id = $1
	`

	ilo := &ILO{}
	err := m.DB.QueryRow(query, id).Scan(
		&ilo.ID,
		&ilo.SubjectID,
		&ilo.Subject,
		&ilo.GradeLevelID,
		&ilo.GradeLevel,
		&ilo.CycleID,
		&ilo.Cycle,
		&ilo.StrandID,
		&ilo.Strand,
		&ilo.ILOCode,
		&ilo.Description,
		&ilo.CreatedAt,
		&ilo.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}

	return ilo, nil
}

// GetSuggestedILOs returns ILOs matching resource metadata (smart narrowing)
// Filters by subject, grade level, and cycle if provided
func (m *ILOModel) GetSuggestedILOs(filter *ILOFilter) ([]*ILO, error) {
	return m.GetAllILOs(filter)
}

// GetOutcomesForResource returns all ILOs linked to a specific resource
func (m *ILOModel) GetOutcomesForResource(resourceID int) ([]*ILO, error) {
	query := `
		SELECT 
			i.id, 
			i.subject_id, 
			s.subject, 
			i.grade_level_id, 
			gl.grade_level, 
			i.cycle_id, 
			i.cycle_id AS cycle,
			i.strand_id, 
			st.name AS strand, 
			i.ilo_code, 
			i.description, 
			i.created_at, 
			i.updated_at
		FROM ilos i
		JOIN subjects s ON i.subject_id = s.id
		JOIN grade_levels gl ON i.grade_level_id = gl.id
		JOIN strands st ON i.strand_id = st.id
		JOIN resource_ilos ri ON i.id = ri.ilo_id
		WHERE ri.resource_id = $1
		ORDER BY s.subject, gl.grade_level, i.cycle_id, st.name, i.ilo_code
	`

	rows, err := m.DB.Query(query, resourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ilos []*ILO
	for rows.Next() {
		ilo := &ILO{}
		err := rows.Scan(
			&ilo.ID,
			&ilo.SubjectID,
			&ilo.Subject,
			&ilo.GradeLevelID,
			&ilo.GradeLevel,
			&ilo.CycleID,
			&ilo.Cycle,
			&ilo.StrandID,
			&ilo.Strand,
			&ilo.ILOCode,
			&ilo.Description,
			&ilo.CreatedAt,
			&ilo.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		ilos = append(ilos, ilo)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return ilos, nil
}

// AttachILOToResource links an ILO to a resource
func (m *ILOModel) AttachILOToResource(resourceID, iloID int) error {
	query := `
		INSERT INTO resource_ilos (resource_id, ilo_id)
		VALUES ($1, $2)
		ON CONFLICT (resource_id, ilo_id) DO NOTHING
	`

	_, err := m.DB.Exec(query, resourceID, iloID)
	return err
}

// RemoveILOFromResource unlinks an ILO from a resource
func (m *ILOModel) RemoveILOFromResource(resourceID, iloID int) error {
	query := `DELETE FROM resource_ilos WHERE resource_id = $1 AND ilo_id = $2`
	_, err := m.DB.Exec(query, resourceID, iloID)
	return err
}

// ReplaceResourceILOs replaces all ILOs for a resource with the provided list
func (m *ILOModel) ReplaceResourceILOs(resourceID int, iloIDs []int) error {
	tx, err := m.DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Delete existing ILO links
	_, err = tx.Exec("DELETE FROM resource_ilos WHERE resource_id = $1", resourceID)
	if err != nil {
		return err
	}

	// Insert new ILO links
	for _, iloID := range iloIDs {
		_, err = tx.Exec(
			"INSERT INTO resource_ilos (resource_id, ilo_id) VALUES ($1, $2)",
			resourceID, iloID,
		)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}
