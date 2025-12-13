#!/bin/bash

# RevTicket Docker Images Build Script
# Builds all microservices Docker images locally and pushes to registry
# Supports multi-platform builds (AMD64/ARM64) for Mac and Windows compatibility

set -e

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"docker.io"}
DOCKER_REPO=${DOCKER_REPO:-"harshwarbhe"}
BUILD_VERSION=${BUILD_VERSION:-"latest"}
PUSH_IMAGES=${PUSH_IMAGES:-"false"}
PLATFORM=${PLATFORM:-"linux/amd64,linux/arm64"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Services to build
BACKEND_SERVICES=(
    "api-gateway"
    "user-service"
    "movie-service"
    "theater-service"
    "showtime-service"
    "booking-service"
    "payment-service"
    "review-service"
    "search-service"
    "notification-service"
    "settings-service"
    "dashboard-service"
)

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  RevTicket Docker Build Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "Registry: ${YELLOW}${DOCKER_REGISTRY}${NC}"
    echo -e "Repository: ${YELLOW}${DOCKER_REPO}${NC}"
    echo -e "Version: ${YELLOW}${BUILD_VERSION}${NC}"
    echo -e "Platform: ${YELLOW}${PLATFORM}${NC}"
    echo -e "Push Images: ${YELLOW}${PUSH_IMAGES}${NC}"
    echo ""
}

setup_buildx() {
    echo -e "${BLUE}Setting up Docker Buildx...${NC}"
    
    # Create buildx builder if it doesn't exist
    if ! docker buildx ls | grep -q "multiarch"; then
        docker buildx create --name multiarch --use --bootstrap
    else
        docker buildx use multiarch
    fi
    
    # Bootstrap the builder
    docker buildx inspect --bootstrap
    echo -e "${GREEN}✓ Docker Buildx setup complete${NC}"
    echo ""
}

build_backend_services() {
    echo -e "${BLUE}Building Backend Services...${NC}"
    
    # First, build all services with Maven
    echo -e "${YELLOW}Building Maven projects...${NC}"
    cd Microservices-Backend
    mvn clean package -DskipTests
    cd ..
    echo -e "${GREEN}✓ Maven build complete${NC}"
    echo ""
    
    # Build Docker images for each service
    for service in "${BACKEND_SERVICES[@]}"; do
        echo -e "${YELLOW}Building ${service}...${NC}"
        
        # Check if multi-platform build
        if [[ "$PLATFORM" == *","* ]]; then
            # Multi-platform build - build for local first (single platform)
            echo -e "${YELLOW}  Building for local (linux/amd64)...${NC}"
            docker buildx build \
                --platform linux/amd64 \
                -f Microservices-Backend/${service}/Dockerfile \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:${BUILD_VERSION} \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:latest \
                --load \
                Microservices-Backend
            
            # If push is enabled, build multi-platform and push
            if [ "$PUSH_IMAGES" = "true" ]; then
                echo -e "${YELLOW}  Building multi-platform and pushing to registry...${NC}"
                docker buildx build \
                    --platform $PLATFORM \
                    -f Microservices-Backend/${service}/Dockerfile \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:${BUILD_VERSION} \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:latest \
                    --push \
                    Microservices-Backend
            fi
        else
            # Single platform build
            if [ "$PUSH_IMAGES" = "true" ]; then
                docker buildx build \
                    --platform $PLATFORM \
                    -f Microservices-Backend/${service}/Dockerfile \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:${BUILD_VERSION} \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:latest \
                    --push \
                    Microservices-Backend
            else
                docker buildx build \
                    --platform $PLATFORM \
                    -f Microservices-Backend/${service}/Dockerfile \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:${BUILD_VERSION} \
                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:latest \
                    --load \
                    Microservices-Backend
            fi
        fi
        
        echo -e "${GREEN}✓ ${service} build complete${NC}"
    done
    
    echo -e "${GREEN}✓ All backend services built successfully${NC}"
    echo ""
}

build_frontend() {
    echo -e "${BLUE}Building Frontend...${NC}"
    
    # Build frontend
    cd Frontend
    npm ci
    npm run build --prod
    cd ..
    
    echo -e "${YELLOW}Building frontend Docker image...${NC}"
    
    # Check if multi-platform build
    if [[ "$PLATFORM" == *","* ]]; then
        # Multi-platform build - build for local first (single platform)
        echo -e "${YELLOW}  Building for local (linux/amd64)...${NC}"
        docker buildx build \
            --platform linux/amd64 \
            -f Frontend/Dockerfile \
            -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
            -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
            --load \
            Frontend
        
        # If push is enabled, build multi-platform and push
        if [ "$PUSH_IMAGES" = "true" ]; then
            echo -e "${YELLOW}  Building multi-platform and pushing to registry...${NC}"
            docker buildx build \
                --platform $PLATFORM \
                -f Frontend/Dockerfile \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
                --push \
                Frontend
        fi
    else
        # Single platform build
        if [ "$PUSH_IMAGES" = "true" ]; then
            docker buildx build \
                --platform $PLATFORM \
                -f Frontend/Dockerfile \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
                --push \
                Frontend
        else
            docker buildx build \
                --platform $PLATFORM \
                -f Frontend/Dockerfile \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
                -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
                --load \
                Frontend
        fi
    fi
    
    echo -e "${GREEN}✓ Frontend build complete${NC}"
    echo ""
}

list_images() {
    echo -e "${BLUE}Built Images:${NC}"
    echo ""
    
    for service in "${BACKEND_SERVICES[@]}"; do
        echo -e "${GREEN}${DOCKER_REGISTRY}/${DOCKER_REPO}/${service}:${BUILD_VERSION}${NC}"
    done
    echo -e "${GREEN}${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION}${NC}"
    echo ""
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --registry REGISTRY    Docker registry (default: docker.io)"
    echo "  -n, --repo REPO           Docker repository name (default: revticket)"
    echo "  -v, --version VERSION     Build version tag (default: latest)"
    echo "  -p, --push               Push images to registry"
    echo "  --platform PLATFORM      Target platform (default: linux/amd64,linux/arm64)"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build locally (multi-platform: local AMD64 only)"
    echo "  $0 --push                            # Build locally + push multi-platform to registry"
    echo "  $0 -r myregistry.com -n myrepo -v 1.0.0 --push"
    echo "  $0 --platform linux/amd64           # Build for AMD64 only"
    echo "  $0 --platform linux/arm64 --push    # Build for ARM64 and push"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        -p|--push)
            PUSH_IMAGES="true"
            shift
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
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
    print_header
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running${NC}"
        exit 1
    fi
    
    # Check if buildx is available
    if ! docker buildx version > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker Buildx is not available${NC}"
        exit 1
    fi
    
    # Setup buildx
    setup_buildx
    
    # Build services
    build_backend_services
    build_frontend
    
    # Show results
    list_images
    
    # Show final status
    if [[ "$PLATFORM" == *","* ]]; then
        echo -e "${GREEN}✓ All images built locally (linux/amd64)!${NC}"
        if [ "$PUSH_IMAGES" = "true" ]; then
            echo -e "${GREEN}✓ All images also pushed to registry (multi-platform: $PLATFORM)!${NC}"
        else
            echo -e "${YELLOW}Note: Use --push flag to also push multi-platform images to registry${NC}"
        fi
    else
        if [ "$PUSH_IMAGES" = "true" ]; then
            echo -e "${GREEN}✓ All images built and pushed successfully!${NC}"
        else
            echo -e "${GREEN}✓ All images built locally!${NC}"
            echo -e "${YELLOW}Note: Use --push flag to push images to registry${NC}"
        fi
    fi
    
    # Show local images
    echo -e "${BLUE}Local images available:${NC}"
    docker images | grep "${DOCKER_REPO}" | head -15
}

# Run main function
main "$@"