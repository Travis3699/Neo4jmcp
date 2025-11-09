# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o neo4j-mcp ./cmd/neo4j-mcp

# Runtime stage
FROM alpine:latest

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/neo4j-mcp .

# Expose port (adjust if needed)
EXPOSE 8080

# Run the MCP server
CMD ["./neo4j-mcp"]
