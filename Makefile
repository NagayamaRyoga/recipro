PDF_TARGET   := document.pdf
TEX_TARGET   := document.tex
TEX_TEMPLATE := template.tex
TMP_DIR      := obj

SRCS   := $(filter-out README.md, $(sort $(wildcard *.md)))
OBJS   := ${SRCS:%.md=${TMP_DIR}/%.md}
BIBLIO := bibliography.bib
ASSETS := $(shell find assets -type f)
TABLES := $(addprefix obj/, $(filter %.csv, ${ASSETS}) $(filter %.tsv, ${ASSETS}))

.PHONY: all clean

all: ${PDF_TARGET}

${PDF_TARGET}: ${TMP_DIR}/${TEX_TARGET} ${BIBLIO} ${ASSETS} ${TABLES}
	ptex2pdf -l -ot "--kanji=utf8 --synctex=1 --interaction=batchmode" -output-directory ${TMP_DIR} $<
	pbibtex --kanji=utf8 ${TMP_DIR}/$(notdir $(basename $<))
	ptex2pdf -l -ot "--kanji=utf8 --synctex=1 --interaction=batchmode" -output-directory ${TMP_DIR} $<
	ptex2pdf -l -ot "--kanji=utf8 --synctex=1 --interaction=batchmode" -output-directory ${TMP_DIR} $<
	@mkdir -p ${@D}
	cp ${TMP_DIR}/${PDF_TARGET} $@

${TMP_DIR}/${TEX_TARGET}: ${OBJS} ${TEX_TEMPLATE}
	pandoc \
		--to latex \
		--top-level-division=chapter \
		--filter pandoc-crossref \
		--template ${TEX_TEMPLATE} \
		--toc \
		${OBJS} \
	| script/postproc \
	> $@

${TMP_DIR}/%.md: %.md
	@mkdir -p ${@D}
	cat $< | script/preproc > $@

${TMP_DIR}/%.csv: %.csv
	@mkdir -p ${@D}
	cat $< | script/convcsv ',' > $@

${TMP_DIR}/%.tsv: %.tsv
	@mkdir -p ${@D}
	cat $< | script/convcsv $$'\t' > $@

clean:
	${RM} -r ${PDF_TARGET} ${TMP_DIR}
