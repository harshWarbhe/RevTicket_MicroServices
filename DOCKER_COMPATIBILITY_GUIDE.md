# Docker Multi-Platform Compatibility Guide

## Overview

This guide explains how RevTicket microservices Docker images are built to be compatible with both Mac (ARM64/M1/M2) and Windows (AMD64) systems.

## Multi-Platform Support

### Supported Platforms
- **linux/amd64** - Intel/AMD processors (Windows, Linux, older Macs)
- **linux/arm64** - ARM processors (Apple M1/M2 Macs, ARM servers)

### Build Strategy

#### 1. Local Development
- Images are built for **linux/amd64** and loaded locally for immediate use
- Compatible with Docker Desktop on both Mac and Windows
- Allows local testing and development

#### 2. Registry Push
- Multi-platform images (amd64 + arm64) are built and pushed to Docker Hub
- Ensures compatibility across different deployment environments
- Docker automatically pulls the correct architecture

## Build Process

### Jenkins Pipeline
```groovy
// 1. Build for local use (AMD64)
docker buildx build --platform linux/amd64 \
    -t registry/repo/service:version \
    --load .

// 2. Build multi-platform and push to registry
docker buildx build --platform linux/amd64,linux/arm64 \
    -t registry/repo/service:version \
    --push .
```

### Local Build Script
```bash
# Build locally only
./build-docker-images.sh

# Build locally + push multi-platform to registry
./build-docker-images.sh --push

# Build for specific platform
./build-docker-images.sh --platform linux/arm64
```

## Docker Images Compatibility

### Base Images Used

#### Backend Services (Java)
```dockerfile
# Build stage - Multi-platform Maven
FROM maven:3.8-eclipse-temurin-17 AS build

# Runtime stage - Multi-platform JRE
FROM eclipse-temurin:17-jre
```

#### Frontend (Angular)
```dockerfile
# Build stage - Multi-platform Node.js
FROM node:18-alpine AS build

# Runtime stage - Multi-platform Nginx
FROM nginx:alpine
```

### Why These Images Are Compatible

1. **Eclipse Temurin JRE 17**
   - Official OpenJDK distribution
   - Available for both AMD64 and ARM64
   - Maintained by Eclipse Foundation

2. **Node.js 18 Alpine**
   - Official Node.js image
   - Alpine Linux base (small footprint)
   - Multi-architecture support

3. **Nginx Alpine**
   - Official Nginx image
   - Alpine Linux base
   - Universal compatibility

## Verification

### Check Image Architecture
```bash
# Inspect image architecture
docker image inspect revticket/api-gateway:latest | grep Architecture

# List all platforms for an image
docker buildx imagetools inspect revticket/api-gateway:latest
```

### Test on Different Platforms

#### Mac (ARM64)
```bash
docker run --platform linux/arm64 revticket/api-gateway:latest
```

#### Windows/Linux (AMD64)
```bash
docker run --platform linux/amd64 revticket/api-gateway:latest
```

## Services and Images

### Backend Services (11)
| Service | Image | Port | Platforms |
|---------|-------|------|-----------|
| API Gateway | `revticket/api-gateway` | 8080 | amd64, arm64 |
| User Service | `revticket/user-service` | 8081 | amd64, arm64 |
| Movie Service | `revticket/movie-service` | 8082 | amd64, arm64 |
| Theater Service | `revticket/theater-service` | 8083 | amd64, arm64 |
| Showtime Service | `revticket/showtime-service` | 8084 | amd64, arm64 |
| Booking Service | `revticket/booking-service` | 8085 | amd64, arm64 |
| Payment Service | `revticket/payment-service` | 8086 | amd64, arm64 |
| Review Service | `revticket/review-service` | 8087 | amd64, arm64 |
| Search Service | `revticket/search-service` | 8088 | amd64, arm64 |
| Notification Service | `revticket/notification-service` | 8089 | amd64, arm64 |
| Settings Service | `revticket/settings-service` | 8090 | amd64, arm64 |
| Dashboard Service | `revticket/dashboard-service` | 8091 | amd64, arm64 |

### Frontend
| Service | Image | Port | Platforms |
|---------|-------|------|-----------|
| Frontend | `revticket/frontend` | 80 | amd64, arm64 |

## Docker Compose Compatibility

### Platform Override
```yaml
services:
  api-gateway:
    image: revticket/api-gateway:latest
    platform: linux/amd64  # Force specific platform if needed
```

### Automatic Platform Selection
```yaml
services:
  api-gateway:
    image: revticket/api-gateway:latest
    # Docker automatically selects correct platform
```

## Troubleshooting

### Platform Mismatch Issues

#### Problem: Wrong Architecture
```
WARNING: The requested image's platform (linux/amd64) does not match 
the detected host platform (linux/arm64/v8)
```

#### Solution 1: Let Docker Handle It
```bash
# Docker will automatically select correct platform
docker run revticket/api-gateway:latest
```

#### Solution 2: Force Platform
```bash
# Force specific platform
docker run --platform linux/arm64 revticket/api-gateway:latest
```

### Build Issues

#### Problem: Buildx Not Available
```bash
# Install buildx plugin
docker buildx install
```

#### Problem: Multi-platform Build Fails
```bash
# Create new builder
docker buildx create --name multiarch --use --bootstrap
```

## Performance Considerations

### Native vs Emulated
- **Native**: Running ARM64 image on ARM64 Mac = Best performance
- **Emulated**: Running AMD64 image on ARM64 Mac = Slower but works
- **Recommendation**: Use multi-platform images for optimal performance

### Image Size Comparison
```bash
# Check image sizes for different platforms
docker images revticket/api-gateway --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

## CI/CD Integration

### Jenkins Pipeline Benefits
1. **Local Testing**: Images available immediately after build
2. **Registry Push**: Multi-platform images for deployment
3. **Compatibility**: Works on any Jenkins agent (AMD64/ARM64)

### GitHub Actions Alternative
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2

- name: Build and push
  uses: docker/build-push-action@v4
  with:
    platforms: linux/amd64,linux/arm64
    push: true
    tags: revticket/api-gateway:latest
```

## Best Practices

### 1. Always Use Multi-Platform Base Images
✅ `eclipse-temurin:17-jre` (supports amd64, arm64)
❌ `openjdk:17-jre` (limited platform support)

### 2. Test on Both Platforms
```bash
# Test AMD64
docker run --platform linux/amd64 revticket/api-gateway:latest

# Test ARM64
docker run --platform linux/arm64 revticket/api-gateway:latest
```

### 3. Use Buildx for All Builds
```bash
# Instead of docker build
docker buildx build --platform linux/amd64,linux/arm64 .
```

### 4. Verify Multi-Platform Images
```bash
# Check what platforms are available
docker buildx imagetools inspect revticket/api-gateway:latest
```

## Deployment Environments

### Development (Local)
- Use local images (single platform)
- Fast build and test cycle

### Staging/Production (Cloud)
- Use registry images (multi-platform)
- Automatic platform selection
- Consistent across environments

## Conclusion

The RevTicket microservices are designed with multi-platform compatibility in mind:

1. **Local Development**: Fast, single-platform builds for immediate testing
2. **Production Deployment**: Multi-platform images for universal compatibility
3. **Cross-Platform Support**: Works on Mac (ARM64) and Windows (AMD64)
4. **Future-Proof**: Ready for ARM-based cloud instances

This approach ensures developers can work efficiently on any platform while maintaining deployment flexibility.