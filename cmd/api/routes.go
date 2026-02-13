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

	// Teacher routes - All authenticated users can list/view, admin/CEO/TSC/DEC can create (must be activated)
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

	// Resource routes - All authenticated users can list/view, create (must be activated)
	router.Handler(http.MethodGet, apiV1Route+"/resources",
		a.requireActivatedUser(http.HandlerFunc(a.getAllResourcesHandler)))
	router.Handler(http.MethodPost, apiV1Route+"/resources",
		a.requireActivatedUser(http.HandlerFunc(a.createResourceHandler)))
	router.Handler(http.MethodGet, apiV1Route+"/resources/:id",
		a.requireActivatedUser(http.HandlerFunc(a.getResourceHandler)))
	router.Handler(http.MethodPatch, apiV1Route+"/resources/:id",
		a.requireActivatedUser(http.HandlerFunc(a.updateResourceHandler)))
	router.Handler(http.MethodDelete, apiV1Route+"/resources/:id",
		a.requireAnyRole([]string{"admin", "CEO", "DEC"}, http.HandlerFunc(a.deleteResourceHandler)))

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
	// Token routes
	// TODO: Implement token handlers
	router.HandlerFunc(http.MethodPost, apiV1Route+"/tokens/authentication", a.createAuthTokenHandler)
	router.HandlerFunc(http.MethodPost, apiV1Route+"/tokens/activation", a.createActivationTokenHandler)
	router.Handler(http.MethodDelete, apiV1Route+"/tokens/user/:user_id",
	a.authenticate(a.requireActivatedUser(a.requireRole("admin", http.HandlerFunc(a.deleteAllTokensForUserHandler)))))
	// Apply middleware
	handler := a.recoverPanic(router)
	handler = a.enableCORS(handler)
	handler = a.authenticate(handler)
	handler = a.rateLimit(handler)

	return handler
}
