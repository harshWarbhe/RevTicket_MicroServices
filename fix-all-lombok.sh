#!/bin/bash

# Fix Lombok configuration in all remaining service pom.xml files
services=(
    "review-service"
    "settings-service"
    "search-service"
    "dashboard-service"
)

echo "Fixing Lombok configuration in remaining services..."

for service in "${services[@]}"; do
    pom_file="Microservices-Backend/$service/pom.xml"
    if [ -f "$pom_file" ]; then
        echo "Fixing $pom_file"
        
        # Replace Lombok dependency configuration
        sed -i '' 's|<optional>true</optional>|'"<version>\${lombok.version}</version>"'\
<scope>provided</scope>|' "$pom_file"
        
        echo "  - Lombok dependency updated"
    fi
done

echo "Lombok configuration fix completed for all services!"
