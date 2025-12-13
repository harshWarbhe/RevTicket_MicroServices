# RevTicket Docker Deployment

## Quick Start

1. **Build and Run Everything:**
   ```bash
   ./build-and-run.sh
   ```

2. **Manual Steps:**
   ```bash
   # Build services
   cd Microservices-Backend
   mvn clean package -DskipTests
   cd ..
   
   # Start containers
   docker-compose up --build -d
   ```

## Access Points

- **Frontend:** http://localhost:4200
- **API Gateway:** http://localhost:8080
- **Consul Dashboard:** http://localhost:8500
- **MySQL:** localhost:3307
- **MongoDB:** localhost:27018

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart user-service

# Clean restart (removes data)
docker-compose down -v && docker-compose up --build -d
```

## Configuration

Edit `.env` file to customize:
- Database passwords
- JWT secret
- Payment gateway keys
- Email settings