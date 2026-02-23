package main

import (
	"context"
	"database/sql"
	"expvar"
	"flag"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/amilcar-vasquez/501SteamHub/internal/data"
	"github.com/amilcar-vasquez/501SteamHub/internal/mailer"
	"github.com/amilcar-vasquez/501SteamHub/internal/services"
	_ "github.com/lib/pq" // PostgreSQL driver
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

const version = "1.0.0"

var dbDSN = os.Getenv("DB_DSN")
var smtpHost = os.Getenv("SMTP_HOST")

// YouTube / Google Drive OAuth2 credentials (required for video auto-upload).
var ytClientID = os.Getenv("YOUTUBE_CLIENT_ID")
var ytClientSecret = os.Getenv("YOUTUBE_CLIENT_SECRET")
var ytRefreshToken = os.Getenv("YOUTUBE_REFRESH_TOKEN")
var ytRedirectURL = os.Getenv("YOUTUBE_REDIRECT_URI")
var smtpPort = 587 // default SMTP port
var smtpUsername = os.Getenv("SMTP_USERNAME")
var smtpPassword = os.Getenv("SMTP_PASSWORD")
var smtpSender = os.Getenv("SMTP_SENDER")

type configuration struct {
	port    int
	env     string
	version string
	db      struct {
		dsn string
	}
	cors struct {
		trustedOrigins []string
	}
	limiter struct {
		rps     float64
		burst   int
		enabled bool
	}
	smtp struct {
		host     string
		port     int
		username string
		password string
		sender   string
	}
	// youtube holds OAuth2 credentials used to upload approved Video resources.
	youtube struct {
		clientID     string
		clientSecret string
		refreshToken string
		// redirectURL is the callback URL registered in Google Cloud Console.
		// Used by the /v1/oauth/google/login → /v1/oauth/google/callback flow.
		redirectURL string
	}
}

type app struct {
	config          configuration
	logger          *slog.Logger
	models          *data.Models
	mailer          mailer.Mailer
	wg              sync.WaitGroup
	youtubeUploader *services.YouTubeUploader
}

// loads the application configuration from terminal flags or defaults in the env.
func loadConfig() configuration {
	var cfg configuration

	cfg.version = version

	// Server settings
	flag.IntVar(&cfg.port, "port", 4000, "API server port")
	flag.StringVar(&cfg.env, "env", "development", "Environment (development|staging|production)")

	// Database settings
	defaultDSN := dbDSN
	if defaultDSN == "" {
		defaultDSN = "user:password@/dbname?parseTime=true"
	}
	flag.StringVar(&cfg.db.dsn, "db-dsn", defaultDSN, "PostgreSQL DSN")

	// CORS trusted origins settings
	flag.Func("cors-trusted-origins", "Trusted CORS origins (space separated)",
		func(val string) error {
			cfg.cors.trustedOrigins = strings.Fields(val)
			return nil
		})

	// Rate limiter settings
	flag.Float64Var(&cfg.limiter.rps, "limiter-rps", 2, "Rate Limiter Maximum requests per second")
	flag.IntVar(&cfg.limiter.burst, "limiter-burst", 5, "Rate Limiter Maximum burst")
	flag.BoolVar(&cfg.limiter.enabled, "limiter-enabled", true, "Enable Rate Limiter")

	// SMTP settings
	flag.StringVar(&cfg.smtp.host, "smtp-host", smtpHost, "SMTP host")
	flag.IntVar(&cfg.smtp.port, "smtp-port", smtpPort, "SMTP port")
	flag.StringVar(&cfg.smtp.username, "smtp-username", smtpUsername, "SMTP username")
	flag.StringVar(&cfg.smtp.password, "smtp-password", smtpPassword, "SMTP password")
	flag.StringVar(&cfg.smtp.sender, "smtp-sender", smtpSender, "SMTP sender email")

	// YouTube / Google Drive OAuth2 settings
	flag.StringVar(&cfg.youtube.clientID, "youtube-client-id", ytClientID, "YouTube OAuth2 client ID")
	flag.StringVar(&cfg.youtube.clientSecret, "youtube-client-secret", ytClientSecret, "YouTube OAuth2 client secret")
	flag.StringVar(&cfg.youtube.refreshToken, "youtube-refresh-token", ytRefreshToken, "YouTube OAuth2 refresh token")
	flag.StringVar(&cfg.youtube.redirectURL, "youtube-redirect-url", ytRedirectURL, "Google OAuth2 redirect URL (GOOGLE_REDIRECT_URL)")

	flag.Parse()

	return cfg
}

// sets up a structured logger using slog that writes to both stdout and a log file
func setupLogger() *slog.Logger {
	// Create logs directory if it doesn't exist
	logsDir := "logs"
	if err := os.MkdirAll(logsDir, 0755); err != nil {
		// If we can't create the directory, fall back to stdout only
		return slog.New(slog.NewTextHandler(os.Stdout, nil))
	}

	// Open or create the log file
	logFile, err := os.OpenFile(
		filepath.Join(logsDir, "server.log"),
		os.O_CREATE|os.O_WRONLY|os.O_APPEND,
		0666,
	)
	if err != nil {
		// If we can't open the file, fall back to stdout only
		return slog.New(slog.NewTextHandler(os.Stdout, nil))
	}

	// Create a multi-writer that writes to both stdout and the log file
	multiWriter := io.MultiWriter(os.Stdout, logFile)

	logger := slog.New(slog.NewTextHandler(multiWriter, nil))
	return logger
}

// openDB establishes a connection to the PostgreSQL database using the provided settings
func openDB(settings configuration) (*sql.DB, error) {
	db, err := sql.Open("postgres", settings.db.dsn)
	if err != nil {
		return nil, err
	}

	// set the context to ensure DB operations don't take too long
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// ping the database to verify connection
	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}

	return db, nil
}

func main() {
	// load the configuration
	cfg := loadConfig()

	// setup the logger
	logger := setupLogger()

	// open the database connection
	db, err := openDB(cfg)
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
	defer db.Close()

	// Initialize models first so both the app and the YouTube uploader share the same instance.
	models := data.NewModels(db)

	// Build the YouTube uploader when credentials are available.
	// The upload runs in a background goroutine so HTTP responses are never blocked.
	var ytUploader *services.YouTubeUploader
	if cfg.youtube.clientID != "" && cfg.youtube.clientSecret != "" && cfg.youtube.refreshToken != "" {
		oauthCfg := &oauth2.Config{
			ClientID:     cfg.youtube.clientID,
			ClientSecret: cfg.youtube.clientSecret,
			Scopes: []string{
				"https://www.googleapis.com/auth/youtube.upload",
				"https://www.googleapis.com/auth/drive.readonly",
			},
			Endpoint: google.Endpoint,
		}
		oauthToken := &oauth2.Token{
			RefreshToken: cfg.youtube.refreshToken,
			TokenType:    "Bearer",
		}
		ytClient := oauthCfg.Client(context.Background(), oauthToken)
		ytUploader = &services.YouTubeUploader{
			Client: ytClient,
			Models: models,
			Logger: logger,
		}
		logger.Info("YouTube uploader configured")
	} else {
		logger.Warn("YouTube uploader not configured — set YOUTUBE_CLIENT_ID, YOUTUBE_CLIENT_SECRET, YOUTUBE_REFRESH_TOKEN to enable auto-upload")
	}

	// initialize the app struct
	app := &app{
		config:          cfg,
		logger:          logger,
		models:          models,
		mailer:          mailer.New(cfg.smtp.host, cfg.smtp.port, cfg.smtp.username, cfg.smtp.password, cfg.smtp.sender),
		youtubeUploader: ytUploader,
	}

	// publish basic expvar metrics
	expvar.NewString("version").Set(version)
	expvar.NewString("env").Set(cfg.env)
	expvar.Publish("goroutines", expvar.Func(func() any { return runtime.NumGoroutine() }))
	expvar.Publish("database", expvar.Func(func() any { return db.Stats() }))

	err = app.Serve()
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
}
