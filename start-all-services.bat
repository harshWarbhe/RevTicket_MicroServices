@echo off
echo Starting All Backend Services...
echo ================================

REM Start API Gateway
echo Starting API Gateway...
start "API Gateway" cmd /c "cd Microservices-Backend\api-gateway && mvn spring-boot:run"
timeout /t 5 >nul

REM Start User Service
start "User Service" cmd /c "cd Microservices-Backend\user-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Movie Service
start "Movie Service" cmd /c "cd Microservices-Backend\movie-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Theater Service
start "Theater Service" cmd /c "cd Microservices-Backend\theater-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Showtime Service
start "Showtime Service" cmd /c "cd Microservices-Backend\showtime-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Booking Service
start "Booking Service" cmd /c "cd Microservices-Backend\booking-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Payment Service
start "Payment Service" cmd /c "cd Microservices-Backend\payment-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Review Service
start "Review Service" cmd /c "cd Microservices-Backend\review-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Search Service
start "Search Service" cmd /c "cd Microservices-Backend\search-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Notification Service
start "Notification Service" cmd /c "cd Microservices-Backend\notification-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Settings Service
start "Settings Service" cmd /c "cd Microservices-Backend\settings-service && mvn spring-boot:run"
timeout /t 3 >nul

REM Start Dashboard Service
start "Dashboard Service" cmd /c "cd Microservices-Backend\dashboard-service && mvn spring-boot:run"
timeout /t 3 >nul



echo.
echo All services are starting in separate windows...
echo.
echo Services will be available at:
echo User Service:         http://localhost:8081
echo Movie Service:        http://localhost:8082
echo Theater Service:      http://localhost:8083
echo Showtime Service:     http://localhost:8084
echo Booking Service:      http://localhost:8085
echo Payment Service:      http://localhost:8086
echo Review Service:       http://localhost:8087
echo Search Service:       http://localhost:8088
echo Notification Service: http://localhost:8089
echo Settings Service:     http://localhost:8090
echo Dashboard Service:    http://localhost:8091
echo API Gateway:          http://localhost:8080
echo.
echo Wait 2-3 minutes for all services to start completely.
pause