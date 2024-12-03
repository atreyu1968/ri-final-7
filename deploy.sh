#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Utility functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
}

# Load environment variables
load_environment() {
    log_info "Loading environment variables..."
    
    # Check if .env file exists
    if [ ! -f .env ]; then
        if [ -f .env.production ]; then
            log_info "Using .env.production file"
            cp .env.production .env
        elif [ -f .env.example ]; then
            log_warn "Using .env.example file. Please update with production values."
            cp .env.example .env
        else
            log_error "No .env file found"
            exit 1
        fi
    fi

    # Export all variables from .env file
    set -a
    source .env
    set +a

    # Validate required variables
    required_vars=(
        "DB_ROOT_PASSWORD"
        "DB_USER"
        "DB_PASSWORD"
        "DB_NAME"
        "JWT_SECRET"
        "ADMIN_EMAIL"
        "ADMIN_PASSWORD"
        "ROCKETCHAT_ADMIN_PASSWORD"
        "DISCOURSE_DB_PASSWORD"
        "DISCOURSE_ADMIN_PASSWORD"
        "NEXTCLOUD_DB_PASSWORD"
        "NEXTCLOUD_ADMIN_PASSWORD"
    )

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Required variable $var is not set in .env file"
            exit 1
        fi
    }
}

# Set up directories and permissions
setup_directories() {
    log_info "Setting up directories..."
    
    # Create necessary directories
    mkdir -p secrets uploads logs backups \
            docker/{jitsi/web,mariadb/{conf.d,init},phpmyadmin} \
            docker/{rocketchat,discourse,nextcloud}
    
    # Set permissions
    chmod -R 755 docker uploads logs backups
}

# Deploy application
deploy_app() {
    log_info "Deploying application..."
    
    # Pull latest images
    log_info "Pulling Docker images..."
    docker compose pull

    # Build and start containers
    log_info "Starting services..."
    docker compose up -d

    # Wait for services to be healthy
    log_info "Waiting for services to be ready..."
    sleep 30
    
    # Check container status
    docker compose ps

    # Check logs for errors
    log_info "Checking service logs..."
    docker compose logs --tail=100
}

# Main function
main() {
    log_info "Starting deployment..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        log_error "This script must be run as root"
        exit 1
    }
    
    check_requirements
    load_environment
    setup_directories
    deploy_app
    
    log_info "Deployment completed successfully"
    
    # Show service URLs
    log_info "Services are available at:"
    echo "Main application: https://${DOMAIN}"
    echo "Chat: https://${DOMAIN}/chat"
    echo "Forum: https://${DOMAIN}/forum"
    echo "Nextcloud: https://${DOMAIN}/nextcloud"
    echo "Documentation: https://${DOMAIN}/docs"
    echo "Video Meetings: https://${DOMAIN}/meet"
}

# Run script
main
