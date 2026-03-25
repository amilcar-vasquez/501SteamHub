// Filename: cmd/api/adminHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// validResourceStatuses is the exhaustive set accepted by the override endpoint.
var validResourceStatuses = []string{
	"Draft", "Submitted", "UnderReview", "NeedsRevision",
	"Rejected", "Approved", "DesignCurate", "Published", "Indexed", "Archived",
}

// overrideResourceStatusHandler sets the status of a resource to any valid
// value without the normal workflow restrictions.
//
// POST /v1/resources/:id/status
func (a *app) overrideResourceStatusHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	var input struct {
		Status string `json:"status"`
		Reason string `json:"reason"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	v.Check(input.Status != "", "status", "must be provided")
	v.Check(validator.PermittedValue(input.Status, validResourceStatuses...), "status", "must be a valid resource_status value")
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
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

	oldStatus := resource.Status
	resource.Status = input.Status

	if err := a.models.Resources.Update(resource); err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	// Record the status change in the audit history.
	actor := a.contextGetUser(r)
	var changedBy *int64
	if !actor.IsAnonymous() {
		cid := actor.ID
		changedBy = &cid
	}
	history := &data.ResourceStatusHistory{
		ResourceID: resource.ID,
		OldStatus:  &oldStatus,
		NewStatus:  input.Status,
		ChangedBy:  changedBy,
	}
	if err := a.models.ResourceStatusHistory.Insert(history); err != nil {
		// Non-fatal — log and continue so the response still succeeds.
		a.logger.Error("failed to write status history", "error", err)
	}

	if input.Reason != "" {
		a.logger.Info("resource status override",
			"resource_id", resource.ID,
			"old_status", oldStatus,
			"new_status", input.Status,
			"reason", input.Reason,
			"changed_by", changedBy,
		)
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"resource": resource}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminMetricsHandler returns aggregate counts for the admin dashboard.
//
// GET /v1/admin/metrics
func (a *app) adminMetricsHandler(w http.ResponseWriter, r *http.Request) {
	metrics, err := a.models.Admin.GetMetrics()
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"metrics": metrics}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminCreateUserHandler creates a new user account with any assignable role.
// Admin-created accounts are activated immediately (no email step).
//
// POST /v1/admin/users
func (a *app) adminCreateUserHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Password string `json:"password"`
		RoleID   int    `json:"role_id"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.RoleID == 0 {
		input.RoleID = 2 // default non-admin role
	}

	user := &data.User{
		Username: input.Username,
		Email:    input.Email,
		RoleID:   input.RoleID,
		IsActive: true, // admin-created users skip email activation
	}

	if err := user.Password.Set(input.Password); err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	v := validator.New()
	if data.ValidateUser(v, user); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	if err := a.models.Users.Insert(user); err != nil {
		switch {
		case errors.Is(err, data.ErrDuplicateEmail):
			v.AddError("email", "email address already in use")
			a.failedValidationResponse(w, r, v.Errors)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err := a.writeJSON(w, http.StatusCreated, envelope{"user": user}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminUpdateUserHandler performs a full update of any user record.
//
// PUT /v1/admin/users/:id
func (a *app) adminUpdateUserHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	user, err := a.models.Users.Get(int(id))
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
		Username *string `json:"username"`
		Email    *string `json:"email"`
		Password *string `json:"password"`
		RoleID   *int    `json:"role_id"`
		IsActive *bool   `json:"is_active"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Username != nil {
		user.Username = *input.Username
	}
	if input.Email != nil {
		user.Email = *input.Email
	}
	if input.RoleID != nil {
		user.RoleID = *input.RoleID
	}
	if input.IsActive != nil {
		user.IsActive = *input.IsActive
	}
	if input.Password != nil {
		if err := user.Password.Set(*input.Password); err != nil {
			a.serverErrorResponse(w, r, err)
			return
		}
	}

	v := validator.New()
	if data.ValidateUser(v, user); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	if err := a.models.Users.Update(user); err != nil {
		switch {
		case errors.Is(err, data.ErrDuplicateEmail):
			v.AddError("email", "email address already in use")
			a.failedValidationResponse(w, r, v.Errors)
		case errors.Is(err, data.ErrEditConflict):
			a.editConflictResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"user": user}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminUpdateUserRoleHandler changes only the role_id of a user.
// Prevents any user from changing role_id to/from 1 (admin role) to prevent
// accidental loss of admin access or intentional privilege escalation.
//
// PATCH /v1/admin/users/:id/role
func (a *app) adminUpdateUserRoleHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	user, err := a.models.Users.Get(int(id))
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
		RoleID int `json:"role_id"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	v.Check(input.RoleID > 0, "role_id", "must be a positive integer")

	// Prevent any changes to/from admin role (role_id = 1) for security
	adminRoleID := 1
	if user.RoleID == adminRoleID || input.RoleID == adminRoleID {
		// If either the old or new role is admin, reject the change
		if user.RoleID == adminRoleID && input.RoleID != adminRoleID {
			v.Check(false, "role_id", "cannot remove admin privileges from an admin user")
		} else if user.RoleID != adminRoleID && input.RoleID == adminRoleID {
			v.Check(false, "role_id", "cannot assign admin role to non-admin users")
		}
	}

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	user.RoleID = input.RoleID

	if err := a.models.Users.Update(user); err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			a.editConflictResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"user": user}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminToggleUserActiveHandler sets the is_active flag of a user.
//
// PATCH /v1/admin/users/:id/active
func (a *app) adminToggleUserActiveHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	user, err := a.models.Users.Get(int(id))
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
		IsActive bool `json:"is_active"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	user.IsActive = input.IsActive

	if err := a.models.Users.Update(user); err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			a.editConflictResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"user": user}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminSendEmailHandler allows an admin to send a custom email to a user
//
// POST /v1/admin/users/:id/send-email
func (a *app) adminSendEmailHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	var input struct {
		Subject string `json:"subject"`
		Body    string `json:"body"`
	}
	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	v.Check(input.Subject != "", "subject", "must be provided")
	v.Check(input.Body != "", "body", "must be provided")
	v.Check(len(input.Subject) <= 255, "subject", "must not exceed 255 characters")
	v.Check(len(input.Body) <= 5000, "body", "must not exceed 5000 characters")
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Get the user
	user, err := a.models.Users.Get(int(id))
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	// Send the email
	data := map[string]string{
		"subject": input.Subject,
		"body":    input.Body,
	}
	if err := a.mailer.Send(user.Email, "admin_custom.tmpl", data); err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Return success
	response := envelope{
		"message": "Email sent successfully",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
