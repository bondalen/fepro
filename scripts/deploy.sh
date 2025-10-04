#!/bin/bash
# FEPRO - Federation Professionals
# Deployment script for production environment
# 
# Usage: ./scripts/deploy.sh [environment]
# Environment: dev, staging, prod (default: prod)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-prod}"
LOG_FILE="$PROJECT_DIR/logs/deploy-$(date +%Y%m%d_%H%M%S).log"

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
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
    
    # Check if we're in the right directory
    if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
        error "docker-compose.yml not found. Please run this script from the project root."
    fi
    
    success "Prerequisites check passed"
}

# Create necessary directories
create_directories() {
    log "Creating necessary directories..."
    
    mkdir -p "$PROJECT_DIR/logs"
    mkdir -p "$PROJECT_DIR/backups"
    mkdir -p "$PROJECT_DIR/data/postgres"
    
    success "Directories created"
}

# Build application
build_application() {
    log "Building FEPRO application..."
    
    cd "$PROJECT_DIR"
    
    # Build Docker image
    docker build -t fepro-app:latest . || error "Failed to build Docker image"
    
    success "Application built successfully"
}

# Start services
start_services() {
    log "Starting services..."
    
    cd "$PROJECT_DIR"
    
    # Start services with Docker Compose
    docker-compose up -d || error "Failed to start services"
    
    success "Services started"
}

# Wait for services to be ready
wait_for_services() {
    log "Waiting for services to be ready..."
    
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

# Display deployment information
display_info() {
    log "Deployment completed successfully!"
    echo
    echo -e "${GREEN}=== FEPRO Deployment Information ===${NC}"
    echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
    echo -e "Application URL: ${BLUE}http://localhost:8082${NC}"
    echo -e "API Endpoint: ${BLUE}http://localhost:8082/api${NC}"
    echo -e "Health Check: ${BLUE}http://localhost:8082/api/actuator/health${NC}"
    echo -e "Database: ${BLUE}localhost:5432/fepro_prod${NC}"
    echo -e "Log File: ${BLUE}$LOG_FILE${NC}"
    echo
    echo -e "${GREEN}=== Useful Commands ===${NC}"
    echo -e "View logs: ${YELLOW}docker-compose logs -f${NC}"
    echo -e "Stop services: ${YELLOW}docker-compose down${NC}"
    echo -e "Restart services: ${YELLOW}docker-compose restart${NC}"
    echo -e "Update application: ${YELLOW}./scripts/update.sh${NC}"
    echo -e "Create backup: ${YELLOW}./scripts/backup.sh${NC}"
    echo
}

# Main deployment function
main() {
    log "Starting FEPRO deployment for environment: $ENVIRONMENT"
    
    check_prerequisites
    create_directories
    build_application
    start_services
    wait_for_services
    check_health
    display_info
    
    success "FEPRO deployment completed successfully!"
}

# Run main function
main "$@"
