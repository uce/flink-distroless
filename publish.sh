#!/bin/bash
set -e
set -o pipefail

IMAGE=ucelebi/flink

function add_tag {
  local tag=$1
  local additional_tag=$2

  docker tag ${IMAGE}:${tag} ${IMAGE}:${additional_tag}
  docker push ${IMAGE}:${additional_tag}
}

# Build and push
make build push IMAGE=$IMAGE FLINK_VERSION=1.8.0 SCALA_VERSION=2.11 TARGET=distroless-debug
make build push IMAGE=$IMAGE FLINK_VERSION=1.8.0 SCALA_VERSION=2.12 TARGET=distroless-debug

make build push IMAGE=$IMAGE FLINK_VERSION=1.8.0 SCALA_VERSION=2.11 TARGET=distroless
make build push IMAGE=$IMAGE FLINK_VERSION=1.8.0 SCALA_VERSION=2.12 TARGET=distroless

# Add tags for convenience
add_tag 1.8.0-scala_2.11-distroless-debug 1.8.0-scala_2.11-debug
add_tag 1.8.0-scala_2.12-distroless-debug 1.8.0-scala_2.12-debug
add_tag 1.8.0-scala_2.12-distroless-debug 1.8.0-debug
add_tag 1.8.0-scala_2.12-distroless-debug 1.8-debug
add_tag 1.8.0-scala_2.12-distroless-debug latest-debug

add_tag 1.8.0-scala_2.11-distroless 1.8.0-scala_2.11
add_tag 1.8.0-scala_2.12-distroless 1.8.0-scala_2.12
add_tag 1.8.0-scala_2.12-distroless 1.8.0
add_tag 1.8.0-scala_2.12-distroless 1.8
add_tag 1.8.0-scala_2.12-distroless latest
