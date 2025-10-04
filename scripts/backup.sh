#!/bin/bash
# FEPRO - Federation Professionals
# Backup script for database and application data
# 
# Usage: ./scripts/backup.sh [backup_type]
# Backup types: full, database, config (default: full)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_TYPE="${1:-full}"
BACKUP_DIR="$PROJECT_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$PROJECT_DIR/logs/backup-$(date +%Y%m%d_%H%M%S).log"

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
    
    # Check if PostgreSQL container is running
    if ! docker-compose ps postgres | grep -q "Up"; then
        error "PostgreSQL container is not running. Please start services first."
    fi
    
    success "Prerequisites check passed"
}

# Create backup directory
create_backup_directory() {
    log "Creating backup directory..."
    
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$PROJECT_DIR/logs"
    
    success "Backup directory created"
}

# Backup database
backup_database() {
    log "Creating database backup..."
    
    local backup_file="$BACKUP_DIR/fepro_db_$DATE.sql"
    
    # Create database dump
    docker-compose exec -T postgres pg_dump \
        -U fepro_user \
        -d fepro_prod \
        --verbose \
        --clean \
        --if-exists \
        --create \
        --format=plain \
        > "$backup_file" || error "Failed to create database backup"
    
    # Compress backup
    gzip "$backup_file"
    
    success "Database backup created: ${backup_file}.gz"
}

# Backup application configuration
backup_config() {
    log "Creating configuration backup..."
    
    local backup_file="$BACKUP_DIR/fepro_config_$DATE.tar.gz"
    
    # Create configuration backup
    tar -czf "$backup_file" \
        -C "$PROJECT_DIR" \
        docker-compose.yml \
        .env \
        scripts/ \
        migrations/ \
        2>/dev/null || warning "Some configuration files not found"
    
    success "Configuration backup created: $backup_file"
}

# Backup application logs
backup_logs() {
    log "Creating logs backup..."
    
    local backup_file="$BACKUP_DIR/fepro_logs_$DATE.tar.gz"
    
    # Create logs backup
    if [ -d "$PROJECT_DIR/logs" ]; then
        tar -czf "$backup_file" \
            -C "$PROJECT_DIR" \
            logs/ \
            2>/dev/null || warning "No logs found to backup"
        
        success "Logs backup created: $backup_file"
    else
        warning "No logs directory found"
    fi
}

# Backup Docker volumes
backup_volumes() {
    log "Creating Docker volumes backup..."
    
    local backup_file="$BACKUP_DIR/fepro_volumes_$DATE.tar.gz"
    
    # Stop services to ensure data consistency
    docker-compose stop fepro-app
    
    # Create volumes backup
    tar -czf "$backup_file" \
        -C "$PROJECT_DIR" \
        data/ \
        2>/dev/null || warning "No data directory found"
    
    # Restart services
    docker-compose start fepro-app
    
    success "Docker volumes backup created: $backup_file"
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    # Keep only last 7 days of backups
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +7 -delete || warning "Failed to clean up old backups"
    
    success "Old backups cleaned up"
}

# Verify backup
verify_backup() {
    log "Verifying backup..."
    
    local backup_file="$BACKUP_DIR/fepro_db_$DATE.sql.gz"
    
    if [ -f "$backup_file" ]; then
        # Check if backup file is not empty
        if [ -s "$backup_file" ]; then
            success "Backup verification passed"
        else
            error "Backup file is empty"
        fi
    else
        error "Backup file not found"
    fi
}

# Display backup information
display_info() {
    log "Backup completed successfully!"
    echo
    echo -e "${GREEN}=== FEPRO Backup Information ===${NC}"
    echo -e "Backup Type: ${YELLOW}$BACKUP_TYPE${NC}"
    echo -e "Backup Date: ${YELLOW}$DATE${NC}"
    echo -e "Backup Directory: ${BLUE}$BACKUP_DIR${NC}"
    echo -e "Log File: ${BLUE}$LOG_FILE${NC}"
    echo
    echo -e "${GREEN}=== Backup Files ===${NC}"
    ls -la "$BACKUP_DIR"/*"$DATE"* 2>/dev/null || echo "No backup files found"
    echo
    echo -e "${GREEN}=== Useful Commands ===${NC}"
    echo -e "List all backups: ${YELLOW}ls -la $BACKUP_DIR${NC}"
    echo -e "Restore database: ${YELLOW}./scripts/restore.sh database $DATE${NC}"
    echo -e "Restore config: ${YELLOW}./scripts/restore.sh config $DATE${NC}"
    echo
}

# Main backup function
main() {
    log "Starting FEPRO backup for type: $BACKUP_TYPE"
    
    check_prerequisites
    create_backup_directory
    
    case "$BACKUP_TYPE" in
        "database")
            backup_database
            ;;
        "config")
            backup_config
            backup_logs
            ;;
        "full")
            backup_database
            backup_config
            backup_logs
            backup_volumes
            ;;
        *)
            error "Invalid backup type: $BACKUP_TYPE. Use: full, database, config"
            ;;
    esac
    
    verify_backup
    cleanup_old_backups
    display_info
    
    success "FEPRO backup completed successfully!"
}

# Run main function
main "$@"
