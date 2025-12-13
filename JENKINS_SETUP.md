# Jenkins Setup Guide for RevTicket Microservices

## 📋 Prerequisites

### Jenkins Plugins Required:
```bash
# Install these plugins in Jenkins
- Pipeline
- Docker Pipeline
- Maven Integration
- NodeJS
- Email Extension
- Kubernetes CLI
- OWASP Dependency-Check
- SonarQube Scanner
- Trivy
```

### Tools Configuration:
1. **Maven**: Configure Maven 3.8+ in Global Tool Configuration
2. **NodeJS**: Configure NodeJS 18+ in Global Tool Configuration  
3. **Docker**: Configure Docker in Global Tool Configuration

## 🔐 Credentials Setup

Add these credentials in Jenkins (Manage Jenkins → Credentials):

### Required Credentials:
```bash
# Database
mysql-root-password (Secret text) = Admin123

# JWT
jwt-secret (Secret text) = RevTicketSecretKeyForJWTTokenGeneration2024SecureAndLongEnough

# Payment Gateway
razorpay-key-id (Secret text) = rzp_test_Ro278zkDXduScL
razorpay-key-secret (Secret text) = PBoZU26dOzGM9ABFwq4Ljc2p

# Email
mail-username (Secret text) = nanijohn460@gmail.com
mail-password (Secret text) = femrwvgygpiurafn

# Docker Registry (if using)
docker-hub-credentials (Username/Password)

# Kubernetes (if using K8s deployment)
kubeconfig-credentials (Secret file)

# SonarQube
sonar-token (Secret text)
```

## 🚀 Pipeline Options

### Option 1: Docker Compose Deployment (Recommended for Development)
- **File**: `Jenkinsfile.docker-compose`
- **Use Case**: Local development, testing, simple deployment
- **Requirements**: Docker, Docker Compose

### Option 2: Kubernetes Deployment (Production)
- **File**: `Jenkinsfile`
- **Use Case**: Production deployment with K8s
- **Requirements**: Kubernetes cluster, kubectl, Helm

## 📁 Project Structure for Jenkins

```
RevTicket_MicroServices/
├── Jenkinsfile                    # Main K8s pipeline
├── Jenkinsfile.docker-compose     # Docker Compose pipeline
├── docker-compose.yml             # Docker Compose config
├── k8s/                          # Kubernetes manifests (create if needed)
│   ├── staging/
│   └── production/
├── Microservices-Backend/
└── Frontend/
```

## 🔧 Jenkins Job Configuration

### 1. Create Multibranch Pipeline Job:
```bash
1. New Item → Multibranch Pipeline
2. Name: RevTicket-Microservices
3. Branch Sources: Git
4. Repository URL: <your-git-repo>
5. Credentials: <your-git-credentials>
6. Build Configuration: by Jenkinsfile
```

### 2. Pipeline Configuration:
```groovy
# For Docker Compose deployment
Script Path: Jenkinsfile.docker-compose

# For Kubernetes deployment  
Script Path: Jenkinsfile
```

### 3. Branch Strategy:
- **main**: Production deployment (manual approval)
- **develop**: Staging deployment (automatic)
- **feature/***: Build and test only

## 🧪 Pipeline Stages Explained

### Docker Compose Pipeline:
1. **Checkout** - Get source code
2. **Environment Setup** - Create .env file with secrets
3. **Build and Test** - Compile backend, build frontend
4. **Run Tests** - Execute unit tests
5. **Package** - Create JAR files
6. **Docker Build and Deploy** - Build images and start containers
7. **Health Check** - Verify services are running
8. **Integration Tests** - Test API endpoints

### Kubernetes Pipeline:
1. **Checkout** - Get source code
2. **Environment Setup** - Create .env file
3. **Build Backend Services** - Parallel Maven builds
4. **Test Backend Services** - Parallel test execution
5. **Code Quality Analysis** - SonarQube scan
6. **Build Frontend** - NPM build
7. **Package Services** - Create artifacts
8. **Build Docker Images** - Build and push to registry
9. **Security Scan** - Trivy and OWASP scans
10. **Deploy to Staging** - K8s deployment (develop branch)
11. **Integration Tests** - End-to-end testing
12. **Deploy to Production** - K8s deployment (main branch)
13. **Smoke Tests** - Production health checks

## 🔍 Monitoring and Notifications

### Build Notifications:
- **Success**: Email to commit author
- **Failure**: Email with console logs
- **Artifacts**: Test reports, security scans

### Health Checks:
```bash
# Service endpoints tested:
http://localhost:8080/actuator/health  # API Gateway
http://localhost:8081/actuator/health  # User Service
http://localhost:8082/actuator/health  # Movie Service
http://localhost:4200                  # Frontend
```

## 🐛 Troubleshooting

### Common Issues:

1. **Docker Permission Denied**:
   ```bash
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

2. **Port Conflicts**:
   ```bash
   # Check running containers
   docker ps
   # Stop conflicting services
   docker-compose down
   ```

3. **Maven Build Failures**:
   ```bash
   # Clear Maven cache
   rm -rf ~/.m2/repository
   ```

4. **Node.js Build Issues**:
   ```bash
   # Clear npm cache
   npm cache clean --force
   ```

## 📊 Quality Gates

### Automated Checks:
- ✅ Unit test coverage > 80%
- ✅ No critical security vulnerabilities
- ✅ SonarQube quality gate passed
- ✅ All services health checks pass
- ✅ Integration tests pass

### Manual Approvals:
- 🔒 Production deployment requires manual approval
- 🔒 Security scan review for critical findings

## 🚀 Quick Start

1. **Setup Jenkins with required plugins**
2. **Add credentials to Jenkins**
3. **Create multibranch pipeline job**
4. **Point to your Git repository**
5. **Choose appropriate Jenkinsfile**
6. **Run the pipeline**

### For Docker Compose (Simple):
```bash
# Use Jenkinsfile.docker-compose
# Deploys to local Docker environment
```

### For Kubernetes (Advanced):
```bash
# Use Jenkinsfile
# Requires K8s cluster setup
# Creates staging and production environments
```

## 📝 Next Steps

1. **Customize environment variables** in Jenkinsfile
2. **Add more integration tests** as needed
3. **Configure monitoring** (Prometheus, Grafana)
4. **Setup log aggregation** (ELK stack)
5. **Add performance testing** stages