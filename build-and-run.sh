#!/bin/bash

echo "Building RevTicket Microservices..."

# Navigate to backend directory
cd "Microservices-Backend"

# Build all services
echo "Building all microservices..."
mvn clean package -DskipTests

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Starting Docker containers..."
    cd ..
    docker-compose up --build -d
    
    echo "Services starting up..."
    echo "Frontend: http://localhost:4200"
    echo "API Gateway: http://localhost:8080"
    echo "Consul: http://localhost:8500"
    echo "MySQL: localhost:3307"
    echo "MongoDB: localhost:27018"
else
    echo "Build failed! Please check the errors above."
    exit 1
fi