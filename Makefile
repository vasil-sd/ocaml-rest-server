.PHONY: all build clean release

release:
	git push --tags
	@ TAG=$$(git tag | tail -n 1); \
	mkdir -p release/rest_server.$$TAG; \
	cp rest_server.descr release/rest_server.$$TAG/descr; \
	cp rest_server.opam release/rest_server.$$TAG/opam; \
	ARCHIVE=https://github.com/vasil-sd/ocaml-rest-server/archive/$$TAG.tar.gz; \
	MD5SUM=$$(wget -O - $$ARCHIVE 2> /dev/null | md5sum | awk '{print $$1}'); \
	echo "archive: \"$$ARCHIVE\"" > release/rest_server.$$TAG/url; \
	echo "checksum: \"$$MD5SUM\"" >> release/rest_server.$$TAG/url

build:
	jbuilder build --dev @install

all: build

install:
	jbuilder install --dev

uninstall:
	jbuilder uninstall

clean:
	rm -rf _build *.install

