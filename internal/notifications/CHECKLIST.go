// IMPLEMENTATION CHECKLIST
//
// Use this checklist to verify all integration points have been implemented.
// Each item should have the corresponding code added to the specified file.

package notifications

/*

═══════════════════════════════════════════════════════════════════════════════════════
STEP 1: INITIALIZE IN main.go
═══════════════════════════════════════════════════════════════════════════════════════

[ ] Import notification package:
    import "github.com/amilcar-vasquez/501SteamHub/internal/notifications"

[ ] Add to application struct definition:
    type appConfig struct {
        // ... existing fields ...
        notificationHelper *notifications.NotificationHelper
    }

[ ] Initialize after mailer setup:
    notifier := notifications.NewEmailNotifier(m, log.With("service", "notifications"))
    app := appConfig{
        // ... existing fields ...
        notificationHelper: notifications.NewNotificationHelper(notifier, log),
    }


═══════════════════════════════════════════════════════════════════════════════════════
STEP 2: FELLOW APPLICATION HANDLERS
═══════════════════════════════════════════════════════════════════════════════════════

FILE: cmd/api/fellowApplicationHandlers.go

[ ] applyForFellowHandler - NOTIFICATION: Fellow application submitted
    LOCATION: After app is successfully inserted
    CODE TEMPLATE:

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

[ ] adminApproveFellowHandler - NOTIFICATION: Fellow application approved
    LOCATION: After user is promoted to Fellow role
    CODE TEMPLATE:

    user, err := a.models.Users.Get(app.UserID)
    if err != nil {
        a.logger.Error("failed to fetch user for notification", "error", err)
    } else {
        a.notificationHelper.AsyncNotifyFellowApplicationApproved(
            user.Email,
            user.Username,
            os.Getenv("DASHBOARD_URL"),
        )
    }

[ ] adminRejectFellowHandler - NOTIFICATION: Fellow application rejected
    LOCATION: After application is rejected
    CODE TEMPLATE:

    user, err := a.models.Users.Get(app.UserID)
    if err != nil {
        a.logger.Error("failed to fetch user for notification", "error", err)
    } else {
        a.notificationHelper.AsyncNotifyFellowApplicationRejected(
            user.Email,
            user.Username,
        )
    }


═══════════════════════════════════════════════════════════════════════════════════════
STEP 3: RESOURCE STATUS CHANGE HANDLERS
═══════════════════════════════════════════════════════════════════════════════════════

FILE: cmd/api/resourceHandlers.go (updateResourceHandler)

[ ] Update resource handler - NOTIFICATION: Resource status changed
    LOCATION: After status is changed and saved
    TRIGGER: When oldStatus != newStatus
    CODE TEMPLATE:

    if oldStatus != newStatus {
        actionRequired := newStatus == "NeedsRevision" || newStatus == "Rejected"

        contributor, err := a.models.Users.Get(resource.ContributorID)
        if err != nil {
            a.logger.Error("failed to fetch contributor for notification", "error", err)
        } else {
            a.notificationHelper.AsyncNotifyResourceStatusChanged(
                contributor.Email,
                contributor.Username,
                resource.Title,
                oldStatus,
                newStatus,
                "",  // reviewerComment (empty for auto-transitions)
                os.Getenv("DASHBOARD_URL"),
                actionRequired,
            )
        }
    }


FILE: cmd/api/resourceReviewHandlers.go (createResourceReviewHandler)

[ ] Review resource handler - NOTIFICATION: Resource status changed to Approved
    LOCATION: After review decision is recorded and resource status updated
    TRIGGER: When decision == "Approved"
    CODE TEMPLATE:

    if decision == "Approved" {
        contributor, err := a.models.Users.Get(resource.ContributorID)
        if err != nil {
            a.logger.Error("failed to fetch contributor for notification", "error", err)
        } else {
            a.notificationHelper.AsyncNotifyResourceStatusChanged(
                contributor.Email,
                contributor.Username,
                resource.Title,
                "UnderReview",
                "Approved",
                review.CommentSummary,
                os.Getenv("DASHBOARD_URL"),
                false,  // No action required for approval
            )
        }
    }

[ ] Review resource handler - NOTIFICATION: Resource status changed to NeedsRevision
    LOCATION: After review decision is recorded and resource status updated
    TRIGGER: When decision == "Rejected" (status becomes NeedsRevision)
    CODE TEMPLATE:

    if decision == "Rejected" {
        contributor, err := a.models.Users.Get(resource.ContributorID)
        if err != nil {
            a.logger.Error("failed to fetch contributor for notification", "error", err)
        } else {
            a.notificationHelper.AsyncNotifyResourceStatusChanged(
                contributor.Email,
                contributor.Username,
                resource.Title,
                "UnderReview",
                "NeedsRevision",
                review.CommentSummary,
                os.Getenv("DASHBOARD_URL"),
                true,  // Action required - needs revision
            )
        }
    }


FILE: cmd/api/adminHandlers.go (or similar - Admin override endpoint)

[ ] Admin force status handler - NOTIFICATION: Admin-forced status change
    LOCATION: After admin status override is applied
    TRIGGER: When oldStatus != newStatus (from admin action)
    CODE TEMPLATE:

    if oldStatus != newStatus {
        actionRequired := newStatus == "NeedsRevision" || newStatus == "Rejected"

        contributor, err := a.models.Users.Get(resource.ContributorID)
        if err != nil {
            a.logger.Error("failed to fetch contributor for notification", "error", err)
        } else {
            overrideReason := "Admin override: " + reason  // Include admin reason
            a.notificationHelper.AsyncNotifyResourceStatusChanged(
                contributor.Email,
                contributor.Username,
                resource.Title,
                oldStatus,
                newStatus,
                overrideReason,
                os.Getenv("DASHBOARD_URL"),
                actionRequired,
            )
        }
    }


═══════════════════════════════════════════════════════════════════════════════════════
STEP 4: USER ACCOUNT HANDLERS
═══════════════════════════════════════════════════════════════════════════════════════

FILE: cmd/api/userHandlers.go (updateUserHandler)

[ ] Password changed - NOTIFICATION: Password changed
    LOCATION: After password is successfully hashed and saved
    TRIGGER: When password field is provided and changed
    CODE TEMPLATE:

    if updateData.Password != nil && *updateData.Password != "" {
        a.notificationHelper.AsyncNotifyPasswordChanged(
            user.Email,
            user.Username,
        )
    }

[ ] Email changed - NOTIFICATION: Email changed
    LOCATION: After email is successfully changed
    TRIGGER: When email field is provided and different from current
    CODE TEMPLATE:

    if updateData.Email != nil && *updateData.Email != user.Email {
        a.notificationHelper.AsyncNotifyEmailChanged(
            user.Email,  // Send to OLD email to confirm change
            user.Username,
            *updateData.Email,  // The NEW email
        )
    }


FILE: cmd/api/tokenHandlers.go (activateUserHandler)

[ ] Account activated - NOTIFICATION: Account activated
    LOCATION: After user.IsActive is set to true and saved
    CODE TEMPLATE:

    a.notificationHelper.AsyncNotifyAccountActivated(
        user.Email,
        user.Username,
        os.Getenv("DASHBOARD_URL"),
    )


═══════════════════════════════════════════════════════════════════════════════════════
STEP 5: ADD REQUIRED IMPORTS
═══════════════════════════════════════════════════════════════════════════════════════

Add to each file that uses notifications:

    import (
        "os"
        "strings"
    )


═══════════════════════════════════════════════════════════════════════════════════════
STEP 6: VERIFY ENVIRONMENT VARIABLES
═══════════════════════════════════════════════════════════════════════════════════════

[ ] Add to .envrc file:
    export DASHBOARD_URL="http://localhost:3000"
    export SMTP_HOST="smtp.gmail.com"
    export SMTP_PORT=587
    export SMTP_USERNAME="your-email@gmail.com"
    export SMTP_PASSWORD="your-app-password"
    export SMTP_SENDER="501 STEAM Hub <noreply@501steamhub.bz>"

    OR for local testing with MailHog:
    export SMTP_HOST="localhost"
    export SMTP_PORT=1025
    export SMTP_USERNAME=""
    export SMTP_PASSWORD=""
    export SMTP_SENDER="test@example.com"


═══════════════════════════════════════════════════════════════════════════════════════
STEP 7: TESTING
═══════════════════════════════════════════════════════════════════════════════════════

[ ] Local SMTP Testing
    1. Install MailHog: brew install mailhog
    2. Run: mailhog
    3. Configure SMTP to localhost:1025
    4. View emails at http://localhost:8025

[ ] Test Each Notification Type
    - [ ] Fellow application submitted
    - [ ] Fellow application approved
    - [ ] Fellow application rejected
    - [ ] Resource status: Auto-transition (Draft→Submitted)
    - [ ] Resource status: Admin decision (Submitted→UnderReview)
    - [ ] Resource status: Reviewer decision (UnderReview→Approved)
    - [ ] Resource status: Reviewer decision (UnderReview→NeedsRevision)
    - [ ] Resource status: Admin override
    - [ ] Password changed
    - [ ] Email changed
    - [ ] Account activated

*/
