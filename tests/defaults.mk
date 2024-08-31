# test execution
error%-test.echo : error%-test.scad
	$(call target-prologue)
	@. $(realpath $(@:.echo=.conf)) && $(BIN)/assert.py fail $(BIN)/make-test.py $$CAMERA $(<:.scad=)
	$(call target-epilogue)

warn%-test.echo : warn%-test.scad
	$(call target-prologue)
	@. $(realpath $(@:.echo=.conf)) && $(BIN)/assert.py fail $(BIN)/make-test.py $$CAMERA $(<:.scad=)
	$(call target-epilogue)

%.echo : %.scad
	$(call target-prologue)
	@. $(realpath $*.conf) && $(BIN)/make-test.py --verbosity 4 $$CAMERA $*
	$(call target-epilogue)

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	$(call target-prologue)
	@(set -a && . $(DEF_CONFS) && . $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	$(call target-epilogue,created)
