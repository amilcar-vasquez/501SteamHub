//filename: internal/data/interfaces.go

package data

// RoleModelInterface defines the interface for role operations
type RoleModelInterface interface {
	Insert(*Role) error
	Get(int) (*Role, error)
	GetByName(string) (*Role, error)
	GetAll() ([]*Role, error)
	Update(*Role) error
	Delete(int) error
}

// ResourceModelInterface defines the interface for resource operations
type ResourceModelInterface interface {
	Insert(*Resource) error
	Get(int64) (*Resource, error)
	GetBySlug(string) (*Resource, error)
	GetAll(status, subject, gradeLevel string, filters Filters) ([]*Resource, Metadata, error)
	Update(*Resource) error
	Delete(int64) error
	GetSubjects(int64) ([]string, error)
	GetGradeLevels(int64) ([]string, error)
	SetSubjects(int64, []string) error
	SetGradeLevels(int64, []string) error
}

// TeacherModelInterface defines the interface for teacher operations
type TeacherModelInterface interface {
	Insert(*Teacher) error
	Get(int64) (*Teacher, error)
	GetByUserID(int64) (*Teacher, error)
	Update(*Teacher) error
	Delete(int64) error
}

// NotificationModelInterface defines the interface for notification operations
type NotificationModelInterface interface {
	Insert(*Notification) error
	Get(int) (*Notification, error)
	GetByUser(int) ([]*Notification, error)
	Delete(int) error
}

// ContributionModelInterface defines the interface for contribution operations
type ContributionModelInterface interface {
	Insert(*Contribution) error
	Get(int64) (*Contribution, error)
	GetByResourceID(int64) (*Contribution, error)
	GetAll(Filters) ([]*Contribution, Metadata, error)
	Update(*Contribution) error
	Delete(int64) error
}
