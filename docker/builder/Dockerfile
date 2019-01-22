FROM paperist/alpine-texlive-ja

RUN apk add --no-cache --virtual .depends \
	curl \
	gmp \
	make \
	&& wget -O - 'https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-linux.tar.gz' | tar zxvf - \
	&& wget -O - 'https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.4.0/linux-ghc86-pandoc24.tar.gz' | tar zxvf - \
	&& mv pandoc-2.5/bin/pandoc pandoc-crossref /usr/local/bin/ \
	&& rm -rf pandoc-2.5 pandoc-crossref.1

CMD ["make"]
