// filename: cmd/api/oauthHandlers.go

package main

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"net/http"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

// oauthStateExpiry is how long the CSRF state cookie stays valid.
const oauthStateExpiry = 10 * time.Minute

// googleScopes are the OAuth2 scopes needed for YouTube uploads and Drive reads.
var googleScopes = []string{
	"https://www.googleapis.com/auth/youtube.upload",
	"https://www.googleapis.com/auth/drive.readonly",
}

// buildGoogleOAuthConfig constructs an *oauth2.Config from the credentials
// already stored in the application configuration.
func (a *app) buildGoogleOAuthConfig() *oauth2.Config {
	return &oauth2.Config{
		ClientID:     a.config.youtube.clientID,
		ClientSecret: a.config.youtube.clientSecret,
		Scopes:       googleScopes,
		Endpoint:     google.Endpoint,
		RedirectURL:  a.config.youtube.redirectURL,
	}
}

// googleLoginHandler redirects the browser to Google's consent page.
//
// GET /v1/oauth/google/login
//
// Query params respected by the redirect:
//   - access_type=offline  → Google returns a refresh token
//   - prompt=consent       → forces the consent screen even for returning users,
//     guaranteeing a fresh refresh token every time
//
// A random CSRF state value is written to a short-lived cookie and reflected in
// the redirect URL so that googleCallbackHandler can validate it.
func (a *app) googleLoginHandler(w http.ResponseWriter, r *http.Request) {
	// Generate a cryptographically random state token.
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}
	state := base64.URLEncoding.EncodeToString(b)

	// Persist the state in a short-lived HTTP-only cookie so the callback can
	// verify it and reject CSRF attempts.
	http.SetCookie(w, &http.Cookie{
		Name:     "oauth_state",
		Value:    state,
		Expires:  time.Now().Add(oauthStateExpiry),
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		Path:     "/",
	})

	cfg := a.buildGoogleOAuthConfig()
	url := cfg.AuthCodeURL(
		state,
		oauth2.AccessTypeOffline,
		oauth2.ApprovalForce,
	)

	http.Redirect(w, r, url, http.StatusTemporaryRedirect)
}

// googleCallbackHandler handles the redirect back from Google after the user
// grants consent.
//
// GET /v1/oauth/google/callback   (or /callback, whichever is registered in
// Google Cloud Console)
//
// On success it logs the refresh token at Info level so you can copy it into
// your .envrc as YOUTUBE_REFRESH_TOKEN.  It also writes a JSON response
// confirming the token exchange.
func (a *app) googleCallbackHandler(w http.ResponseWriter, r *http.Request) {
	// ── CSRF state validation ──────────────────────────────────────────────
	stateCookie, err := r.Cookie("oauth_state")
	if err != nil {
		a.invalidCredentialsResponse(w, r)
		return
	}

	if r.URL.Query().Get("state") != stateCookie.Value {
		a.invalidCredentialsResponse(w, r)
		return
	}

	// Clear the state cookie immediately — it has served its purpose.
	http.SetCookie(w, &http.Cookie{
		Name:     "oauth_state",
		Value:    "",
		Expires:  time.Unix(0, 0),
		MaxAge:   -1,
		HttpOnly: true,
		Path:     "/",
	})

	// ── Exchange the authorisation code for tokens ─────────────────────────
	code := r.URL.Query().Get("code")
	if code == "" {
		a.badRequestResponse(w, r, errors.New("authorization code is missing from the callback request"))
		return
	}

	cfg := a.buildGoogleOAuthConfig()
	token, err := cfg.Exchange(context.Background(), code)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	// ── Log the refresh token so it can be persisted ───────────────────────
	// The refresh token is only returned when access_type=offline and (on first
	// use or after prompt=consent).  Log it so the operator can copy it into
	// their .envrc as YOUTUBE_REFRESH_TOKEN.
	if token.RefreshToken != "" {
		a.logger.Info("google oauth: refresh token received — save this as YOUTUBE_REFRESH_TOKEN",
			"refresh_token", token.RefreshToken)
	} else {
		a.logger.Warn("google oauth: no refresh token returned; ensure access_type=offline and prompt=consent were set, and that the token has not been issued before")
	}

	err = a.writeJSON(w, http.StatusOK, envelope{
		"message":     "OAuth2 token exchange successful",
		"has_refresh": token.RefreshToken != "",
		"token_type":  token.TokenType,
		"expiry":      token.Expiry,
	}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}
