// Filename: cmd/api/resourceReviewHandlers.go

package main

import (
	"errors"
	"net/http"
	"os"
	"strings"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/services"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createResourceReviewHandler creates a new resource review
func (a *app) createResourceReviewHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ResourceID     int64  `json:"resource_id"`
		ReviewerID     int64  `json:"reviewer_id"`
		ReviewerRoleID int64  `json:"reviewer_role_id"`
		Decision       string `json:"decision"`
		CommentSummary string `json:"comment_summary"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	review := &data.ResourceReview{
		ResourceID:     input.ResourceID,
		ReviewerID:     input.ReviewerID,
		ReviewerRoleID: input.ReviewerRoleID,
		Decision:       input.Decision,
		CommentSummary: input.CommentSummary,
	}

	v := validator.New()
	// TODO: Add resource review validation
	v.Check(review.ResourceID > 0, "resource_id", "must be provided")
	v.Check(review.ReviewerID > 0, "reviewer_id", "must be provided")
	v.Check(review.Decision != "", "decision", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.ResourceReviews.Insert(review)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// Apply resource status transition based on the reviewer's decision.
	// "Rejected" moves the resource to NeedsRevision so the contributor can revise.
	// "Approved" moves the resource to the Approved stage.
	// Status update errors are returned to the caller so the frontend always
	// receives the real DB state (no silent failures).
	var updatedResource *data.Resource
	if review.ResourceID > 0 {
		resource, getErr := a.models.Resources.Get(review.ResourceID)
		if getErr != nil {
			a.serverErrorResponse(w, r, getErr)
			return
		}

		oldStatus := resource.Status
		switch review.Decision {
		case "Rejected":
			resource.Status = "NeedsRevision"
		case "Approved":
			resource.Status = "Approved"
		}

		if oldStatus != resource.Status {
			if updateErr := a.models.Resources.Update(resource); updateErr != nil {
				a.serverErrorResponse(w, r, updateErr)
				return
			}
			user := a.contextGetUser(r)
			a.logResourceStatusChange(resource.ID, oldStatus, resource.Status, user.ID)

			// Send notification to resource owner about review decision
			contributor, err := a.models.Users.Get(int(resource.ContributorID))
			if err != nil {
				a.logger.Error("failed to fetch contributor for review notification", "error", err)
			} else {
				actionRequired := resource.Status == "NeedsRevision"
				a.notificationHelper.AsyncNotifyResourceStatusChanged(
					contributor.Email,
					contributor.Username,
					resource.Title,
					oldStatus,
					resource.Status,
					review.CommentSummary,
					os.Getenv("DASHBOARD_URL"),
					actionRequired,
				)
			}

			// Trigger YouTube upload for approved Video resources only when
			// no published_url exists yet — prevents re-uploading after an
			// admin resets and re-approves an already-published video.
			if review.Decision == "Approved" && resource.Category == "Video" &&
				(resource.PublishedURL == nil || *resource.PublishedURL == "") {
				if a.youtubeUploader != nil {
					a.youtubeUploader.UploadResourceToYouTube(resource)
				} else {
					a.logger.Warn("video approved but YouTube uploader is not configured — skipping upload",
						"resource_id", resource.ID)
				}
			}

			// Calculate and award STEAM Points if resource is approved (FR-27)
			if review.Decision == "Approved" {
				// Prepare resource with lesson content for score calculation
				if strings.ToLower(resource.Category) == "lesson plan" {
					lessons, err := a.models.Lessons.GetByResource(resource.ID)
					if err == nil && len(lessons) > 0 {
						lesson := lessons[0]
						resource.LessonContent = &data.LessonContent{
							Objectives:           strings.Join(lesson.Objectives, "; "),
							Materials:            strings.Join(lesson.Materials, "; "),
							InstructionalContent: lesson.Content,
							Assessment:           a.derefString(lesson.Assessment),
							Differentiation:      a.derefString(lesson.Differentiation),
						}
					}
				}

				// Calculate STEAM Points for this resource
				points := services.CalculateSteamPoints([]data.Resource{*resource})

				// Award points to contributor (fellow)
				if points > 0 {
					// Get the fellow for this user (ContributorID is a user_id, not fellow_id)
					fellow, err := a.models.Fellows.GetByUserID(resource.ContributorID)
					if err != nil {
						a.logger.Warn("Could not find fellow for user when awarding STEAM Points",
							"user_id", resource.ContributorID,
							"resource_id", resource.ID,
							"points", points,
							"error", err.Error())
						// Don't fail the approval if fellow doesn't exist
					} else {
						// Update the fellow's steam points
						err := a.models.Fellows.UpdateSteamPoints(fellow.ID, points)
						if err != nil {
							a.logger.Error("Failed to update fellow steam points",
								"fellow_id", fellow.ID,
								"user_id", resource.ContributorID,
								"resource_id", resource.ID,
								"points", points,
								"error", err.Error())
							// Don't fail the approval if scoring fails — log and continue
						} else {
							a.logger.Info("STEAM Points awarded to contributor",
								"fellow_id", fellow.ID,
								"user_id", resource.ContributorID,
								"resource_id", resource.ID,
								"category", resource.Category,
								"points", points)
						}
					}
				}
			}
		}
		updatedResource = resource
	}

	response := envelope{
		"review": review,
	}
	if updatedResource != nil {
		response["resource"] = updatedResource
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getResourceReviewHandler retrieves a specific resource review by ID
func (a *app) getResourceReviewHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	review, err := a.models.ResourceReviews.Get(id)
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
		"review": review,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getReviewsByResourceIDHandler retrieves all reviews for a specific resource
func (a *app) getReviewsByResourceIDHandler(w http.ResponseWriter, r *http.Request) {
	resourceID := r.URL.Query().Get("resource_id")
	if resourceID == "" {
		a.badRequestResponse(w, r, errors.New("resource_id parameter is required"))
		return
	}

	v := validator.New()
	id := a.getSingleIntegerParameter(r.URL.Query(), "resource_id", 0, v)
	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	reviews, err := a.models.ResourceReviews.GetByResourceID(int64(id))
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"reviews": reviews,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllResourceReviewsHandler retrieves all resource reviews with pagination and filtering
func (a *app) getAllResourceReviewsHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a resource_id lookup request
	if resourceID := qs.Get("resource_id"); resourceID != "" {
		a.getReviewsByResourceIDHandler(w, r)
		return
	}

	var input struct {
		Decision string
		data.Filters
	}

	v := validator.New()

	input.Decision = a.getSingleQueryParameter(qs, "decision", "")

	input.Filters.Page = a.getSingleIntegerParameter(qs, "page", 1, v)
	input.Filters.PageSize = a.getSingleIntegerParameter(qs, "page_size", 20, v)
	input.Filters.Sort = a.getSingleQueryParameter(qs, "sort", "review_id")
	input.Filters.SortSafelist = []string{"review_id", "reviewed_at", "-review_id", "-reviewed_at"}

	if data.ValidateFilters(v, input.Filters); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	// TODO: Implement GetAll method in ResourceReviewModel
	// For now, return empty list
	reviews := []*data.ResourceReview{}
	metadata := data.Metadata{}

	// reviews, metadata, err := a.models.ResourceReviews.GetAll(input.Decision, input.Filters)
	// if err != nil {
	// 	a.serverErrorResponse(w, r, err)
	// 	return
	// }

	response := envelope{
		"reviews":  reviews,
		"metadata": metadata,
	}
	err := a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateResourceReviewHandler updates an existing resource review
func (a *app) updateResourceReviewHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	review, err := a.models.ResourceReviews.Get(id)
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
		Decision       *string `json:"decision"`
		CommentSummary *string `json:"comment_summary"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.Decision != nil {
		review.Decision = *input.Decision
	}
	if input.CommentSummary != nil {
		review.CommentSummary = *input.CommentSummary
	}

	v := validator.New()
	// TODO: Add resource review validation
	v.Check(review.ResourceID > 0, "resource_id", "must be provided")
	v.Check(review.ReviewerID > 0, "reviewer_id", "must be provided")
	v.Check(review.Decision != "", "decision", "must be provided")

	if !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.ResourceReviews.Update(review)
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
		"review": review,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteResourceReviewHandler deletes a resource review
func (a *app) deleteResourceReviewHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.ResourceReviews.Delete(id)
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
		"message": "review successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
