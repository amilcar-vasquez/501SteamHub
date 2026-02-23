// filename: internal/services/google_auth.go

// Package services contains application-level business logic that sits above
// the data layer but below the HTTP handlers.
package services

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

// googleScopes are the OAuth2 scopes required for uploading to YouTube and
// reading from Google Drive.
var googleScopes = []string{
	"https://www.googleapis.com/auth/youtube.upload",
	"https://www.googleapis.com/auth/drive.readonly",
}

// NewGoogleOAuthConfig builds an *oauth2.Config from the environment variables
// YOUTUBE_CLIENT_ID, YOUTUBE_CLIENT_SECRET, and GOOGLE_REDIRECT_URL.
// It returns an error if either credential is missing.
func NewGoogleOAuthConfig(redirectURL string) (*oauth2.Config, error) {
	clientID := os.Getenv("YOUTUBE_CLIENT_ID")
	clientSecret := os.Getenv("YOUTUBE_CLIENT_SECRET")

	if clientID == "" || clientSecret == "" {
		return nil, fmt.Errorf("google_auth: YOUTUBE_CLIENT_ID and YOUTUBE_CLIENT_SECRET must be set")
	}

	return &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		Scopes:       googleScopes,
		Endpoint:     google.Endpoint,
		RedirectURL:  redirectURL,
	}, nil
}

// GetClient constructs a pre-authorised *http.Client using a stored refresh
// token.  It reads YOUTUBE_CLIENT_ID, YOUTUBE_CLIENT_SECRET, and
// YOUTUBE_REFRESH_TOKEN from the environment.  The returned client
// automatically refreshes the access token when it expires.
func GetClient() (*http.Client, error) {
	clientID := os.Getenv("YOUTUBE_CLIENT_ID")
	clientSecret := os.Getenv("YOUTUBE_CLIENT_SECRET")
	refreshToken := os.Getenv("YOUTUBE_REFRESH_TOKEN")

	if clientID == "" {
		return nil, fmt.Errorf("google_auth: YOUTUBE_CLIENT_ID is not set")
	}
	if clientSecret == "" {
		return nil, fmt.Errorf("google_auth: YOUTUBE_CLIENT_SECRET is not set")
	}
	if refreshToken == "" {
		return nil, fmt.Errorf("google_auth: YOUTUBE_REFRESH_TOKEN is not set")
	}

	cfg := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		Scopes:       googleScopes,
		Endpoint:     google.Endpoint,
	}

	token := &oauth2.Token{
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
	}

	return cfg.Client(context.Background(), token), nil
}
