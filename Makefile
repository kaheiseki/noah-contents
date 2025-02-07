NPM := npm
NODE := node

TOOLKIT_DIR=./content_toolkit
TOOLKIT_DIST_DIR=$(TOOLKIT_DIR)/dist
PREVIEW_DIR = ./preview


DIST_DIR := $(PREVIEW_DIR)/public/generated
MEDIA_DIST_DIR := $(DIST_DIR)/media

SAMPLE_DIR := ./sample
SAMPLE_FILES := $(shell find $(SAMPLE_DIR)/*.xml)
SAMPLE_DIST_FILES :=$(SAMPLE_FILES:$(SAMPLE_DIR)/%.xml=$(DIST_DIR)/%.sample.json)

DOC_DIR := ./articles
DOC_FILES := $(shell find $(DOC_DIR)/*.xml)
DOC_DIST_FILES :=$(DOC_FILES:$(DOC_DIR)/%.xml=$(DIST_DIR)/%.json)


# Initialization
.PHONY: init-toolkit
init-toolkit:
	cd $(TOOLKIT_DIR) && $(NPM) install && $(NPM) run build
	

.PHONY: init-preview
init-preview:
	cd $(PREVIEW_DIR) && $(NPM) install && $(NPM) run build

# Test
.PHONY: test-sample
test-sample:
	$(NODE) $(TOOLKIT_DIST_DIR)/validate.js $(SAMPLE_FILES)

.PHONY: test-article
test-test-article:
	$(NODE) $(TOOLKIT_DIST_DIR)/validate.js $(DOC_FILES)

.PHONY: test
test:
	$(NODE) $(TOOLKIT_DIST_DIR)/validate.js $(SAMPLE_FILES) $(DOC_FILES)

# Generate
generate-sample: $(SAMPLE_DIST_FILES)
generate-article: $(DOC_DIST_FILES)
generate: generate-sample generate-article generate-toc

# Generate Inner (Generate JSON)
$(DIST_DIR)/%.json:	$(DOC_DIR)/%.xml
	mkdir -p $(DIST_DIR) $(MEDIA_DIST_DIR)
	$(NODE) $(TOOLKIT_DIST_DIR)/generate.js article $(MEDIA_DIST_DIR) $(DIST_DIR) $(DOC_DIR)/$*.xml

$(DIST_DIR)/%.sample.json:	$(SAMPLE_DIR)/%.xml
	mkdir -p $(DIST_DIR) $(MEDIA_DIST_DIR)
	$(NODE) $(TOOLKIT_DIST_DIR)/generate.js sample $(MEDIA_DIST_DIR) $(DIST_DIR) $(SAMPLE_DIR)/$*.xml


# Generate Table of contents
.PHONY: generate-toc
generate-toc:	
	rm -f $(DIST_DIR)/toc.json
	mkdir -p $(DIST_DIR)
	$(NODE) $(TOOLKIT_DIST_DIR)/toc.js $(DIST_DIR) $(DIST_DIR)/toc.json

# Utility

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)

.PHONY: cleanAll
cleanAll: clean
	cd $(TOOLKIT_DIR) && $(NPM) run clean:hard
	cd $(PREVIEW_DIR) && $(NPM) run clean:hard

.PHONY: serve
serve: generate
	cd $(PREVIEW_DIR) && $(NPM) run start
