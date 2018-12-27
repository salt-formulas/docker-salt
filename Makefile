VERSION = $(shell date +%Y%m%d)
ORGANIZATION ?= $(shell id -un)
SUDO ?= "sudo"

build:
	$(SUDO) docker build -t $(ORGANIZATION)/salt-master:$(VERSION) -f salt-master.Dockerfile .
	$(SUDO) docker tag $(ORGANIZATION)/salt-master:$(VERSION) $(ORGANIZATION)/salt-master:latest

push:
	$(SUDO) docker push $(ORGANIZATION)/salt-master:$(VERSION)
	$(SUDO) docker push $(ORGANIZATION)/salt-master:latest
