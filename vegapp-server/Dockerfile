# Use Eclipse Temurin JDK (Alpine Linux-based) with Maven as the base image
FROM maven:3.8.4-eclipse-temurin-17 as build

# Optional: Set a working directory
WORKDIR /app

# Copy the source code into the container
COPY src /app/src
COPY pom.xml /app

# Build the application using Maven
RUN mvn clean package -DskipTests

# Use Eclipse Temurin JDK (Alpine Linux-based) for the final image
FROM eclipse-temurin:17-jdk-alpine

# Optional: Set a working directory (not mandatory but a good practice)
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port your app runs on
EXPOSE 8090

# Define the command to run your app
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

# Note: The VOLUME /tmp line is for temporary files storage by Spring Boot
# VOLUME /tmp
