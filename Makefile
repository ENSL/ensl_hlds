REGISTRY ?= ensl
PROJECT  ?= ensl_hlds
TAG      ?= latest

.PHONY: all clean build stop

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
	mkdir -p logs
	#docker run -p 27015:27015 27015/udp:27015/udp -v $(shell pwd)/logs:/home/steam/hlds/ns/logs -ti $(IMAGE)
	docker run --name=$(PROJECT) --net=host -v $(shell pwd)/logs:/home/steam/hlds/ns/logs -ti $(IMAGE)
#	docker run -e HLDS='1' --name=$(PROJECT) --net=host -v $(shell pwd)/logs:/home/steam/hlds/ns/logs -ti $(IMAGE)

stop:
	docker stop $(PROJECT)
	docker rm $(PROJECT)

shell:
	docker run --name=$(PROJECT) --net=host -v $(shell pwd)/logs:/home/steam/hlds/ns/logs -u0 -ti $(IMAGE) /bin/bash
#	docker exec -u0 -ti $(IMAGE) -v /bin/bash

pull:
	docker pull $(IMAGE) || true

push:
	docker push $(IMAGE)

clean:
	docker ps -a | awk '{ print $$1,$$2 }' | grep $(IMAGE) |awk '{print $$1 }' |xargs -I {} docker rm {}
	docker images -a |grep $(IMAGE) |awk '{print $$3}' |xargs -I {} docker rmi {}
