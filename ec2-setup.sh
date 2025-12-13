#!/bin/bash

# EC2 Setup Script for RevTicket Microservices
# Run this script on your EC2 instance to prepare it for deployment

echo "Setting up EC2 instance for RevTicket deployment..."

# Update system
sudo apt-get update -y

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Create application directory
mkdir -p /home/ubuntu/revticket
cd /home/ubuntu/revticket

# Create .env file template
cat > .env << EOF
# Database Configuration
MYSQL_ROOT_PASSWORD=your_mysql_password

# JWT Configuration
JWT_SECRET=RevTicketSecretKeyForJWTTokenGeneration2024SecureAndLongEnough

# Email Configuration
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password

# Payment Gateway Configuration
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
EOF

# Set proper permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/revticket
chmod 600 .env

# Configure firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 4200
sudo ufw allow 8080
sudo ufw allow 8500
sudo ufw --force enable

# Create systemd service for auto-start
sudo tee /etc/systemd/system/revticket.service > /dev/null << EOF
[Unit]
Description=RevTicket Microservices
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/revticket
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable revticket.service

echo "EC2 setup completed!"
echo "Please update the .env file with your actual credentials"
echo "Then run: sudo systemctl start revticket"