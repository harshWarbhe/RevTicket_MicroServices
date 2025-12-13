#!/bin/bash

# Fix Lombok exclusion in all service pom.xml files
services=(
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

for service in "${services[@]}"; do
    pom_file="Microservices-Backend/$service/pom.xml"
    if [ -f "$pom_file" ]; then
        echo "Fixing $pom_file"
        # Remove Lombok exclusion from Spring Boot plugin
        sed -i '' '/<excludes>/,/<\/excludes>/d' "$pom_file"
        # Clean up any empty configuration tags
        sed -i '' '/<configuration>$/,/<\/configuration>$/{/^[[:space:]]*<configuration>$/d; /^[[:space:]]*<\/configuration>$/d;}' "$pom_file"
    fi
done

echo "Lombok exclusions removed from all services"