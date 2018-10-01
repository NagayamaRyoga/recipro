RECIPRO_DIR  := .recipro
DIST_DIR     := dist
SRC_DIR      := src
ASSETS_DIR   := assets

INDEX_HTML   := index.html

PANDOC       := pandoc
PANDOC_FLAGS := --filter pandoc-crossref

MD_SRCS      := $(shell find ${SRC_DIR} -name '*.md' -type f)

OBJ_DIR      := ${RECIPRO_DIR}/obj
HTML_TARGET  := ${DIST_DIR}/${INDEX_HTML}
MD_OBJS      := ${MD_SRCS:%=${OBJ_DIR}/%}

.PHONY: all html tex clean

all: html tex
	echo ${MD_OBJS}

html: ${HTML_TARGET}

tex:

clean:
	${RM} -r dist .recipro

${HTML_TARGET}: ${MD_OBJS}
	@mkdir -p $(dir $@)
	${PANDOC} ${PANDOC_FLAGS} -o $@ $^
	cp -rf ${ASSETS_DIR} $(dir $@)/

${OBJ_DIR}/${SRC_DIR}/%.md: ${SRC_DIR}/%.md
	@mkdir -p $(dir $@)
	cp $< $@
