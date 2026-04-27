// Filename: cmd/api/fellowHandlers.go

package main

import (
	"errors"
	"net/http"
	"strings"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createFellowHandler creates a new fellow profile
func (a *app) createFellowHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID                int64  `json:"user_id"`
		FirstName             string `json:"first_name"`
		LastName              string `json:"last_name"`
		BemisNumber           string `json:"bemis_number"`
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

	bemisNumber := strings.TrimSpace(input.BemisNumber)
	if bemisNumber == "" {
		bemisNumber = strings.TrimSpace(input.MoeIdentifier)
	}

	fellow := &data.Fellow{
		UserID:                input.UserID,
		FirstName:             input.FirstName,
		LastName:              input.LastName,
		BemisNumber:           bemisNumber,
		School:                a.refString(input.School),
		SubjectSpecialization: a.refString(input.SubjectSpecialization),
		District:              a.refString(input.District),
		ProfileStatus:         input.ProfileStatus,
	}

	v := validator.New()
	v.Check(fellow.FirstName != "", "first_name", "must be provided")
	v.Check(fellow.LastName != "", "last_name", "must be provided")
	v.Check(fellow.BemisNumber != "", "bemis_number", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Fellows.Insert(fellow)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"fellow": fellow,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getFellowHandler retrieves a specific fellow by ID
func (a *app) getFellowHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	fellow, err := a.models.Fellows.Get(id)
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
		"fellow": fellow,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getFellowByUserIDHandler retrieves a fellow by user ID
func (a *app) getFellowByUserIDHandler(w http.ResponseWriter, r *http.Request) {
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

	if id < 1 {
		a.badRequestResponse(w, r, errors.New("user_id must be a positive integer"))
		return
	}

	a.logger.Info("Fetching fellow by user_id", "user_id", id)

	fellow, err := a.models.Fellows.GetByUserID(int64(id))
	if err != nil {
		a.logger.Warn("Failed to fetch fellow by user_id",
			"user_id", id,
			"error", err.Error())
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	a.logger.Info("Successfully fetched fellow", "fellow_id", fellow.ID, "user_id", fellow.UserID)

	response := envelope{
		"fellow": fellow,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllFellowsHandler retrieves all fellows with pagination and filtering
func (a *app) getAllFellowsHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a user_id lookup request
	if userID := qs.Get("user_id"); userID != "" {
		a.getFellowByUserIDHandler(w, r)
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

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "fellow_id")
	input.Filters.SortSafelist = []string{"fellow_id", "last_name", "first_name", "created_at", "-fellow_id", "-last_name", "-first_name", "-created_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement GetAll method in FellowModel
	// For now, return empty list
	fellows := []*data.Fellow{}
	metadata := data.Metadata{}

	// fellows, metadata, err := a.models.Fellows.GetAll(input.District, input.SubjectSpecialization, input.ProfileStatus, input.Filters)
	// if err != nil {
	// 	a.serverErrorResponse(w, r, err)
	// 	return
	// }

	response := envelope{
		"fellows":  fellows,
		"metadata": metadata,
	}
	err := a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateFellowHandler updates an existing fellow
func (a *app) updateFellowHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	fellow, err := a.models.Fellows.Get(id)
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
		BemisNumber           *string `json:"bemis_number"`
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
		fellow.FirstName = *input.FirstName
	}
	if input.LastName != nil {
		fellow.LastName = *input.LastName
	}
	if input.BemisNumber != nil {
		fellow.BemisNumber = *input.BemisNumber
	} else if input.MoeIdentifier != nil {
		fellow.BemisNumber = *input.MoeIdentifier
	}
	if input.School != nil {
		fellow.School = input.School
	}
	if input.SubjectSpecialization != nil {
		fellow.SubjectSpecialization = input.SubjectSpecialization
	}
	if input.District != nil {
		fellow.District = input.District
	}
	if input.ProfileStatus != nil {
		fellow.ProfileStatus = *input.ProfileStatus
	}

	v := validator.New()
	v.Check(fellow.FirstName != "", "first_name", "must be provided")
	v.Check(fellow.LastName != "", "last_name", "must be provided")
	v.Check(fellow.BemisNumber != "", "bemis_number", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Fellows.Update(fellow)
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
		"fellow": fellow,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteFellowHandler deletes a fellow
func (a *app) deleteFellowHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Fellows.Delete(id)
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
		"message": "fellow successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
