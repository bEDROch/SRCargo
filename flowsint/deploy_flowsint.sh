#!/usr/bin/env bash
# Flowsint Deployment Hook for Portainer
# Purpose: Deploy/update Flowsint stack with health checks
# Usage: ./deploy_flowsint.sh [--update|--restart|--logs]

set -euo pipefail

# === Configuration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yaml"
ENV_FILE="/srv/cargo/portainer/build/env/flowsint.env"
STACK_NAME="flowsint"
VOLUMES_BASE="/srv/maria/cargo/volumes/flowsint"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === Functions ===
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if [[ ! -f "${COMPOSE_FILE}" ]]; then
        log_error "docker-compose.yaml not found at ${COMPOSE_FILE}"
        exit 1
    fi
    
    if [[ ! -f "${ENV_FILE}" ]]; then
        log_error "Environment file not found at ${ENV_FILE}"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker not installed"
        exit 1
    fi
    
    log_success "Prerequisites OK"
}

create_volumes() {
    log_info "Creating/verifying volume directories..."
    
    mkdir -p "${VOLUMES_BASE}"/{redis,neo4j/{data,logs,import,plugins},logs}
    
    # Set permissions
    chmod -R 755 "${VOLUMES_BASE}"
    
    log_success "Volumes ready"
}

pull_images() {
    log_info "Pulling latest images..."
    docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" pull
    log_success "Images pulled"
}

deploy_stack() {
    log_info "Deploying Flowsint stack..."
    
    docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d
    
    log_success "Stack deployed"
}

health_check() {
    log_info "Running health checks..."
    
    local max_attempts=30
    local attempt=0
    
    while [[ ${attempt} -lt ${max_attempts} ]]; do
        if docker compose -f "${COMPOSE_FILE}" ps | grep -q "healthy"; then
            log_success "Services healthy"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    log_warn "Health check timeout - check logs for details"
    docker compose -f "${COMPOSE_FILE}" ps
    return 1
}

show_status() {
    log_info "Current stack status:"
    docker compose -f "${COMPOSE_FILE}" ps
    
    echo ""
    log_info "Service URLs:"
    echo "  • Flowsint API: http://localhost:8090"
    echo "  • Neo4j Browser: http://localhost:7475"
    echo "  • Redis: localhost:6380"
    echo "  • Flower Dashboard: http://localhost:5555"
}

show_logs() {
    docker compose -f "${COMPOSE_FILE}" logs -f --tail=50
}

restart_stack() {
    log_info "Restarting Flowsint stack..."
    docker compose -f "${COMPOSE_FILE}" restart
    log_success "Stack restarted"
}

stop_stack() {
    log_info "Stopping Flowsint stack..."
    docker compose -f "${COMPOSE_FILE}" down
    log_success "Stack stopped"
}

# === Main Execution ===
main() {
    case "${1:-deploy}" in
        --update)
            check_prerequisites
            pull_images
            deploy_stack
            health_check
            show_status
            ;;
        --restart)
            restart_stack
            health_check
            show_status
            ;;
        --logs)
            show_logs
            ;;
        --stop)
            stop_stack
            ;;
        --status)
            show_status
            ;;
        *)
            log_info "Starting Flowsint deployment..."
            check_prerequisites
            create_volumes
            pull_images
            deploy_stack
            health_check
            show_status
            log_success "Deployment complete!"
            ;;
    esac
}

main "$@"
