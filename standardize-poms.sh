#!/bin/bash

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
        echo "Standardizing $pom_file"
        
        # Fix parent section to use the correct parent
        sed -i '' '/<parent>/,/<\/parent>/{
            /<groupId>org.springframework.boot<\/groupId>/c\
        <groupId>com.revticket</groupId>
            /<artifactId>spring-boot-starter-parent<\/artifactId>/c\
        <artifactId>revticket-microservices</artifactId>
            /<version>3.2.0<\/version>/c\
        <version>1.0.0</version>
            /<relativePath\/>/d
        }' "$pom_file"
        
        # Remove duplicate properties and dependencyManagement sections
        sed -i '' '/<properties>/,/<\/properties>/d' "$pom_file"
        sed -i '' '/<dependencyManagement>/,/<\/dependencyManagement>/d' "$pom_file"
        
        # Ensure relativePath is set correctly
        sed -i '' '/<version>1.0.0<\/version>/a\
        <relativePath>../pom.xml</relativePath>' "$pom_file"
        
    fi
done

echo "All pom.xml files standardized"