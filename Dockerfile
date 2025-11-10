# Use Python base image for official mcp-neo4j-cypher
FROM python:3.11-slim

# Install uv package manager for faster installs
RUN pip install --no-cache-dir uv

# Install Neo4j MCP Cypher server
RUN uv pip install --system mcp-neo4j-cypher

# Neo4j connection configuration
ENV NEO4J_URI=neo4j+s://a83acdda.databases.neo4j.io \
    NEO4J_USER=neo4j \
    NEO4J_PASSWORD=E6RWi4K6nqhQd8bjGpK7gpD4SGzoVk0Cv7ou8vuLM4 \
    NEO4J_DATABASE=neo4j

# HTTP transport configuration (required for Smithery)
ENV NEO4J_TRANSPORT=http \
    NEO4J_MCP_SERVER_HOST=0.0.0.0 \
    NEO4J_MCP_SERVER_PORT=8080 \
    NEO4J_MCP_SERVER_PATH=/mcp
    ENV     NEO4J_MCP_SERVER_ALLOWED_HOSTS=*

# Smithery requires port 8080
EXPOSE 8080

# Run the official Neo4j MCP server
CMD ["mcp-neo4j-cypher"]
