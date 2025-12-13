#!/bin/bash

# EC2 Instance Setup Script for RevTicket
# Run this on your EC2 instance to prepare it for deployment

set -e

echo "🔧 Setting up EC2 instance for RevTicket deployment..."

# Update system
sudo apt-get update -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Configure firewall (if ufw is enabled)
if command -v ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 80/tcp      # Frontend
    sudo ufw allow 8080/tcp    # API Gateway
    sudo ufw allow 8500/tcp    # Consul
    sudo ufw allow 22/tcp      # SSH
fi

# Create application directory
mkdir -p /home/$USER/revticket
cd /home/$USER/revticket

echo "✅ EC2 instance setup complete!"
echo "📋 Next steps:"
echo "1. Copy your deployment files to this instance"
echo "2. Configure .env file with your secrets"
echo "3. Run: docker-compose up -d"
echo ""
echo "🔗 Access URLs (replace <EC2_IP> with your instance IP):"
echo "   Frontend: http://<EC2_IP>:80"
echo "   API Gateway: http://<EC2_IP>:8080"
echo "   Consul: http://<EC2_IP>:8500"