// INTEGRATION GUIDE: Email Notifications System
//
// This file documents how to integrate the email notifications system into existing handlers.
// Follow the patterns shown below for each event type.
//
// ═══════════════════════════════════════════════════════════════════════════════════════

// ──[ 1. SETUP IN MAIN.GO ]──────────────────────────────────────────────────────────────
//
// Add these imports to cmd/api/main.go:
//
//     "github.com/amilcar-vasquez/501SteamHub/internal/notifications"
//
// After initializing the mailer and logger, add:
//
//     notifier := notifications.NewEmailNotifier(
//         m,  // Your existing mailer instance
//         log.With("service", "notifications"),
//     )
//     notificationHelper := notifications.NewNotificationHelper(notifier, log)
//
// Pass notificationHelper to your application struct:
//
//     config := appConfig{
//         // ... existing config ...
//         notificationHelper: notificationHelper,
//     }

// ──[ 2. ADD NOTIFICATION HELPER TO APPLICATION STRUCT ]──────────────────────────────────
//
// In cmd/api/main.go or appropriate struct definition add:
//
//     type appConfig struct {
//         // ... existing fields ...
//         notificationHelper *notifications.NotificationHelper
//     }
//
// Then access it in handlers as: a.notificationHelper

// ──[ 3. FELLOW APPLICATION: SUBMITTED ]───────────────────────────────────────────────────
//
// In cmd/api/fellowApplicationHandlers.go, in the applyForFellowHandler function,
// after successfully saving the application, add:
//
//     // Get admin/DSC emails (typically from database or config)
//     // This is a simplified example - adjust based on your user model
//     adminEmails := []string{"admin@example.com", "dsc@example.com"}
//
//     // Send async notification
//     a.notificationHelper.AsyncNotifyFellowApplicationSubmitted(
//         adminEmails,
//         application.FullName,
//         user.Email,
//         application.Organization,
//         strings.Join(application.Subjects, ", "),
//         strings.Join(application.GradeLevels, ", "),
//         application.ExperienceYears,
//         "https://yourdomain.com",  // Dashboard URL
//     )
//
// Example placement in current handler:
//
//     app, err := a.models.FellowApplications.Insert(application)
//     if err != nil {
//         // ... existing error handling ...
//         return
//     }
//
//     // ✓ ADD THIS: Send notification
//     adminEmails := []string{"admin@example.com"} // Get from config or DB
//     a.notificationHelper.AsyncNotifyFellowApplicationSubmitted(
//         adminEmails,
//         app.FullName,
//         user.Email,
//         app.Organization,
//         strings.Join(app.Subjects, ", "),
//         strings.Join(app.GradeLevels, ", "),
//         app.ExperienceYears,
//         os.Getenv("DASHBOARD_URL"),
//     )
//
//     a.writeJSON(w, http.StatusCreated, env...)

// ──[ 4. FELLOW APPLICATION: APPROVED ]────────────────────────────────────────────────────
//
// In cmd/api/fellowApplicationHandlers.go, in adminApproveFellowHandler,
// after successfully updating the application and promoting user, add:
//
//     // After user is promoted to Fellow role
//     a.notificationHelper.AsyncNotifyFellowApplicationApproved(
//         user.Email,
//         user.Username,
//         "https://yourdomain.com",
//     )
//
// Example:
//
//     app, err := a.models.FellowApplications.Approve(appID, userID)
//     if err != nil {
//         // ... error handling ...
//         return
//     }
//
//     // Fetch the user to get their email
//     user, err := a.models.Users.Get(app.UserID)
//     if err != nil {
//         a.logger.Error("failed to fetch user for notification", "error", err)
//         // Continue anyway - notification failure shouldn't block response
//     } else {
//         // ✓ ADD THIS: Send notification
//         a.notificationHelper.AsyncNotifyFellowApplicationApproved(
//             user.Email,
//             user.Username,
//             os.Getenv("DASHBOARD_URL"),
//         )
//     }
//
//     a.writeJSON(w, http.StatusOK, env...)

// ──[ 5. FELLOW APPLICATION: REJECTED ]────────────────────────────────────────────────────
//
// In cmd/api/fellowApplicationHandlers.go, in adminRejectFellowHandler,
// after successfully rejecting the application, add:
//
//     a.notificationHelper.AsyncNotifyFellowApplicationRejected(
//         user.Email,
//         user.Username,
//     )
//
// Example:
//
//     app, err := a.models.FellowApplications.Reject(appID)
//     if err != nil {
//         // ... error handling ...
//         return
//     }
//
//     // Fetch user for notification
//     user, err := a.models.Users.Get(app.UserID)
//     if err != nil {
//         a.logger.Error("failed to fetch user for notification", "error", err)
//     } else {
//         // ✓ ADD THIS: Send notification
//         a.notificationHelper.AsyncNotifyFellowApplicationRejected(
//             user.Email,
//             user.Username,
//         )
//     }
//
//     a.writeJSON(w, http.StatusOK, env...)

// ──[ 6. RESOURCE STATUS: ANY CHANGE ]─────────────────────────────────────────────────────
//
// Key transitions that trigger notifications:
//   • Draft → Submitted
//   • Submitted → UnderReview
//   • UnderReview → NeedsRevision (action required)
//   • UnderReview → Approved
//   • Any → Rejected (action required)
//   • Approved → Published
//
// In cmd/api/resourceHandlers.go, in updateResourceHandler,
// after status change is saved, add:
//
//     // After saving status change
//     if oldStatus != newStatus {
//         // Determine if action is required
//         actionRequired := newStatus == "NeedsRevision" || newStatus == "Rejected"
//
//         contributor, err := a.models.Users.Get(resource.ContributorID)
//         if err != nil {
//             a.logger.Error("failed to fetch contributor", "error", err)
//         } else {
//             a.notificationHelper.AsyncNotifyResourceStatusChanged(
//                 contributor.Email,
//                 contributor.Username,
//                 resource.Title,
//                 oldStatus,
//                 newStatus,
//                 "",  // Leave empty if no reviewer comment
//                 os.Getenv("DASHBOARD_URL"),
//                 actionRequired,
//             )
//         }
//     }

// ──[ 7. RESOURCE STATUS: APPROVAL (FROM REVIEW) ]──────────────────────────────────────────
//
// In cmd/api/resourceReviewHandlers.go, in createResourceReviewHandler,
// when decision is "Approved", add notification:
//
//     if decision == "Approved" {
//         // After resource is updated to Approved status
//         a.notificationHelper.AsyncNotifyResourceStatusChanged(
//             contributor.Email,
//             contributor.Username,
//             resource.Title,
//             "UnderReview",
//             "Approved",
//             review.CommentSummary,
//             os.Getenv("DASHBOARD_URL"),
//             false,  // No action required for approved
//         )
//     }

// ──[ 8. RESOURCE STATUS: ADMIN OVERRIDE ]──────────────────────────────────────────────────
//
// In cmd/api/adminHandlers.go, in forceResourceStatusHandler (or similar),
// add notification after enforcing status change:
//
//     if oldStatus != newStatus {
//         actionRequired := newStatus == "NeedsRevision" || newStatus == "Rejected"
//
//         contributor, err := a.models.Users.Get(resource.ContributorID)
//         if err != nil {
//             a.logger.Error("failed to fetch contributor", "error", err)
//         } else {
//             a.notificationHelper.AsyncNotifyResourceStatusChanged(
//                 contributor.Email,
//                 contributor.Username,
//                 resource.Title,
//                 oldStatus,
//                 newStatus,
//                 reason,  // Include admin override reason if provided
//                 os.Getenv("DASHBOARD_URL"),
//                 actionRequired,
//             )
//         }
//     }

// ──[ 9. USER: PASSWORD CHANGED ]──────────────────────────────────────────────────────────
//
// In cmd/api/userHandlers.go, in updateUserHandler,
// when password is changed, add:
//
//     // After password is successfully hashed and saved
//     if updateData.Password != nil && *updateData.Password != "" {
//         a.notificationHelper.AsyncNotifyPasswordChanged(
//             user.Email,
//             user.Username,
//         )
//     }
//
// Example placement:
//
//     err = a.models.Users.Update(user.User_id, updateData)
//     if err != nil {
//         // ... error handling ...
//         return
//     }
//
//     // ✓ ADD THIS: Send password changed notification
//     if updateData.Password != nil && *updateData.Password != "" {
//         a.notificationHelper.AsyncNotifyPasswordChanged(
//             user.Email,
//             user.Username,
//         )
//     }

// ──[ 10. USER: EMAIL CHANGED ]────────────────────────────────────────────────────────────
//
// In cmd/api/userHandlers.go, in updateUserHandler,
// when email is changed, add:
//
//     // After email is successfully changed
//     if updateData.Email != nil && *updateData.Email != user.Email {
//         a.notificationHelper.AsyncNotifyEmailChanged(
//             user.Email,  // Send to old email to confirm change
//             user.Username,
//             *updateData.Email,
//         )
//     }

// ──[ 11. USER: ACCOUNT ACTIVATED ]───────────────────────────────────────────────────────
//
// In cmd/api/tokenHandlers.go, in activateUserHandler,
// after account is activated, add:
//
//     // After user.IsActive is set to true and saved
//     a.notificationHelper.AsyncNotifyAccountActivated(
//         user.Email,
//         user.Username,
//         os.Getenv("DASHBOARD_URL"),
//     )

// ──[ ENVIRONMENT VARIABLES ]─────────────────────────────────────────────────────────────
//
// Add these to your .envrc file:
//
//     export DASHBOARD_URL="http://localhost:3000"
//     export SMTP_HOST="smtp.gmail.com"
//     export SMTP_PORT=587
//     export SMTP_USERNAME="your-email@gmail.com"
//     export SMTP_PASSWORD="your-app-password"
//     export SMTP_SENDER="501 STEAM Hub <noreply@501steamhub.bz>"

// ──[ OPTIONAL: ENABLE/DISABLE NOTIFICATIONS ]────────────────────────────────────────────
//
// To add a feature toggle for notifications, you can add:
//
//     export ENABLE_EMAIL_NOTIFICATIONS="true"
//
// Then modify the notification helper to check this:
//
//     if os.Getenv("ENABLE_EMAIL_NOTIFICATIONS") != "true" {
//         return  // Skip notification
//     }

// ──[ TESTING NOTIFICATIONS ]─────────────────────────────────────────────────────────────
//
// To test notifications locally without a real SMTP server:
// 1. Use MailHog: https://github.com/mailhog/MailHog
// 2. Run: mailhog (listens on port 1025 for SMTP, 8025 for UI)
// 3. Set environment variables:
//
//     export SMTP_HOST="localhost"
//     export SMTP_PORT=1025
//     export SMTP_USERNAME=""
//     export SMTP_PASSWORD=""
//     export SMTP_SENDER="test@example.com"
//
// 4. View emails at http://localhost:8025

// ──[ ERROR HANDLING ]─────────────────────────────────────────────────────────────────────
//
// Key principles:
// • Notification failures should NOT block the main request response
// • Always log notification errors with context
// • Use async execution (goroutines) for all notifications
// • Validate required fields exist before sending
//
// Example error handling pattern:
//
//     contributor, err := a.models.Users.Get(resource.ContributorID)
//     if err != nil {
//         a.logger.Error("failed to fetch contributor for notification", "error", err)
//         // Don't return - continue processing - notification isn't critical
//     } else {
//         a.notificationHelper.AsyncNotifyResourceStatusChanged(...)
//     }

package notifications
