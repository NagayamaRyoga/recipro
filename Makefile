TEMP_DIR     := .recipro
DIST_DIR     := dist
SRC_DIR      := src

PANDOC       := pandoc
PANDOC_FLAGS := --filter pandoc-crossref

define DEF_DOCUMENT

SRCS        := $(shell find ${SRC_DIR}/$1 -type f)
OBJS        := $${SRCS:%=${TEMP_DIR}/%}
OBJ_MDS     := $$(filter %.md,$${OBJS})
OBJ_ASSETS  := $$(filter-out %.md,$${OBJS})

HTML        := ${DIST_DIR}/$1/index.html
HTML_ASSETS := $${OBJ_ASSETS:${TEMP_DIR}/${SRC_DIR}/%=${DIST_DIR}/%}
TEX         := ${TEMP_DIR}/${SRC_DIR}/$1/main.tex

all: $1
html: $1-html
tex: $1-tex

$1: $1-html $1-tex
$1-html: $${HTML} $${HTML_ASSETS}
$1-tex: $${TEX} $${OBJ_ASSETS}

$${HTML}: $${OBJ_MDS}
$${TEX}: $${OBJ_MDS}

endef

$(eval $(foreach dir,$(wildcard ${SRC_DIR}/*/),$(call DEF_DOCUMENT,${dir:${SRC_DIR}/%/=%})))

.PHONY: all clean

all:

clean:
	${RM} -r ${DIST_DIR} ${TEMP_DIR}

${TEMP_DIR}/${SRC_DIR}/%.md: ${SRC_DIR}/%.md
	@mkdir -p $(dir $@)
	cp $< $@

${TEMP_DIR}/${SRC_DIR}/%: ${SRC_DIR}/%
	@mkdir -p $(dir $@)
	cp $< $@

${DIST_DIR}/%: ${TEMP_DIR}/${SRC_DIR}/%
	@mkdir -p $(dir $@)
	cp $< $@

${DIST_DIR}/%/index.html:
	@mkdir -p $(dir $@)
	${PANDOC} ${PANDOC_FLAGS} -o $@ $^

${TEMP_DIR}/%/main.tex:
	@mkdir -p $(dir $@)
	${PANDOC} ${PANDOC_FLAGS} -o $@ $^
