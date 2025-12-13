#!/bin/bash

echo "Building RevTicket Microservices for Docker..."

cd "Microservices-Backend"

# Build all services without tests and with minimal processing
echo "Building all microservices..."
mvn clean package -DskipTests -Dmaven.compiler.proc=none

if [ $? -eq 0 ]; then
    echo "Build successful! Starting Docker containers..."
    cd ..
    docker-compose up --build -d
    
    echo "Services starting up..."
    echo "Frontend: http://localhost:4200"
    echo "API Gateway: http://localhost:8080"
    echo "Consul: http://localhost:8500"
else
    echo "Build failed! Please check the errors above."
    exit 1
fi