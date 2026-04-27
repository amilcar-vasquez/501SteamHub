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

### 🔐 Authentication & Authorization
- **Email + Password Registration** — self-service sign-up with field validation
- **Email Activation Flow** — confirmation token sent via SMTP; user must click to activate
- **Bearer Token Auth** — scoped tokens (`authentication` for login, `activation` for email verification)
- **Password Security** — bcrypt hashing (cost 12)
- **Role-Based Access Control** — 7 roles with permission inheritance: `admin`, `DSC`, `TeamLead`, `SubjectExpert`, `Fellow`, `Secretary`, `User`
- **Admin User Management** — create/update/delete users; change roles; toggle active status (all audited)

### 📚 Resources & Content
- **Five Resource Categories** — Lesson Plans, Videos, Slideshows, Assessments, Other
- **Multi-Subject & Grade Level Tagging** — resources can belong to many subjects/levels simultaneously
- **Auto-Generated URL Slugs** — shareable links like `/resource-by-slug/my-great-lesson`
- **Google Drive Integration** — store file links with resources
- **Contributor Tracking** — record who created/modified each resource
- **View Count Metrics** — track engagement per resource
- **Full CRUD with Filtering** — list by subject, grade level, status, contributor; pagination support
- **Bulk Metrics** — dashboard counts by status (Draft, UnderReview, Approved, Published, etc.)

### 📝 Lesson Plans
- **Block-Based Builder** — 5 instructional fields: Objectives, Materials, Content, Assessment, Differentiation
- **Versioned Content** — each edit creates a new version with change description tracked
- **Duration Tracking** — lesson length recorded in minutes
- **Structure Validation** — ensures lessons meet minimum completion criteria

### ⭐ Resource Review Workflow
- **Multi-Status Lifecycle** — Draft → Submitted → UnderReview → Approved/Rejected/NeedsRevision → DesignCurate → Published → Indexed → Archived
- **Multi-Role ReviewDecisions** — SubjectExpert, TeamLead, DSC, and admin can review independently
- **Inline Comments** — reviewers add block-specific feedback tied to lesson indices with resolution tracking
- **Status History & Audit Trail** — every status change logged with user, timestamp, and context
- **Force Override** — admin/DSC can jump resources to any status for emergency adjustments
- **Reviewer Dashboard** — see real-time count of resources per status

### 👥 Fellow System
- **Extended Profiles** — school, district, BEMIS number (Ministry of Education), subject specialization
- **STEAM Points Tracking** — cumulative contribution score via weighted algorithm (FR-27)
- **Application Workflow** — User → applies → DSC/Admin approves → role upgraded to Fellow
- **Application Status Tracking** — Pending / Approved / Rejected (with audit trail)
- **MOE Document Upload** — applicants attach supporting files stored securely in private directory
- **Fellows Directory** — activated fellows listed for discovery and collaboration

### 🏆 Contribution Scoring (FR-27)
- **Weighted Algorithm** — base points vary by resource type (Video: 7pts, LessonPlan: 10pts, etc.)
- **Completeness Multiplier** — lesson plans with all 5 blocks filled earn full bonus
- **Synergy Bonus** — multi-category contributions earn up to 2.0x multiplier (e.g., lesson + video + assessment)
- **Automatic Calculation** — points awarded upon resource approval, no manual entry
- **Leaderboard Ready** — cached scores for ranking top contributors
- **Audit Logging** — track when points were awarded and by what action

### 💬 Comments & Discussion
- **Public Comments** — users browse resources and leave discussion; full CRUD
- **Review Comments** — privileged feedback during approval process by reviewers
- **Comment Resolution** — mark review feedback as addressed to track reviewer sign-off
- **Threaded Discussions** — support for comment threads (schema ready)

### 📹 YouTube Integration
- **Automatic Upload** — approved Video resources uploaded in background without blocking the UI
- **Full Metadata Control** — title, description, tags, privacy (public/unlisted/private), made-for-kids, category all configurable
- **Google OAuth2 Flow** — secure auth to obtain and refresh YouTube credentials
- **Google Drive Extraction** — supports multiple Drive link formats automatically
- **Non-Blocking Processing** — upload happens asynchronously; user sees status in resource

### 🔔 Notifications
- **Email Notifications** — SMTP-based messaging for 7+ events (application approved, status changed, password reset, etc.)
- **In-App Notifications** — persistent messages in user dashboard
- **Bulk Messaging** — admin/DSC/Secretary send notifications to single users or broadcast
- **User Notification Preferences** — users manage their own read/unread status
- **Email Templates** — pre-built templates for common workflows (Fellow approved, Resource published, etc.)

### 📊 Admin Dashboard
- **Platform Metrics** — total users, resources by status, resource breakdown
- **User Management Console** — list, create, update, delete users; change roles with confirmation
- **Admin Safeguards** — prevent accidental removal of own admin role
- **Force Status Overrides** — jump resources to any lifecycle state
- **Fellow Application Review** — list pending applications; approve/reject with audit trail
- **Document Management** — retrieve MOE upload files from fellow applications
- **Activity Logs** — resource status history and points award history

### 📈 Access & Analytics
- **View Tracking** — record each resource access with user and timestamp
- **Access Reports** — admin/DSC/DEC can pull access analytics per resource
- **Engagement Metrics** — understand which resources are most viewed

### 🛡️ Security & Performance
- **CORS Support** — cross-origin requests properly configured for SPA frontend
- **Rate Limiting** — protect endpoints from abuse
- **Input Validation** — comprehensive validation on all user inputs (fields, lengths, enums, etc.)
- **Error Handling** — proper HTTP status codes (400, 401, 403, 404, 409, 500, etc.)
- **Graceful Shutdown** — safe cleanup when server stops
- **Metrics Endpoint** — `/debug/vars` for Go runtime and custom app metrics

### 📦 Database & Infrastructure
- **PostgreSQL 14+** — normalized schema with 16+ tables, indexes, and constraints
- **Golang-Migrate Compatibility** — 25 migrations with rollback support
- **Schema Bootstrap** — `schema.sql` for quick setup without migration tool
- **Seed Data** — 7 roles and 20+ subjects pre-populated
- **Default Admin** — `admin` / `Admin@501steam` (change on first login!)
- **Structured Logging** — `log/slog` to stdout and `logs/server.log`

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
