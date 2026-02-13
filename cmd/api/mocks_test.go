// Filename: cmd/api/mocks_test.go

package main

import (
	"io"
	"log/slog"
	"testing"
	"time"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/mailer"
)

// Mock Role Model
type MockRoleModel struct {
	InsertFunc    func(*data.Role) error
	GetFunc       func(int) (*data.Role, error)
	GetByNameFunc func(string) (*data.Role, error)
	GetAllFunc    func() ([]*data.Role, error)
	UpdateFunc    func(*data.Role) error
	DeleteFunc    func(int) error
}

func (m *MockRoleModel) Insert(role *data.Role) error {
	if m.InsertFunc != nil {
		return m.InsertFunc(role)
	}
	role.ID = 1
	return nil
}

func (m *MockRoleModel) Get(id int) (*data.Role, error) {
	if m.GetFunc != nil {
		return m.GetFunc(id)
	}
	if id < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Role{ID: id, RoleName: "TestRole"}, nil
}

func (m *MockRoleModel) GetByName(name string) (*data.Role, error) {
	if m.GetByNameFunc != nil {
		return m.GetByNameFunc(name)
	}
	return &data.Role{ID: 1, RoleName: name}, nil
}

func (m *MockRoleModel) GetAll() ([]*data.Role, error) {
	if m.GetAllFunc != nil {
		return m.GetAllFunc()
	}
	return []*data.Role{
		{ID: 1, RoleName: "admin"},
		{ID: 2, RoleName: "user"},
	}, nil
}

func (m *MockRoleModel) Update(role *data.Role) error {
	if m.UpdateFunc != nil {
		return m.UpdateFunc(role)
	}
	return nil
}

func (m *MockRoleModel) Delete(id int) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(id)
	}
	if id < 1 {
		return data.ErrRecordNotFound
	}
	return nil
}

// Mock Resource Model
type MockResourceModel struct {
	InsertFunc func(*data.Resource) error
	GetFunc    func(int64) (*data.Resource, error)
	GetAllFunc func(string, string, string, data.Filters) ([]*data.Resource, data.Metadata, error)
	UpdateFunc func(*data.Resource) error
	DeleteFunc func(int64) error
}

func (m *MockResourceModel) Insert(resource *data.Resource) error {
	if m.InsertFunc != nil {
		return m.InsertFunc(resource)
	}
	resource.ID = 1
	resource.CreatedAt = time.Now()
	return nil
}

func (m *MockResourceModel) Get(id int64) (*data.Resource, error) {
	if m.GetFunc != nil {
		return m.GetFunc(id)
	}
	if id < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Resource{
		ID:            id,
		Title:         "Test Resource",
		Category:      "Lesson Plan",
		Subject:       "Math",
		GradeLevel:    "Grade 5",
		Status:        "pending",
		ContributorID: 1,
		CreatedAt:     time.Now(),
	}, nil
}

func (m *MockResourceModel) GetAll(status, subject, gradeLevel string, filters data.Filters) ([]*data.Resource, data.Metadata, error) {
	if m.GetAllFunc != nil {
		return m.GetAllFunc(status, subject, gradeLevel, filters)
	}
	return []*data.Resource{}, data.Metadata{}, nil
}

func (m *MockResourceModel) Update(resource *data.Resource) error {
	if m.UpdateFunc != nil {
		return m.UpdateFunc(resource)
	}
	return nil
}

func (m *MockResourceModel) Delete(id int64) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(id)
	}
	if id < 1 {
		return data.ErrRecordNotFound
	}
	return nil
}

// Mock Teacher Model
type MockTeacherModel struct {
	InsertFunc      func(*data.Teacher) error
	GetFunc         func(int64) (*data.Teacher, error)
	GetByUserIDFunc func(int64) (*data.Teacher, error)
	UpdateFunc      func(*data.Teacher) error
	DeleteFunc      func(int64) error
}

func (m *MockTeacherModel) Insert(teacher *data.Teacher) error {
	if m.InsertFunc != nil {
		return m.InsertFunc(teacher)
	}
	teacher.ID = 1
	teacher.CreatedAt = time.Now()
	return nil
}

func (m *MockTeacherModel) Get(id int64) (*data.Teacher, error) {
	if m.GetFunc != nil {
		return m.GetFunc(id)
	}
	if id < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Teacher{
		ID:            id,
		UserID:        1,
		FirstName:     "John",
		LastName:      "Doe",
		MoeIdentifier: "MOE123",
		CreatedAt:     time.Now(),
	}, nil
}

func (m *MockTeacherModel) GetByUserID(userID int64) (*data.Teacher, error) {
	if m.GetByUserIDFunc != nil {
		return m.GetByUserIDFunc(userID)
	}
	if userID < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Teacher{
		ID:            1,
		UserID:        userID,
		FirstName:     "John",
		LastName:      "Doe",
		MoeIdentifier: "MOE123",
		CreatedAt:     time.Now(),
	}, nil
}

func (m *MockTeacherModel) Update(teacher *data.Teacher) error {
	if m.UpdateFunc != nil {
		return m.UpdateFunc(teacher)
	}
	return nil
}

func (m *MockTeacherModel) Delete(id int64) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(id)
	}
	if id < 1 {
		return data.ErrRecordNotFound
	}
	return nil
}

// Mock Notification Model
type MockNotificationModel struct {
	InsertFunc    func(*data.Notification) error
	GetFunc       func(int) (*data.Notification, error)
	GetByUserFunc func(int) ([]*data.Notification, error)
	DeleteFunc    func(int) error
}

func (m *MockNotificationModel) Insert(n *data.Notification) error {
	if m.InsertFunc != nil {
		return m.InsertFunc(n)
	}
	n.ID = 1
	n.SentAt = time.Now()
	return nil
}

func (m *MockNotificationModel) Get(id int) (*data.Notification, error) {
	if m.GetFunc != nil {
		return m.GetFunc(id)
	}
	if id < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Notification{
		ID:      id,
		UserID:  1,
		Message: "Test notification",
		Channel: "email",
		SentAt:  time.Now(),
		Read:    false,
	}, nil
}

func (m *MockNotificationModel) GetByUser(userID int) ([]*data.Notification, error) {
	if m.GetByUserFunc != nil {
		return m.GetByUserFunc(userID)
	}
	return []*data.Notification{}, nil
}

func (m *MockNotificationModel) Delete(id int) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(id)
	}
	if id < 1 {
		return data.ErrRecordNotFound
	}
	return nil
}

// Mock Contribution Model
type MockContributionModel struct {
	InsertFunc          func(*data.Contribution) error
	GetFunc             func(int64) (*data.Contribution, error)
	GetByResourceIDFunc func(int64) (*data.Contribution, error)
	GetAllFunc          func(data.Filters) ([]*data.Contribution, data.Metadata, error)
	UpdateFunc          func(*data.Contribution) error
	DeleteFunc          func(int64) error
}

func (m *MockContributionModel) Insert(c *data.Contribution) error {
	if m.InsertFunc != nil {
		return m.InsertFunc(c)
	}
	c.ID = 1
	c.CalculatedAt = time.Now()
	return nil
}

func (m *MockContributionModel) Get(id int64) (*data.Contribution, error) {
	if m.GetFunc != nil {
		return m.GetFunc(id)
	}
	if id < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Contribution{
		ID:           id,
		ResourceID:   1,
		Score:        85.5,
		CalculatedAt: time.Now(),
	}, nil
}

func (m *MockContributionModel) GetByResourceID(resourceID int64) (*data.Contribution, error) {
	if m.GetByResourceIDFunc != nil {
		return m.GetByResourceIDFunc(resourceID)
	}
	if resourceID < 1 {
		return nil, data.ErrRecordNotFound
	}
	return &data.Contribution{
		ID:           1,
		ResourceID:   resourceID,
		Score:        85.5,
		CalculatedAt: time.Now(),
	}, nil
}

func (m *MockContributionModel) GetAll(filters data.Filters) ([]*data.Contribution, data.Metadata, error) {
	if m.GetAllFunc != nil {
		return m.GetAllFunc(filters)
	}
	return []*data.Contribution{}, data.Metadata{}, nil
}

func (m *MockContributionModel) Update(c *data.Contribution) error {
	if m.UpdateFunc != nil {
		return m.UpdateFunc(c)
	}
	return nil
}

func (m *MockContributionModel) Delete(id int64) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(id)
	}
	if id < 1 {
		return data.ErrRecordNotFound
	}
	return nil
}

// Helper function to create app with custom mocks
func newTestAppWithMocks(t *testing.T, roles *MockRoleModel, resources *MockResourceModel, teachers *MockTeacherModel, notifications *MockNotificationModel, contributions *MockContributionModel) *app {
	models := &data.Models{}

	if roles != nil {
		models.Roles = roles
	} else {
		models.Roles = &MockRoleModel{}
	}

	if resources != nil {
		models.Resources = resources
	} else {
		models.Resources = &MockResourceModel{}
	}

	if teachers != nil {
		models.Teachers = teachers
	} else {
		models.Teachers = &MockTeacherModel{}
	}

	if notifications != nil {
		models.Notifications = notifications
	} else {
		models.Notifications = &MockNotificationModel{}
	}

	if contributions != nil {
		models.Contributions = contributions
	} else {
		models.Contributions = &MockContributionModel{}
	}

	return &app{
		config: configuration{
			version: "1.0.0",
			env:     "test",
		},
		logger: slog.New(slog.NewTextHandler(io.Discard, nil)),
		models: models,
		mailer: mailer.Mailer{},
	}
}
