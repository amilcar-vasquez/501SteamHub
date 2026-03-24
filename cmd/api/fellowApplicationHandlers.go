// filename: cmd/api/fellowApplicationHandlers.go

package main

import (
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/services"
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
		FirstName       string   `json:"first_name"`
		LastName        string   `json:"last_name"`
		Organization    string   `json:"organization"`
		MoeIdentifier   string   `json:"moe_identifier"`
		MoeDocPath      string   `json:"moe_doc_path"`
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
		FirstName:       input.FirstName,
		LastName:        input.LastName,
		Organization:    input.Organization,
		MoeIdentifier:   input.MoeIdentifier,
		MoeDocPath:      input.MoeDocPath,
		Subjects:        input.Subjects,
		GradeLevels:     input.GradeLevels,
		ExperienceYears: input.ExperienceYears,
		Bio:             input.Bio,
		CredentialsLink: input.CredentialsLink,
	}

	v := validator.New()
	v.Check(app.FirstName != "", "first_name", "must be provided")
	v.Check(len(app.FirstName) <= 100, "first_name", "must not exceed 100 characters")
	v.Check(app.LastName != "", "last_name", "must be provided")
	v.Check(len(app.LastName) <= 100, "last_name", "must not exceed 100 characters")
	v.Check(app.MoeIdentifier != "", "moe_identifier", "must be provided")
	v.Check(len(app.MoeIdentifier) <= 50, "moe_identifier", "must not exceed 50 characters")
	v.Check(app.MoeDocPath != "", "moe_doc_path", "must be provided")
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

	// Send notification to admins/DSC about new fellow application
	adminEmails := []string{"admin@example.com"} // TODO: Fetch from config or admin users list
	fullName := app.FirstName + " " + app.LastName
	a.notificationHelper.AsyncNotifyFellowApplicationSubmitted(
		adminEmails,
		fullName,
		user.Email,
		app.Organization,
		strings.Join(app.Subjects, ", "),
		strings.Join(app.GradeLevels, ", "),
		app.ExperienceYears,
		os.Getenv("DASHBOARD_URL"),
	)

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

	// Send approval notification to applicant
	app, err := a.models.FellowApplications.Get(id)
	if err == nil {
		user, err := a.models.Users.Get(int(app.UserID))
		if err != nil {
			a.logger.Error("failed to fetch user for approval notification", "error", err)
		} else {
			a.notificationHelper.AsyncNotifyFellowApplicationApproved(
				user.Email,
				user.Username,
				os.Getenv("DASHBOARD_URL"),
			)
		}
	} else {
		a.logger.Error("failed to fetch application for approval notification", "error", err)
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

	// Send rejection notification to applicant
	app, err := a.models.FellowApplications.Get(id)
	if err == nil {
		user, err := a.models.Users.Get(int(app.UserID))
		if err != nil {
			a.logger.Error("failed to fetch user for rejection notification", "error", err)
		} else {
			a.notificationHelper.AsyncNotifyFellowApplicationRejected(
				user.Email,
				user.Username,
			)
		}
	} else {
		a.logger.Error("failed to fetch application for rejection notification", "error", err)
	}

	err = a.writeJSON(w, http.StatusOK,
		envelope{"message": "application rejected"}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// uploadMoeDocumentHandler handles POST /v1/fellow-applications/moe-document/upload.
// Authenticated users upload their MOE verification documents (PDF, JPG, PNG).
// The file is validated strictly on the backend (type, size, content).
// Only the storage path (NOT public URL) is saved in the database.
func (a *app) uploadMoeDocumentHandler(w http.ResponseWriter, r *http.Request) {
	user := a.contextGetUser(r)

	// Set maximum request body size to 5MB + some overhead for multipart headers
	r.Body = http.MaxBytesReader(w, r.Body, 6<<20) // 6 MB limit

	// Parse multipart form (required before accessing FormFile)
	err := r.ParseMultipartForm(1 << 20) // 1 MB in-memory limit for form parsing
	if err != nil {
		a.errorResponseJSON(w, r, http.StatusBadRequest, "failed to parse multipart form: "+err.Error())
		return
	}

	// Get the file from the multipart form
	file, fileHeader, err := r.FormFile("moe_document")
	if err != nil {
		if err == http.ErrMissingFile {
			a.errorResponseJSON(w, r, http.StatusBadRequest, "file field (moe_document) is required")
		} else {
			a.errorResponseJSON(w, r, http.StatusBadRequest, "failed to retrieve file: "+err.Error())
		}
		return
	}
	defer file.Close()

	// Validate and save the file
	validator := services.NewMoeDocumentValidator()
	storagePath, err := validator.ValidateAndSaveFile(file, fileHeader.Filename, validator)
	if err != nil {
		// Determine the specific error to give appropriate HTTP status
		if strings.Contains(err.Error(), "file too large") {
			a.errorResponseJSON(w, r, http.StatusRequestEntityTooLarge, err.Error())
		} else if strings.Contains(err.Error(), "invalid file type") {
			a.errorResponseJSON(w, r, http.StatusBadRequest, err.Error())
		} else {
			a.errorResponseJSON(w, r, http.StatusBadRequest, "file validation failed: "+err.Error())
		}
		return
	}

	// Return the storage path to the client (not a public URL)
	err = a.writeJSON(w, http.StatusOK, envelope{
		"message":      "file uploaded successfully",
		"storage_path": storagePath,
		"user_id":      user.ID,
		"uploaded_at":  time.Now(),
	}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getMoeDocumentHandler handles GET /v1/admin/moe-documents/:storagePath.
// Only authenticated admin/reviewers can download MOE verification documents.
// Returns a time-limited access to the stored file.
func (a *app) getMoeDocumentHandler(w http.ResponseWriter, r *http.Request) {
	user := a.contextGetUser(r)

	// Check authorization: only admin or users with review permission
	role, err := a.models.Roles.Get(user.RoleID)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Only allow admin, DSC, and users with Fellow reviewer role
	allowedRoles := map[string]bool{
		"admin": true,
		"DSC":   true,
	}
	if !allowedRoles[role.RoleName] {
		a.errorResponseJSON(w, r, http.StatusForbidden, "you do not have permission to access MOE documents")
		return
	}

	// Get storage path from query parameter
	storagePath := r.URL.Query().Get("path")
	if storagePath == "" {
		a.errorResponseJSON(w, r, http.StatusBadRequest, "path parameter is required")
		return
	}

	// Retrieve the file from secure storage
	fileData, err := services.RetrieveSecureFile(storagePath)
	if err != nil {
		if strings.Contains(err.Error(), "access denied") {
			a.errorResponseJSON(w, r, http.StatusForbidden, err.Error())
		} else {
			a.errorResponseJSON(w, r, http.StatusNotFound, "document not found")
		}
		a.logger.Error("moe document retrieval error", "user_id", user.ID, "path", storagePath, "error", err)
		return
	}

	// Determine content type based on file extension
	contentType := "application/pdf"
	if strings.HasSuffix(storagePath, ".jpg") || strings.HasSuffix(storagePath, ".jpeg") {
		contentType = "image/jpeg"
	} else if strings.HasSuffix(storagePath, ".png") {
		contentType = "image/png"
	}

	// Set response headers for file download
	w.Header().Set("Content-Type", contentType)
	w.Header().Set("Content-Length", fmt.Sprintf("%d", len(fileData)))
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"moe-document%s\"",
		getExtensionFromPath(storagePath)))
	w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
	w.Header().Set("Pragma", "no-cache")

	// Write file to response
	_, err = w.Write(fileData)
	if err != nil {
		a.logger.Error("failed to write moe document response", "user_id", user.ID, "error", err)
	}
}

// getExtensionFromPath extracts file extension from storage path
func getExtensionFromPath(storagePath string) string {
	if strings.HasSuffix(storagePath, ".pdf") {
		return ".pdf"
	} else if strings.HasSuffix(storagePath, ".jpg") || strings.HasSuffix(storagePath, ".jpeg") {
		return ".jpg"
	} else if strings.HasSuffix(storagePath, ".png") {
		return ".png"
	}
	return ".bin"
}
