FROM alpine:3.9 AS build-env
ARG FLINK_VERSION=1.8.0
ARG SCALA_VERSION=2.12
# Download and unpack to /flink
RUN wget -nv -O flink.tgz "https://archive.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz" && \
  mkdir /flink && \
  tar -C /flink -xf flink.tgz --strip-components=1 && \
  rm flink.tgz
WORKDIR /flink
# Remove examples, optional dependencies, shell scripts, and config files
RUN rm -rf bin \
  && rm -rf conf/* \
  && rm -rf examples \
  && rm -rf log \
  && rm -rf opt



FROM gcr.io/distroless/java:8-debug as distroless-debug
ENV JAVA_HOME=/usr/bin/java
WORKDIR /flink
USER nobody:nobody
COPY --from=build-env /flink .
COPY lib lib
COPY conf conf
ENTRYPOINT ["java", "-classpath", "lib/*", "-Dlog4j.configuration=file:/flink/conf/log4j.properties", "-Dlog.file=/tmp/flink.log", "-XX:InitialRAMPercentage=80.0", "-XX:MaxRAMPercentage=80.0"]



FROM gcr.io/distroless/java:8 as distroless
ENV JAVA_HOME=/usr/bin/java
WORKDIR /flink
USER nobody:nobody
COPY --from=build-env /flink .
COPY lib lib
COPY conf conf
ENTRYPOINT ["java", "-classpath", "lib/*", "-Dlog4j.configuration=file:/flink/conf/log4j.properties", "-Dlog.file=/tmp/flink.log", "-XX:InitialRAMPercentage=80.0", "-XX:MaxRAMPercentage=80.0"]
