# Build stage for Neo4j MCP
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o neo4j-mcp ./cmd/neo4j-mcp

# Final stage with Alpine
FROM alpine:latest

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/neo4j-mcp .

# Expose port for HTTP
EXPOSE 8080

# Set default Neo4j environment variables
ENV NEO4J_URI=neo4j+s://a83acdda.databases.neo4j.io \
    NEO4J_USER=neo4j \
    NEO4J_PASSWORD=E6RWi4K6nqhQd8bjGpK7gpD4SGzoVk0Cv7ou8vuLM4 \
    NEO4J_DATABASE=neo4j

# Run neo4j-mcp directly with HTTP transport
CMD ["/root/neo4j-mcp", "--transport", "http", "--host", "0.0.0.0", "--port", "8080"]
