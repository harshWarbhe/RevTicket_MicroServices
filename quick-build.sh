#!/bin/bash
cd Microservices-Backend
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
mvn clean package -DskipTests -q
echo "Build completed successfully!"