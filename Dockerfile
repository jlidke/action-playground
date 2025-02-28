FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /home/gradle/src
ENV GRADLE_USER_HOME=/gradle

COPY . .

RUN ./gradlew clean build --info && \
    java -Djarmode=layertools -jar build/libs/*.jar extract

FROM gcr.io/distroless/java21:nonroot

USER root
USER nonroot

WORKDIR /opt/action-playground
COPY --from=build /home/gradle/src/dependencies/ ./
COPY --from=build /home/gradle/src/spring-boot-loader/ ./
COPY --from=build /home/gradle/src/application/ ./

USER 65532
ARG GIT_REF=""
ARG GIT_URL=""
ARG BUILD_TIME=""
ARG VERSION=0.0.0
ENV APP_VERSION=${VERSION} \
    SPRING_PROFILES_ACTIVE="prod"
EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=85", "org.springframework.boot.loader.launch.JarLauncher"]


LABEL org.opencontainers.image.created=${BUILD_TIME} \
    org.opencontainers.image.authors="J. Lidke" \
    org.opencontainers.image.source=${GIT_URL} \
    org.opencontainers.image.version=${VERSION} \
    org.opencontainers.image.revision=${GIT_REF} \
    org.opencontainers.image.title="action-playground" \
    org.opencontainers.image.description="play around"

