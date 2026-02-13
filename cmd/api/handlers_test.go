// Filename: cmd/api/handlers_test.go

package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/mailer"
	"github.com/julienschmidt/httprouter"
)

// newTestApp creates a test application instance with test models
func newTestApp(t *testing.T) *app {
	return &app{
		config: configuration{
			version: "1.0.0",
			env:     "test",
		},
		logger: slog.New(slog.NewTextHandler(io.Discard, nil)),
		models: data.NewTestModels(),
		mailer: mailer.Mailer{},
	}
}

// TestHealthCheckHandler tests the health check endpoint
func TestHealthCheckHandler(t *testing.T) {
	app := newTestApp(t)

	req := httptest.NewRequest(http.MethodGet, "/v1/healthcheck", nil)
	rr := httptest.NewRecorder()

	handler := http.HandlerFunc(app.healthCheckHandler)
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var response envelope
	err := json.NewDecoder(rr.Body).Decode(&response)
	if err != nil {
		t.Fatalf("Failed to decode response: %v", err)
	}

	if response["status"] != "available" {
		t.Errorf("Expected status 'available', got %v", response["status"])
	}
}

// TestGetAllRolesHandler tests the get all roles endpoint
func TestGetAllRolesHandler(t *testing.T) {
	tests := []struct {
		name           string
		mockSetup      func() *MockRoleModel
		expectedStatus int
		checkResponse  bool
	}{
		{
			name: "Valid GET request returns roles",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetAllFunc: func() ([]*data.Role, error) {
						return []*data.Role{
							{ID: 1, RoleName: "admin"},
							{ID: 2, RoleName: "user"},
						}, nil
					},
				}
			},
			expectedStatus: http.StatusOK,
			checkResponse:  true,
		},
		{
			name: "Database error returns 500",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetAllFunc: func() ([]*data.Role, error) {
						return nil, errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
			checkResponse:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, tt.mockSetup(), nil, nil, nil, nil)

			req := httptest.NewRequest(http.MethodGet, "/v1/roles", nil)
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(app.getAllRolesHandler)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v", status, tt.expectedStatus)
			}

			if tt.checkResponse {
				var response envelope
				err := json.NewDecoder(rr.Body).Decode(&response)
				if err != nil {
					t.Fatalf("Failed to decode response: %v", err)
				}

				if _, ok := response["roles"]; !ok {
					t.Error("Expected 'roles' key in response")
				}
			}
		})
	}
}

// TestCreateRoleHandler tests creating a new role
func TestCreateRoleHandler(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		mockSetup      func() *MockRoleModel
		expectedStatus int
		checkResponse  bool
	}{
		{
			name: "Valid role creation",
			requestBody: map[string]interface{}{
				"role_name": "TestRole",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					InsertFunc: func(role *data.Role) error {
						role.ID = 1
						return nil
					},
				}
			},
			expectedStatus: http.StatusCreated,
			checkResponse:  true,
		},
		{
			name: "Missing role name",
			requestBody: map[string]interface{}{
				"role_name": "",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{}
			},
			expectedStatus: http.StatusUnprocessableEntity,
			checkResponse:  false,
		},
		{
			name: "Database error on insert",
			requestBody: map[string]interface{}{
				"role_name": "TestRole",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					InsertFunc: func(role *data.Role) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
			checkResponse:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, tt.mockSetup(), nil, nil, nil, nil)

			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPost, "/v1/roles", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(app.createRoleHandler)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}

			if tt.checkResponse {
				var response envelope
				err := json.NewDecoder(rr.Body).Decode(&response)
				if err != nil {
					t.Fatalf("Failed to decode response: %v", err)
				}

				if _, ok := response["role"]; !ok {
					t.Error("Expected 'role' key in response")
				}
			}
		})
	}
}

// TestWriteJSON tests the writeJSON helper method
func TestWriteJSON(t *testing.T) {
	app := newTestApp(t)

	tests := []struct {
		name           string
		data           envelope
		status         int
		expectedStatus int
	}{
		{
			name: "Simple JSON response",
			data: envelope{
				"message": "test",
				"value":   123,
			},
			status:         http.StatusOK,
			expectedStatus: http.StatusOK,
		},
		{
			name:           "Empty envelope with OK status",
			data:           envelope{},
			status:         http.StatusOK,
			expectedStatus: http.StatusOK,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			rr := httptest.NewRecorder()

			err := app.writeJSON(rr, tt.status, tt.data, nil)
			if err != nil {
				t.Errorf("writeJSON returned an error: %v", err)
			}

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("Expected status %v, got %v", tt.expectedStatus, status)
			}

			contentType := rr.Header().Get("Content-Type")
			if contentType != "application/json" {
				t.Errorf("Expected Content-Type 'application/json', got '%s'", contentType)
			}
		})
	}
}

// TestReadJSON tests the readJSON helper method
func TestReadJSON(t *testing.T) {
	app := newTestApp(t)

	tests := []struct {
		name        string
		body        string
		expectError bool
	}{
		{
			name:        "Valid JSON",
			body:        `{"name": "test", "value": 123}`,
			expectError: false,
		},
		{
			name:        "Invalid JSON",
			body:        `{"name": "test", "value": }`,
			expectError: true,
		},
		{
			name:        "Empty body",
			body:        ``,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var destination map[string]interface{}
			req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(tt.body))
			rr := httptest.NewRecorder()

			err := app.readJSON(rr, req, &destination)

			if tt.expectError && err == nil {
				t.Error("Expected an error but got none")
			}

			if !tt.expectError && err != nil {
				t.Errorf("Did not expect an error but got: %v", err)
			}
		})
	}
}

// TestCreateResourceHandler tests creating a new resource
func TestCreateResourceHandler(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		mockSetup      func() *MockResourceModel
		expectedStatus int
	}{
		{
			name: "Valid resource creation",
			requestBody: map[string]interface{}{
				"title":          "Test Resource",
				"category":       "Lesson Plan",
				"subject":        "Mathematics",
				"grade_level":    "Grade 5",
				"ilo":            "ILO1",
				"status":         "pending",
				"contributor_id": 1,
			},
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{
					InsertFunc: func(r *data.Resource) error {
						r.ID = 1
						return nil
					},
				}
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Missing required fields",
			requestBody: map[string]interface{}{
				"title": "",
			},
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{}
			},
			expectedStatus: http.StatusUnprocessableEntity,
		},
		{
			name: "Database error on insert",
			requestBody: map[string]interface{}{
				"title":          "Test Resource",
				"category":       "Lesson Plan",
				"subject":        "Mathematics",
				"grade_level":    "Grade 5",
				"ilo":            "ILO1",
				"status":         "pending",
				"contributor_id": 1,
			},
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{
					InsertFunc: func(r *data.Resource) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, nil, tt.mockSetup(), nil, nil, nil)

			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPost, "/v1/resources", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(app.createResourceHandler)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestCreateNotificationHandler tests creating a notification
func TestCreateNotificationHandler(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		mockSetup      func() *MockNotificationModel
		expectedStatus int
	}{
		{
			name: "Valid notification",
			requestBody: map[string]interface{}{
				"user_id": 1,
				"message": "Test notification",
				"channel": "email",
			},
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{
					InsertFunc: func(n *data.Notification) error {
						n.ID = 1
						return nil
					},
				}
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Missing user_id",
			requestBody: map[string]interface{}{
				"message": "Test notification",
			},
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{}
			},
			expectedStatus: http.StatusUnprocessableEntity,
		},
		{
			name: "Database error on insert",
			requestBody: map[string]interface{}{
				"user_id": 1,
				"message": "Test notification",
				"channel": "email",
			},
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{
					InsertFunc: func(n *data.Notification) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, nil, nil, nil, tt.mockSetup(), nil)

			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPost, "/v1/notifications", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(app.createNotificationHandler)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestErrorResponses tests various error response handlers
func TestErrorResponses(t *testing.T) {
	app := newTestApp(t)

	tests := []struct {
		name           string
		handlerFunc    func(http.ResponseWriter, *http.Request)
		expectedStatus int
	}{
		{
			name: "Not Found Response",
			handlerFunc: func(w http.ResponseWriter, r *http.Request) {
				app.notFoundResponse(w, r)
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name: "Method Not Allowed Response",
			handlerFunc: func(w http.ResponseWriter, r *http.Request) {
				app.methodNotAllowedResponse(w, r)
			},
			expectedStatus: http.StatusMethodNotAllowed,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/test", nil)
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(tt.handlerFunc)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v",
					status, tt.expectedStatus)
			}
		})
	}
}

// TestGetRoleHandler tests retrieving a role by ID
func TestGetRoleHandler(t *testing.T) {
	tests := []struct {
		name           string
		roleID         string
		mockSetup      func() *MockRoleModel
		expectedStatus int
	}{
		{
			name:   "Valid role retrieval",
			roleID: "1",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return &data.Role{
							ID:       1,
							RoleName: "TestRole",
						}, nil
					},
				}
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:   "Role not found",
			roleID: "999",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return nil, data.ErrRecordNotFound
					},
				}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:   "Invalid role ID",
			roleID: "invalid",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:   "Database error",
			roleID: "1",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return nil, errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, tt.mockSetup(), nil, nil, nil, nil)

			req := httptest.NewRequest(http.MethodGet, "/v1/roles/"+tt.roleID, nil)
			rr := httptest.NewRecorder()

			router := httprouter.New()
			router.HandlerFunc(http.MethodGet, "/v1/roles/:id", app.getRoleHandler)
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestDeleteRoleHandler tests deleting a role
func TestDeleteRoleHandler(t *testing.T) {
	tests := []struct {
		name           string
		roleID         string
		mockSetup      func() *MockRoleModel
		expectedStatus int
	}{
		{
			name:   "Valid role deletion",
			roleID: "1",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					DeleteFunc: func(id int) error {
						return nil
					},
				}
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:   "Role not found",
			roleID: "999",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					DeleteFunc: func(id int) error {
						return data.ErrRecordNotFound
					},
				}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:   "Database error",
			roleID: "1",
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					DeleteFunc: func(id int) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, tt.mockSetup(), nil, nil, nil, nil)

			req := httptest.NewRequest(http.MethodDelete, "/v1/roles/"+tt.roleID, nil)
			rr := httptest.NewRecorder()

			router := httprouter.New()
			router.HandlerFunc(http.MethodDelete, "/v1/roles/:id", app.deleteRoleHandler)
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestUpdateRoleHandler tests updating a role
func TestUpdateRoleHandler(t *testing.T) {
	tests := []struct {
		name           string
		roleID         string
		requestBody    map[string]interface{}
		mockSetup      func() *MockRoleModel
		expectedStatus int
	}{
		{
			name:   "Valid role update",
			roleID: "1",
			requestBody: map[string]interface{}{
				"role_name": "UpdatedRole",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return &data.Role{
							ID:       1,
							RoleName: "OldRole",
						}, nil
					},
					UpdateFunc: func(role *data.Role) error {
						return nil
					},
				}
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:   "Role not found",
			roleID: "999",
			requestBody: map[string]interface{}{
				"role_name": "UpdatedRole",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return nil, data.ErrRecordNotFound
					},
				}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:   "Database error on update",
			roleID: "1",
			requestBody: map[string]interface{}{
				"role_name": "UpdatedRole",
			},
			mockSetup: func() *MockRoleModel {
				return &MockRoleModel{
					GetFunc: func(id int) (*data.Role, error) {
						return &data.Role{
							ID:       1,
							RoleName: "OldRole",
						}, nil
					},
					UpdateFunc: func(role *data.Role) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, tt.mockSetup(), nil, nil, nil, nil)

			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPatch, "/v1/roles/"+tt.roleID, bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			rr := httptest.NewRecorder()

			router := httprouter.New()
			router.HandlerFunc(http.MethodPatch, "/v1/roles/:id", app.updateRoleHandler)
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestDeleteResourceHandler tests deleting a resource
func TestDeleteResourceHandler(t *testing.T) {
	tests := []struct {
		name           string
		resourceID     string
		mockSetup      func() *MockResourceModel
		expectedStatus int
	}{
		{
			name:       "Valid resource deletion",
			resourceID: "1",
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{
					DeleteFunc: func(id int64) error {
						return nil
					},
				}
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:       "Resource not found",
			resourceID: "999",
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{
					DeleteFunc: func(id int64) error {
						return data.ErrRecordNotFound
					},
				}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:       "Database error",
			resourceID: "1",
			mockSetup: func() *MockResourceModel {
				return &MockResourceModel{
					DeleteFunc: func(id int64) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, nil, tt.mockSetup(), nil, nil, nil)

			req := httptest.NewRequest(http.MethodDelete, "/v1/resources/"+tt.resourceID, nil)
			rr := httptest.NewRecorder()

			router := httprouter.New()
			router.HandlerFunc(http.MethodDelete, "/v1/resources/:id", app.deleteResourceHandler)
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}

// TestDeleteNotificationHandler tests deleting a notification
func TestDeleteNotificationHandler(t *testing.T) {
	tests := []struct {
		name           string
		notificationID string
		mockSetup      func() *MockNotificationModel
		expectedStatus int
	}{
		{
			name:           "Valid notification deletion",
			notificationID: "1",
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{
					DeleteFunc: func(id int) error {
						return nil
					},
				}
			},
			expectedStatus: http.StatusOK,
		},
		{
			name:           "Notification not found",
			notificationID: "999",
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{
					DeleteFunc: func(id int) error {
						return data.ErrRecordNotFound
					},
				}
			},
			expectedStatus: http.StatusNotFound,
		},
		{
			name:           "Database error",
			notificationID: "1",
			mockSetup: func() *MockNotificationModel {
				return &MockNotificationModel{
					DeleteFunc: func(id int) error {
						return errors.New("database error")
					},
				}
			},
			expectedStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestAppWithMocks(t, nil, nil, nil, tt.mockSetup(), nil)

			req := httptest.NewRequest(http.MethodDelete, "/v1/notifications/"+tt.notificationID, nil)
			rr := httptest.NewRecorder()

			router := httprouter.New()
			router.HandlerFunc(http.MethodDelete, "/v1/notifications/:id", app.deleteNotificationHandler)
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v\nResponse: %s",
					status, tt.expectedStatus, rr.Body.String())
			}
		})
	}
}
