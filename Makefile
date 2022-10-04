all: build-test check

build-test: clean
	@docker build -t diff-shellcheck-test-image test/

check:
	@docker run -dt -v "${PWD}:/home" --name diff-shellcheck-test diff-shellcheck-test-image
	@docker exec diff-shellcheck-test bash -c 'cd /home && bats test'
	@docker container stop diff-shellcheck-test

clean:
	@docker container rm -f diff-shellcheck-test

.PHONY: all build-test check clean
