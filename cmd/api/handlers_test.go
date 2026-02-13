// Filename: cmd/api/handlers_test.go

package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/mailer"
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
	t.Skip("Skipping test that requires database connection")

	tests := []struct {
		name           string
		method         string
		expectedStatus int
		checkResponse  bool
	}{
		{
			name:           "Valid GET request",
			method:         http.MethodGet,
			expectedStatus: http.StatusOK,
			checkResponse:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestApp(t)

			req := httptest.NewRequest(tt.method, "/v1/roles", nil)
			rr := httptest.NewRecorder()

			handler := http.HandlerFunc(app.getAllRolesHandler)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("handler returned wrong status code: got %v want %v", status, tt.expectedStatus)
			}

			if tt.checkResponse && tt.method == http.MethodGet {
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
	t.Skip("Skipping test that requires database connection")

	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
	}{
		{
			name: "Valid role creation",
			requestBody: map[string]interface{}{
				"role_name": "TestRole",
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Missing role name",
			requestBody: map[string]interface{}{
				"role_name": "",
			},
			expectedStatus: http.StatusUnprocessableEntity,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestApp(t)

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
	t.Skip("Skipping test that requires database connection")

	tests := []struct {
		name           string
		requestBody    map[string]interface{}
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
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Missing required fields",
			requestBody: map[string]interface{}{
				"title": "",
			},
			expectedStatus: http.StatusUnprocessableEntity,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestApp(t)

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
	t.Skip("Skipping test that requires database connection")

	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
	}{
		{
			name: "Valid notification",
			requestBody: map[string]interface{}{
				"user_id": 1,
				"message": "Test notification",
				"channel": "email",
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "Missing user_id",
			requestBody: map[string]interface{}{
				"message": "Test notification",
			},
			expectedStatus: http.StatusUnprocessableEntity,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := newTestApp(t)

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
