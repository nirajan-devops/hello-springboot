# ─────────────────────────────────────────────────────────
# Stage 1: Build and test the Spring Boot app with Maven
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jdk AS builder

# Set workdir inside container
WORKDIR /app

# Copy everything including .mvn, mvnw, pom.xml, src/
COPY . .

# Make mvnw executable (matches your GitHub step)
RUN chmod +x mvnw

# Build and run tests (like `./mvnw clean package`)
RUN ./mvnw clean package --no-transfer-progress

# ─────────────────────────────────────────────────────────
# Stage 2: Create minimal runtime image
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre

# Create non-root user (optional but recommended for security)
RUN useradd -ms /bin/bash appuser
USER appuser

# Copy jar from builder stage to final image
COPY --from=builder /app/target/*.jar /app/app.jar

# Set default port
EXPOSE 8080

# Command to run the Spring Boot app
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
