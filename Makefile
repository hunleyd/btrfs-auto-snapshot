FILES = btrfs-auto-snapshot release

.PHONY: lint
lint: shfmt shellcheck

.PHONY: shfmt
shfmt:
	shfmt --keep-padding --func-next-line -i 4 -w $(FILES)

.PHONY: shellcheck
shellcheck:
	shellcheck $(FILES)
