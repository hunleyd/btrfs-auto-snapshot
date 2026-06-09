FILES = btrfs-auto-snapshot release

.PHONY: lint
lint: shfmt shellcheck

.PHONY: test
test:
	@echo "Running loopback tests..."
	./tests/run_tests.sh

.PHONY: shfmt
shfmt:
	shfmt --keep-padding --func-next-line -i 4 -w $(FILES)

.PHONY: shellcheck
shellcheck:
	shellcheck $(FILES)
