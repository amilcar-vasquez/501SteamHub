// filename: cmd/api/statusLogger.go

package main

import "github.com/amilcar-vasquez/501SteamHub/internal/data"

// logResourceStatusChange inserts a status-transition record into resource_status_history.
// oldStatus may be empty if the resource had no previous status (e.g. on creation).
// userID may be 0 if the change is system-initiated or the actor is unknown.
// Errors are logged but never propagated — status history is best-effort; it must not
// block the main workflow.
func (a *app) logResourceStatusChange(resourceID int64, oldStatus, newStatus string, userID int64) {
	var old *string
	if oldStatus != "" {
		s := oldStatus
		old = &s
	}

	var by *int64
	if userID > 0 {
		by = &userID
	}

	history := &data.ResourceStatusHistory{
		ResourceID: resourceID,
		OldStatus:  old,
		NewStatus:  newStatus,
		ChangedBy:  by,
	}

	if err := a.models.ResourceStatusHistory.Insert(history); err != nil {
		a.logger.Error("failed to log resource status change",
			"resource_id", resourceID,
			"old_status", oldStatus,
			"new_status", newStatus,
			"error", err,
		)
	}
}
