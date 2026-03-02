// filename: cmd/api/reviewCommentHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createReviewCommentHandler adds a granular reviewer comment to a resource.
// POST /v1/review-comments
//
// Accepted resource statuses: Submitted or UnderReview.
// If the resource is still Submitted, adding the first comment automatically
// transitions it to UnderReview, signalling that active review has begun.
func (a *app) createReviewCommentHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID int64   `json:"resource_id"`
		ReviewerID int64   `json:"reviewer_id"`
		Section    *string `json:"section"`
		BlockIndex *int    `json:"block_index"`
		Comment    string  `json:"comment"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	v.Check(input.ResourceID > 0, "resource_id", "must be provided")
	v.Check(input.ReviewerID > 0, "reviewer_id", "must be provided")
	v.Check(input.Comment != "", "comment", "must be provided")
	v.Check(len(input.Comment) <= 5000, "comment", "must not exceed 5000 characters")
	if input.Section != nil {
		v.Check(len(*input.Section) <= 100, "section", "must not exceed 100 characters")
	}
	if input.BlockIndex != nil {
		v.Check(*input.BlockIndex >= 0, "block_index", "must be a non-negative integer")
	}

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Fetch the resource
	resource, err := a.models.Resources.Get(input.ResourceID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	// Only allow comments on resources that are in the review pipeline
	if resource.Status != "Draft" && resource.Status != "Submitted" && resource.Status != "UnderReview" && resource.Status != "NeedsRevision" {
		a.errorResponseJSON(w, r, http.StatusUnprocessableEntity,
			"review comments can only be added to resources that are Draft, Submitted, UnderReview, or NeedsRevision")
		return
	}

	// Automatically advance Draft/Submitted/NeedsRevision → UnderReview when a reviewer adds the first comment.
	// This signals that active review has begun.
	if resource.Status == "Draft" || resource.Status == "Submitted" || resource.Status == "NeedsRevision" {
		oldStatus := resource.Status
		resource.Status = "UnderReview"
		if updateErr := a.models.Resources.Update(resource); updateErr == nil {
			user := a.contextGetUser(r)
			a.logResourceStatusChange(resource.ID, oldStatus, "UnderReview", user.ID)
		} else {
			a.logger.Error("failed to auto-transition resource to UnderReview",
				"resource_id", resource.ID, "error", updateErr)
		}
	}

	rc := &data.ReviewComment{
		ResourceID: input.ResourceID,
		ReviewerID: input.ReviewerID,
		Section:    input.Section,
		BlockIndex: input.BlockIndex,
		Comment:    input.Comment,
	}

	err = a.models.ReviewComments.Insert(rc)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	err = a.writeJSON(w, http.StatusCreated, envelope{"review_comment": rc}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getReviewCommentsByResourceHandler returns all review comments for a resource.
// GET /v1/resources/:id/review-comments
func (a *app) getReviewCommentsByResourceHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	// Confirm the resource exists
	_, err = a.models.Resources.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	comments, err := a.models.ReviewComments.GetByResourceID(id)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"review_comments": comments}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// resolveReviewCommentHandler marks a single review comment as resolved.
// PATCH /v1/review-comments/:id/resolve
func (a *app) resolveReviewCommentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	rc, err := a.models.ReviewComments.Resolve(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			// ErrRecordNotFound is returned when the comment doesn't exist OR
			// it is already resolved (the UPDATE WHERE resolved=FALSE matched nothing).
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"review_comment": rc}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
