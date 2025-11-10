#!/bin/bash

# Database Backup Script for Hasura Blog
# This script creates PostgreSQL database backups with timestamps

set -e

# Default configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEFAULT_DB_NAME="hasura"
DEFAULT_DB_USER="postgres"
COMPRESS=false
USE_DOCKER=true

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -d, --database NAME      Database name (default: hasura)
    -u, --user USER         Database user (default: postgres)
    -o, --output DIR        Output directory for backups (default: ./backups)
    -c, --compress          Compress backup with gzip
    -n, --no-docker         Use direct PostgreSQL connection instead of Docker
    -h, --host HOST         Database host (for non-Docker mode, default: localhost)
    -p, --port PORT         Database port (for non-Docker mode, default: 5432)
    --help                  Show this help message

Environment Variables:
    POSTGRES_PASSWORD       Database password (required for non-Docker mode)
    
Examples:
    # Backup using Docker (default)
    $0

    # Backup with compression
    $0 --compress

    # Backup to custom directory
    $0 --output /path/to/backups

    # Backup using direct connection
    $0 --no-docker --host localhost --port 5432

    # Backup specific database
    $0 --database mydb --user myuser

EOF
    exit 0
}

# Parse command line arguments
DB_NAME="$DEFAULT_DB_NAME"
DB_USER="$DEFAULT_DB_USER"
DB_HOST="localhost"
DB_PORT="5432"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--database)
            DB_NAME="$2"
            shift 2
            ;;
        -u|--user)
            DB_USER="$2"
            shift 2
            ;;
        -o|--output)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -c|--compress)
            COMPRESS=true
            shift
            ;;
        -n|--no-docker)
            USE_DOCKER=false
            shift
            ;;
        -h|--host)
            DB_HOST="$2"
            shift 2
            ;;
        -p|--port)
            DB_PORT="$2"
            shift 2
            ;;
        --help)
            show_usage
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main backup function
main() {
    print_info "Starting database backup..."
    echo ""
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        print_info "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Set backup filename
    if [ "$COMPRESS" = true ]; then
        BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"
    else
        BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql"
    fi
    
    # Perform backup
    if [ "$USE_DOCKER" = true ]; then
        backup_docker
    else
        backup_direct
    fi
    
    # Check if backup was successful
    if [ -f "$BACKUP_FILE" ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        print_success "Backup completed successfully!"
        echo ""
        echo "Backup details:"
        echo "  File: $BACKUP_FILE"
        echo "  Size: $BACKUP_SIZE"
        echo "  Database: $DB_NAME"
        echo "  Timestamp: $TIMESTAMP"
        echo ""
        
        # Show restore instructions
        print_info "To restore this backup, use:"
        if [ "$USE_DOCKER" = true ]; then
            if [ "$COMPRESS" = true ]; then
                echo "  gunzip -c $BACKUP_FILE | docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME"
            else
                echo "  docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
            fi
        else
            if [ "$COMPRESS" = true ]; then
                echo "  gunzip -c $BACKUP_FILE | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
            else
                echo "  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
            fi
        fi
    else
        print_error "Backup file was not created"
        exit 1
    fi
}

# Backup using Docker
backup_docker() {
    print_info "Using Docker to create backup..."
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose is not installed"
        exit 1
    fi
    
    # Check if postgres container is running
    if ! docker-compose ps postgres | grep -q "Up"; then
        print_error "PostgreSQL container is not running"
        echo "Start the container with: docker-compose up -d postgres"
        exit 1
    fi
    
    # Create backup
    if [ "$COMPRESS" = true ]; then
        docker-compose exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"
    else
        docker-compose exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
    fi
}

# Backup using direct connection
backup_direct() {
    print_info "Using direct PostgreSQL connection..."
    
    # Check if pg_dump is available
    if ! command -v pg_dump &> /dev/null; then
        print_error "pg_dump is not installed"
        echo "Install PostgreSQL client tools first"
        exit 1
    fi
    
    # Check if password is set
    if [ -z "$POSTGRES_PASSWORD" ]; then
        print_error "POSTGRES_PASSWORD environment variable is not set"
        echo "Set it with: export POSTGRES_PASSWORD=your_password"
        exit 1
    fi
    
    # Export password for pg_dump
    export PGPASSWORD="$POSTGRES_PASSWORD"
    
    # Create backup
    if [ "$COMPRESS" = true ]; then
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"
    else
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
    fi
    
    # Unset password
    unset PGPASSWORD
}

# Run main function
main
