@echo off
echo ==========================================
echo Starting RevTicket with Consul Discovery
echo ==========================================
echo.
echo Make sure Consul is running:
echo   consul agent -dev -ui -client=0.0.0.0
echo.
echo Consul UI: http://localhost:8500
echo API Gateway: http://localhost:8080
echo.
pause

cd Microservices-Backend

start "API Gateway" cmd /k "cd api-gateway && mvn spring-boot:run"

start "User Service" cmd /k "cd user-service && mvn spring-boot:run"
start "Movie Service" cmd /k "cd movie-service && mvn spring-boot:run"
start "Theater Service" cmd /k "cd theater-service && mvn spring-boot:run"
start "Showtime Service" cmd /k "cd showtime-service && mvn spring-boot:run"
start "Booking Service" cmd /k "cd booking-service && mvn spring-boot:run"
start "Payment Service" cmd /k "cd payment-service && mvn spring-boot:run"
start "Review Service" cmd /k "cd review-service && mvn spring-boot:run"
start "Search Service" cmd /k "cd search-service && mvn spring-boot:run"
start "Notification Service" cmd /k "cd notification-service && mvn spring-boot:run"
start "Settings Service" cmd /k "cd settings-service && mvn spring-boot:run"
start "Dashboard Service" cmd /k "cd dashboard-service && mvn spring-boot:run"

echo.
echo ==========================================
echo All services started!
echo Check Consul UI: http://localhost:8500
echo ==========================================