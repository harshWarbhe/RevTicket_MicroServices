FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/settings-service-1.0.0.jar app.jar

EXPOSE 8090

ENTRYPOINT ["java", "-jar", "app.jar"]