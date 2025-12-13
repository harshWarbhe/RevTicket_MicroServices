#!/bin/bash

# RevTicket Deployment Script
# Supports both local development and CI/CD deployment

set -e

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"docker.io"}
DOCKER_REPO=${DOCKER_REPO:-"harshwarbhe"}
BUILD_VERSION=${BUILD_VERSION:-"latest"}
DEPLOYMENT_MODE=${DEPLOYMENT_MODE:-"local"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  RevTicket Deployment Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "Registry: ${YELLOW}${DOCKER_REGISTRY}${NC}"
    echo -e "Repository: ${YELLOW}${DOCKER_REPO}${NC}"
    echo -e "Version: ${YELLOW}${BUILD_VERSION}${NC}"
    echo -e "Mode: ${YELLOW}${DEPLOYMENT_MODE}${NC}"
    echo ""
}

check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running${NC}"
        exit 1
    fi
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Error: docker-compose is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites check passed${NC}"
    echo ""
}

setup_environment() {
    echo -e "${BLUE}Setting up environment...${NC}"
    
    # Export environment variables for docker-compose
    export DOCKER_REGISTRY
    export DOCKER_REPO
    export BUILD_VERSION
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        echo -e "${YELLOW}Creating .env file from template...${NC}"
        cp .env.example .env
    fi
    
    echo -e "${GREEN}✓ Environment setup complete${NC}"
    echo ""
}

deploy_local() {
    echo -e "${BLUE}Deploying locally (build mode)...${NC}"
    
    # Stop existing containers
    docker-compose down || true
    
    # Build and start services
    docker-compose up --build -d
    
    echo -e "${GREEN}✓ Local deployment complete${NC}"
}

deploy_staging() {
    echo -e "${BLUE}Deploying to staging (image mode)...${NC}"
    
    # Stop existing containers
    docker-compose down || true
    
    # Pull latest images
    docker-compose pull
    
    # Start services with pulled images
    docker-compose up -d
    
    echo -e "${GREEN}✓ Staging deployment complete${NC}"
}

deploy_production() {
    echo -e "${BLUE}Deploying to production...${NC}"
    
    # Create production compose file
    cp docker-compose.yml docker-compose.prod.yml
    
    # Stop existing production containers
    docker-compose -f docker-compose.prod.yml down || true
    
    # Pull latest images
    docker-compose -f docker-compose.prod.yml pull
    
    # Start production services
    docker-compose -f docker-compose.prod.yml up -d
    
    echo -e "${GREEN}✓ Production deployment complete${NC}"
}

wait_for_services() {
    echo -e "${BLUE}Waiting for services to be ready...${NC}"
    
    # Wait for services to start
    sleep 30
    
    echo -e "${GREEN}✓ Services should be ready${NC}"
    echo ""
}

health_check() {
    echo -e "${BLUE}Performing health checks...${NC}"
    
    # Check service health endpoints
    services_healthy=0
    total_services=12
    
    for port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091; do
        if curl -f -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Service on port $port is healthy${NC}"
            ((services_healthy++))
        else
            echo -e "${YELLOW}⚠ Service on port $port is not ready${NC}"
        fi
    done
    
    # Check frontend
    if curl -f -s http://localhost:4200 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Frontend is healthy${NC}"
        ((services_healthy++))
        ((total_services++))
    else
        echo -e "${YELLOW}⚠ Frontend is not ready${NC}"
    fi
    
    echo ""
    echo -e "Health Status: ${GREEN}$services_healthy${NC}/${total_services} services healthy"
    
    if [ $services_healthy -eq $total_services ]; then
        echo -e "${GREEN}✅ All services are healthy!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Some services are not ready yet${NC}"
        return 1
    fi
}

show_status() {
    echo -e "${BLUE}Current deployment status:${NC}"
    echo ""
    
    # Show running containers
    docker-compose ps
    
    echo ""
    echo -e "${BLUE}Access URLs:${NC}"
    echo -e "Frontend: ${GREEN}http://localhost:4200${NC}"
    echo -e "API Gateway: ${GREEN}http://localhost:8080${NC}"
    echo -e "Consul: ${GREEN}http://localhost:8500${NC}"
    echo ""
}

cleanup() {
    echo -e "${BLUE}Cleaning up...${NC}"
    
    # Stop all containers
    docker-compose down
    
    # Remove production compose file if it exists
    rm -f docker-compose.prod.yml
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

show_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the application (default)"
    echo "  status    Show deployment status"
    echo "  health    Check service health"
    echo "  cleanup   Stop and cleanup deployment"
    echo ""
    echo "Options:"
    echo "  -m, --mode MODE       Deployment mode: local, staging, production (default: local)"
    echo "  -r, --registry REG    Docker registry (default: docker.io)"
    echo "  -n, --repo REPO       Docker repository (default: revticket)"
    echo "  -v, --version VER     Build version (default: latest)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Deploy locally"
    echo "  $0 -m staging                        # Deploy to staging"
    echo "  $0 -m production -v 1.0.0           # Deploy to production with version"
    echo "  $0 status                            # Show status"
    echo "  $0 cleanup                           # Cleanup deployment"
}

# Parse command line arguments
COMMAND="deploy"

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            DEPLOYMENT_MODE="$2"
            shift 2
            ;;
        -r|--registry)
            DOCKER_REGISTRY="$2"
            shift 2
            ;;
        -n|--repo)
            DOCKER_REPO="$2"
            shift 2
            ;;
        -v|--version)
            BUILD_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        deploy|status|health|cleanup)
            COMMAND="$1"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    case $COMMAND in
        deploy)
            print_header
            check_prerequisites
            setup_environment
            
            case $DEPLOYMENT_MODE in
                local)
                    deploy_local
                    ;;
                staging)
                    deploy_staging
                    ;;
                production)
                    deploy_production
                    ;;
                *)
                    echo -e "${RED}Invalid deployment mode: $DEPLOYMENT_MODE${NC}"
                    exit 1
                    ;;
            esac
            
            wait_for_services
            health_check
            show_status
            ;;
        status)
            show_status
            ;;
        health)
            health_check
            ;;
        cleanup)
            cleanup
            ;;
        *)
            echo -e "${RED}Unknown command: $COMMAND${NC}"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"