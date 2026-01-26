# This Makefile builds locally the Docker image used for run OFL tests.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SHELL			:= /bin/bash
# depending on the installed docker engine (docker vs podman) the image removal
# command could differ
DOCKER_RMI		= $(shell file $$(which docker) | (grep ELF >&/dev/null && echo 'docker rmi &>/dev/null' || echo 'docker rmi --ignore'))
# DOCKER_RUN gets '-it' options only if the current bash has tty attached to
# stdin
DOCKER_RUN		= docker run -v $(PRJ_ROOT):/import:Z $(if $(patsubst not a tty,,$(shell tty)),-it) --rm
FEDORA_MAKE		= $(DOCKER_RUN) ofl:fedora
UBUNTU_MAKE		= $(DOCKER_RUN) ofl:ubuntu

DOCKER_BUILD	= docker build
FEDORA_BUILD	= $(DOCKER_BUILD) -t ofl:fedora
UBUNTU_BUILD	= $(DOCKER_BUILD) -t ofl:ubuntu

.DEFAULT_GOAL := help

all: fedora ubuntu	## Build images for all the supported platforms

clean:
	$(call aggregate-prologue)
	$(DOCKER_RMI) ofl:fedora ofl:ubuntu || true
	$(call aggregate-epilogue)

fedora-build:	## build docker image: pre-requisite for all fedora targets
	$(call target-prologue)
	cd $(word 1,$(subst -, ,$@)) && $(FEDORA_BUILD) .
	$(call target-epilogue-success)

fedora: fedora-build	## Fedora make "all"
	$(FEDORA_MAKE)

fedora-tests: fedora-build	## Fedora make "tests/runs"
	$(call section-prologue,$@)
	$(FEDORA_MAKE) tests/runs
	$(call section-epilogue,$@)

ubuntu-build:	## build docker image: pre-requisite for all ubuntu targets
	$(call section-prologue,$@)
	cd $(word 1,$(subst -, ,$@)) && $(UBUNTU_BUILD) .
	$(call section-epilogue,$@)

ubuntu: ubuntu-build	## Ubuntu make "all"
	$(UBUNTU_MAKE)

ubuntu-tests: ubuntu-build	## Ubuntu make "tests/runs"
	$(call section-prologue,$@)
	$(UBUNTU_MAKE) tests/runs
	$(call section-epilogue,$@)

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
