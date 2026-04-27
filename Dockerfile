# Stage 1: Build
FROM golang:1.25.0-alpine AS builder

# Install build dependencies and migrate tool
RUN apk add --no-cache git make curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz -C /usr/local/bin

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the API binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api ./cmd/api

# Stage 2: Runtime
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates postgresql-client

# Copy migrate from builder
COPY --from=builder /usr/local/bin/migrate /usr/local/bin/migrate

# Copy binary from builder
COPY --from=builder /app/api /app/api

# Copy migrations
COPY migrations /app/migrations

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:4000/v1/healthcheck || exit 1

# Run the API
CMD ["/app/api"]
