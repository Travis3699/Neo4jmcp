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

# Final stage with Node.js for mcp-proxy
FROM node:20-alpine

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/neo4j-mcp .

# Install mcp-proxy globally
RUN npm install -g mcp-proxy
# Expose port for HTTP
EXPOSE 8080

# Create entrypoint script
RUN echo '#!/bin/sh' > /root/entrypoint.sh && \
    echo 'mcp-proxy sse-to-stdio --port 8080 --path /mcp -- /root/neo4j-mcp' >> /root/entrypoint.sh && \
    chmod +x /root/entrypoint.sh

# Run the proxy wrapper
CMD ["/root/entrypoint.sh"]
