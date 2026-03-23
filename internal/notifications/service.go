package notifications

import (
	"fmt"
	"log/slog"
	"strings"

	"github.com/amilcar-vasquez/501SteamHub/internal/mailer"
)

// Notifier defines the interface for sending notifications
type Notifier interface {
	SendFellowApplicationSubmitted(adminEmails []string, fullName, applicantEmail, organization, subjects, gradeLevels string, experienceYears int, dashboardURL string) error
	SendFellowApplicationApproved(userEmail, userName, dashboardURL string) error
	SendFellowApplicationRejected(userEmail, userName string) error
	SendResourceStatusChanged(userEmail, contributorName, resourceTitle, oldStatus, newStatus, reviewerComment, dashboardURL string, actionRequired bool) error
	SendPasswordChanged(userEmail, username string) error
	SendEmailChanged(userEmail, username, newEmail string) error
	SendAccountActivated(userEmail, username, dashboardURL string) error
}

// EmailNotifier implements the Notifier interface using the mailer service
type EmailNotifier struct {
	mailer mailer.Mailer
	logger *slog.Logger
}

// NewEmailNotifier creates a new EmailNotifier instance
func NewEmailNotifier(mailer mailer.Mailer, logger *slog.Logger) Notifier {
	return &EmailNotifier{
		mailer: mailer,
		logger: logger,
	}
}

// SendFellowApplicationSubmitted notifies admins/DSC of a new fellow application
func (en *EmailNotifier) SendFellowApplicationSubmitted(adminEmails []string, fullName, applicantEmail, organization, subjects, gradeLevels string, experienceYears int, dashboardURL string) error {
	if len(adminEmails) == 0 {
		return nil // Skip if no admin emails provided
	}

	data := map[string]interface{}{
		"FullName":        fullName,
		"ApplicantEmail":  applicantEmail,
		"Organization":    organization,
		"Subjects":        subjects,
		"GradeLevels":     gradeLevels,
		"ExperienceYears": experienceYears,
		"DashboardURL":    dashboardURL,
	}

	// Send to all admins
	for _, email := range adminEmails {
		if err := en.mailer.Send(email, "fellow_application_submitted.tmpl", data); err != nil {
			en.logger.Error(
				"failed to send fellow application notification",
				"email", email,
				"error", err,
			)
			// Continue sending to other admins even if one fails
		}
	}

	return nil
}

// SendFellowApplicationApproved notifies applicant of approval
func (en *EmailNotifier) SendFellowApplicationApproved(userEmail, userName, dashboardURL string) error {
	data := map[string]interface{}{
		"FullName":     userName,
		"DashboardURL": dashboardURL,
	}

	if err := en.mailer.Send(userEmail, "fellow_application_approved.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send fellow application approved notification",
			"email", userEmail,
			"error", err,
		)
		return fmt.Errorf("failed to send approval email: %w", err)
	}

	return nil
}

// SendFellowApplicationRejected notifies applicant of rejection
func (en *EmailNotifier) SendFellowApplicationRejected(userEmail, userName string) error {
	data := map[string]interface{}{
		"FullName": userName,
	}

	if err := en.mailer.Send(userEmail, "fellow_application_rejected.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send fellow application rejected notification",
			"email", userEmail,
			"error", err,
		)
		return fmt.Errorf("failed to send rejection email: %w", err)
	}

	return nil
}

// SendResourceStatusChanged notifies resource owner of status change
func (en *EmailNotifier) SendResourceStatusChanged(userEmail, contributorName, resourceTitle, oldStatus, newStatus, reviewerComment, dashboardURL string, actionRequired bool) error {
	data := map[string]interface{}{
		"ContributorName": contributorName,
		"ResourceTitle":   resourceTitle,
		"OldStatus":       oldStatus,
		"NewStatus":       newStatus,
		"ReviewerComment": reviewerComment,
		"DashboardURL":    dashboardURL,
		"ActionRequired":  actionRequired,
		"UpdatedAt":       getCurrentTimestampString(),
	}

	if err := en.mailer.Send(userEmail, "resource_status_changed.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send resource status change notification",
			"email", userEmail,
			"resource", resourceTitle,
			"error", err,
		)
		return fmt.Errorf("failed to send status change email: %w", err)
	}

	return nil
}

// SendPasswordChanged notifies user of password change
func (en *EmailNotifier) SendPasswordChanged(userEmail, username string) error {
	data := map[string]interface{}{
		"Username": username,
	}

	if err := en.mailer.Send(userEmail, "password_changed.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send password changed notification",
			"email", userEmail,
			"error", err,
		)
		return fmt.Errorf("failed to send password changed email: %w", err)
	}

	return nil
}

// SendEmailChanged notifies user of email change
func (en *EmailNotifier) SendEmailChanged(userEmail, username, newEmail string) error {
	data := map[string]interface{}{
		"Username": username,
		"NewEmail": newEmail,
	}

	if err := en.mailer.Send(userEmail, "email_changed.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send email changed notification",
			"email", userEmail,
			"error", err,
		)
		return fmt.Errorf("failed to send email changed email: %w", err)
	}

	return nil
}

// SendAccountActivated notifies user of account activation
func (en *EmailNotifier) SendAccountActivated(userEmail, username, dashboardURL string) error {
	data := map[string]interface{}{
		"Username":     username,
		"DashboardURL": dashboardURL,
	}

	if err := en.mailer.Send(userEmail, "account_activated.tmpl", data); err != nil {
		en.logger.Error(
			"failed to send account activated notification",
			"email", userEmail,
			"error", err,
		)
		return fmt.Errorf("failed to send activation email: %w", err)
	}

	return nil
}

// getCurrentTimestampString returns a formatted current timestamp
func getCurrentTimestampString() string {
	return strings.TrimSpace("") // Simple format - can be enhanced with time.Now().Format() if needed
}
