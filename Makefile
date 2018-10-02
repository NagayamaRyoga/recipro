TEMP_DIR     := .recipro
DIST_DIR     := dist
SRC_DIR      := src

PANDOC       := pandoc
PANDOC_FLAGS := --filter pandoc-crossref

define DEF_DOCUMENT
NAME   := $(patsubst ${SRC_DIR}/%/,%,$1)
SRCS   := $(shell find $1 -type f)
OBJS   := $${SRCS:%=${TEMP_DIR}/%}

HTML   := ${DIST_DIR}/$${NAME}/index.html
TEX    := ${TEMP_DIR}/$${NAME}/main.tex

all: $${NAME}
html: $${NAME}-html
tex: $${NAME}-tex

$${NAME}: $${NAME}-html $${NAME}-tex
$${NAME}-html: $${HTML}
$${NAME}-tex: $${TEX}

$${HTML}: $${OBJS}
$${TEX}: $${OBJS}
endef

$(eval $(foreach dir,$(wildcard ${SRC_DIR}/*/),$(call DEF_DOCUMENT,${dir})))

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

${DIST_DIR}/%/index.html:
	${PANDOC} ${PANDOC_FLAGS} -o $@ $(filter %.md,$^)

${TEMP_DIR}/%/main.tex:
	${PANDOC} ${PANDOC_FLAGS} -o $@ $(filter %.md,$^)
