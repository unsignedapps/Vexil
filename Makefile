#
# Makefile for Linux-based tests
#

SWIFT_DOCKER_IMAGE = swift:latest

test:
	docker run --rm --volume "$(shell pwd):/src" --workdir "/src" $(SWIFT_DOCKER_IMAGE) swift test --enable-test-discovery
