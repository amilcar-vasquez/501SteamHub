//filename: internal/data/models.go

package data

import (
	"database/sql"
)

// Models struct wraps all the data models
type Models struct {
	Users           UserModel
	Roles           RoleModel
	Teachers        TeacherModel
	Resources       ResourceModel
	ResourceReviews ResourceReviewModel
	ResourceAccess  ResourceAccessModel
	Contributions   ContributionModel
}

// NewModels returns a Models struct containing all the initialized models
func NewModels(db *sql.DB) Models {
	return Models{
		Users:           UserModel{DB: db},
		Roles:           RoleModel{DB: db},
		Teachers:        TeacherModel{DB: db},
		Resources:       ResourceModel{DB: db},
		ResourceReviews: ResourceReviewModel{DB: db},
		ResourceAccess:  ResourceAccessModel{DB: db},
		Contributions:   ContributionModel{DB: db},
	}
}
