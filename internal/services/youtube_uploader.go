// filename: internal/services/youtube_uploader.go

// Package services contains application-level business logic that sits above
// the data layer but below the HTTP handlers.
package services

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"regexp"
	"strconv"
	"strings"

	"net/http"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"google.golang.org/api/drive/v3"
	"google.golang.org/api/googleapi"
	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

// driveFileIDPatterns tries to extract a Google Drive file ID from the common URL
// formats returned by the sharing dialog.
var driveFileIDPatterns = []*regexp.Regexp{
	// https://drive.google.com/file/d/<ID>/view
	regexp.MustCompile(`/file/d/([a-zA-Z0-9_-]+)`),
	// https://drive.google.com/open?id=<ID>
	// https://drive.google.com/uc?id=<ID>
	// https://drive.google.com/uc?export=download&id=<ID>
	regexp.MustCompile(`[?&]id=([a-zA-Z0-9_-]+)`),
}

// ExtractDriveFileID parses a Google Drive share/download URL and returns the
// file ID portion.  Returns an error if no recognised pattern is found.
func ExtractDriveFileID(driveLink string) (string, error) {
	for _, p := range driveFileIDPatterns {
		if m := p.FindStringSubmatch(driveLink); len(m) > 1 {
			return m[1], nil
		}
	}
	return "", fmt.Errorf("could not extract Google Drive file ID from URL: %q", driveLink)
}

// YouTubeUploader holds the shared dependencies required to stream a Google
// Drive video directly to YouTube without writing anything to disk.
type YouTubeUploader struct {
	// Client is a pre-authorised OAuth2 HTTP client that carries the scopes:
	//   https://www.googleapis.com/auth/youtube.upload
	//   https://www.googleapis.com/auth/drive.readonly
	Client *http.Client

	// Models is used to persist the YouTube URL back to the database after a
	// successful upload.
	Models *data.Models

	// Logger is the shared structured logger.
	Logger *slog.Logger
}

// UploadResourceToYouTube kicks off a background goroutine that:
//  1. Downloads the video from Google Drive using a streaming HTTP response.
//  2. Pipes the bytes directly into a YouTube resumable upload (no disk I/O).
//  3. On success, sets resource.PublishedURL and resource.Status = "Published"
//     in the database.
//
// The function returns immediately; all work happens in the goroutine.
// Any error is logged but never surfaced to the caller.
func (u *YouTubeUploader) UploadResourceToYouTube(resource *data.Resource) {
	// Capture values that the goroutine needs before we return.
	resourceID := resource.ID
	resourceTitle := resource.Title
	resourceCategory := resource.Category

	var summary string
	if resource.Summary != nil {
		summary = *resource.Summary
	}
	subjects := append([]string(nil), resource.Subjects...) // defensive copy

	var driveLink string
	if resource.DriveLink != nil {
		driveLink = *resource.DriveLink
	}

	go func() {
		ctx := context.Background()

		// ── Validate inputs ────────────────────────────────────────────────
		if driveLink == "" {
			u.Logger.Error("youtube upload: drive_link is empty — skipping",
				"resource_id", resourceID)
			return
		}

		// Only Video resources should be uploaded.
		if resourceCategory != "Video" {
			u.Logger.Warn("youtube upload: category is not Video — skipping",
				"resource_id", resourceID, "category", resourceCategory)
			return
		}

		fileID, err := ExtractDriveFileID(driveLink)
		if err != nil {
			u.Logger.Error("youtube upload: failed to extract Drive file ID",
				"resource_id", resourceID, "error", err)
			return
		}

		// ── Build API clients ──────────────────────────────────────────────
		driveSvc, err := drive.NewService(ctx, option.WithHTTPClient(u.Client))
		if err != nil {
			u.Logger.Error("youtube upload: failed to create Drive service",
				"resource_id", resourceID, "error", err)
			return
		}

		ytSvc, err := youtube.NewService(ctx, option.WithHTTPClient(u.Client))
		if err != nil {
			u.Logger.Error("youtube upload: failed to create YouTube service",
				"resource_id", resourceID, "error", err)
			return
		}

		// ── Fetch file metadata (MIME type) from Drive ─────────────────────
		fileMeta, err := driveSvc.Files.Get(fileID).Fields("name", "mimeType").Do()
		if err != nil {
			u.Logger.Error("youtube upload: failed to fetch Drive file metadata",
				"resource_id", resourceID, "file_id", fileID, "error", err)
			return
		}
		mimeType := fileMeta.MimeType
		if mimeType == "" {
			mimeType = "video/mp4"
		}

		// ── Stream download from Drive → YouTube via io.Pipe ───────────────
		// The pipe lets us avoid writing anything to disk: one goroutine
		// forwards the Drive response body into the write-end of the pipe
		// while the YouTube resumable upload reads from the read-end.
		pr, pw := io.Pipe()

		// Start the Drive download and forward bytes into the pipe.
		driveResp, err := driveSvc.Files.Get(fileID).Download()
		if err != nil {
			u.Logger.Error("youtube upload: failed to initiate Drive download",
				"resource_id", resourceID, "file_id", fileID, "error", err)
			return
		}

		go func() {
			defer driveResp.Body.Close()
			_, copyErr := io.Copy(pw, driveResp.Body)
			pw.CloseWithError(copyErr) // propagates any read error to YouTube upload
		}()

		// ── Build YouTube video metadata ───────────────────────────────────
		// Defaults derived from the Resource row.
		videoTitle := resourceTitle
		description := summary
		if len(subjects) > 0 {
			description += "\n\nSubjects: " + strings.Join(subjects, ", ")
		}
		categoryID := "27" // Education (YouTube category)
		privacyStatus := "unlisted"
		var tags []string
		var madeForKids bool

		// Apply VideoMetadata overrides when available.
		vm, vmErr := u.Models.VideoMetadata.GetByResource(resourceID)
		if vmErr == nil {
			if vm.YouTubeTitle != "" {
				videoTitle = vm.YouTubeTitle
			}
			if vm.YouTubeDescription != "" {
				description = vm.YouTubeDescription
			}
			if len(vm.Tags) > 0 {
				tags = []string(vm.Tags)
			}
			if vm.PrivacyStatus != "" {
				privacyStatus = vm.PrivacyStatus
			}
			madeForKids = vm.MadeForKids
			if vm.CategoryID != 0 {
				categoryID = strconv.Itoa(vm.CategoryID)
			}
		} else if vmErr != data.ErrRecordNotFound {
			// A real DB error — log and continue with defaults.
			u.Logger.Warn("youtube upload: could not load video_metadata, using resource defaults",
				"resource_id", resourceID, "error", vmErr)
		}

		video := &youtube.Video{
			Snippet: &youtube.VideoSnippet{
				Title:       videoTitle,
				Description: description,
				CategoryId:  categoryID,
				Tags:        tags,
			},
			Status: &youtube.VideoStatus{
				PrivacyStatus: privacyStatus,
				MadeForKids:   madeForKids,
			},
		}

		// ── Perform resumable upload ───────────────────────────────────────
		// ChunkSize(0) uses the library default (256 KiB).  Use a larger value
		// (e.g. 8 MiB) for better throughput on big files.
		call := ytSvc.Videos.Insert([]string{"snippet", "status"}, video)
		call.Media(pr, googleapi.ChunkSize(8*1024*1024))
		call.Header().Set("X-Upload-Content-Type", mimeType)

		u.Logger.Info("youtube upload: starting upload",
			"resource_id", resourceID, "drive_file_id", fileID)

		uploaded, err := call.Do()
		if err != nil {
			u.Logger.Error("youtube upload: upload failed",
				"resource_id", resourceID, "error", err)
			return
		}

		// ── Persist results ────────────────────────────────────────────────
		youtubeURL := "https://www.youtube.com/watch?v=" + uploaded.Id

		// Re-fetch the resource to avoid overwriting concurrent edits.
		dbResource, err := u.Models.Resources.Get(resourceID)
		if err != nil {
			u.Logger.Error("youtube upload: failed to re-fetch resource for update",
				"resource_id", resourceID, "error", err)
			return
		}

		dbResource.PublishedURL = &youtubeURL
		dbResource.Status = "Published"

		if err := u.Models.Resources.Update(dbResource); err != nil {
			u.Logger.Error("youtube upload: failed to update resource after upload",
				"resource_id", resourceID, "youtube_url", youtubeURL, "error", err)
			return
		}

		u.Logger.Info("youtube upload: complete",
			"resource_id", resourceID,
			"youtube_id", uploaded.Id,
			"youtube_url", youtubeURL)
	}()
}
