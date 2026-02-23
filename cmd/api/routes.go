package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func (a *app) routes() http.Handler {

	const apiV1Route = "/v1"

	// Initialize the router
	router := httprouter.New()

	// handle 404
	router.NotFound = http.HandlerFunc(a.notFoundResponse)

	// Define API routes
	router.HandlerFunc(http.MethodGet, apiV1Route+"/healthcheck", a.healthCheckHandler)

	// !User routes
	// *-- Register a New User (public) -- *
	router.HandlerFunc(http.MethodPost, apiV1Route+"/users", a.registerUserHandler)
	// *-- Activate a User (public) -- *
	router.HandlerFunc(http.MethodPut, apiV1Route+"/users/activated", a.activateUserHandler)

	// Protected user routes - admin, CEO, DEC, TSC can view all users (must be activated)
	router.Handler(http.MethodGet, apiV1Route+"/users", a.requireAnyRole([]string{"admin", "CEO", "DEC", "TSC"}, http.HandlerFunc(a.getAllUsersHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/users/:id", a.requireActivatedUser(a.getUserHandler))
	// admin, CEO, and DEC can update users (must be activated)
	router.Handler(http.MethodPatch, apiV1Route+"/users/:id", a.requireActivatedUser(a.updateUserHandler))
	// Only admin can delete users (must be activated)
	router.Handler(http.MethodDelete, apiV1Route+"/users/:id",
		a.requireRole("admin", http.HandlerFunc(a.deleteUserHandler)))

	// Role routes - Only admin can manage roles (must be activated)
	router.Handler(http.MethodPost, apiV1Route+"/roles",
		a.requireRole("admin", http.HandlerFunc(a.createRoleHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/roles",
		http.HandlerFunc(a.getAllRolesHandler))
	router.Handler(http.MethodGet, apiV1Route+"/roles/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getRoleHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/roles/:id",
		a.requireRole("admin", http.HandlerFunc(a.updateRoleHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/roles/:id",
		a.requireRole("admin", http.HandlerFunc(a.deleteRoleHandler)))

	// Teacher routes - All authenticated users can list/view
	router.Handler(http.MethodGet, apiV1Route+"/teachers",
		a.requireActivatedUser(http.HandlerFunc(a.getAllTeachersHandler)))
	router.Handler(http.MethodPost, apiV1Route+"/teachers",
		a.requireActivatedUser(http.HandlerFunc(a.createTeacherHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/teachers/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getTeacherHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/teachers/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateTeacherHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/teachers/:id",
		a.requireAnyRole([]string{"admin", "CEO", "TSC"}, http.HandlerFunc(a.deleteTeacherHandler)))

	// Resource slug route (separate path to avoid httprouter wildcard conflicts)
	router.HandlerFunc(http.MethodGet, apiV1Route+"/resource-by-slug/:slug", a.getResourceBySlugHandler)

	// Resource metrics — lives outside /resources/:id to avoid httprouter
	// wildcard-vs-children conflicts (same pattern as resource-by-slug).
	router.Handler(http.MethodGet, apiV1Route+"/resource-metrics",
		a.requireAnyRole([]string{"SubjectExpert", "TeamLead", "DSC", "admin"}, http.HandlerFunc(a.resourceMetricsHandler)))

	// Resource routes - Public can view, authenticated users can create/modify
	router.HandlerFunc(http.MethodGet, apiV1Route+"/resources", a.getAllResourcesHandler)
	router.Handler(http.MethodPost, apiV1Route+"/resources",
		a.requireActivatedUser(http.HandlerFunc(a.createResourceHandler)))
	router.HandlerFunc(http.MethodGet, apiV1Route+"/resources/:id/lessons", a.getResourceLessonsHandler)
	router.HandlerFunc(http.MethodGet, apiV1Route+"/resources/:id/comments", a.getResourceCommentsHandler)
	// Review comments per resource (anyone authenticated can view; reviewers can create/resolve)
	router.Handler(http.MethodGet, apiV1Route+"/resources/:id/review-comments",
		a.requireActivatedUser(http.HandlerFunc(a.getReviewCommentsByResourceHandler)))
	router.HandlerFunc(http.MethodGet, apiV1Route+"/resources/:id", a.getResourceHandler)
	router.Handler(http.MethodPatch, apiV1Route+"/resources/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateResourceHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/resources/:id",
		a.requireAnyRole([]string{"admin", "CEO", "DEC"}, http.HandlerFunc(a.deleteResourceHandler)))

	// Lesson routes - Public can view, authenticated users can create/modify
	router.Handler(http.MethodPost, apiV1Route+"/lessons",
		a.requireActivatedUser(http.HandlerFunc(a.createLessonHandler)))
	router.HandlerFunc(http.MethodGet, apiV1Route+"/lessons/:id", a.getLessonHandler)
	router.Handler(http.MethodPatch, apiV1Route+"/lessons/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateLessonHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/lessons/:id",
		a.requireAnyRole([]string{"admin", "CEO", "DEC"}, http.HandlerFunc(a.deleteLessonHandler)))

	// Comment routes - Public can view, authenticated users can create/modify
	router.Handler(http.MethodPost, apiV1Route+"/comments",
		a.requireActivatedUser(http.HandlerFunc(a.createCommentHandler)))
	router.HandlerFunc(http.MethodGet, apiV1Route+"/comments/:id", a.getCommentHandler)
	router.Handler(http.MethodPatch, apiV1Route+"/comments/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateCommentHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/comments/:id",
		a.requireActivatedUser(http.HandlerFunc(a.deleteCommentHandler)))

	// Resource Review routes - admin/CEO/TSC/DEC can create reviews (must be activated)
	router.Handler(http.MethodGet, apiV1Route+"/resource-reviews",
		a.requireActivatedUser(http.HandlerFunc(a.getAllResourceReviewsHandler)))
	router.Handler(http.MethodPost, apiV1Route+"/resource-reviews",
		a.requireAnyRole([]string{"admin", "CEO", "TSC", "DEC"}, http.HandlerFunc(a.createResourceReviewHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/resource-reviews/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getResourceReviewHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/resource-reviews/:id",
		a.requireAnyRole([]string{"admin", "CEO", "TSC", "DEC"}, http.HandlerFunc(a.updateResourceReviewHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/resource-reviews/:id",
		a.requireRole("admin", http.HandlerFunc(a.deleteResourceReviewHandler)))

	// Review comment routes
	// Reviewers add iterative comments; contributors/reviewers resolve them
	router.Handler(http.MethodPost, apiV1Route+"/review-comments",
		a.requireAnyRole([]string{"admin", "CEO", "TSC", "DEC"}, http.HandlerFunc(a.createReviewCommentHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/review-comments/:id/resolve",
		a.requireActivatedUser(http.HandlerFunc(a.resolveReviewCommentHandler)))

	// Resource Access routes - track resource access (must be activated)
	router.Handler(http.MethodGet, apiV1Route+"/resource-access",
		a.requireAnyRole([]string{"admin", "CEO", "DEC"}, http.HandlerFunc(a.getAllResourceAccessHandler)))
	router.Handler(http.MethodPost, apiV1Route+"/resource-access",
		a.requireActivatedUser(http.HandlerFunc(a.createResourceAccessHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/resource-access/:id",
		a.requireAnyRole([]string{"admin", "CEO", "DEC"}, http.HandlerFunc(a.getResourceAccessHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/resource-access/:id",
		a.requireRole("admin", http.HandlerFunc(a.deleteResourceAccessHandler)))

	// Contribution routes - admin can manage contributions (must be activated)
	router.Handler(http.MethodGet, apiV1Route+"/contributions",
		a.requireActivatedUser(http.HandlerFunc(a.getAllContributionsHandler)))
	router.Handler(http.MethodPost, apiV1Route+"/contributions",
		a.requireAnyRole([]string{"admin", "CEO"}, http.HandlerFunc(a.createContributionHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/contributions/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getContributionHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/contributions/:id",
		a.requireAnyRole([]string{"admin", "CEO"}, http.HandlerFunc(a.updateContributionHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/contributions/:id",
		a.requireRole("admin", http.HandlerFunc(a.deleteContributionHandler)))

	// Notification routes - admin/CEO/Secretary can create, users can manage their own (must be activated)
	router.Handler(http.MethodPost, apiV1Route+"/notifications", a.requireAnyRole([]string{"admin", "CEO", "Secretary"}, http.HandlerFunc(a.createNotificationHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/notifications",
		a.requireActivatedUser(http.HandlerFunc(a.getAllNotificationsHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/notifications/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getNotificationHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/notifications/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateNotificationHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/notifications/:id",
		a.requireActivatedUser(http.HandlerFunc(a.deleteNotificationHandler)))
	// ── Admin routes (admin + DSC only) ────────────────────────────────────

	// Resource status override — lets admins/DSC force-set any status value.
	router.Handler(http.MethodPost, apiV1Route+"/resources/:id/status",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.overrideResourceStatusHandler)))

	// Admin-level metrics: user counts + full resource-status breakdown.
	router.Handler(http.MethodGet, apiV1Route+"/admin/metrics",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.adminMetricsHandler)))

	// Admin user management — distinct from the general /users endpoints so
	// that role and activation changes always require admin/DSC privilege.
	router.Handler(http.MethodPost, apiV1Route+"/admin/users",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.adminCreateUserHandler)))
	router.Handler(http.MethodPut, apiV1Route+"/admin/users/:id",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.adminUpdateUserHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/admin/users/:id/role",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.adminUpdateUserRoleHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/admin/users/:id/active",
		a.requireAnyRole([]string{"admin", "DSC"}, http.HandlerFunc(a.adminToggleUserActiveHandler)))

	// Token routes
	// TODO: Implement token handlers
	router.HandlerFunc(http.MethodPost, apiV1Route+"/tokens/authentication", a.createAuthTokenHandler)
	router.HandlerFunc(http.MethodPost, apiV1Route+"/tokens/activation", a.createActivationTokenHandler)
	router.Handler(http.MethodDelete, apiV1Route+"/tokens/user/:user_id",
		a.authenticate(a.requireActivatedUser(a.requireRole("admin", http.HandlerFunc(a.deleteAllTokensForUserHandler)))))

	// Google OAuth2 routes — used once to obtain a refresh token for
	// YOUTUBE_REFRESH_TOKEN.  Keep these behind your firewall or restrict them
	// to admin use; they do not need JWT authentication.
	router.HandlerFunc(http.MethodGet, apiV1Route+"/oauth/google/login", a.googleLoginHandler)
	router.HandlerFunc(http.MethodGet, apiV1Route+"/oauth/google/callback", a.googleCallbackHandler)
	// Apply middleware
	// Execution order (outermost runs first):
	// enableCORS → rateLimit → authenticate → recoverPanic → router
	// CORS must be outermost so preflight responses always include
	// Access-Control-Allow-Origin, even when rateLimit or authenticate
	// reject the request.
	handler := a.recoverPanic(router)
	handler = a.authenticate(handler)
	handler = a.rateLimit(handler)
	handler = a.enableCORS(handler)

	return handler
}
