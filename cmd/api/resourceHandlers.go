// Filename: cmd/api/resourceHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createResourceHandler creates a new resource
func (a *app) createResourceHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title         string  `json:"title"`
		Category      string  `json:"category"`
		Subject       string  `json:"subject"`
		GradeLevel    string  `json:"grade_level"`
		ILO           string  `json:"ilo"`
		DriveLink     *string `json:"drive_link"`
		Status        string  `json:"status"`
		PublishedURL  *string `json:"published_url"`
		ContributorID int64   `json:"contributor_id"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	resource := &data.Resource{
		Title:         input.Title,
		Category:      input.Category,
		Subject:       input.Subject,
		GradeLevel:    input.GradeLevel,
		ILO:           input.ILO,
		DriveLink:     input.DriveLink,
		Status:        input.Status,
		PublishedURL:  input.PublishedURL,
		ContributorID: input.ContributorID,
	}

	v := validator.New()
	// TODO: Add resource validation
	v.Check(resource.Title != "", "title", "must be provided")
	v.Check(resource.Status != "", "status", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Resources.Insert(resource)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"resource": resource,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceHandler retrieves a specific resource by ID
func (a *app) getResourceHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	resource, err := a.models.Resources.Get(id)
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
		"resource": resource,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllResourcesHandler retrieves all resources with pagination and filtering
func (a *app) getAllResourcesHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	var input struct {
		Status     string
		Subject    string
		GradeLevel string
		data.Filters
	}

	v := validator.New()

	input.Status = a.getSingleQueryParameter(qs, "status", "")
	input.Subject = a.getSingleQueryParameter(qs, "subject", "")
	input.GradeLevel = a.getSingleQueryParameter(qs, "grade_level", "")

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "resource_id")
	input.Filters.SortSafelist = []string{"resource_id", "title", "created_at", "-resource_id", "-title", "-created_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	resources, metadata, err := a.models.Resources.GetAll(input.Status, input.Subject, input.GradeLevel, input.Filters)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"resources": resources,
		"metadata":  metadata,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateResourceHandler updates an existing resource
func (a *app) updateResourceHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	resource, err := a.models.Resources.Get(id)
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
		Title        *string `json:"title"`
		Category     *string `json:"category"`
		Subject      *string `json:"subject"`
		GradeLevel   *string `json:"grade_level"`
		ILO          *string `json:"ilo"`
		DriveLink    *string `json:"drive_link"`
		Status       *string `json:"status"`
		PublishedURL *string `json:"published_url"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Title != nil {
		resource.Title = *input.Title
	}
	if input.Category != nil {
		resource.Category = *input.Category
	}
	if input.Subject != nil {
		resource.Subject = *input.Subject
	}
	if input.GradeLevel != nil {
		resource.GradeLevel = *input.GradeLevel
	}
	if input.ILO != nil {
		resource.ILO = *input.ILO
	}
	if input.DriveLink != nil {
		resource.DriveLink = input.DriveLink
	}
	if input.Status != nil {
		resource.Status = *input.Status
	}
	if input.PublishedURL != nil {
		resource.PublishedURL = input.PublishedURL
	}

	v := validator.New()
	// TODO: Add resource validation
	v.Check(resource.Title != "", "title", "must be provided")
	v.Check(resource.Status != "", "status", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Resources.Update(resource)
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
		"resource": resource,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteResourceHandler deletes a resource
func (a *app) deleteResourceHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Resources.Delete(id)
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
		"message": "resource successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
