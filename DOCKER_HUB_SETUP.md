# Docker Hub Setup Guide

## Your Docker Hub Configuration

**Username**: `harshwarbhe`  
**Registry**: `docker.io` (Docker Hub)

## Image Names

All RevTicket microservices will be pushed to your Docker Hub account with these names:

### Backend Services
- `harshwarbhe/api-gateway`
- `harshwarbhe/user-service`
- `harshwarbhe/movie-service`
- `harshwarbhe/theater-service`
- `harshwarbhe/showtime-service`
- `harshwarbhe/booking-service`
- `harshwarbhe/payment-service`
- `harshwarbhe/review-service`
- `harshwarbhe/search-service`
- `harshwarbhe/notification-service`
- `harshwarbhe/settings-service`
- `harshwarbhe/dashboard-service`

### Frontend
- `harshwarbhe/frontend`

## Setup Steps

### 1. Docker Hub Account
Ensure you have a Docker Hub account at https://hub.docker.com with username `harshwarbhe`

### 2. Local Docker Login
```bash
# Login to Docker Hub
docker login

# Enter your credentials:
# Username: harshwarbhe
# Password: [your-docker-hub-password]
```

### 3. Jenkins Credentials
Configure Jenkins with your Docker Hub credentials:

**Credential ID**: `docker-hub-credentials`
**Type**: Username with password
**Username**: `harshwarbhe`
**Password**: `[your-docker-hub-password]`

## Build and Push Commands

### Local Build and Push
```bash
# Build all images and push to your Docker Hub
./build-docker-images.sh --push

# Build specific version
./build-docker-images.sh -v 1.0.0 --push
```

### Manual Docker Commands
```bash
# Build and push API Gateway
docker buildx build --platform linux/amd64,linux/arm64 \
  -f Microservices-Backend/api-gateway/Dockerfile \
  -t harshwarbhe/api-gateway:latest \
  --push Microservices-Backend

# Pull and run
docker pull harshwarbhe/api-gateway:latest
docker run -p 8080:8080 harshwarbhe/api-gateway:latest
```

## Deployment

### Local Development (Build from Source)
```bash
# Uses local Dockerfiles to build images
docker-compose up --build
```

### Staging/Production (Use Registry Images)
```bash
# Uses images from harshwarbhe/* on Docker Hub
export DOCKER_REPO=harshwarbhe
export BUILD_VERSION=latest
docker-compose pull
docker-compose up -d
```

### Using Deployment Script
```bash
# Local development
./deploy.sh -m local

# Staging with your images
./deploy.sh -m staging -n harshwarbhe

# Production with specific version
./deploy.sh -m production -n harshwarbhe -v 1.0.0
```

## Jenkins Pipeline

The Jenkins pipeline is configured to:

1. **Build Images**: Create multi-platform images (AMD64 + ARM64)
2. **Local Storage**: Store AMD64 images locally for immediate use
3. **Registry Push**: Push multi-platform images to `harshwarbhe/*` on Docker Hub
4. **Deploy**: Use images from your Docker Hub account for staging/production

### Pipeline Environment Variables
```groovy
environment {
    DOCKER_REGISTRY = 'docker.io'
    DOCKER_REPO = 'harshwarbhe'
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
}
```

## Verification

### Check Your Docker Hub Repositories
Visit: https://hub.docker.com/u/harshwarbhe

You should see 13 repositories after the first successful build:
- api-gateway
- user-service
- movie-service
- theater-service
- showtime-service
- booking-service
- payment-service
- review-service
- search-service
- notification-service
- settings-service
- dashboard-service
- frontend

### Check Image Platforms
```bash
# Verify multi-platform support
docker buildx imagetools inspect harshwarbhe/api-gateway:latest

# Should show both:
# - linux/amd64
# - linux/arm64
```

### Pull and Test Images
```bash
# Pull all images
docker pull harshwarbhe/api-gateway:latest
docker pull harshwarbhe/user-service:latest
docker pull harshwarbhe/frontend:latest

# Test run
docker run -p 8080:8080 harshwarbhe/api-gateway:latest
```

## Troubleshooting

### Authentication Issues
```bash
# Re-login to Docker Hub
docker logout
docker login

# Verify credentials
docker info | grep Username
```

### Push Permission Denied
- Ensure you're logged in as `harshwarbhe`
- Check repository exists on Docker Hub
- Verify Jenkins credentials are correct

### Image Not Found
```bash
# Check if image exists
docker search harshwarbhe/api-gateway

# Pull specific tag
docker pull harshwarbhe/api-gateway:1.0.0
```

## Best Practices

### Tagging Strategy
- `latest` - Latest stable build
- `{BUILD_NUMBER}-{GIT_COMMIT}` - Specific build version
- `v1.0.0` - Release versions

### Security
- Use Docker Hub access tokens instead of passwords
- Regularly rotate credentials
- Enable 2FA on Docker Hub account

### Repository Management
- Add descriptions to your Docker Hub repositories
- Use README files for each repository
- Set up automated builds if needed

## Example Usage

### Complete Workflow
```bash
# 1. Build and push all images
./build-docker-images.sh --push

# 2. Deploy to staging
./deploy.sh -m staging

# 3. Check deployment
./deploy.sh status

# 4. Run health checks
./deploy.sh health
```

Your RevTicket microservices are now configured to use your Docker Hub account `harshwarbhe` for all image storage and deployment!