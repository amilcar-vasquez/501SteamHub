# Email Notifications System

A robust, non-blocking email notification system for the 501 STEAM Hub platform. This implementation handles critical system events with a clean, extensible architecture.

## Overview

The notification system sends transactional emails for:
- Fellow application workflows (submitted, approved, rejected)
- Resource status transitions (throughout lifecycle)
- User account events (password change, email change, activation)

All notifications are:
- ✅ **Asynchronous** - Never block the main request
- ✅ **Logged** - All failures are recorded for debugging
- ✅ **HTML-formatted** - Professional, branded email templates
- ✅ **Non-critical** - System continues operating if notifications fail
- ✅ **Extensible** - Easy to add new notification types

## Architecture

```
Handler (cmd/api/)
    ↓
    └─→ a.notificationHelper.AsyncNotifyXYZ(...)
            ↓
            └─→ go func() { notifier.SendXYZ() }()
                    ↓
                    └─→ Mailer (internal/mailer/)
                            ↓
                            └─→ SMTP (email sent)
```

## Package Structure

```
internal/notifications/
├── service.go                  # Core EmailNotifier implementation
├── async.go                   # Async helper functions for handlers
├── INTEGRATION_GUIDE.go       # Code examples for integration
└── templates/                 # Email HTML templates
    ├── fellow_application_submitted.tmpl
    ├── fellow_application_approved.tmpl
    ├── fellow_application_rejected.tmpl
    ├── resource_status_changed.tmpl
    ├── password_changed.tmpl
    ├── email_changed.tmpl
    └── account_activated.tmpl
```

## Components

### 1. EmailNotifier Service

**File:** `service.go`

High-level service for sending notifications:

```go
type Notifier interface {
    SendFellowApplicationSubmitted(adminEmails []string, ...) error
    SendFellowApplicationApproved(userEmail, userName, dashboardURL string) error
    SendFellowApplicationRejected(userEmail, userName string) error
    SendResourceStatusChanged(userEmail, ...) error
    SendPasswordChanged(userEmail, username string) error
    SendEmailChanged(userEmail, username, newEmail string) error
    SendAccountActivated(userEmail, username, dashboardURL string) error
}
```

### 2. NotificationHelper

**File:** `async.go`

Convenience wrapper for async notifications in handlers:

```go
// Usage in handlers
a.notificationHelper.AsyncNotifyResourceStatusChanged(
    contributor.Email,
    contributor.Username,
    resource.Title,
    oldStatus,
    newStatus,
    reviewComment,
    dashboardURL,
    actionRequired,
)
```

### 3. Email Templates

**Location:** `templates/`

Professional HTML email templates with:
- Branded header and footer
- Clear call-to-action buttons
- Status-specific styling
- Mobile-responsive design
- Plain text fallback

## Integration Steps

### Step 1: Initialize in main.go

```go
package main

import (
    "github.com/amilcar-vasquez/501SteamHub/internal/notifications"
)

func main() {
    // ... existing code ...
    
    // Initialize notifier
    notifier := notifications.NewEmailNotifier(m, log.With("service", "notifications"))
    notificationHelper := notifications.NewNotificationHelper(notifier, log)
    
    // Add to application config
    app := appConfig{
        // ... existing fields ...
        notificationHelper: notificationHelper,
    }
}
```

### Step 2: Add Helper to Application Struct

```go
type appConfig struct {
    // ... existing fields ...
    notificationHelper *notifications.NotificationHelper
}
```

### Step 3: Hook into Handlers

See `INTEGRATION_GUIDE.go` for detailed examples for each handler.

**Key Integration Points:**

| Event | Handler File | Trigger |
|-------|--------------|---------|
| Fellow application submitted | `fellowApplicationHandlers.go` | After INSERT |
| Fellow application approved | `fellowApplicationHandlers.go` | After UPDATE + promotion |
| Fellow application rejected | `fellowApplicationHandlers.go` | After UPDATE |
| Resource status changed | `resourceHandlers.go` | After status transition |
| Password changed | `userHandlers.go` | After password UPDATE |
| Email changed | `userHandlers.go` | After email UPDATE |
| Account activated | `tokenHandlers.go` | After activation |

## Usage Examples

### Fellow Applications

```go
// In applyForFellowHandler
app, err := a.models.FellowApplications.Insert(application)
if err != nil { /* handle error */ }

// Send notification
adminEmails := []string{"admin@example.com", "dsc@example.com"}
a.notificationHelper.AsyncNotifyFellowApplicationSubmitted(
    adminEmails,
    app.FullName,
    user.Email,
    app.Organization,
    strings.Join(app.Subjects, ", "),
    strings.Join(app.GradeLevels, ", "),
    app.ExperienceYears,
    os.Getenv("DASHBOARD_URL"),
)
```

### Resource Status Changes

```go
// In updateResourceHandler or review handler
if oldStatus != newStatus {
    actionRequired := newStatus == "NeedsRevision" || newStatus == "Rejected"
    
    contributor, err := a.models.Users.Get(resource.ContributorID)
    if err != nil {
        a.logger.Error("failed to fetch contributor", "error", err)
    } else {
        a.notificationHelper.AsyncNotifyResourceStatusChanged(
            contributor.Email,
            contributor.Username,
            resource.Title,
            oldStatus,
            newStatus,
            reviewerComment,
            os.Getenv("DASHBOARD_URL"),
            actionRequired,
        )
    }
}
```

### User Account Events

```go
// Password changed
a.notificationHelper.AsyncNotifyPasswordChanged(user.Email, user.Username)

// Email changed
a.notificationHelper.AsyncNotifyEmailChanged(user.Email, user.Username, newEmail)

// Account activated
a.notificationHelper.AsyncNotifyAccountActivated(
    user.Email,
    user.Username,
    os.Getenv("DASHBOARD_URL"),
)
```

## Configuration

### Environment Variables

```bash
# SMTP Configuration
export SMTP_HOST="smtp.gmail.com"
export SMTP_PORT="587"
export SMTP_USERNAME="your-email@gmail.com"
export SMTP_PASSWORD="your-app-password"
export SMTP_SENDER="501 STEAM Hub <noreply@501steamhub.bz>"

# Dashboard URL (used in email links)
export DASHBOARD_URL="https://steamhub.501bz.org"

# Optional: Enable/disable notifications
export ENABLE_EMAIL_NOTIFICATIONS="true"
```

### Local Testing with MailHog

For local development without sending real emails:

```bash
# Install and run MailHog
brew install mailhog  # or download from https://github.com/mailhog/MailHog
mailhog

# Configure SMTP to use MailHog
export SMTP_HOST="localhost"
export SMTP_PORT="1025"
export SMTP_USERNAME=""
export SMTP_PASSWORD=""
export SMTP_SENDER="test@example.com"

# View emails at http://localhost:8025
```

## Error Handling

### Key Principles

1. **Notification failures never block requests**
   ```go
   contributor, err := a.models.Users.Get(id)
   if err != nil {
       a.logger.Error("notification fetch failed", "error", err)
       // Continue - don't abort request
   } else {
       a.notificationHelper.AsyncNotifyXYZ(...)
   }
   ```

2. **All errors are logged with context**
   ```go
   // Logged as:
   // level=ERROR service=notifications msg="async notification failed"
   //     error="failed to send email: SMTP connection timeout"
   ```

3. **Async execution prevents timeout cascades**
   ```go
   // Each notification runs in separate goroutine
   // No wait for SMTP, handler returns immediately
   go func() { /* send email */ }()
   ```

## Testing

### Unit Testing Notifications

```go
// Mock the Notifier interface
type mockNotifier struct {
    sent []string
}

func (m *mockNotifier) SendFellowApplicationApproved(email, name, url string) error {
    m.sent = append(m.sent, email)
    return nil
}

// Use in tests
mockNotifier := &mockNotifier{}
helper := NewNotificationHelper(mockNotifier, logger)
helper.AsyncNotifyFellowApplicationApproved("user@example.com", "John", "http://example.com")
```

### Integration Testing

Use MailHog to verify emails are being sent and check their content.

## Template Variables

### Fellow Application Submitted
- `FullName` - Applicant's full name
- `ApplicantEmail` - Applicant's email
- `Organization` - Organization name
- `Subjects` - CSV of subjects
- `GradeLevels` - CSV of grade levels
- `ExperienceYears` - Years of experience
- `DashboardURL` - Link to admin dashboard

### Resource Status Changed
- `ContributorName` - Resource owner name
- `ResourceTitle` - Resource title
- `OldStatus` - Previous status
- `NewStatus` - Current status
- `ReviewerComment` - Optional feedback
- `DashboardURL` - Link to resources
- `ActionRequired` - Boolean flag
- `UpdatedAt` - Timestamp

## Monitoring & Debugging

### Check Logs

```bash
# View notification errors
grep "async notification failed" logs/server.log

# View email sending errors
grep "failed to send" logs/server.log
```

### Email Flow Debugging

```go
// If a notification isn't sending, check:
// 1. SMTP configuration is correct
// 2. Template file exists in templates/
// 3. Mailer.Send() succeeds (check logs)
// 4. Required fields are provided to notification function
// 5. Email address is valid (format)
```

## Production Considerations

### Rate Limiting
- Consider rate limiting per recipient if sending multiple notifications
- Use SMTP provider's built-in rate limiting

### Retry Logic
- Existing mailer has 3-attempt retry with 500ms delays
- Consider adding queue-based retry for critical notifications

### Monitoring
- Log all notifications sent to audit trail
- Monitor SMTP provider's delivery rates
- Set up alerts for recurring email failures

### Backup Strategy
- Store unsent notifications in database (optional enhancement)
- Implement admin interface to resend failed notifications (optional)

## Future Enhancements

1. **Database Notification Logs**
   - Store sent/failed notifications in a `notifications` table
   - Enable admins to resend failed emails

2. **SMS Notifications**
   - Add SMS service layer for critical alerts
   - Implement Twilio or similar provider

3. **In-App Notifications**
   - Mirror critical emails as in-app notifications
   - Build notification center UI

4. **Notification Preferences**
   - Allow users to opt-out of certain notification types
   - Support multiple email addresses per user

5. **Advanced Templates**
   - Multi-language support
   - User preference-based templates
   - Dynamic branding based on organization

## Troubleshooting

### Emails Not Sending

**Check SMTP Configuration:**
```bash
# Test SMTP connection
telnet $SMTP_HOST $SMTP_PORT
```

**Verify Credentials:**
- Gmail: Enable 2FA, use app-specific password
- Other providers: Check SMTP settings in account settings

**Check Template Files:**
```bash
ls -la internal/notifications/templates/
```

**Review Logs:**
```bash
grep -i "smtp\|mail\|notification" logs/server.log
```

### Template Rendering Issues

- Verify template file names match exactly
- Check variable names in template (`{{.VariableName}}`)
- Ensure all required variables are provided in data map

### Goroutine Leaks

- NotificationHelper properly closes goroutines
- Monitor for hanging goroutines in production with `expvar`

## Code Examples

See `INTEGRATION_GUIDE.go` for comprehensive, copy-paste-ready code examples for each integration point.
