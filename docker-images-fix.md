# Docker Images Build Issue Fix

## Current Issue

Your Jenkins pipeline is only building 2 Docker images:

- ✅ Frontend Image (52s)
- ✅ API Gateway Image (8.4s)
- ❌ Missing: 10 other microservices images

## Expected Images (12 total)

- ✅ Frontend
- ✅ API Gateway
- ❌ User Service
- ❌ Movie Service
- ❌ Theater Service
- ❌ Showtime Service
- ❌ Booking Service
- ❌ Payment Service
- ❌ Review Service
- ❌ Dashboard Service
- ❌ Notification Service
- ❌ Settings Service
- ❌ Search Service

## Likely Causes & Solutions

### 1. **Jenkinsfile Configuration**

Your Jenkinsfile probably only has Docker builds for specific services:

```groovy
// Current (only 2 services)
sh 'docker build -t harshwarbhe/revticket_microservices-frontend:38 ./Frontend'
sh 'docker build -t harshwarbhe/revticket_microservices-api-gateway:38 ./Microservices-Backend/api-gateway'

// Fix: Add all services
def services = [
    'api-gateway',
    'user-service',
    'movie-service',
    'theater-service',
    'showtime-service',
    'booking-service',
    'payment-service',
    'review-service',
    'dashboard-service',
    'notification-service',
    'settings-service',
    'search-service'
]

for (service in services) {
    sh "docker build -t harshwarbhe/revticket_microservices-${service}:38 ./Microservices-Backend/${service}"
}
```

### 2. **Dockerfiles Missing**

Check if all services have Dockerfiles:

```bash
find Microservices-Backend -name "Dockerfile"
```

### 3. **Build Script Configuration**

Your build scripts might only target specific services.

## Quick Fix - Update Jenkinsfile

Add Docker build steps for all services:

```groovy
stage('Build Docker Images') {
    steps {
        script {
            def services = [
                'api-gateway',
                'user-service',
                'movie-service',
                'theater-service',
                'showtime-service',
                'booking-service',
                'payment-service',
                'review-service',
                'dashboard-service',
                'notification-service',
                'settings-service',
                'search-service'
            ]

            // Build frontend
            sh 'docker build -t harshwarbhe/revticket_microservices-frontend:38 ./Frontend'

            // Build all microservices
            for (service in services) {
                sh "docker build -t harshwarbhe/revticket_microservices-${service}:38 ./Microservices-Backend/${service}"
            }
        }
    }
}
```

## Verify All Dockerfiles Exist

```bash
ls -la Microservices-Backend/*/Dockerfile
```

This should show 12 Dockerfiles (one for each service).
