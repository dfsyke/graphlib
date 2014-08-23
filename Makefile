MOD = graphlib

NPM = npm
BROWSERIFY = ./node_modules/browserify/bin/cmd.js
ISTANBUL = ./node_modules/istanbul/lib/cli.js
JSHINT = ./node_modules/jshint/bin/jshint
JSCS = ./node_modules/jscs/bin/jscs
MOCHA = ./node_modules/mocha/bin/_mocha
UGLIFY = ./node_modules/uglify-js/bin/uglifyjs

ISTANBUL_OPTS = --dir $(COVERAGE_DIR) --report html
JSHINT_OPTS = --reporter node_modules/jshint-stylish/stylish.js
MOCHA_OPTS = -R dot

BUILD_DIR = build
COVERAGE_DIR = $(BUILD_DIR)/cov

SRC_FILES = index.js lib/version.js $(shell find lib -type f -name '*.js')
TEST_FILES = $(shell find test -type f -name '*.js')
BUILD_FILES = $(addprefix $(BUILD_DIR)/, $(MOD).js $(MOD).min.js)

DIRS = $(BUILD_DIR)

.PHONY: all clean dist watch

all: $(BUILD_FILES)

bench: all
	@src/bench.js

lib/version.js: package.json
	@src/version.js > $@

$(DIRS):
	@mkdir -p $@

$(BUILD_DIR)/$(MOD).js: browser.js $(SRC_FILES) $(TEST_FILES) node_modules | $(BUILD_DIR)
	@echo Building...
	@# $(MOCHA) $(MOCHA_OPTS) $(TEST_FILES)
	@$(ISTANBUL) cover $(ISTANBUL_OPTS) $(MOCHA) --dir $(COVERAGE_DIR) -- $(MOCHA_OPTS) $(TEST_FILES)
	@$(JSHINT) $(JSHINT_OPTS) $(filter-out node_modules, $?)
	@$(JSCS) $(filter-out node_modules, $?)
	@$(BROWSERIFY) $< > $@

$(BUILD_DIR)/$(MOD).min.js: $(BUILD_DIR)/$(MOD).js
	@$(UGLIFY) $< --comments '@license' > $@

watch: all
	@fswatch -o $(SRC_FILES) $(TEST_FILES) package.json | xargs -n1 -I{} make

clean:
	rm -rf $(BUILD_DIR)

node_modules: package.json
	@$(NPM) install
	@touch $@
