-- Grant all privileges to root user from any host
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Create databases if they don't exist
CREATE DATABASE IF NOT EXISTS user_service_db;
CREATE DATABASE IF NOT EXISTS movie_service_db;
CREATE DATABASE IF NOT EXISTS theater_service_db;
CREATE DATABASE IF NOT EXISTS showtime_service_db;
CREATE DATABASE IF NOT EXISTS booking_service_db;
CREATE DATABASE IF NOT EXISTS payment_service_db;
CREATE DATABASE IF NOT EXISTS review_service_db;
CREATE DATABASE IF NOT EXISTS search_service_db;
CREATE DATABASE IF NOT EXISTS notification_service_db;
CREATE DATABASE IF NOT EXISTS settings_service_db;
CREATE DATABASE IF NOT EXISTS dashboard_service_db;