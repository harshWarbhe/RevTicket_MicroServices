@echo off
echo Starting RevTicket Microservices with Docker and Consul...

echo.
echo 1. Building and starting all services...
docker-compose up --build -d

echo.
echo 2. Waiting for services to start...
timeout /t 30

echo.
echo 3. Checking service status...
docker-compose ps

echo.
echo ✅ RevTicket system is running!
echo Frontend: http://localhost:4200
echo API Gateway: http://localhost:8080
echo Consul UI: http://localhost:8500

pause