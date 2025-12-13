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
        echo "Creating clean $pom_file"
        
        # Get service name with proper capitalization
        service_name=$(echo "$service" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        
        cat > "$pom_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.revticket</groupId>
        <artifactId>revticket-microservices</artifactId>
        <version>1.0.0</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>$service</artifactId>
    <name>$service_name</name>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-consul-discovery</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF
    fi
done

# Add specific dependencies for certain services
echo "Adding mail dependency to user-service and booking-service..."
sed -i '' '/<artifactId>spring-boot-starter-validation<\/artifactId>/a\
        </dependency>\
        <dependency>\
            <groupId>org.springframework.boot</groupId>\
            <artifactId>spring-boot-starter-mail</artifactId>' Microservices-Backend/user-service/pom.xml

sed -i '' '/<artifactId>spring-boot-starter-validation<\/artifactId>/a\
        </dependency>\
        <dependency>\
            <groupId>org.springframework.boot</groupId>\
            <artifactId>spring-boot-starter-mail</artifactId>' Microservices-Backend/booking-service/pom.xml

# Add OAuth2 dependency to user-service
sed -i '' '/<artifactId>spring-boot-starter-mail<\/artifactId>/a\
        </dependency>\
        <dependency>\
            <groupId>org.springframework.boot</groupId>\
            <artifactId>spring-boot-starter-oauth2-client</artifactId>' Microservices-Backend/user-service/pom.xml

echo "All pom.xml files recreated with clean structure"