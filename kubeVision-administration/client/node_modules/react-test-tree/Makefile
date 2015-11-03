BIN = ./node_modules/.bin

.PHONY: test test-watch lint release bootstrap

SRC = $(shell find ./lib ./index.js ./test -type f -name '*.js*')

test: lint
	@$(BIN)/karma start --single-run

test-watch: lint
	@$(BIN)/karma start

lint: bootstrap
	@$(BIN)/semistandard

release: test
	@inc=$(inc) sh scripts/release.sh

bootstrap:
	@npm install;