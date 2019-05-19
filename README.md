## flink-distroless

[Distroless](https://github.com/GoogleContainerTools/distroless) Docker images for [Apache Flink](https://github.com/apache/flink).

```
ucelebi/flink:1.8.0-scala_2.11-distroless
ucelebi/flink:1.8.0-scala_2.12-distroless
```

You can find all published tags at https://hub.docker.com/r/ucelebi/flink.

### Docker Images

The provided images are based on [GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless). In contrast to other images, `distroless` images do not contain package managers, shells, or any other programs you would find in a standard Linux distribution. The goal is to restrict the images to what is required to run the application, in our case the JVM.

Furthermore, the images *do not* include any optional dependencies distributed with Flink. They also *do not* include the standard Flink shell scripts that are typically used to start Flink JVMs. This keeps the images small in size, the Java classpath clean, and avoids hard to follow control flow during JVM start up.

For more details, check out the [`Dockerfile`](https://github.com/uce/flink-distroless/blob/master/Dockerfile).

#### Debugging

As noted, the images do not include a shell. For debugging purposes, there is a `-debug` variant of each image that includes a busybox shell.

```
ucelebi/flink:1.8.0-scala_2.11-distroless-debug
ucelebi/flink:1.8.0-scala_2.12-distroless-debug
```

Attach `-debug` to the Docker image tag to get the debug variant of the respective image.

### How to Use

Flink is installed into `/flink`. By default, the entrypoint will configure the JVM classpath to `/flink/lib` (no recursive scanning), configure logging, and allocate 80% of the available memory for the JVM heap using the JVM's container support (`flink-conf.yaml` is ignored).

For more details, check out the [`Dockerfile`](https://github.com/uce/flink-distroless/blob/master/Dockerfile#L37).

#### Bundle Your Dependencies

Use a custom `Dockerfile` in order to bundle your application-specific dependencies.

```Dockerfile
FROM ucelebi/flink:1.8.0-scala_2.12-distroless
WORKDIR /flink
COPY opt/flink-s3-fs-presto-1.8.0.jar ./lib
COPY examples/streaming/TopSpeedWindowing.jar ./lib
```

This examples bundles two additional dependencies, the S3 `FileSystem` and the example `TopSpeedWindowing` application.

#### Entrypoint

Since we don't run the Flink shell scripts to start the processes (we actually can't since we use `distroless`), you have to explicitly specify which entry class you want to execute.

1. **Session Cluster**:
      ```
      org.apache.flink.runtime.entrypoint.StandaloneSessionClusterEntrypoint -c /flink/conf
      ```
1. **Job Cluster**:
      ```
      org.apache.flink.runtime.entrypoint.StandaloneJobClusterEntryPoint -c /flink/conf
      ```
1. **Task Executor**:
      ```
      org.apache.flink.runtime.taskexecutor.TaskManagerRunner -c /flink/conf -Djobmanager.rpc.address=localhost
      ```
      Note that you have to configure the master node's RPC address for `TaskExecutor` instances via the `jobmanager.rpc.address` configuration entry. If you don't have it as part of `/flink/conf/flink-conf.yaml`, you can dynamically add configuration entries via `-Dkey=value` on the command line. Otherwise, `TaskExecutor` start up will fail.

#### Optional Dependencies

As noted, we don't bundle optional Flink dependencies found in the vanilla distribution of Flink. You have to manually download these dependencies and bundle them with your image. Please [download your desired Flink distribution](https://flink.apache.org/downloads.html) in order to extract your required optional dependencies, such as `FileSystem` implementations (e.g. [S3](https://aws.amazon.com/s3/)) or a particular metrics reporter (e.g. [Prometheus](https://prometheus.io)).

You can run the following command to only dowload the dependencies in `opt` from a Flink release:

```bash
FLINK_VERSION=1.8.0
SCALA_VERSION=2.12
FLINK_URL=https://archive.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz

curl -L ${FLINK_URL} | tar xvz --strip-components=1 - "*/opt"
```

Note that you still download the complete release archive.
