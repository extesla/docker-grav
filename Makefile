.PHONY: build-all
build-all: build-1.4 build-1.5 build-1.6 build-latest

.PHONY: build-1.4
build-1.4:
	@/bin/sh ./images/1.4/setup.sh

.PHONY: build-1.5
build-1.5:
	@/bin/sh ./images/1.5/setup.sh

.PHONY: build-1.6
build-1.6:
	@/bin/sh ./images/1.6/setup.sh

.PHONY: build-1.6
build-latest: build-1.6
	@docker tag extesla/grav:1.6 extesla/grav:latest

.PHONY: clean
clean:
	@docker container prune -f
	@docker system prune -f
