# FEPRO - Federation Professionals
# Multi-stage Docker build for production deployment
# 
# Stage 1: Build Frontend (Vue.js + Quasar)
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Copy package files and install dependencies
COPY frontend/package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source code and build
COPY frontend/ .
RUN npm run build

# Stage 2: Build Backend (Spring Boot)
FROM maven:3.9-openjdk-21-alpine AS backend-build
WORKDIR /app/backend

# Copy Maven configuration
COPY backend/pom.xml .

# Copy source code
COPY backend/src ./src

# Build application
RUN mvn clean package -DskipTests

# Stage 3: Final Production Image
FROM openjdk:21-jre-alpine
WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -g 1001 -S fepro && \
    adduser -u 1001 -S fepro -G fepro

# Copy application JAR from backend build
COPY --from=backend-build /app/backend/target/*.jar app.jar

# Copy frontend build from frontend build
COPY --from=frontend-build /app/frontend/dist ./static

# Set proper ownership
RUN chown -R fepro:fepro /app

# Switch to non-root user
USER fepro

# Expose application port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8082/api/actuator/health || exit 1

# Start application
CMD ["java", "-jar", "app.jar"]
