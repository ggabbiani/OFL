POD_RUN			= podman run -v $(PRJ_ROOT):/import:Z -it --rm
FEDORA_MAKE		= $(POD_RUN) ofl:fedora
UBUNTU_RUN		= $(POD_RUN) ofl:ubuntu

POD_BUILD		= podman build
FEDORA_BUILD	= $(POD_BUILD) -t ofl:fedora
UBUNTU_BUILD	= $(POD_BUILD) -t ofl:ubuntu

# .PHONY: fedora fedora-build

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

clean:
	$(call aggregate-prologue)
	podman rmi --ignore ofl:fedora ofl:ubuntu
	$(call aggregate-epilogue)

ubuntu-build:
	$(call section-prologue,$@)
	cd $(word 1,$(subst -, ,$@)) && $(UBUNTU_BUILD) .
	$(call section-epilogue,$@)

docs: fedora-docs ubuntu-docs

fedora-docs: fedora-build
	$(call target-prologue)
	@$(FEDORA_MAKE) docs/all
	$(call target-epilogue-success)

ubuntu-docs:  ubuntu-build
	$(call section-prologue,$@)
	@$(POD_RUN) ofl:ubuntu docs/all
	$(call section-epilogue,$@)

orthodocs: fedora-orthodocs ubuntu-orthodocs

fedora-orthodocs: fedora-build
	$(call target-prologue)
	@$(FEDORA_MAKE) orthodocs/all
	$(call target-epilogue-success)

ubuntu-orthodocs:  ubuntu-build
	$(call section-prologue,$@)
	@$(POD_RUN) ofl:ubuntu orthodocs/all
	$(call section-epilogue,$@)

ubuntu-tests: ubuntu-build
	$(call section-prologue,$@)
	@$(UBUNTU_RUN) tests/runs
	$(call section-epilogue,$@)
