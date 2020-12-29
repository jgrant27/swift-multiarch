# Valid values are amd64, arm64, armv7, armv8 etc.
ARCH?=amd64

OS=ubuntu-18.04

IMAGE_NAME=swift-multiarch:$(ARCH)-$(OS)
CONTAINER_NAME=swift-multiarch-$(ARCH)-$(OS)

REMOTE_PREFIX=jng27

run:
	docker run \
		-it $(IMAGE_NAME) bash

build:
	OS=$(OS) docker build \
				-e ARCH=$(ARCH) \
				--platform $(ARCH) \
				-t $(IMAGE_NAME) \
				-f Dockerfile .

squash: build
	mkdir .tmp || true
	docker rm $(CONTAINER_NAME) || true
	docker create --name $(CONTAINER_NAME) $(IMAGE_NAME)
	docker export $(CONTAINER_NAME) | pigz > .tmp/$(CONTAINER_NAME).tgz
	zcat .tmp/$(CONTAINER_NAME).tgz | docker import - $(IMAGE_NAME)
	rm -fr .tmp || true

push: squash
	docker tag $(IMAGE_NAME) $(REMOTE_PREFIX)/$(IMAGE_NAME)
	docker push $(REMOTE_PREFIX)/$(IMAGE_NAME)

build-swift: build
	docker run \
		--platform $(ARCH) \
		--name $(CONTAINER_NAME) \
		-it $(IMAGE_NAME) \
		swift build --triple $(ARCH)-$(OS) \
			-Xswiftc -static-executable -j 8 -c release
	docker commit $(IMAGE_NAME)
	docker stop $(IMAGE_NAME)
	docker rm $(IMAGE_NAME)

full-prune:
	docker system prune
	docker builder prune
