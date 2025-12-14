#!/bin/bash

# Comprehensive Lombok Fix Script for RevTicket Microservices
# This script fixes Lombok configuration across all 12 microservices for Jenkins CI/CD

set -e

echo "🔧 Starting Lombok configuration fix for Jenkins CI/CD..."

# Array of all microservices
SERVICES=(
    "api-gateway"
    "user-service"
    "movie-service"
    "theater-service"
    "showtime-service"
    "booking-service"
    "payment-service"
    "review-service"
    "dashboard-service"
    "notification-service"
    "settings-service"
    "search-service"
)

# Function to fix Lombok dependency in a service pom.xml
fix_service_lombok() {
    local service=$1
    local pom_file="Microservices-Backend/$service/pom.xml"
    
    if [ ! -f "$pom_file" ]; then
        echo "⚠️  $pom_file not found, skipping..."
        return
    fi
    
    echo "🔧 Fixing $service..."
    
    # Create backup
    cp "$pom_file" "$pom_file.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove existing Lombok dependency if present
    sed -i '' '/<dependency>/,/<\/dependency>/{
        /<groupId>org.projectlombok<\/groupId>/{
            :a
            N
            /<\/dependency>/!ba
            /<groupId>org.projectlombok<\/groupId>/d
        }
    }' "$pom_file"
    
    # Add Lombok dependency with proper configuration
    # Find the right place to insert - after the last </dependency> before </dependencies>
    sed -i '' '/<\/dependencies>/i\
        <dependency>\
            <groupId>org.projectlombok</groupId>\
            <artifactId>lombok</artifactId>\
            <scope>provided</scope>\
        </dependency>' "$pom_file"
    
    echo "✅ Fixed $service"
}

# Function to verify Lombok annotations in Java files
verify_lombok_usage() {
    local service=$1
    local java_dir="Microservices-Backend/$service/src/main/java"
    
    if [ ! -d "$java_dir" ]; then
        return
    fi
    
    echo "🔍 Verifying Lombok usage in $service..."
    
    # Check for Lombok annotations
    local lombok_count=$(find "$java_dir" -name "*.java" -exec grep -l "@Data\|@Getter\|@Setter\|@AllArgsConstructor\|@NoArgsConstructor" {} \; | wc -l)
    
    if [ "$lombok_count" -gt 0 ]; then
        echo "✅ Found $lombok_count files with Lombok annotations in $service"
    else
        echo "ℹ️  No Lombok annotations found in $service"
    fi
}

# Function to test compilation
test_compilation() {
    local service=$1
    
    echo "🧪 Testing compilation for $service..."
    
    cd "Microservices-Backend/$service"
    
    # Clean and compile
    if mvn clean compile -q; then
        echo "✅ $service compiles successfully"
    else
        echo "❌ $service compilation failed"
        return 1
    fi
    
    cd - > /dev/null
}

# Function to create IDE configuration files
create_ide_configs() {
    local service=$1
    local base_dir="Microservices-Backend/$service"
    
    # Create . lombok.config if not exists
    if [ ! -f "$base_dir/.lombok.config" ]; then
        cat > "$base_dir/.lombok.config" << EOF
# Lombok configuration for $service
config.stopBubbling = true
lombok.addLombokGeneratedAnnotation = true
lombok.extern.findbugs.addSuppressFBWarnings = true
EOF
        echo "✅ Created .lombok.config for $service"
    fi
    
    # Create IntelliJ IDEA configuration
    mkdir -p "$base_dir/.idea/libraries"
    if [ ! -f "$base_dir/.idea/libraries/Lombok.xml" ]; then
        cat > "$base_dir/.idea/libraries/Lombok.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component name="libraryTable">
  <library name="Lombok">
    <classpath>
      <root url="jar://\$MAVEN_REPOSITORY$/org/projectlombok/lombok/1.18.42/lombok-1.18.42.jar!/" />
    </classpath>
  </library>
</component>
EOF
        echo "✅ Created IntelliJ Lombok configuration for $service"
    fi
}

# Main execution
echo "🚀 Starting comprehensive Lombok fix..."

# Fix parent pom first (already done, but verify)
echo "📋 Verifying parent pom.xml..."
if grep -q "1.18.42" "Microservices-Backend/pom.xml"; then
    echo "✅ Parent pom.xml has correct Lombok version (1.18.42)"
else
    echo "❌ Parent pom.xml Lombok version issue detected"
fi

# Fix each service
for service in "${SERVICES[@]}"; do
    echo ""
    echo "🔧 Processing $service..."
    fix_service_lombok "$service"
    verify_lombok_usage "$service"
    create_ide_configs "$service"
done

# Test compilation for all services
echo ""
echo "🧪 Testing compilation for all services..."
FAILED_SERVICES=()

for service in "${SERVICES[@]}"; do
    if ! test_compilation "$service"; then
        FAILED_SERVICES+=("$service")
    fi
done

# Report results
echo ""
echo "📊 LOMBOK FIX SUMMARY"
echo "====================="
echo "✅ Services processed: ${#SERVICES[@]}"
echo "❌ Failed compilations: ${#FAILED_SERVICES[@]}"

if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    echo ""
    echo "❌ Services with compilation issues:"
    for failed in "${FAILED_SERVICES[@]}"; do
        echo "   - $failed"
    done
    echo ""
    echo "🔧 Please check the error messages above and fix any remaining issues."
else
    echo ""
    echo "🎉 All services compiled successfully!"
    echo ""
    echo "📝 Next steps for Jenkins CI/CD:"
    echo "1. Commit and push the changes"
    echo "2. Run your Jenkins pipeline"
    echo "3. Monitor the build logs for any remaining issues"
fi

echo ""
echo "🔧 Lombok fix completed!"
echo "💡 If you encounter issues, check the backup files created with .backup.* extension"
