# Valid values are x86_64, aarch64, armv8 etc.
ARCH?=x86_64

OS=ubuntu-18.04

IMAGE_NAME=swift-multiarch:$(ARCH)-$(OS)

REMOTE_PREFIX=jng27

run:
	docker run \
		-it $(IMAGE_NAME) bash

create:
	docker build \
		--platform $(ARCH) \
		-t $(IMAGE_NAME) \
		-f Dockerfile.$(ARCH) .

push:
	docker tag $(IMAGE_NAME) $(REMOTE_PREFIX)/$(IMAGE_NAME)
	docker push $(REMOTE_PREFIX)/$(IMAGE_NAME)

build:
	docker run \
		--platform $(ARCH) \
		--name $(IMAGE_NAME) \
		-it $(IMAGE_NAME) \
		swift build --triple $(ARCH)-$(OS) \
			-Xswiftc -static-executable -j 8 -c release
	docker commit $(IMAGE_NAME)
	docker stop $(IMAGE_NAME)
	docker rm $(IMAGE_NAME)

full-prune:
	docker system prune -a
	docker builder prune -a
