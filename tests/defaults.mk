# test execution
# the optional «name».json parameter file is a prerequisite too: editing its
# TEST_CASE parameter sets must trigger a new run
.SECONDEXPANSION:

error%-test.echo : error%-test.scad $$(wildcard $$(basename $$@).json)
	$(call target-prologue)
	$(BIN)/make-test.py --must-fail $(<:.scad=)
	$(call target-epilogue)

warn%-test.echo : warn%-test.scad $$(wildcard $$(basename $$@).json)
	$(call target-prologue)
	$(BIN)/make-test.py --must-fail $(<:.scad=)
	$(call target-epilogue)

%.echo : %.scad $$(wildcard $$*.json)
	$(call target-prologue)
	$(BIN)/make-test.py $*
	$(call target-epilogue)

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	$(call target-prologue)
	(set -a && . $(DEF_CONFS) && . $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	$(call target-epilogue,created)

# shows the effective values of the variables used by the test template
# (tests/defaults.conf + «name»-test.conf): nothing is written
%.vars : %.conf $(DEF_CONFS)
	(set -a && . $(DEF_CONFS) && . $(realpath $*.conf) && \
	for v in $$(grep -o '\$${[A-Za-z_][A-Za-z0-9_]*}' $(TEMPLATE_DIR)/$${TEST_TEMPLATE} | tr -d '$${}' | awk '!seen[$$0]++') ; do \
		printf '\033[0;33m#### %s\033[0m\n%s\n\n' "$$v" "$${!v}" ; \
	done)
