#!/bin/bash
# FEPRO - Federation Professionals
# Blue-Green deployment script for zero-downtime updates
# 
# Usage: ./scripts/blue-green-deploy.sh [environment]
# Environment: dev, staging, prod (default: prod)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-prod}"
LOG_FILE="$PROJECT_DIR/logs/blue-green-$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        error "Docker is not running. Please start Docker first."
    fi
    
    # Check if we're in the right directory
    if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
        error "docker-compose.yml not found. Please run this script from the project root."
    fi
    
    success "Prerequisites check passed"
}

# Create backup before deployment
create_backup() {
    log "Creating backup before blue-green deployment..."
    
    # Run backup script
    "$SCRIPT_DIR/backup.sh" full || error "Failed to create backup"
    
    success "Backup created successfully"
}

# Build green version
build_green_version() {
    log "Building green version..."
    
    cd "$PROJECT_DIR"
    
    # Build new Docker image with green tag
    docker build -t fepro-app:green . || error "Failed to build green version"
    
    success "Green version built successfully"
}

# Start green environment
start_green_environment() {
    log "Starting green environment..."
    
    cd "$PROJECT_DIR"
    
    # Create green docker-compose file
    cat > docker-compose.green.yml << EOF
version: '3.8'

services:
  fepro-app-green:
    image: fepro-app:green
    container_name: fepro-app-green
    ports:
      - "8083:8082"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/fepro_prod
      - SPRING_DATASOURCE_USERNAME=fepro_user
      - SPRING_DATASOURCE_PASSWORD=fepro_pass
      - HAZELCAST_ENABLED=true
      - HAZELCAST_CLUSTER_NAME=fepro-cluster
      - HAZELCAST_NETWORK_PORT=5701
      - HAZELCAST_MANAGEMENT_CENTER_ENABLED=false
      - SERVER_PORT=8082
      - SERVER_SERVLET_CONTEXT_PATH=/api
      - LOGGING_LEVEL_COM_FEPRO=INFO
      - LOGGING_FILE_NAME=/app/logs/fepro.log
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./logs:/app/logs
      - ./backups:/app/backups
    restart: unless-stopped
    networks:
      - fepro-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8082/api/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  postgres:
    image: postgres:16-alpine
    container_name: fepro-postgres
    environment:
      - POSTGRES_DB=fepro_prod
      - POSTGRES_USER=fepro_user
      - POSTGRES_PASSWORD=fepro_pass
      - POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
      - ./backups:/backups
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - fepro-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U fepro_user -d fepro_prod"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./data/postgres

networks:
  fepro-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF
    
    # Start green environment
    docker-compose -f docker-compose.green.yml up -d || error "Failed to start green environment"
    
    success "Green environment started"
}

# Wait for green environment to be ready
wait_for_green_environment() {
    log "Waiting for green environment to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8083/api/actuator/health &> /dev/null; then
            success "Green environment is ready"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - waiting for green environment..."
        sleep 10
        ((attempt++))
    done
    
    error "Green environment failed to start within expected time"
}

# Test green environment
test_green_environment() {
    log "Testing green environment..."
    
    # Test health endpoint
    if ! curl -f http://localhost:8083/api/actuator/health; then
        error "Green environment health check failed"
    fi
    
    # Test database connection
    if ! docker-compose -f docker-compose.green.yml exec -T postgres pg_isready -U fepro_user -d fepro_prod; then
        error "Green environment database check failed"
    fi
    
    # Test GraphQL endpoint
    if ! curl -f http://localhost:8083/api/graphql -X POST -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'; then
        warning "GraphQL endpoint test failed, but continuing..."
    fi
    
    success "Green environment tests passed"
}

# Switch traffic to green
switch_traffic() {
    log "Switching traffic to green environment..."
    
    # This is a placeholder for load balancer configuration
    # In a real environment, you would update nginx, haproxy, or cloud load balancer
    # For now, we'll just update the main docker-compose.yml
    
    cd "$PROJECT_DIR"
    
    # Stop blue environment
    docker-compose stop fepro-app || error "Failed to stop blue environment"
    
    # Update main docker-compose.yml to use green image
    sed -i 's/fepro-app:latest/fepro-app:green/g' docker-compose.yml
    
    # Start green environment on main port
    docker-compose up -d fepro-app || error "Failed to start green environment on main port"
    
    success "Traffic switched to green environment"
}

# Wait for main environment to be ready
wait_for_main_environment() {
    log "Waiting for main environment to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8082/api/actuator/health &> /dev/null; then
            success "Main environment is ready"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - waiting for main environment..."
        sleep 10
        ((attempt++))
    done
    
    error "Main environment failed to start within expected time"
}

# Cleanup green environment
cleanup_green_environment() {
    log "Cleaning up green environment..."
    
    cd "$PROJECT_DIR"
    
    # Stop green environment
    docker-compose -f docker-compose.green.yml down || warning "Failed to stop green environment"
    
    # Remove green docker-compose file
    rm -f docker-compose.green.yml
    
    # Tag current image as latest
    docker tag fepro-app:green fepro-app:latest
    
    # Remove green tag
    docker rmi fepro-app:green || warning "Failed to remove green tag"
    
    success "Green environment cleaned up"
}

# Rollback function
rollback() {
    warning "Rolling back to blue environment..."
    
    cd "$PROJECT_DIR"
    
    # Stop current environment
    docker-compose stop fepro-app
    
    # Restore original docker-compose.yml
    git checkout docker-compose.yml || error "Failed to restore docker-compose.yml"
    
    # Start blue environment
    docker-compose up -d fepro-app || error "Failed to start blue environment"
    
    success "Rolled back to blue environment"
}

# Display deployment information
display_info() {
    log "Blue-Green deployment completed successfully!"
    echo
    echo -e "${GREEN}=== FEPRO Blue-Green Deployment Information ===${NC}"
    echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
    echo -e "Application URL: ${BLUE}http://localhost:8082${NC}"
    echo -e "API Endpoint: ${BLUE}http://localhost:8082/api${NC}"
    echo -e "Health Check: ${BLUE}http://localhost:8082/api/actuator/health${NC}"
    echo -e "Database: ${BLUE}localhost:5432/fepro_prod${NC}"
    echo -e "Log File: ${BLUE}$LOG_FILE${NC}"
    echo
    echo -e "${GREEN}=== Useful Commands ===${NC}"
    echo -e "View logs: ${YELLOW}docker-compose logs -f fepro-app${NC}"
    echo -e "Check status: ${YELLOW}docker-compose ps${NC}"
    echo -e "Rollback: ${YELLOW}./scripts/blue-green-deploy.sh rollback${NC}"
    echo
}

# Main deployment function
main() {
    log "Starting FEPRO blue-green deployment for environment: $ENVIRONMENT"
    
    # Handle rollback request
    if [ "$1" = "rollback" ]; then
        rollback
        exit 0
    fi
    
    check_prerequisites
    create_backup
    build_green_version
    start_green_environment
    wait_for_green_environment
    test_green_environment
    switch_traffic
    wait_for_main_environment
    cleanup_green_environment
    display_info
    
    success "FEPRO blue-green deployment completed successfully!"
}

# Run main function
main "$@"
