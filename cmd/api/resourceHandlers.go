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
		Title         string   `json:"title"`
		Category      string   `json:"category"`
		Slug          *string  `json:"slug"`
		Summary       *string  `json:"summary"`
		Subjects      []string `json:"subjects"`
		GradeLevels   []string `json:"grade_levels"`
		DriveLink     *string  `json:"drive_link"`
		Status        string   `json:"status"`
		PublishedURL  *string  `json:"published_url"`
		ContributorID int64    `json:"contributor_id"`
	}

	// Log the incoming request
	a.logger.Info("Receiving resource creation request", "method", r.Method, "path", r.URL.Path)

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.logger.Error("Failed to read JSON", "error", err.Error())
		a.badRequestResponse(w, r, err)
		return
	}

	// Log the parsed input
	a.logger.Info("Parsed resource data",
		"title", input.Title,
		"category", input.Category,
		"subjects", input.Subjects,
		"grade_levels", input.GradeLevels,
		"contributor_id", input.ContributorID)

	resource := &data.Resource{
		Title:         input.Title,
		Category:      input.Category,
		Slug:          input.Slug,
		Summary:       input.Summary,
		DriveLink:     input.DriveLink,
		Status:        input.Status,
		PublishedURL:  input.PublishedURL,
		ContributorID: input.ContributorID,
	}

	v := validator.New()
	// Add comprehensive validation
	v.Check(resource.Title != "", "title", "must be provided")
	v.Check(len(resource.Title) <= 255, "title", "must not be more than 255 characters")
	v.Check(resource.Category != "", "category", "must be provided")
	v.Check(len(input.Subjects) > 0, "subjects", "at least one subject must be provided")
	v.Check(len(input.GradeLevels) > 0, "grade_levels", "at least one grade level must be provided")
	v.Check(resource.Status != "", "status", "must be provided")
	v.Check(resource.ContributorID > 0, "contributor_id", "must be provided")

	if !v.IsEmpty() {
		a.logger.Error("Validation failed", "errors", v.Errors)
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	a.logger.Info("Attempting to insert resource into database")
	err = a.models.Resources.Insert(resource)
	if err != nil {
		a.logger.Error("Failed to insert resource", "error", err.Error())
		a.serverErrorResponse(w, r, err)
		return
	}

	// Set subjects and grade levels
	if len(input.Subjects) > 0 {
		err = a.models.Resources.SetSubjects(resource.ID, input.Subjects)
		if err != nil {
			a.logger.Error("Failed to set subjects", "error", err.Error())
			a.serverErrorResponse(w, r, err)
			return
		}
	}

	if len(input.GradeLevels) > 0 {
		err = a.models.Resources.SetGradeLevels(resource.ID, input.GradeLevels)
		if err != nil {
			a.logger.Error("Failed to set grade levels", "error", err.Error())
			a.serverErrorResponse(w, r, err)
			return
		}
	}

	// Reload resource to get subjects and grade levels
	resource, err = a.models.Resources.Get(resource.ID)
	if err != nil {
		a.logger.Error("Failed to reload resource", "error", err.Error())
		a.serverErrorResponse(w, r, err)
		return
	}

	a.logger.Info("Resource created successfully", "resource_id", resource.ID)

	response := envelope{
		"resource": resource,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.logger.Error("Failed to write JSON response", "error", err.Error())
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
		Title        *string  `json:"title"`
		Category     *string  `json:"category"`
		Slug         *string  `json:"slug"`
		Summary      *string  `json:"summary"`
		Subjects     []string `json:"subjects"`
		GradeLevels  []string `json:"grade_levels"`
		DriveLink    *string  `json:"drive_link"`
		Status       *string  `json:"status"`
		PublishedURL *string  `json:"published_url"`
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
	if input.Slug != nil {
		resource.Slug = input.Slug
	}
	if input.Summary != nil {
		resource.Summary = input.Summary
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

	// Update subjects if provided
	if input.Subjects != nil {
		err = a.models.Resources.SetSubjects(resource.ID, input.Subjects)
		if err != nil {
			a.serverErrorResponse(w, r, err)
			return
		}
	}

	// Update grade levels if provided
	if input.GradeLevels != nil {
		err = a.models.Resources.SetGradeLevels(resource.ID, input.GradeLevels)
		if err != nil {
			a.serverErrorResponse(w, r, err)
			return
		}
	}

	// Reload resource to get updated subjects and grade levels
	resource, err = a.models.Resources.Get(resource.ID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
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
