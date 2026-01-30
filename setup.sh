#!/bin/bash

# NCAE Competition Setup Script
# Usage: sudo ./setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

LOG_FILE="/var/log/ncae_setup.log"

log() {
    echo -e "${GREEN}[+]${NC} $1"
    echo "$(date): $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    echo "$(date): WARNING: $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[-]${NC} $1"
    echo "$(date): ERROR: $1" >> "$LOG_FILE"
    exit 1
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run as root"
    fi
}

update_system() {
    log "Updating package lists..."
    apt-get update -y
}

# --- Service Functions ---

setup_http() {
    log "Setting up HTTP (Nginx)..."
    apt-get install -y nginx

    # Create index.html with "Hello World!"
    echo "Hello World!" > /var/www/html/index.html

    # Ensure permissions are correct
    chown www-data:www-data /var/www/html/index.html
    chmod 644 /var/www/html/index.html

    log "HTTP setup complete."
}

setup_ftp() {
    log "FTP setup placeholder..."
}

setup_dns() {
    log "DNS setup placeholder..."
}

setup_sql() {
    log "SQL setup placeholder..."
}

setup_ssh() {
    log "SSH setup placeholder..."
}

setup_security() {
    log "Security hardening placeholder..."
}

# --- Main Execution ---

main() {
    check_root
    
    log "Starting NCAE setup..."

    update_system
    
    setup_http
    # setup_ftp
    # setup_dns
    # setup_sql
    # setup_ssh
    
    # setup_security

    log "Setup complete!"
}

main
