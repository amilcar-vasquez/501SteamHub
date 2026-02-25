# 501 STEAM Hub

A full-stack educational resource platform for Belizean educators. Teachers and Fellows can submit, review, and publish STEAM lesson plans, videos, slideshows, and assessments. A structured multi-role review workflow governs every resource from draft through publication, with automated YouTube upload for approved video content.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Roles & Permissions](#roles--permissions)
- [Resource Lifecycle](#resource-lifecycle)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Reference](#api-reference)
- [Make Targets](#make-targets)

---

## Tech Stack

| Layer    | Technology |
|----------|-----------|
| Backend  | Go 1.25, `net/http`, `httprouter` |
| Database | PostgreSQL (`lib/pq`) |
| Frontend | Svelte (SPA, client-side routing) |
| Auth     | Bearer token (bcrypt password hashing, cost 12) |
| Email    | SMTP via `go-mail` |
| Video    | YouTube Data API v3 via Google OAuth2 |
| Logging  | `log/slog` → stdout + `logs/server.log` |
| Metrics  | `expvar` at `/debug/vars` |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  Svelte SPA  (ui/)          localhost:3000        │
│  Client-side router, Material Design 3 tokens    │
└──────────────────────┬──────────────────────────┘
                       │  REST / JSON
┌──────────────────────▼──────────────────────────┐
│  Go API  (cmd/api/)         localhost:4000        │
│  CORS → rateLimit → authenticate → router        │
│                                                   │
│  internal/data/     — database models             │
│  internal/mailer/   — SMTP activation emails      │
│  internal/services/ — Google OAuth2 + YouTube     │
│  internal/validator/— input validation            │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│  PostgreSQL database                              │
│  migrations/  (golang-migrate)                    │
│  schema.sql   (single-file bootstrap)             │
└─────────────────────────────────────────────────┘
```

---

## Roles & Permissions

| Role | Description |
|------|-------------|
| `admin` | Full system access — user management, role changes, status overrides |
| `DSC` | Director of Science & Technology — mirrors admin for content and user management |
| `TeamLead` | Reviews and approves resources across all subjects; manages Fellows |
| `SubjectExpert` | Reviews and approves resources in their subject area |
| `Fellow` | Submits and manages resources; has an extended profile |
| `Secretary` | Administrative — can send notifications |
| `User` | Default role — browse, comment, and rate resources |

---

## Resource Lifecycle

```
Draft → Submitted → UnderReview ──→ NeedsRevision
                                 └→ Rejected
                                 └→ Approved → DesignCurate → Published → Indexed → Archived
```

- **Fellows** create resources (Draft) and submit them.
- **SubjectExpert / TeamLead** review and move resources through the workflow.
- **DSC / admin** can force-override any status at any time.
- **Video** resources are automatically uploaded to YouTube when approved (if YouTube credentials are configured).

---

## Features

### Resources
- Five categories: `LessonPlan`, `Video`, `Slideshow`, `Assessment`, `Other`
- Multi-value subjects and grade levels via junction tables
- URL slug auto-generated from title for shareable links
- Drive link for source file storage
- Per-resource status history (full audit trail)
- View access tracking

### Lesson Plans
- Structured block-based lesson builder (objectives, activities, assessment, differentiation)
- Versioned lesson content with change descriptions

### Review Workflow
- Multi-role decision records per resource
- Inline reviewer comments tied to specific lesson block indices
- Comment resolution tracking

### Fellows
- Extended user profiles with school, district, MOE identifier
- Fellow application flow: User → applies → DSC/admin approves → role upgraded
- Applications track status (Pending / Approved / Rejected)

### Users & Auth
- Email + password registration with email activation flow
- Bearer token authentication (scoped: `authentication`, `activation`)
- Admin can create, update, toggle active status, and change roles directly

### YouTube Integration
- Approved `Video` resources are uploaded automatically in a background goroutine
- YouTube title, description, tags, privacy, made-for-kids, category configurable at submission
- Google OAuth2 login/callback flow to obtain refresh token

### Notifications
- In-app notifications with email channel support
- Admin / DSC / Secretary can create; users manage their own

### Contribution Scoring
- Cached per-resource contribution score for ranking contributors

---

## Project Structure

```
501SteamHub/
├── cmd/api/                  Go API server
│   ├── main.go               Entry point, config, DB init
│   ├── routes.go             All REST routes + middleware chain
│   ├── middleware.go         CORS, rate limit, auth, recover
│   ├── *Handlers.go          One file per domain
│   └── server.go             Graceful HTTP server
│
├── internal/
│   ├── data/                 Database models (one file per table)
│   ├── mailer/               SMTP email sender
│   ├── services/             Google OAuth2 + YouTube upload
│   └── validator/            Input validation helpers
│
├── migrations/               golang-migrate SQL files (000–022)
├── schema.sql                Single-file full schema + seed data
├── ui/                       Svelte SPA
│   └── src/
│       ├── pages/            Full-page views
│       ├── components/       Reusable UI components
│       ├── api/              REST client helpers
│       ├── stores/           Svelte stores (auth, user)
│       └── router.js         Client-side history-API router
├── makefile                  Dev tasks
└── .envrc                    Local environment variables (not committed)
```

---

## Getting Started

### Prerequisites

- Go 1.25+
- PostgreSQL 14+
- Node.js 18+ (for the UI)
- [`golang-migrate`](https://github.com/golang-migrate/migrate) CLI (optional — `schema.sql` works without it)

### Clone

```bash
git clone https://github.com/amilcar-vasquez/501SteamHub.git
cd 501SteamHub
```

---

## Environment Variables

Create a `.envrc` file in the repo root (it is `source`d by the Makefile):

```bash
# Database
export DB_DSN="postgres://user:password@localhost/steamhub_db?sslmode=disable"

# SMTP (for activation emails)
export SMTP_HOST="smtp.example.com"
export SMTP_PORT=587
export SMTP_USERNAME="no-reply@example.com"
export SMTP_PASSWORD="secret"
export SMTP_SENDER="501 STEAM Hub <no-reply@example.com>"

# YouTube / Google OAuth2 (optional — required for video auto-upload)
export YOUTUBE_CLIENT_ID="..."
export YOUTUBE_CLIENT_SECRET="..."
export YOUTUBE_REFRESH_TOKEN="..."
export YOUTUBE_REDIRECT_URI="http://localhost:4000/v1/oauth/google/callback"
```

---

## Database Setup

### Option A — single-file bootstrap (no migration tool needed)

```bash
# Create the database
createdb steamhub_db

# Apply full schema + seed data in one step
psql -U postgres -d steamhub_db -f schema.sql
```

### Option B — golang-migrate

```bash
make db/migrations/up
```

### Default admin credentials

After bootstrapping, an admin account is available:

| Field    | Value |
|----------|-------|
| Username | `admin` |
| Password | `Admin@501steam` |

> **Change this password immediately after first login.**

---

## Running the Application

### API server

```bash
make run/api
# or directly:
go run ./cmd/api --port=4000 --env=development --db-dsn="$DB_DSN"
```

### UI (development)

```bash
cd ui
npm install
npm run dev        # starts on http://localhost:5173 or :3000
```

---

## API Reference

All routes are prefixed with `/v1`. Authentication uses a `Bearer <token>` header.

### Auth & Users

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `POST` | `/v1/users` | Public | Register a new user |
| `PUT` | `/v1/users/activated` | Public | Activate account via token |
| `POST` | `/v1/tokens/authentication` | Public | Sign in — returns bearer token |
| `POST` | `/v1/tokens/activation` | Public | Re-send activation token |
| `GET` | `/v1/users/:id` | Activated | Get user profile |
| `PATCH` | `/v1/users/:id` | Activated | Update own profile |
| `GET` | `/v1/users` | admin | List all users |
| `DELETE` | `/v1/users/:id` | admin | Delete user |

### Admin — User Management

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `POST` | `/v1/admin/users` | admin / DSC | Create user directly |
| `PUT` | `/v1/admin/users/:id` | admin / DSC | Full user update |
| `PATCH` | `/v1/admin/users/:id/role` | admin / DSC | Change user role |
| `PATCH` | `/v1/admin/users/:id/active` | admin / DSC | Toggle active status |
| `GET` | `/v1/admin/metrics` | admin / DSC | Platform-wide metrics |

### Resources

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `GET` | `/v1/resources` | Public | List resources (filterable + paginated) |
| `POST` | `/v1/resources` | Fellow | Submit a new resource |
| `GET` | `/v1/resources/:id` | Public | Get resource by ID |
| `PATCH` | `/v1/resources/:id` | Activated | Update resource |
| `DELETE` | `/v1/resources/:id` | admin | Delete resource |
| `GET` | `/v1/resource-by-slug/:slug` | Public | Get resource by slug |
| `GET` | `/v1/resource-metrics` | Reviewer | Per-status resource counts |
| `POST` | `/v1/resources/:id/status` | admin / DSC | Force-override status |

### Reviews & Comments

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `POST` | `/v1/resource-reviews` | Reviewer role | Submit review decision |
| `GET` | `/v1/resource-reviews` | Activated | List reviews |
| `PATCH` | `/v1/resource-reviews/:id` | Reviewer role | Update review |
| `POST` | `/v1/review-comments` | Reviewer role | Add inline review comment |
| `PATCH` | `/v1/review-comments/:id/resolve` | Activated | Resolve comment |
| `GET` | `/v1/resources/:id/review-comments` | Activated | Get review comments |
| `POST` | `/v1/comments` | Activated | Add public comment |
| `GET` | `/v1/resources/:id/comments` | Public | List resource comments |

### Fellows

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `POST` | `/v1/fellow-applications` | Activated | Apply to become a Fellow |
| `GET` | `/v1/fellow-applications/me` | Activated | Get own application status |
| `GET` | `/v1/admin/fellow-applications` | admin / DSC | List all applications |
| `PATCH` | `/v1/admin/fellow-applications/:id/approve` | admin / DSC | Approve application |
| `PATCH` | `/v1/admin/fellow-applications/:id/reject` | admin / DSC | Reject application |
| `GET` | `/v1/fellows` | Activated | List fellows |
| `POST` | `/v1/fellows` | Activated | Create fellow profile |

### Lessons

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `POST` | `/v1/lessons` | Activated | Create lesson |
| `GET` | `/v1/lessons/:id` | Public | Get lesson |
| `PATCH` | `/v1/lessons/:id` | Activated | Update lesson |
| `GET` | `/v1/resources/:id/lessons` | Public | List lessons for resource |

### Notifications & Contributions

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| `GET` | `/v1/notifications` | Activated | Get own notifications |
| `PATCH` | `/v1/notifications/:id` | Activated | Mark read / update |
| `POST` | `/v1/notifications` | admin / Secretary | Send notification |
| `GET` | `/v1/contributions` | Activated | List contribution scores |

### Google OAuth2 (YouTube setup)

| Method | Route | Description |
|--------|-------|-------------|
| `GET` | `/v1/oauth/google/login` | Redirect to Google consent screen |
| `GET` | `/v1/oauth/google/callback` | Receive authorization code, exchange for refresh token |

---

## Make Targets

```bash
make run/api                   # Start the API server
make db/psql                   # Open a psql shell to the database
make db/migrations/up          # Apply all pending migrations
make db/migrations/down        # Roll back the last migration
make db/migrations/version     # Show current migration version
make db/migrations/force version=N  # Force-set migration version (use with care)
make db/migrations/new name=X  # Create a new empty migration pair
make db/setup                  # Run the database setup script
make test                      # Run the full Go test suite
```
