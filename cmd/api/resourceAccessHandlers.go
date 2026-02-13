// Filename: cmd/api/resourceAccessHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createResourceAccessHandler creates a new resource access record
func (a *app) createResourceAccessHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID int64 `json:"resource_id"`
		UserID     int64 `json:"user_id"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	access := &data.ResourceAccess{
		ResourceID: input.ResourceID,
		UserID:     input.UserID,
	}

	v := validator.New()
	// TODO: Add resource access validation
	v.Check(access.ResourceID > 0, "resource_id", "must be provided")
	v.Check(access.UserID > 0, "user_id", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.ResourceAccess.Insert(access)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"access": access,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceAccessHandler retrieves a specific resource access record by ID
func (a *app) getResourceAccessHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	access, err := a.models.ResourceAccess.Get(id)
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
		"access": access,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAccessByResourceIDHandler retrieves all access records for a specific resource
func (a *app) getAccessByResourceIDHandler(w http.ResponseWriter, r *http.Request) {
	resourceID := r.URL.Query().Get("resource_id")
	if resourceID == "" {
		a.badRequestResponse(w, r, errors.New("resource_id parameter is required"))
		return
	}

	qs := r.URL.Query()
	v := validator.New()

	id := a.getSingleIntegerParameter(qs, "resource_id", 0, v)
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	var input struct {
		data.Filters
	}

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "-accessed_at")
	input.Filters.SortSafelist = []string{"access_id", "accessed_at", "-access_id", "-accessed_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	accessRecords, metadata, err := a.models.ResourceAccess.GetByResourceID(int64(id), input.Filters)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"access":   accessRecords,
		"metadata": metadata,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAccessByUserIDHandler retrieves all access records for a specific user
func (a *app) getAccessByUserIDHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		a.badRequestResponse(w, r, errors.New("user_id parameter is required"))
		return
	}

	qs := r.URL.Query()
	v := validator.New()

	id := a.getSingleIntegerParameter(qs, "user_id", 0, v)
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	var input struct {
		data.Filters
	}

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "-accessed_at")
	input.Filters.SortSafelist = []string{"access_id", "accessed_at", "-access_id", "-accessed_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	accessRecords, metadata, err := a.models.ResourceAccess.GetByUserID(int64(id), input.Filters)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"access":   accessRecords,
		"metadata": metadata,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllResourceAccessHandler retrieves all resource access records with pagination
func (a *app) getAllResourceAccessHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a resource_id or user_id lookup request
	if resourceID := qs.Get("resource_id"); resourceID != "" {
		a.getAccessByResourceIDHandler(w, r)
		return
	}
	if userID := qs.Get("user_id"); userID != "" {
		a.getAccessByUserIDHandler(w, r)
		return
	}

	var input struct {
		data.Filters
	}

	v := validator.New()

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "-accessed_at")
	input.Filters.SortSafelist = []string{"access_id", "accessed_at", "-access_id", "-accessed_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement GetAll method in ResourceAccessModel
	// For now, return empty list
	accessRecords := []*data.ResourceAccess{}
	metadata := data.Metadata{}

	// accessRecords, metadata, err := a.models.ResourceAccess.GetAll(input.Filters)
	// if err != nil {
	// 	a.serverErrorResponse(w, r, err)
	// 	return
	// }

	response := envelope{
		"access":   accessRecords,
		"metadata": metadata,
	}
	err := a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteResourceAccessHandler deletes a resource access record
func (a *app) deleteResourceAccessHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.ResourceAccess.Delete(id)
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
		"message": "resource access record successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
