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

# coverage: clean coverage-$(CONTAINER_TOOL)
# Use ulimit -n 524288 as work-around for issue when kcov was using `ulimit -a`: "open files (-n) 1073741816" isntead of "-n: file descriptors 524288"
# coverage-podman: CONTAINER_TOOL = podman
# coverage-podman:
# 	$(CONTAINER_TOOL) container rm -f diff-shellcheck-test
# 	$(CONTAINER_TOOL) run -t -v "${PWD}:/home:O" --name diff-shellcheck-test diff-shellcheck-test-image \
# 		'cd /home && mkdir --mode 777 coverage && \
# 		ulimit -n 524288 \
# 		kcov \
# 			--clean \
# 			--include-path . \
# 			--exclude-path test/bats \
# 			--exclude-path test/test_helper \
# 			coverage \
# 			bats test'
# 	$(CONTAINER_TOOL) cp diff-shellcheck-test:/home/coverage .
# coverage-docker:
# 	$(CONTAINER_TOOL) container rm -f diff-shellcheck-test
# 	$(CONTAINER_TOOL) run -t -v "${PWD}:/home" --name diff-shellcheck-test diff-shellcheck-test-image \
# 		'cd /home && mkdir --mode 777 coverage && \
# 		ulimit -n 524288 \
# 		kcov \
# 			--clean \
# 			--include-path . \
# 			--exclude-path test/bats \
# 			--exclude-path test/test_helper \
# 			coverage \
# 			bats test'

.PHONY: coverage coverage-podman coverage-docker

clean:
	$(CONTAINER_TOOL) container rm -f diff-shellcheck-test
	rm -rf coverage/
# clean-podman could be used indepemdently
clean-podman: CONTAINER_TOOL = podman
clean-podman: clean

.PHONY: clean clean-podman
