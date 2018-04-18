REGISTRY ?= ensl
PROJECT  ?= ensl_hlds
TAG      ?= latest

.PHONY: all clean build

ifdef REGISTRY
  IMAGE=$(REGISTRY)/$(PROJECT):$(TAG)
else
  IMAGE=$(PROJECT):$(TAG)
endif

all:
	@echo "Available targets:"
	@echo "  * build - build a Docker image for $(IMAGE)"
	@echo "  * pull  - pull $(IMAGE)"
	@echo "  * push  - push $(IMAGE)"
	@echo "  * test  - build and test $(IMAGE)"

build: Dockerfile
	docker build -t $(IMAGE) .

run: build
	docker run -ti $(IMAGE)

shell: build
	docker run -u0 -ti $(IMAGE) -v $(shell pwd)/logs:/home/steam/hlds/ns/logs /bin/bash

pull:
	docker pull $(IMAGE) || true

push:
	docker push $(IMAGE)

clean:
	rm -f $(shell pwd)/logs/*
	docker ps -a | awk '{ print $$1,$$2 }' | grep $(IMAGE) |awk '{print $$1 }' |xargs -I {} docker rm {}
	docker images -a |grep $(IMAGE) |awk '{print $$3}' |xargs -I {} docker rmi {}
