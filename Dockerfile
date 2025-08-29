# Multi-stage Dockerfile for Railway deployment
# This will build all services but Railway will run them as one

# Build frontend
FROM node:18-alpine as frontend-builder
WORKDIR /app/frontend
COPY archon-ui-main/package*.json ./
RUN npm ci
COPY archon-ui-main/ ./
RUN npm run build

# Build backend
FROM python:3.11-slim as backend
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy Python requirements and install
COPY python/requirements.server.txt ./
RUN pip install --no-cache-dir -r requirements.server.txt

# Copy backend code
COPY python/ ./python/
COPY migration/ ./migration/

# Copy frontend build to the correct location for serving
COPY --from=frontend-builder /app/frontend/dist ./python/static
COPY --from=frontend-builder /app/frontend/dist ./static

# Set environment variables
ENV PYTHONPATH=/app/python
ENV SERVER_PORT=8181
ENV PROD=true

# Install a simple HTTP server for the frontend
RUN pip install aiofiles

# Expose port
EXPOSE 8181

# Start the backend server (which will also serve the frontend)
CMD ["python", "-m", "uvicorn", "src.server.main:app", "--host", "0.0.0.0", "--port", "8181", "--root-path", "/"]