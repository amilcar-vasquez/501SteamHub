// Filename: cmd/api/commentHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createCommentHandler creates a new comment on a resource
func (a *app) createCommentHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID      int64  `json:"resource_id"`
		UserID          int64  `json:"user_id"`
		ParentCommentID *int64 `json:"parent_comment_id"`
		Content         string `json:"content"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	comment := &data.ResourceComment{
		ResourceID:      input.ResourceID,
		UserID:          input.UserID,
		ParentCommentID: input.ParentCommentID,
		Content:         input.Content,
	}

	v := validator.New()
	v.Check(comment.ResourceID > 0, "resource_id", "must be provided")
	v.Check(comment.UserID > 0, "user_id", "must be provided")
	v.Check(comment.Content != "", "content", "must be provided")
	v.Check(len(comment.Content) <= 2000, "content", "must not exceed 2000 characters")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.ResourceComments.Insert(comment)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"comment": comment,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getCommentHandler retrieves a specific comment by ID
func (a *app) getCommentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	comment, err := a.models.ResourceComments.Get(id)
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
		"comment": comment,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceCommentsHandler retrieves all comments for a resource
func (a *app) getResourceCommentsHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	comments, err := a.models.ResourceComments.GetByResource(id)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"comments": comments,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateCommentHandler updates an existing comment
func (a *app) updateCommentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	comment, err := a.models.ResourceComments.Get(id)
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
		Content *string `json:"content"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Content != nil {
		comment.Content = *input.Content
	}

	v := validator.New()
	v.Check(comment.Content != "", "content", "must be provided")
	v.Check(len(comment.Content) <= 2000, "content", "must not exceed 2000 characters")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.ResourceComments.Update(comment)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"comment": comment,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteCommentHandler deletes a comment
func (a *app) deleteCommentHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.ResourceComments.Delete(id)
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
		"message": "comment successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
