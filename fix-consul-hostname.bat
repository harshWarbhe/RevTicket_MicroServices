@echo off
echo Fixing Consul hostname configuration for all services...

set services=user-service movie-service theater-service showtime-service booking-service payment-service review-service search-service notification-service settings-service dashboard-service

for %%s in (%services%) do (
    echo Updating %%s...
    cd "Microservices-Backend\%%s\src\main\resources"
    
    REM Add hostname and prefer-ip-address configuration if not exists
    powershell -Command "(Get-Content application.yml) -replace 'health-check-interval: 10s', 'health-check-interval: 10s^r^n        hostname: localhost^r^n        prefer-ip-address: false' | Set-Content application.yml"
    
    cd ..\..\..\..\
)

echo Done! All services updated. Please restart all services.
pause