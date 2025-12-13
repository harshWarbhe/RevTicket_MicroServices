#!/bin/bash

# Quick deployment commands for RevTicket

echo "RevTicket Deployment Commands"
echo "============================="

# Build all services locally
build_all() {
    echo "Building all services..."
    cd Microservices-Backend
    for service in api-gateway user-service movie-service theater-service showtime-service booking-service payment-service review-service search-service notification-service settings-service dashboard-service; do
        echo "Building $service..."
        cd $service && mvn clean package -DskipTests -q && cd ..
    done
    cd ..
}

# Build and push Docker images
build_docker() {
    echo "Building Docker images..."
    REGISTRY=${1:-"your-dockerhub-username"}
    
    # Build frontend
    cd Frontend
    docker build -t $REGISTRY/revticket-frontend:latest .
    cd ..
    
    # Build backend services
    cd Microservices-Backend
    for service in api-gateway user-service movie-service theater-service showtime-service booking-service payment-service review-service search-service notification-service settings-service dashboard-service; do
        echo "Building Docker image for $service..."
        cd $service
        docker build -t $REGISTRY/revticket-$service:latest .
        cd ..
    done
    cd ..
}

# Push all images to Docker Hub
push_images() {
    REGISTRY=${1:-"your-dockerhub-username"}
    echo "Pushing images to $REGISTRY..."
    
    docker push $REGISTRY/revticket-frontend:latest
    
    for service in api-gateway user-service movie-service theater-service showtime-service booking-service payment-service review-service search-service notification-service settings-service dashboard-service; do
        echo "Pushing $service..."
        docker push $REGISTRY/revticket-$service:latest
    done
}

# Deploy to EC2
deploy_ec2() {
    EC2_HOST=${1:-"your-ec2-ip"}
    EC2_USER=${2:-"ubuntu"}
    SSH_KEY=${3:-"~/.ssh/your-key.pem"}
    
    echo "Deploying to EC2: $EC2_HOST"
    
    # Copy files to EC2
    scp -i $SSH_KEY docker-compose.prod.yml $EC2_USER@$EC2_HOST:/home/$EC2_USER/docker-compose.yml
    scp -i $SSH_KEY .env.example $EC2_USER@$EC2_HOST:/home/$EC2_USER/.env
    
    # Deploy on EC2
    ssh -i $SSH_KEY $EC2_USER@$EC2_HOST '
        docker-compose pull
        docker-compose down
        docker-compose up -d
        docker system prune -f
    '
}

# Show usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  build                     - Build all Maven services"
    echo "  docker [registry]         - Build Docker images"
    echo "  push [registry]           - Push images to Docker Hub"
    echo "  deploy [host] [user] [key] - Deploy to EC2"
    echo "  all [registry] [host] [user] [key] - Build, push and deploy"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 docker myusername"
    echo "  $0 push myusername"
    echo "  $0 deploy 1.2.3.4 ubuntu ~/.ssh/key.pem"
    echo "  $0 all myusername 1.2.3.4 ubuntu ~/.ssh/key.pem"
}

# Main execution
case "$1" in
    "build")
        build_all
        ;;
    "docker")
        build_all
        build_docker $2
        ;;
    "push")
        push_images $2
        ;;
    "deploy")
        deploy_ec2 $2 $3 $4
        ;;
    "all")
        build_all
        build_docker $2
        push_images $2
        deploy_ec2 $3 $4 $5
        ;;
    *)
        usage
        ;;
esac