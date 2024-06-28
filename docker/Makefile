SHELL			:= /bin/bash
# depending on the installed docker engine (docker vs podman) the image removal
# command could differ
DOCKER_RMI		= $(shell file $$(which docker) | (grep ELF >&/dev/null && echo 'docker rmi' || echo 'docker rmi --ignore'))
# DOCKER_RUN gets '-it' options only if the current bash has tty attached to
# stdin
DOCKER_RUN		= docker run -v $(PRJ_ROOT):/import:Z $(if $(patsubst not a tty,,$(shell tty)),-it) --rm
FEDORA_MAKE		= $(DOCKER_RUN) ofl:fedora
UBUNTU_MAKE		= $(DOCKER_RUN) ofl:ubuntu

DOCKER_BUILD	= docker build
FEDORA_BUILD	= $(DOCKER_BUILD) -t ofl:fedora
UBUNTU_BUILD	= $(DOCKER_BUILD) -t ofl:ubuntu

$(info docker rmi '$(DOCKER_RMI)')

clean:
	$(call aggregate-prologue)
	$(DOCKER_RMI) ofl:fedora ofl:ubuntu
	$(call aggregate-epilogue)

# build docker image: pre-requisite for all fedora targets
fedora-build:
	$(call target-prologue)
	@cd $(word 1,$(subst -, ,$@)) && $(FEDORA_BUILD) .
	$(call target-epilogue-success)

# Fedora make "all"
fedora: fedora-build
	$(FEDORA_MAKE)

# Fedora make "tests/runs"
fedora-tests: fedora-build
	$(call section-prologue,$@)
	@$(FEDORA_MAKE) tests/runs
	$(call section-epilogue,$@)

# build docker image: pre-requisite for all ubuntu targets
ubuntu-build:
	$(call section-prologue,$@)
	cd $(word 1,$(subst -, ,$@)) && $(UBUNTU_BUILD) .
	$(call section-epilogue,$@)

# Ubuntu make "all"
ubuntu: ubuntu-build
	$(UBUNTU_MAKE)

# Ubuntu make "tests/runs"
ubuntu-tests: ubuntu-build
	$(call section-prologue,$@)
	@$(UBUNTU_MAKE) tests/runs
	$(call section-epilogue,$@)
