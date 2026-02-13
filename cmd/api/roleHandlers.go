// Filename: cmd/api/roleHandlers.go

package main

import (
	"errors"
	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/validator"
)

// createRoleHandler creates a new role
func (a *app) createRoleHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		RoleName string `json:"role_name"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	role := &data.Role{
		RoleName: input.RoleName,
	}

	v := validator.New()
	if data.ValidateRole(v, role); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Roles.Insert(role)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"role": role,
	}
	err = a.writeJSON(w, http.StatusCreated, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getRoleHandler retrieves a specific role by ID
func (a *app) getRoleHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	role, err := a.models.Roles.Get(int(id))
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
		"role": role,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getRoleByNameHandler retrieves a role by name
func (a *app) getRoleByNameHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		a.badRequestResponse(w, r, errors.New("name parameter is required"))
		return
	}

	role, err := a.models.Roles.GetByName(name)
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
		"role": role,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// getAllRolesHandler retrieves all roles
func (a *app) getAllRolesHandler(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()

	// Check if this is a name lookup request
	if name := qs.Get("name"); name != "" {
		a.getRoleByNameHandler(w, r)
		return
	}

	roles, err := a.models.Roles.GetAll()
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"roles": roles,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// updateRoleHandler updates an existing role
func (a *app) updateRoleHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	role, err := a.models.Roles.Get(int(id))
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
		RoleName *string `json:"role_name"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	if input.RoleName != nil {
		role.RoleName = *input.RoleName
	}

	v := validator.New()
	if data.ValidateRole(v, role); !v.IsEmpty() {
		a.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = a.models.Roles.Update(role)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	response := envelope{
		"role": role,
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// deleteRoleHandler deletes a role
func (a *app) deleteRoleHandler(w http.ResponseWriter, r *http.Request) {
	id, err := a.readIDParam(r)
	if err != nil {
		a.notFoundResponse(w, r)
		return
	}

	err = a.models.Roles.Delete(int(id))
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
		"message": "role successfully deleted",
	}
	err = a.writeJSON(w, http.StatusOK, response, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
