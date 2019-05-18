IMAGE         = $(or $(shell printenv IMAGE),ucelebi/flink)
TIMESTAMP     = $(or $(shell printenv TIMESTAMP),$(shell date -u +'%Y-%m-%dT%H:%M:%SZ'))
TARGET        = $(or $(shell printenv TARGET),distroless)
FLINK_VERSION = $(or $(shell printenv FLINK_VERSION),1.8.0)
SCALA_VERSION = $(or $(shell printenv SCALA_VERSION),2.12)

.PHONY: all
all: build

.PHONY: build
build:
	docker build \
	  --build-arg FLINK_VERSION=$(FLINK_VERSION) \
	  --build-arg SCALA_VERSION=$(SCALA_VERSION) \
	  --target $(TARGET) \
	  --iidfile .imageid \
	  --label maintainer="Ufuk Celebi <ucelebi@posteo.net>" \
	  --label name="flink" \
	  --label flink.version="$(FLINK_VERSION)-scala_$(SCALA_VERSION)" \
	  --label created="$(TIMESTAMP)" . 
	docker tag $$(cat .imageid) $(IMAGE):$(FLINK_VERSION)-scala_$(SCALA_VERSION)-$(TARGET)

.PHONY: push
push:
	docker push $(IMAGE):$(FLINK_VERSION)-scala_$(SCALA_VERSION)-$(TARGET)
