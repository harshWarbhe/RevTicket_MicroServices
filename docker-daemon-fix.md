# Docker Daemon Fix Guide

## Issue

```
ERROR: Cannot connect to the Docker daemon at unix:///Users/harshwarbhe/.docker/run/docker.sock. Is the docker daemon running?
```

## Solutions

### 1. **Start Docker Desktop (macOS)**

```bash
# If you have Docker Desktop installed
open -a Docker
```

### 2. **Check Docker Status**

```bash
# Check if Docker is running
docker info

# If not running, start Docker Desktop from Applications or use:
sudo dockerd
```

### 3. **Install Docker Desktop (if not installed)**

```bash
# Install via Homebrew
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop
```

### 4. **Alternative: Use Docker without daemon**

```bash
# If you need to build without Docker daemon running, you can:
# 1. Skip Docker builds in your pipeline
# 2. Use Docker Buildx
# 3. Run containers with Docker Compose instead
```

## Quick Fix for Your Pipeline

If you want to temporarily skip Docker builds, modify your Jenkinsfile:

```groovy
// Comment out or add condition for Docker builds
// sh 'docker build -t harshwarbhe/revticket_microservices-frontend:38 .'

// Or use Docker Compose
sh 'docker-compose build'
```

## Verify Docker Installation

```bash
docker --version
docker-compose --version
docker run hello-world
```

Once Docker daemon is running, your pipeline should work end-to-end!
