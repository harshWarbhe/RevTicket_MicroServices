@echo off
echo Restarting all services to apply Consul hostname fix...

echo Stopping all Java processes...
taskkill /f /im java.exe 2>nul

echo Waiting 5 seconds...
timeout /t 5 /nobreak >nul

echo Starting services...
cd Microservices-Backend

start "User Service" cmd /k "cd user-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Movie Service" cmd /k "cd movie-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Theater Service" cmd /k "cd theater-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Showtime Service" cmd /k "cd showtime-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Booking Service" cmd /k "cd booking-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Payment Service" cmd /k "cd payment-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Review Service" cmd /k "cd review-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Search Service" cmd /k "cd search-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Notification Service" cmd /k "cd notification-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Settings Service" cmd /k "cd settings-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "Dashboard Service" cmd /k "cd dashboard-service && mvn spring-boot:run"
timeout /t 3 /nobreak >nul

start "API Gateway" cmd /k "cd api-gateway && mvn spring-boot:run"

echo All services started! Wait 2-3 minutes for full startup, then check Consul health.
pause