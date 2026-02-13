// Filename: cmd/api/notificationHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createNotificationHandler creates a new notification
func (a *app) createNotificationHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID  int    `json:"user_id"`
		Message string `json:"message"`
		Channel string `json:"channel"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	notification := &data.Notification{
		UserID:  input.UserID,
		Message: input.Message,
		Channel: input.Channel,
	}

	v := validator.New()
	// TODO: Add notification validation
	v.Check(notification.UserID > 0, "user_id", "must be provided")
	v.Check(notification.Message != "", "message", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Notifications.Insert(notification)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"notification": notification,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getNotificationHandler retrieves a specific notification by ID
func (a *app) getNotificationHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	notification, err := a.models.Notifications.Get(int(id))
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
		"notification": notification,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getNotificationsByUserIDHandler retrieves all notifications for a specific user
func (a *app) getNotificationsByUserIDHandler(w http.ResponseWriter, r *http.Request) {
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

	notifications, err := a.models.Notifications.GetByUser(id)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"notifications": notifications,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllNotificationsHandler retrieves all notifications with optional user ID filter
func (a *app) getAllNotificationsHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a user_id lookup request
	if userID := qs.Get("user_id"); userID != "" {
		a.getNotificationsByUserIDHandler(w, r)
		return
	}

	var input struct {
		ReadStatus *bool
		data.Filters
	}

	v := validator.New()

	// Parse read status filter
	if readStr := qs.Get("read"); readStr != "" {
		if readStr == "true" {
			read := true
			input.ReadStatus = &read
		} else if readStr == "false" {
			read := false
			input.ReadStatus = &read
		} else {
			v.AddError("read", "must be true or false")
		}
	}

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "-sent_at")
	input.Filters.SortSafelist = []string{"notification_id", "sent_at", "-notification_id", "-sent_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement GetAll method in NotificationModel
	// For now, return empty list
	notifications := []*data.Notification{}
	metadata := data.Metadata{}

	// notifications, metadata, err := a.models.Notifications.GetAll(input.ReadStatus, input.Filters)
	// if err != nil {
	// 	a.serverErrorResponse(w, r, err)
	// 	return
	// }

	response := envelope{
		"notifications": notifications,
		"metadata":      metadata,
	}
	err := a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateNotificationHandler updates an existing notification (mainly for marking as read)
func (a *app) updateNotificationHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	notification, err := a.models.Notifications.Get(int(id))
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
		Read *bool `json:"read"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Read != nil {
		notification.Read = *input.Read
	}

	v := validator.New()
	// TODO: Add notification validation
	v.Check(notification.UserID > 0, "user_id", "must be provided")
	v.Check(notification.Message != "", "message", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement Update method in NotificationModel
	// For now, just return the notification as-is
	// err = a.models.Notifications.Update(notification)
	// if err != nil {
	// 	switch {
	// 	case errors.Is(err, data.ErrEditConflict):
	// 		a.editConflictResponse(w, r)
	// 	default:
	// 		a.serverErrorResponse(w, r, err)
	// 	}
	// 	return
	// }

	response := envelope{
		"notification": notification,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteNotificationHandler deletes a notification
func (a *app) deleteNotificationHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Notifications.Delete(int(id))
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
		"message": "notification successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
