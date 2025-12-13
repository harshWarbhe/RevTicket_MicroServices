# Consul Migration Guide

## Overview
Successfully migrated RevTicket microservices from Eureka to Consul for service discovery.

## What Changed

### 1. Dependencies Updated
- **Removed**: `spring-cloud-starter-netflix-eureka-client`
- **Added**: `spring-cloud-starter-consul-discovery`

### 2. Configuration Changes
All `application.yml` files updated:

**Before (Eureka):**
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

**After (Consul):**
```yaml
spring:
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        enabled: true
        register: true
        service-name: ${spring.application.name}
        health-check-path: /actuator/health
        health-check-interval: 10s
        instance-id: ${spring.application.name}:${server.port}
```

## Setup Instructions

### 1. Install Consul

**Option A: Download Binary**
```bash
# Download from https://www.consul.io/downloads
# Extract and add to PATH
```

**Option B: Using Package Manager**
```bash
# Windows (Chocolatey)
choco install consul

# macOS (Homebrew)
brew install consul

# Linux (Ubuntu)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul
```

### 2. Start Consul

```bash
# Development mode with UI
consul agent -dev -ui -client=0.0.0.0

# Access Consul UI at: http://localhost:8500
```

### 3. Start Services

**Option A: Use Batch Script**
```bash
# Windows
start-with-consul.bat

# Linux/macOS
chmod +x start-with-consul.sh
./start-with-consul.sh
```

**Option B: Manual Start**
```bash
# 1. Start API Gateway
cd Microservices-Backend/api-gateway
mvn spring-boot:run

# 2. Start each microservice
cd ../user-service && mvn spring-boot:run &
cd ../movie-service && mvn spring-boot:run &
# ... continue for all services
```

## Service Ports

| Service | Port | Health Check |
|---------|------|--------------|
| Consul | 8500 | http://localhost:8500/ui |
| API Gateway | 8080 | http://localhost:8080/actuator/health |
| User Service | 8081 | http://localhost:8081/actuator/health |
| Movie Service | 8082 | http://localhost:8082/actuator/health |
| Theater Service | 8083 | http://localhost:8083/actuator/health |
| Showtime Service | 8084 | http://localhost:8084/actuator/health |
| Booking Service | 8085 | http://localhost:8085/actuator/health |
| Payment Service | 8086 | http://localhost:8086/actuator/health |
| Review Service | 8087 | http://localhost:8087/actuator/health |
| Search Service | 8088 | http://localhost:8088/actuator/health |
| Notification Service | 8089 | http://localhost:8089/actuator/health |
| Settings Service | 8090 | http://localhost:8090/actuator/health |
| Dashboard Service | 8091 | http://localhost:8091/actuator/health |

## Verification

### 1. Check Consul UI
- Open http://localhost:8500/ui
- Verify all services are registered
- Check health status (green = healthy)

### 2. Test Service Discovery
```bash
# Check service registration
curl http://localhost:8500/v1/catalog/services

# Check specific service
curl http://localhost:8500/v1/catalog/service/user-service
```

### 3. Test API Gateway
```bash
# Test routing through gateway
curl http://localhost:8080/api/movies
curl http://localhost:8080/api/theaters
```

## Benefits of Consul over Eureka

1. **Active Development**: Consul is actively maintained by HashiCorp
2. **Built-in Health Checks**: Automatic health monitoring
3. **Key-Value Store**: Configuration management capabilities
4. **Multi-datacenter Support**: Better for distributed systems
5. **Service Mesh Ready**: Advanced networking features
6. **Better Performance**: More efficient service discovery

## Troubleshooting

### Services Not Registering
```bash
# Check Consul logs
consul monitor

# Verify service configuration
curl http://localhost:8081/actuator/health
```

### Port Conflicts
```bash
# Check port usage
netstat -an | findstr :8500
netstat -an | findstr :8080
```

### Health Check Failures
- Ensure `/actuator/health` endpoint is accessible
- Check service logs for errors
- Verify database connections

## Rollback (if needed)

To rollback to Eureka:
1. Revert pom.xml dependencies
2. Restore eureka configuration in application.yml
3. Start eureka-server
4. Restart all services

## Next Steps

1. **Configuration Management**: Use Consul KV store for centralized config
2. **Service Mesh**: Consider Consul Connect for advanced networking
3. **Monitoring**: Integrate with Prometheus/Grafana
4. **Security**: Enable Consul ACLs for production

---

**Migration completed successfully! 🎉**