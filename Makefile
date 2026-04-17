# SPDX-License-Identifier: GPL-3.0-or-later

# Docker is default tool for running containers
CONTAINER_TOOL := docker

PREFIX ?= /usr
LIBEXECDIR ?= $(PREFIX)/libexec/differential-shellcheck
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
DOCDIR ?= $(PREFIX)/share/doc/differential-shellcheck
LICENSEDIR ?= $(PREFIX)/share/licenses/differential-shellcheck

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
# Use ulimit -n 524288 as work-around for issue when kcov was using `ulimit -a`: "open files (-n) 1073741816" instead of "-n: file descriptors 524288"
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
# clean-podman could be used independently
clean-podman: CONTAINER_TOOL = podman
clean-podman: clean

.PHONY: clean clean-podman

# --- Man page ---

man: docs/differential-shellcheck.1

docs/differential-shellcheck.1: docs/differential-shellcheck.1.md
	pandoc -s -t man $< -o $@

.PHONY: man

# --- Install ---

install: man
	install -d $(DESTDIR)$(LIBEXECDIR)
	install -m 755 src/index.sh $(DESTDIR)$(LIBEXECDIR)/
	install -m 644 src/functions.sh $(DESTDIR)$(LIBEXECDIR)/
	install -m 644 src/setup.sh $(DESTDIR)$(LIBEXECDIR)/
	install -m 644 src/validation.sh $(DESTDIR)$(LIBEXECDIR)/
	install -m 644 src/summary.sh $(DESTDIR)$(LIBEXECDIR)/
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 src/cli.sh $(DESTDIR)$(BINDIR)/differential-shellcheck
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 docs/differential-shellcheck.1 $(DESTDIR)$(MANDIR)/
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/
	install -d $(DESTDIR)$(LICENSEDIR)
	install -m 644 LICENSE $(DESTDIR)$(LICENSEDIR)/
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 VERSION $(DESTDIR)$(DOCDIR)/

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/differential-shellcheck
	rm -rf $(DESTDIR)$(LIBEXECDIR)
	rm -f $(DESTDIR)$(MANDIR)/differential-shellcheck.1
	rm -rf $(DESTDIR)$(DOCDIR)
	rm -rf $(DESTDIR)$(LICENSEDIR)

.PHONY: install uninstall
