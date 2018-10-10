-include config/config.mk
-include config/layout.mk

# default settings
SRC_DIR         ?= src
LAYOUT_DIR      ?= layouts
LAYOUT_DIR_HTML ?= ${LAYOUT_DIR}/html
TMP_DIR         ?= .recipro
DIST_DIR        ?= dist

# default layouts
LAYOUT_HTML        ?= default.html
LAYOUT_HTML_ASSETS ?= default.css

# pandoc settings
PANDOC ?= pandoc

PANDOC_FLAGS ?= \
	--standalone \
	--filter pandoc-crossref \
	-M crossrefYaml=config/crossref.yml \
	--table-of-contents

PANDOC_HTML_FLAGS ?= \
	${PANDOC_FLAGS} \
	-w html5 \
	--mathjax \
	--template=${LAYOUT_DIR_HTML}/${LAYOUT_HTML}

PANDOC_TEX_FLAGS ?= \
	${PANDOC_FLAGS}

# textlint settings
TEXTLINT ?= npm run lint

TEXTLINT_FLAGS ?=

# enumerates subdirectories
ARTICLES := $(patsubst ${SRC_DIR}/%/,%,$(filter %/,$(wildcard ${SRC_DIR}/*/)))

.PHONY: all html pdf clean

all:
lint:
html:
pdf:

clean:
	${RM} -r ${TMP_DIR} ${DIST_DIR}

# expands targets
define article_targets

$1_FILES   := $(wildcard ${SRC_DIR}/$1/*)
$1_SRCS    := $$(sort $$(filter %.md,$${$1_FILES}))
$1_OBJS    := $${$1_SRCS:${SRC_DIR}/%=${TMP_DIR}/%}
$1_ASSETS  := $$(shell find $$(filter-out %.md,$${$1_FILES}) -type f)
$1_TASSETS := $${$1_ASSETS:${SRC_DIR}/%=${TMP_DIR}/%} $$(addprefix ${TMP_DIR}/$1/,${LAYOUT_HTML_ASSETS})
$1_DASSETS := $${$1_TASSETS:${TMP_DIR}/%=${DIST_DIR}/%}

.PHONY: $1 $1/lint $1/html $1/pdf

all: $1
lint: $1/lint
html: $1/html
pdf: $1/pdf

$1: $1/html $1/pdf
$1/lint: $${$1_OBJS}
$1/html: ${DIST_DIR}/$1/index.html $${$1_DASSETS}
$1/pdf: ${DIST_DIR}/$1.pdf

${DIST_DIR}/$1/index.html: $${$1_OBJS}
	@mkdir -p $$(dir $$@)
	${PANDOC} ${PANDOC_HTML_FLAGS} $$(addprefix --css=,${LAYOUT_HTML_ASSETS}) -o $$@ $$^

${DIST_DIR}/$1.pdf: ${TMP_DIR}/$1/main.tex $${$1_TASSETS}

${TMP_DIR}/$1/main.tex: $${$1_OBJS}
	@mkdir -p $$(dir $$@)
	${PANDOC} ${PANDOC_TEX_FLAGS} -o $$@ $$^

${TMP_DIR}/$1/%.md: ${SRC_DIR}/$1/%.md
	@mkdir -p $$(dir $$@)
	@if [ -n "$${TEXTLINT}" ]; then \
		$${TEXTLINT} $$<; \
	fi
	cp $$< $$@

${TMP_DIR}/$1/%: ${SRC_DIR}/$1/%
	@mkdir -p $$(dir $$@)
	cp $$< $$@

${TMP_DIR}/$1/%: ${LAYOUT_DIR_HTML}/%
	@mkdir -p $$(dir $$@)
	cp $$< $$@

${DIST_DIR}/$1/%: ${TMP_DIR}/$1/%
	@mkdir -p $$(dir $$@)
	cp $$< $$@

endef

$(eval $(foreach article,${ARTICLES},$(call article_targets,${article})))
