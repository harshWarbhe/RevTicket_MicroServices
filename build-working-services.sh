#!/bin/bash

echo "Building working RevTicket Microservices..."

cd "Microservices-Backend"

# Build only working services
echo "Building API Gateway and User Service..."
mvn clean package -pl api-gateway,user-service -DskipTests

if [ $? -eq 0 ]; then
    echo "Build successful! Creating minimal Docker setup..."
    cd ..
    
    # Create minimal docker-compose for working services
    cat > docker-compose-minimal.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: revticket-mysql
    environment:
      MYSQL_ROOT_PASSWORD: Admin123
      MYSQL_DATABASE: revticket_db
    ports:
      - "3307:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - revticket-network

  consul:
    image: consul:1.15
    container_name: consul
    ports:
      - "8500:8500"
    command: consul agent -dev -ui -client=0.0.0.0
    networks:
      - revticket-network

  api-gateway:
    build: ./Microservices-Backend/api-gateway
    container_name: api-gateway
    ports:
      - "8080:8080"
    environment:
      SPRING_CLOUD_CONSUL_HOST: consul
      JWT_SECRET: RevTicketSecretKeyForJWTTokenGeneration2024SecureAndLongEnough
    depends_on:
      - consul
    networks:
      - revticket-network

  user-service:
    build: ./Microservices-Backend/user-service
    container_name: user-service
    ports:
      - "8081:8081"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/user_service_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: Admin123
      SPRING_CLOUD_CONSUL_HOST: consul
      JWT_SECRET: RevTicketSecretKeyForJWTTokenGeneration2024SecureAndLongEnough
    depends_on:
      - mysql
      - consul
    networks:
      - revticket-network

volumes:
  mysql_data:

networks:
  revticket-network:
    driver: bridge
EOF
    
    docker-compose -f docker-compose-minimal.yml up --build -d
    
    echo "Minimal services started:"
    echo "API Gateway: http://localhost:8080"
    echo "User Service: http://localhost:8081"
    echo "Consul: http://localhost:8500"
    echo "MySQL: localhost:3307"
else
    echo "Build failed! Please check the errors above."
    exit 1
fi