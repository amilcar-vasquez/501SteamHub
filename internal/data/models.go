//filename: internal/data/models.go

package data

import (
	"database/sql"
)

// Models struct wraps all the data models
type Models struct {
	Users            *UserModel
	Roles            RoleModelInterface
	Teachers         TeacherModelInterface
	Resources        ResourceModelInterface
	ResourceReviews  *ResourceReviewModel
	ResourceAccess   *ResourceAccessModel
	Contributions    ContributionModelInterface
	Tokens           *TokenModel
	Notifications    NotificationModelInterface
	Lessons          *LessonModel
	ResourceComments *ResourceCommentModel
}

// NewModels returns a Models struct containing all the initialized models
func NewModels(db *sql.DB) *Models {
	return &Models{
		Users:            &UserModel{DB: db},
		Roles:            &RoleModel{DB: db},
		Teachers:         &TeacherModel{DB: db},
		Resources:        &ResourceModel{DB: db},
		ResourceReviews:  &ResourceReviewModel{DB: db},
		ResourceAccess:   &ResourceAccessModel{DB: db},
		Contributions:    &ContributionModel{DB: db},
		Tokens:           &TokenModel{DB: db},
		Notifications:    &NotificationModel{DB: db},
		Lessons:          &LessonModel{DB: db},
		ResourceComments: &ResourceCommentModel{DB: db},
	}
}

// NewTestModels initializes and returns a new Models struct for testing
// with nil DB connections (for validation tests that don't need database)

func NewTestModels() *Models {
	return &Models{
		Users:            &UserModel{DB: nil},
		Roles:            &RoleModel{DB: nil},
		Teachers:         &TeacherModel{DB: nil},
		Resources:        &ResourceModel{DB: nil},
		ResourceReviews:  &ResourceReviewModel{DB: nil},
		ResourceAccess:   &ResourceAccessModel{DB: nil},
		Contributions:    &ContributionModel{DB: nil},
		Tokens:           &TokenModel{DB: nil},
		Notifications:    &NotificationModel{DB: nil},
		Lessons:          &LessonModel{DB: nil},
		ResourceComments: &ResourceCommentModel{DB: nil},
	}
}
