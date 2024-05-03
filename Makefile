FILES = btrfs-auto-snapshot

.PHONY: lint
lint: shfmt shellcheck

.PHONY: shfmt
shfmt:
	shfmt --keep-padding --func-next-line -i 4 -w $(FILES)

.PHONY: shellcheck
shellcheck:
	shellcheck $(FILES)
