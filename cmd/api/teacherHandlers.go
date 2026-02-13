// Filename: cmd/api/teacherHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createTeacherHandler creates a new teacher profile
func (a *app) createTeacherHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID                int64  `json:"user_id"`
		FirstName             string `json:"first_name"`
		LastName              string `json:"last_name"`
		MoeIdentifier         string `json:"moe_identifier"`
		School                string `json:"school"`
		SubjectSpecialization string `json:"subject_specialization"`
		District              string `json:"district"`
		ProfileStatus         string `json:"profile_status"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	teacher := &data.Teacher{
		UserID:                input.UserID,
		FirstName:             input.FirstName,
		LastName:              input.LastName,
		MoeIdentifier:         input.MoeIdentifier,
		School:                input.School,
		SubjectSpecialization: input.SubjectSpecialization,
		District:              input.District,
		ProfileStatus:         input.ProfileStatus,
	}

	v := validator.New()
	// TODO: Add teacher validation
	v.Check(teacher.FirstName != "", "first_name", "must be provided")
	v.Check(teacher.LastName != "", "last_name", "must be provided")
	v.Check(teacher.MoeIdentifier != "", "moe_identifier", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Teachers.Insert(teacher)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"teacher": teacher,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getTeacherHandler retrieves a specific teacher by ID
func (a *app) getTeacherHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	teacher, err := a.models.Teachers.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"teacher": teacher,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getTeacherByUserIDHandler retrieves a teacher by user ID
func (a *app) getTeacherByUserIDHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		a.badRequestResponse(w, r, errors.New("user_id parameter is required"))
		return
	}

	v := validator.New()
	id := a.getSingleIntegerParameter(r.URL.Query(), "user_id", 0, v)
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	teacher, err := a.models.Teachers.GetByUserID(int64(id))
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"teacher": teacher,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllTeachersHandler retrieves all teachers with pagination and filtering
func (a *app) getAllTeachersHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a user_id lookup request
	if userID := qs.Get("user_id"); userID != "" {
		a.getTeacherByUserIDHandler(w, r)
		return
	}

	var input struct {
		District              string
		SubjectSpecialization string
		ProfileStatus         string
		data.Filters
	}

	v := validator.New()

	input.District = a.getSingleQueryParameter(qs, "district", "")
	input.SubjectSpecialization = a.getSingleQueryParameter(qs, "subject_specialization", "")
	input.ProfileStatus = a.getSingleQueryParameter(qs, "profile_status", "")

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "teacher_id")
	input.Filters.SortSafelist = []string{"teacher_id", "last_name", "first_name", "created_at", "-teacher_id", "-last_name", "-first_name", "-created_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement GetAll method in TeacherModel
	// For now, return empty list
	teachers := []*data.Teacher{}
	metadata := data.Metadata{}

	// teachers, metadata, err := a.models.Teachers.GetAll(input.District, input.SubjectSpecialization, input.ProfileStatus, input.Filters)
	// if err != nil {
	// 	a.serverErrorResponse(w, r, err)
	// 	return
	// }

	response := envelope{
		"teachers": teachers,
		"metadata": metadata,
	}
	err := a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateTeacherHandler updates an existing teacher
func (a *app) updateTeacherHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	teacher, err := a.models.Teachers.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	var input struct {
		FirstName             *string `json:"first_name"`
		LastName              *string `json:"last_name"`
		MoeIdentifier         *string `json:"moe_identifier"`
		School                *string `json:"school"`
		SubjectSpecialization *string `json:"subject_specialization"`
		District              *string `json:"district"`
		ProfileStatus         *string `json:"profile_status"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.FirstName != nil {
		teacher.FirstName = *input.FirstName
	}
	if input.LastName != nil {
		teacher.LastName = *input.LastName
	}
	if input.MoeIdentifier != nil {
		teacher.MoeIdentifier = *input.MoeIdentifier
	}
	if input.School != nil {
		teacher.School = *input.School
	}
	if input.SubjectSpecialization != nil {
		teacher.SubjectSpecialization = *input.SubjectSpecialization
	}
	if input.District != nil {
		teacher.District = *input.District
	}
	if input.ProfileStatus != nil {
		teacher.ProfileStatus = *input.ProfileStatus
	}

	v := validator.New()
	// TODO: Add teacher validation
	v.Check(teacher.FirstName != "", "first_name", "must be provided")
	v.Check(teacher.LastName != "", "last_name", "must be provided")
	v.Check(teacher.MoeIdentifier != "", "moe_identifier", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Teachers.Update(teacher)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			a.editConflictResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"teacher": teacher,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteTeacherHandler deletes a teacher
func (a *app) deleteTeacherHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Teachers.Delete(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	response := envelope{
		"message": "teacher successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
