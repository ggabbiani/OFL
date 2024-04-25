POD_RUN			= docker run -v $(PRJ_ROOT):/import:Z -it --rm
FEDORA_MAKE		= $(POD_RUN) ofl:fedora
UBUNTU_MAKE		= $(POD_RUN) ofl:ubuntu

POD_BUILD		= docker build
FEDORA_BUILD	= $(POD_BUILD) -t ofl:fedora
UBUNTU_BUILD	= $(POD_BUILD) -t ofl:ubuntu

clean:
	$(call aggregate-prologue)
	podman rmi --ignore ofl:fedora ofl:ubuntu
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
