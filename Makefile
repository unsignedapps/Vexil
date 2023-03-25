#
# Makefile for Linux-based tests
#

SWIFT := swift
SWIFTFORMAT := $(SWIFT) package plugin --allow-writing-to-package-directory swiftformat
DOCKER := docker
SWIFT_DOCKER_IMAGE = swift:latest

XCBEAUTIFY := $(shell command -v xcbeautify 2> /dev/null)
ifndef XCBEAUTIFY
	XCBEAUTIFY := cat
endif

# Linting / Formatting

.PHONY: format lint

format:
	$(SWIFTFORMAT) .

lint:
	$(SWIFTFORMAT) . --lint

# Testing / Documentation

.PHONY: test docs

test:
	$(DOCKER) run --rm --platform linux/amd64 -e QEMU_CPU=max --volume "$(shell pwd):/src" --workdir "/src" $(SWIFT_DOCKER_IMAGE) swift test

docs:
	rm -f website/content/guides/*.md
	for i in Documentation/*.md; do website/scripts/copy-markdown.sh $$i `echo $$i | sed 's/Documentation/website\/content\/guides/'`; done;
	rm website/content/guides/README.md
	rm -f website/content/api/*.md
	$(SWIFT) doc generate Sources/Vexil -n Vexil -o .build/docs
	rm .build/docs/_*.md
	for i in .build/docs/*.md; do cat $$i | sed -E 's/\(\/([^)]+)\)/(\1.md)/g' > $$i.new; mv $$i.new $$i; done
	mv .build/docs/Home.md website/content/api/_index.md
	for i in .build/docs/*.md; do website/scripts/copy-markdown.sh $$i `echo $$i | sed 's/.build\/docs/website\/content\/api/'`; done
	echo "---\ntoc: true\n---\n\n" > website/content/_index.md
	cat README.md >> website/content/_index.md
	cd website && hugo
	rm -f website/content/guides/*.md
	rm -f website/content/api/*.md
	rm -f website/content/_index.md
