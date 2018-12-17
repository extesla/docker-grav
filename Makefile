.PHONY: build-all
build-all: build-1.4 build-1.5 build-latest

.PHONY: build-1.4
build-1.4:
	@/bin/sh ./images/1.4/setup.sh

.PHONY: build-1.5
build-1.5:
	@/bin/sh ./images/1.5/setup.sh

.PHONY: build-latest
build-latest:
	@/bin/sh ./images/latest/setup.sh
