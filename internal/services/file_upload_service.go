// filename: internal/services/file_upload_service.go

package services

import (
	"bytes"
	"fmt"
	"io"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"
)

// FileValidator holds rules for validating uploaded files
type FileValidator struct {
	MaxSize      int64
	AllowedMimes map[string]string // mime -> extension mapping
}

// NewMoeDocumentValidator creates a validator for MOE verification documents
func NewMoeDocumentValidator() *FileValidator {
	return &FileValidator{
		MaxSize: 5 << 20, // 5 MB
		AllowedMimes: map[string]string{
			"application/pdf": ".pdf",
			"image/jpeg":      ".jpg",
			"image/png":       ".png",
		},
	}
}

// ValidateAndSaveFile performs strict validation on uploaded file and saves it securely.
// It returns the storage path (NOT a public URL) on success.
// NEVER trust client-provided metadata (filename, Content-Type).
func (fv *FileValidator) ValidateAndSaveFile(file io.Reader, filename string, validator *FileValidator) (storagePath string, err error) {
	// Read file into memory with size limit pre-check
	limitedReader := io.LimitReader(file, validator.MaxSize+1)
	fileData, err := io.ReadAll(limitedReader)
	if err != nil {
		return "", fmt.Errorf("failed to read file: %w", err)
	}

	// Enforce size limit BEFORE processing
	if int64(len(fileData)) > validator.MaxSize {
		return "", fmt.Errorf("file too large: max %d bytes allowed", validator.MaxSize)
	}

	// Detect MIME type from file bytes (NOT client Content-Type header)
	detectedMime := http.DetectContentType(fileData)
	// Normalize the MIME type to remove parameters (e.g., "text/plain; charset=utf-8" -> "text/plain")
	detectedMime, _, _ = mime.ParseMediaType(detectedMime)

	// Verify MIME type is allowed
	extension, allowed := validator.AllowedMimes[detectedMime]
	if !allowed {
		return "", fmt.Errorf("invalid file type: %s not allowed", detectedMime)
	}

	// Generate safe filename using UUID + detected extension
	safeFilename := uuid.New().String() + extension
	storagePath = filepath.Join("moe_docs", safeFilename)

	// Save to secure storage location (outside public directory)
	err = saveFileSecurely(storagePath, fileData)
	if err != nil {
		return "", fmt.Errorf("failed to save file: %w", err)
	}

	return storagePath, nil
}

// saveFileSecurely stores file in a private directory not accessible via HTTP
func saveFileSecurely(storagePath string, data []byte) error {
	// Create private storage directory if it doesn't exist
	storageDir := filepath.Join(".", "private_storage")
	err := os.MkdirAll(storageDir, 0700) // Owner read/write/execute only
	if err != nil {
		return fmt.Errorf("failed to create storage directory: %w", err)
	}

	fullPath := filepath.Join(storageDir, storagePath)

	// Create parent directory if needed
	err = os.MkdirAll(filepath.Dir(fullPath), 0700)
	if err != nil {
		return fmt.Errorf("failed to create subdirectory: %w", err)
	}

	// Write file securely (create if not exists, fail if exists)
	f, err := os.OpenFile(fullPath, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0600) // Owner read/write only
	if err != nil {
		return fmt.Errorf("failed to create file: %w", err)
	}
	defer f.Close()

	_, err = f.Write(data)
	if err != nil {
		// Clean up on write failure
		os.Remove(fullPath)
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

// GenerateSignedURL creates a time-limited URL for accessing a stored document.
// Only authorized users (admin/reviewer) should receive this URL.
func GenerateSignedURL(storagePath string, expiresIn time.Duration) (string, error) {
	// For now, return a simple reference that includes the path and expiration
	// In production with S3, this would be an S3 presigned URL
	// This is a placeholder that your application would handle via a GET endpoint

	expiryTime := time.Now().Add(expiresIn).Unix()
	// URL format: /v1/admin/moe-documents/{storagePath}?expires={expiryTime}&signature={signature}
	// Signature validation would happen server-side
	signedURL := fmt.Sprintf("/v1/admin/moe-documents/%s?expires=%d", storagePath, expiryTime)
	return signedURL, nil
}

// RetrieveSecureFile reads a file from secure storage.
// Must verify authentication before calling.
func RetrieveSecureFile(storagePath string) ([]byte, error) {
	fullPath := filepath.Join(".", "private_storage", storagePath)

	// Prevent directory traversal attacks
	absPath, err := filepath.Abs(fullPath)
	if err != nil {
		return nil, fmt.Errorf("invalid path: %w", err)
	}

	storageDir, err := filepath.Abs(filepath.Join(".", "private_storage"))
	if err != nil {
		return nil, fmt.Errorf("storage directory error: %w", err)
	}

	// Ensure the requested file is within the storage directory
	if !bytes.HasPrefix([]byte(absPath), []byte(storageDir)) {
		return nil, fmt.Errorf("access denied: path traversal attempt detected")
	}

	data, err := os.ReadFile(absPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}

	return data, nil
}
