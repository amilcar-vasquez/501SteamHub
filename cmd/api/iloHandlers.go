package main

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/julienschmidt/httprouter"
)

// getAllILOsHandler returns all ILOs with optional filtering and keyword search
// GET /v1/ilos?subject=X&grade=Y&cycle=Z&strand=S&keyword=K&limit=20&offset=0
func (a *app) getAllILOsHandler(w http.ResponseWriter, r *http.Request) {
	// Get and validate query parameters
	subject := r.URL.Query().Get("subject")
	gradeLevel := r.URL.Query().Get("grade")
	cycleStr := r.URL.Query().Get("cycle")
	keyword := r.URL.Query().Get("keyword")
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	var cycle int
	if cycleStr != "" {
		c, err := strconv.Atoi(cycleStr)
		if err != nil {
			a.badRequestResponse(w, r, errors.New("invalid cycle parameter"))
			return
		}
		cycle = c
	}

	var limit, offset int
	if limitStr != "" {
		l, err := strconv.Atoi(limitStr)
		if err != nil || l < 1 {
			a.badRequestResponse(w, r, errors.New("invalid limit parameter"))
			return
		}
		limit = l
	}
	if offsetStr != "" {
		o, err := strconv.Atoi(offsetStr)
		if err != nil || o < 0 {
			a.badRequestResponse(w, r, errors.New("invalid offset parameter"))
			return
		}
		offset = o
	}

	strand := r.URL.Query().Get("strand")

	// Build filter
	filter := &data.ILOFilter{
		Subject:    subject,
		GradeLevel: gradeLevel,
		Cycle:      cycle,
		Strand:     strand,
		Keyword:    keyword,
		Limit:      limit,
		Offset:     offset,
	}

	// Get ILOs
	ilos, err := a.models.ILOs.GetAllILOs(filter)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Return empty array instead of null for JSON consistency
	if ilos == nil {
		ilos = []*data.ILO{}
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"ilos": ilos}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getILOHandler returns a single ILO by ID
// GET /v1/ilos/:id
func (a *app) getILOHandler(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	id, err := strconv.Atoi(params.ByName("id"))
	if err != nil || id < 1 {
		a.badRequestResponse(w, r, errors.New("invalid ILO ID"))
		return
	}

	ilo, err := a.models.ILOs.GetILOByID(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"ilo": ilo}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getSuggestedILOsHandler returns ILOs with smart relevance-based ranking
// GET /v1/suggested-ilos?subject=X&grade=Y&cycle=Z&keyword=K&limit=25
func (a *app) getSuggestedILOsHandler(w http.ResponseWriter, r *http.Request) {
	// Get query parameters
	subject := r.URL.Query().Get("subject")
	gradeLevel := r.URL.Query().Get("grade")
	cycleStr := r.URL.Query().Get("cycle")
	keyword := r.URL.Query().Get("keyword")
	limitStr := r.URL.Query().Get("limit")

	var cycle int
	if cycleStr != "" {
		c, err := strconv.Atoi(cycleStr)
		if err != nil {
			a.badRequestResponse(w, r, errors.New("invalid cycle parameter"))
			return
		}
		cycle = c
	}

	var limit int
	if limitStr != "" {
		l, err := strconv.Atoi(limitStr)
		if err != nil || l < 1 {
			a.badRequestResponse(w, r, errors.New("invalid limit parameter"))
			return
		}
		limit = l
	}

	// Build filter (don't filter by strand for suggestions - let user browse)
	filter := &data.ILOFilter{
		Subject:    subject,
		GradeLevel: gradeLevel,
		Cycle:      cycle,
		Keyword:    keyword,
		Limit:      limit, // Default 25 in GetSuggestedILOs if not specified
	}

	// Get suggested ILOs (with relevance ranking)
	ilos, err := a.models.ILOs.GetSuggestedILOs(filter)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Return empty array instead of null for JSON consistency
	if ilos == nil {
		ilos = []*data.ILO{}
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"ilos": ilos}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceILOsHandler returns all ILOs linked to a resource
// GET /v1/resources/:id/ilos
func (a *app) getResourceILOsHandler(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	resourceID, err := strconv.Atoi(params.ByName("id"))
	if err != nil || resourceID < 1 {
		a.badRequestResponse(w, r, errors.New("invalid resource ID"))
		return
	}

	ilos, err := a.models.ILOs.GetOutcomesForResource(resourceID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Return empty array instead of null for JSON consistency
	if ilos == nil {
		ilos = []*data.ILO{}
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"ilos": ilos}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// AttachILORequest represents the request body for attaching ILOs to a resource
type AttachILORequest struct {
	ILOIDs []int `json:"ilo_ids"`
}

// attachResourceILOsHandler attaches/sets ILOs for a resource
// POST /v1/resources/:id/ilos
func (a *app) attachResourceILOsHandler(w http.ResponseWriter, r *http.Request) {
	params := httprouter.ParamsFromContext(r.Context())
	resourceID, err := strconv.Atoi(params.ByName("id"))
	if err != nil || resourceID < 1 {
		a.badRequestResponse(w, r, errors.New("invalid resource ID"))
		return
	}

	var req AttachILORequest
	err = a.readJSON(w, r, &req)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	// Validate ILO IDs
	if len(req.ILOIDs) == 0 {
		a.badRequestResponse(w, r, errors.New("ilo_ids must contain at least one ID"))
		return
	}

	// Replace existing ILOs with new ones
	err = a.models.ILOs.ReplaceResourceILOs(resourceID, req.ILOIDs)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Return the updated ILOs
	ilos, err := a.models.ILOs.GetOutcomesForResource(resourceID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusOK)
	err = a.writeJSON(w, http.StatusOK, envelope{"ilos": ilos}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
