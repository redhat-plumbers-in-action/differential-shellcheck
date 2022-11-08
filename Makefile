# Docker is default tool for running containers
# https://www.unix.com/programming/118420-makefile-ifeq-not-working.html
CONTAINER_TOOL := docker

all: build-test check

podman: CONTAINER_TOOL = podman
podman: build-test check-podman

.PHONY: all podman

build-test: clean
	$(CONTAINER_TOOL) build -t diff-shellcheck-test-image test/

.PHONY: build-test

check: check-$(CONTAINER_TOOL)
check-podman:
	$(CONTAINER_TOOL) run -t -v "${PWD}:/home:O" --name diff-shellcheck-test diff-shellcheck-test-image 'cd /home && bats test'
check-docker:
	$(CONTAINER_TOOL) run -t -v "${PWD}:/home" --name diff-shellcheck-test diff-shellcheck-test-image 'cd /home && bats test'

.PHONY: check check-podman check-docker

clean:
	$(CONTAINER_TOOL) container rm -f diff-shellcheck-test
# clean-podman could be used indepemdently
clean-podman: CONTAINER_TOOL = podman
clean-podman: clean

.PHONY: clean clean-podman
