.PHONY: all build clean

build:
	jbuilder build --dev @install

all: build

install:
	jbuilder install --dev

uninstall:
	jbuilder uninstall

clean:
	rm -rf _build *.install

