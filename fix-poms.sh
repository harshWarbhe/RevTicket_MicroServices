#!/bin/bash

# Reset all pom.xml files to basic Spring Boot plugin configuration
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
        # Replace build section with simple configuration
        cat > temp_build.xml << 'EOF'
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
EOF
        
        # Use Python to properly replace the build section
        python3 << EOF
import re

with open('$pom_file', 'r') as f:
    content = f.read()

# Remove everything from <build> to </build>
content = re.sub(r'<build>.*?</build>', '', content, flags=re.DOTALL)

# Add the new build section before </project>
with open('temp_build.xml', 'r') as f:
    build_section = f.read()

content = content.replace('</project>', build_section + '\n</project>')

with open('$pom_file', 'w') as f:
    f.write(content)
EOF
        
        rm -f temp_build.xml
    fi
done

echo "All pom.xml files fixed"