// Filename: cmd/api/contributionHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createContributionHandler creates a new contribution record
func (a *app) createContributionHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID int64   `json:"resource_id"`
		Score      float64 `json:"score"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	contribution := &data.Contribution{
		ResourceID: input.ResourceID,
		Score:      input.Score,
	}

	v := validator.New()
	// TODO: Add contribution validation
	v.Check(contribution.ResourceID > 0, "resource_id", "must be provided")
	v.Check(contribution.Score >= 0, "score", "must be a positive number")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Contributions.Insert(contribution)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"contribution": contribution,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getContributionHandler retrieves a specific contribution by ID
func (a *app) getContributionHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	contribution, err := a.models.Contributions.Get(id)
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
		"contribution": contribution,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getContributionByResourceIDHandler retrieves a contribution by resource ID
func (a *app) getContributionByResourceIDHandler(w http.ResponseWriter, r *http.Request) {
	resourceID := r.URL.Query().Get("resource_id")
	if resourceID == "" {
		a.badRequestResponse(w, r, errors.New("resource_id parameter is required"))
		return
	}

	v := validator.New()
	id := a.getSingleIntegerParameter(r.URL.Query(), "resource_id", 0, v)
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	contribution, err := a.models.Contributions.GetByResourceID(int64(id))
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
		"contribution": contribution,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllContributionsHandler retrieves all contributions with pagination and filtering
func (a *app) getAllContributionsHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a resource_id lookup request
	if resourceID := qs.Get("resource_id"); resourceID != "" {
		a.getContributionByResourceIDHandler(w, r)
		return
	}

	var input struct {
		MinScore *float64
		MaxScore *float64
		data.Filters
	}

	v := validator.New()

	// TODO: Add score filtering support
	// For now, ignore min_score and max_score parameters

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "-score")
	input.Filters.SortSafelist = []string{"contribution_id", "score", "calculated_at", "-contribution_id", "-score", "-calculated_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	contributions, metadata, err := a.models.Contributions.GetAll(input.Filters)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"contributions": contributions,
		"metadata":      metadata,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateContributionHandler updates an existing contribution
func (a *app) updateContributionHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	contribution, err := a.models.Contributions.Get(id)
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
		Score *float64 `json:"score"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Score != nil {
		contribution.Score = *input.Score
	}

	v := validator.New()
	// TODO: Add contribution validation
	v.Check(contribution.ResourceID > 0, "resource_id", "must be provided")
	v.Check(contribution.Score >= 0, "score", "must be a positive number")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Contributions.Update(contribution)
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
		"contribution": contribution,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteContributionHandler deletes a contribution
func (a *app) deleteContributionHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Contributions.Delete(id)
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
		"message": "contribution successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
