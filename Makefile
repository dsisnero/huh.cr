.PHONY: install update format lint test markdown markdown-check build-examples clean

EXAMPLE_SOURCES := $(wildcard examples/*.cr)
EXAMPLE_BINS := $(patsubst examples/%.cr,bin/examples/%,$(EXAMPLE_SOURCES))

install:
	BEADS_DIR=$$(pwd)/.beads shards install

update:
	BEADS_DIR=$$(pwd)/.beads shards update

format:
	crystal tool format --check

lint:
	ameba --fix
	ameba

test:
	crystal spec

markdown:
	rumdl fmt .

markdown-check:
	rumdl check . --check

build-examples: $(EXAMPLE_BINS)

bin/examples/%: examples/%.cr
	@mkdir -p bin/examples
	@echo "Building $< -> $@"
	@CRYSTAL_CACHE_DIR=$(PWD)/.crystal-cache crystal build "$<" -o "$@"

clean:
	rm -rf temp/* bin/examples/* bin/*.dwarf
