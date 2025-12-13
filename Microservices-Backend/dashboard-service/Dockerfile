FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/dashboard-service-1.0.0.jar app.jar

EXPOSE 8091

ENTRYPOINT ["java", "-jar", "app.jar"]