# Stage 1: Build the Go application
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum for dependency caching
COPY go.mod .
COPY go.sum .

# Download Go modules
RUN go mod download

# Copy the entire application source code
COPY . .

# Build the Go application
# CGO_ENABLED=0 disables CGO for static linking
# GOOS=linux ensures the binary is built for Linux
# -o myapp specifies the output binary name
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp .

# Stage 2: Create the final lean image
FROM alpine:latest

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set ownership of application directory and copy files
RUN mkdir /app && chown appuser:appgroup /app
WORKDIR /app
COPY . /app

# Switch to the non-root user
USER appuser

# Copy the compiled binary from the builder stage
COPY --from=builder /app/myapp .

# Define the command to run when the container starts
CMD ["./myapp"]
