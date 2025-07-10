#!/bin/bash

# Onyx (Danswer) Setup and Deployment Script
# This script sets up the development environment and prepares for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. Some operations may behave differently."
    fi
}

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_warning "Node.js is not installed. Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    log_success "All requirements satisfied"
}

# Setup environment files
setup_environment() {
    log_info "Setting up environment files..."
    
    # Create .env file if it doesn't exist
    if [[ ! -f .env ]]; then
        log_info "Creating .env file from template..."
        cp deployment/docker_compose/env.prod.template .env
        
        # Generate random secrets
        SECRET_KEY=$(openssl rand -hex 32)
        POSTGRES_PASSWORD=$(openssl rand -base64 32)
        
        # Update .env with generated secrets
        sed -i "s/your-secret-key-here/$SECRET_KEY/g" .env
        sed -i "s/your-postgres-password-here/$POSTGRES_PASSWORD/g" .env
        
        log_warning "Please review and update the .env file with your specific configuration"
    else
        log_info ".env file already exists"
    fi
    
    # Setup web environment
    if [[ ! -f web/.env.local ]]; then
        log_info "Creating web/.env.local file..."
        cat > web/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_DISABLE_STREAMING=false
NEXT_PUBLIC_NEW_CHAT_DIRECTS_TO_SAME_PERSONA=false
NEXT_PUBLIC_POSITIVE_PREDEFINED_FEEDBACK_OPTIONS=
NEXT_PUBLIC_NEGATIVE_PREDEFINED_FEEDBACK_OPTIONS=
NEXT_PUBLIC_DISABLE_LLM_DOC_RELEVANCE=false
NEXT_PUBLIC_DEFAULT_SIDEBAR_OPEN=false
NEXT_PUBLIC_GMAIL_AUTH_IS_ADMIN_CONNECTORS=true
NEXT_PUBLIC_CLOUD_ENABLED=false
EOF
    fi
    
    log_success "Environment files configured"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Install Python dependencies
    if [[ -d backend ]]; then
        log_info "Installing Python dependencies..."
        cd backend
        
        # Create virtual environment if it doesn't exist
        if [[ ! -d .venv ]]; then
            python3 -m venv .venv
        fi
        
        source .venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements/default.txt
        pip install -r requirements/dev.txt
        
        cd ..
        log_success "Python dependencies installed"
    fi
    
    # Install Node.js dependencies
    if [[ -d web ]]; then
        log_info "Installing Node.js dependencies..."
        cd web
        npm install
        cd ..
        log_success "Node.js dependencies installed"
    fi
}

# Setup database
setup_database() {
    log_info "Setting up database..."
    
    # Start database services
    docker-compose -f deployment/docker_compose/docker-compose.resources.yml up -d
    
    # Wait for database to be ready
    log_info "Waiting for database to be ready..."
    sleep 10
    
    # Run database migrations
    if [[ -d backend ]]; then
        cd backend
        source .venv/bin/activate
        alembic upgrade head
        cd ..
        log_success "Database migrations completed"
    fi
}

# Build application
build_application() {
    log_info "Building application..."
    
    # Build backend
    if [[ -d backend ]]; then
        log_info "Building backend..."
        docker build -t onyx-backend:latest backend/
        log_success "Backend built successfully"
    fi
    
    # Build frontend
    if [[ -d web ]]; then
        log_info "Building frontend..."
        cd web
        npm run build
        cd ..
        docker build -t onyx-web:latest web/
        log_success "Frontend built successfully"
    fi
}

# Setup development environment
setup_dev() {
    log_info "Setting up development environment..."
    
    # Install pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        pre-commit install
        log_success "Pre-commit hooks installed"
    else
        log_warning "pre-commit not found. Install it with: pip install pre-commit"
    fi
    
    # Setup IDE configuration
    if [[ ! -d .vscode ]]; then
        mkdir -p .vscode
        cat > .vscode/settings.json << EOF
{
    "python.defaultInterpreterPath": "./backend/.venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": false,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "typescript.preferences.importModuleSpecifier": "relative",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
EOF
        log_success "VS Code configuration created"
    fi
}

# Deploy application
deploy_application() {
    local deployment_type=${1:-"dev"}
    
    log_info "Deploying application in $deployment_type mode..."
    
    case $deployment_type in
        "dev")
            docker-compose -f deployment/docker_compose/docker-compose.dev.yml up -d
            ;;
        "prod")
            docker-compose -f deployment/docker_compose/docker-compose.prod.yml up -d
            ;;
        "prod-no-ssl")
            docker-compose -f deployment/docker_compose/docker-compose.prod-no-letsencrypt.yml up -d
            ;;
        *)
            log_error "Unknown deployment type: $deployment_type"
            log_info "Available types: dev, prod, prod-no-ssl"
            exit 1
            ;;
    esac
    
    log_success "Application deployed successfully"
    log_info "Application should be available at:"
    log_info "  - Frontend: http://localhost:3000"
    log_info "  - Backend API: http://localhost:8080"
    log_info "  - Admin Panel: http://localhost:3000/admin"
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    # Check if services are running
    local services=("api_server" "web_server" "relational_db" "index" "cache")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            log_success "$service is running"
        else
            log_warning "$service is not running"
        fi
    done
    
    # Check API endpoint
    if curl -f http://localhost:8080/health &> /dev/null; then
        log_success "API health check passed"
    else
        log_warning "API health check failed"
    fi
    
    # Check web frontend
    if curl -f http://localhost:3000 &> /dev/null; then
        log_success "Web frontend health check passed"
    else
        log_warning "Web frontend health check failed"
    fi
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    
    # Stop all containers
    docker-compose down
    
    # Remove unused Docker images
    docker image prune -f
    
    # Clean npm cache
    if [[ -d web ]]; then
        cd web
        npm cache clean --force
        cd ..
    fi
    
    log_success "Cleanup completed"
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup       - Full setup (requirements, environment, dependencies)"
    echo "  dev         - Setup development environment"
    echo "  build       - Build application"
    echo "  deploy      - Deploy application (default: dev mode)"
    echo "  health      - Perform health check"
    echo "  cleanup     - Clean up resources"
    echo "  help        - Show this help message"
    echo ""
    echo "Deploy options:"
    echo "  dev         - Development deployment"
    echo "  prod        - Production deployment with SSL"
    echo "  prod-no-ssl - Production deployment without SSL"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 deploy dev"
    echo "  $0 deploy prod"
    echo "  $0 health"
}

# Main function
main() {
    local command=${1:-"help"}
    local option=${2:-""}
    
    check_root
    
    case $command in
        "setup")
            check_requirements
            setup_environment
            install_dependencies
            setup_database
            setup_dev
            log_success "Setup completed successfully!"
            ;;
        "dev")
            setup_dev
            ;;
        "build")
            build_application
            ;;
        "deploy")
            deploy_application "$option"
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"