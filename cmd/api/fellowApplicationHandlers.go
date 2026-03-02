// filename: cmd/api/fellowApplicationHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// applyForFellowHandler handles POST /v1/fellow-applications.
// Only activated users with role "User" may apply; duplicate pending apps are
// blocked.
// NOTE: This route intentionally uses /fellow-applications (not /fellows/apply)
// to avoid httprouter's wildcard conflict with /fellows/:id — see routes.go.
func (a *app) applyForFellowHandler(w http.ResponseWriter, r *http.Request) {
	user := a.contextGetUser(r)

	// Verify the caller's role is "User"
	role, err := a.models.Roles.Get(user.RoleID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}
	if role.RoleName != "User" {
		a.errorResponseJSON(w, r, http.StatusForbidden,
			"only users with the 'User' role may submit a fellow application")
		return
	}

	// Prevent duplicate pending applications
	hasPending, err := a.models.FellowApplications.HasPendingApplication(user.ID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}
	if hasPending {
		a.errorResponseJSON(w, r, http.StatusConflict,
			"you already have a pending fellow application")
		return
	}

	var input struct {
		FullName        string   `json:"full_name"`
		Organization    string   `json:"organization"`
		Subjects        []string `json:"subjects"`
		GradeLevels     []string `json:"grade_levels"`
		ExperienceYears int      `json:"experience_years"`
		Bio             string   `json:"bio"`
		CredentialsLink string   `json:"credentials_link"`
	}

	if err := a.readJSON(w, r, &input); err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	app := &data.FellowApplication{
		UserID:          user.ID,
		FullName:        input.FullName,
		Organization:    input.Organization,
		Subjects:        input.Subjects,
		GradeLevels:     input.GradeLevels,
		ExperienceYears: input.ExperienceYears,
		Bio:             input.Bio,
		CredentialsLink: input.CredentialsLink,
	}

	v := validator.New()
	v.Check(app.FullName != "", "full_name", "must be provided")
	v.Check(len(app.FullName) <= 200, "full_name", "must not exceed 200 characters")
	v.Check(app.Organization != "", "organization", "must be provided")
	v.Check(len(app.Organization) <= 200, "organization", "must not exceed 200 characters")
	v.Check(len(app.Subjects) > 0, "subjects", "must include at least one subject")
	v.Check(len(app.GradeLevels) > 0, "grade_levels", "must include at least one grade level")
	v.Check(app.ExperienceYears >= 0, "experience_years", "must not be negative")
	v.Check(app.Bio != "", "bio", "must be provided")
	v.Check(len(app.Bio) <= 2000, "bio", "must not exceed 2000 characters")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	if err := a.models.FellowApplications.Insert(app); err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	err = a.writeJSON(w, http.StatusCreated, envelope{"application": app}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getMyFellowApplicationHandler handles GET /v1/fellows/apply/me.
// Returns the authenticated user's most recent application.
func (a *app) getMyFellowApplicationHandler(w http.ResponseWriter, r *http.Request) {
	user := a.contextGetUser(r)

	app, err := a.models.FellowApplications.GetByUserID(user.ID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"application": app}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminListFellowApplicationsHandler handles GET /v1/admin/fellow-applications.
// Accepts an optional ?status= query parameter to filter by Pending/Approved/Rejected.
func (a *app) adminListFellowApplicationsHandler(w http.ResponseWriter, r *http.Request) {
	statusFilter := r.URL.Query().Get("status")

	apps, err := a.models.FellowApplications.GetAll(statusFilter)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	if apps == nil {
		apps = []*data.FellowApplication{}
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"applications": apps}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminApproveFellowHandler handles PATCH /v1/admin/fellow-applications/:id/approve.
func (a *app) adminApproveFellowHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	reviewer := a.contextGetUser(r)

	if err := a.models.FellowApplications.Approve(id, reviewer.ID); err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK,
		envelope{"message": "application approved; user promoted to Fellow"}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// adminRejectFellowHandler handles PATCH /v1/admin/fellow-applications/:id/reject.
func (a *app) adminRejectFellowHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	reviewer := a.contextGetUser(r)

	if err := a.models.FellowApplications.Reject(id, reviewer.ID); err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			a.notFoundResponse(w, r)
		default:
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK,
		envelope{"message": "application rejected"}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
