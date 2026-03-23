package notifications

import (
	"log/slog"
	"time"
)

// Helper type to provide convenience functions for handlers
type NotificationHelper struct {
	notifier Notifier
	logger   *slog.Logger
}

// NewNotificationHelper creates a new helper instance
func NewNotificationHelper(notifier Notifier, logger *slog.Logger) *NotificationHelper {
	return &NotificationHelper{
		notifier: notifier,
		logger:   logger,
	}
}

// AsyncNotifyFellowApplicationSubmitted sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyFellowApplicationSubmitted(
	adminEmails []string,
	fullName, applicantEmail, organization, subjects, gradeLevels string,
	experienceYears int,
	dashboardURL string,
) {
	go func() {
		if err := nh.notifier.SendFellowApplicationSubmitted(
			adminEmails, fullName, applicantEmail, organization, subjects, gradeLevels, experienceYears, dashboardURL,
		); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyFellowApplicationApproved sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyFellowApplicationApproved(
	userEmail, userName, dashboardURL string,
) {
	go func() {
		if err := nh.notifier.SendFellowApplicationApproved(userEmail, userName, dashboardURL); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyFellowApplicationRejected sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyFellowApplicationRejected(
	userEmail, userName string,
) {
	go func() {
		if err := nh.notifier.SendFellowApplicationRejected(userEmail, userName); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyResourceStatusChanged sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyResourceStatusChanged(
	userEmail, contributorName, resourceTitle, oldStatus, newStatus, reviewerComment, dashboardURL string,
	actionRequired bool,
) {
	go func() {
		if err := nh.notifier.SendResourceStatusChanged(
			userEmail, contributorName, resourceTitle, oldStatus, newStatus, reviewerComment, dashboardURL, actionRequired,
		); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyPasswordChanged sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyPasswordChanged(
	userEmail, username string,
) {
	go func() {
		if err := nh.notifier.SendPasswordChanged(userEmail, username); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyEmailChanged sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyEmailChanged(
	userEmail, username, newEmail string,
) {
	go func() {
		if err := nh.notifier.SendEmailChanged(userEmail, username, newEmail); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// AsyncNotifyAccountActivated sends notification asynchronously
func (nh *NotificationHelper) AsyncNotifyAccountActivated(
	userEmail, username, dashboardURL string,
) {
	go func() {
		if err := nh.notifier.SendAccountActivated(userEmail, username, dashboardURL); err != nil {
			nh.logger.Error("async notification failed", "error", err)
		}
	}()
}

// WaitForAsync waits for a short duration to allow goroutines to start
// Useful for testing or when you want to ensure notifications are queued
func (nh *NotificationHelper) WaitForAsync(duration time.Duration) {
	time.Sleep(duration)
}
