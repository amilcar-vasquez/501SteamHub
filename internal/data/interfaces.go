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
	InsertWithVideoMetadata(*Resource, *VideoMetadata) error
	Get(int64) (*Resource, error)
	GetBySlug(string) (*Resource, error)
	GetAll(status, subject, gradeLevel string, filters Filters) ([]*Resource, Metadata, error)
	GetStatusCounts() (*ResourceStatusCounts, error)
	Update(*Resource) error
	Delete(int64) error
	GetSubjects(int64) ([]string, error)
	GetGradeLevels(int64) ([]string, error)
	SetSubjects(int64, []string) error
	SetGradeLevels(int64, []string) error
}

// FellowApplicationModelInterface defines the interface for fellow application operations
type FellowApplicationModelInterface interface {
	Insert(*FellowApplication) error
	Get(int64) (*FellowApplication, error)
	GetByUserID(int64) (*FellowApplication, error)
	HasPendingApplication(int64) (bool, error)
	Approve(id, reviewerID int64) error
	Reject(id, reviewerID int64) error
	GetAll(statusFilter string) ([]*FellowApplication, error)
}

// FellowModelInterface defines the interface for fellow operations
type FellowModelInterface interface {
	Insert(*Fellow) error
	Get(int64) (*Fellow, error)
	GetByUserID(int64) (*Fellow, error)
	Update(*Fellow) error
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
