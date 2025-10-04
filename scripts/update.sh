#!/bin/bash
# FEPRO - Federation Professionals
# Update script for production environment
# 
# Usage: ./scripts/update.sh [environment]
# Environment: dev, staging, prod (default: prod)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-prod}"
LOG_FILE="$PROJECT_DIR/logs/update-$(date +%Y%m%d_%H%M%S).log"

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

# Check if services are running
check_services() {
    log "Checking if services are running..."
    
    if ! docker-compose ps | grep -q "Up"; then
        error "Services are not running. Please run ./scripts/deploy.sh first."
    fi
    
    success "Services are running"
}

# Create backup before update
create_backup() {
    log "Creating backup before update..."
    
    # Run backup script
    "$SCRIPT_DIR/backup.sh" || error "Failed to create backup"
    
    success "Backup created successfully"
}

# Build new version
build_new_version() {
    log "Building new version..."
    
    cd "$PROJECT_DIR"
    
    # Build new Docker image
    docker build -t fepro-app:latest . || error "Failed to build new version"
    
    success "New version built successfully"
}

# Update application
update_application() {
    log "Updating application..."
    
    cd "$PROJECT_DIR"
    
    # Stop application service
    docker-compose stop fepro-app || error "Failed to stop application"
    
    # Start application service with new image
    docker-compose up -d fepro-app || error "Failed to start updated application"
    
    success "Application updated successfully"
}

# Wait for application to be ready
wait_for_application() {
    log "Waiting for application to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8082/api/actuator/health &> /dev/null; then
            success "Application is ready"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - waiting for application..."
        sleep 10
        ((attempt++))
    done
    
    error "Application failed to start within expected time"
}

# Check application health
check_health() {
    log "Checking application health..."
    
    # Check application health endpoint
    if ! curl -f http://localhost:8082/api/actuator/health; then
        error "Application health check failed"
    fi
    
    # Check database connection
    if ! docker-compose exec -T postgres pg_isready -U fepro_user -d fepro_prod; then
        error "Database health check failed"
    fi
    
    success "All health checks passed"
}

# Rollback function
rollback() {
    warning "Rolling back to previous version..."
    
    cd "$PROJECT_DIR"
    
    # Stop current application
    docker-compose stop fepro-app
    
    # Start previous version (if available)
    if docker images | grep -q "fepro-app:previous"; then
        docker-compose up -d fepro-app:previous
        success "Rolled back to previous version"
    else
        error "No previous version available for rollback"
    fi
}

# Cleanup old images
cleanup() {
    log "Cleaning up old Docker images..."
    
    # Remove dangling images
    docker image prune -f || warning "Failed to clean up dangling images"
    
    # Keep only last 3 versions
    docker images fepro-app --format "table {{.Tag}}\t{{.ID}}" | tail -n +4 | awk '{print $2}' | xargs -r docker rmi || true
    
    success "Cleanup completed"
}

# Display update information
display_info() {
    log "Update completed successfully!"
    echo
    echo -e "${GREEN}=== FEPRO Update Information ===${NC}"
    echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
    echo -e "Application URL: ${BLUE}http://localhost:8082${NC}"
    echo -e "API Endpoint: ${BLUE}http://localhost:8082/api${NC}"
    echo -e "Health Check: ${BLUE}http://localhost:8082/api/actuator/health${NC}"
    echo -e "Log File: ${BLUE}$LOG_FILE${NC}"
    echo
    echo -e "${GREEN}=== Useful Commands ===${NC}"
    echo -e "View logs: ${YELLOW}docker-compose logs -f fepro-app${NC}"
    echo -e "Check status: ${YELLOW}docker-compose ps${NC}"
    echo -e "Rollback: ${YELLOW}./scripts/update.sh rollback${NC}"
    echo
}

# Main update function
main() {
    log "Starting FEPRO update for environment: $ENVIRONMENT"
    
    # Handle rollback request
    if [ "$1" = "rollback" ]; then
        rollback
        exit 0
    fi
    
    check_services
    create_backup
    build_new_version
    update_application
    wait_for_application
    check_health
    cleanup
    display_info
    
    success "FEPRO update completed successfully!"
}

# Run main function
main "$@"
