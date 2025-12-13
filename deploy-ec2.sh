#!/bin/bash

# EC2 Deployment Script for RevTicket Microservices
# Usage: ./deploy-ec2.sh <EC2_HOST> <EC2_USER> <KEY_PATH>

set -e

EC2_HOST=${1:-$EC2_HOST}
EC2_USER=${2:-ubuntu}
KEY_PATH=${3:-~/.ssh/id_rsa}

if [ -z "$EC2_HOST" ]; then
    echo "Error: EC2_HOST is required"
    echo "Usage: ./deploy-ec2.sh <EC2_HOST> <EC2_USER> <KEY_PATH>"
    exit 1
fi

echo "🚀 Deploying RevTicket to EC2: $EC2_HOST"

# Copy files to EC2
echo "📁 Copying deployment files..."
scp -i $KEY_PATH -o StrictHostKeyChecking=no docker-compose.prod.yml $EC2_USER@$EC2_HOST:/home/$EC2_USER/docker-compose.yml
scp -i $KEY_PATH -o StrictHostKeyChecking=no .env.example $EC2_USER@$EC2_HOST:/home/$EC2_USER/.env

# Deploy on EC2
echo "🐳 Deploying containers..."
ssh -i $KEY_PATH -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << 'EOF'
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y docker.io docker-compose
        sudo usermod -aG docker $USER
        sudo systemctl enable docker
        sudo systemctl start docker
    fi

    # Stop existing containers
    docker-compose down || true

    # Pull latest images
    docker-compose pull

    # Start services
    docker-compose up -d

    # Wait and check health
    sleep 30
    docker-compose ps

    echo "✅ Deployment complete!"
    echo "🌐 Frontend: http://$(curl -s ifconfig.me):80"
    echo "🔗 API Gateway: http://$(curl -s ifconfig.me):8080"
    echo "📊 Consul: http://$(curl -s ifconfig.me):8500"
EOF

echo "✅ RevTicket deployed successfully to EC2!"