# test execution
%.echo : %.scad
	$(call target-prologue)
	@. $(realpath $*.conf) && $(BIN)/make-test.py $$CAMERA $*
	$(call target-epilogue)

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	$(call target-prologue)
	@(set -a && . $(DEF_CONFS) && . $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	$(call target-epilogue,created)
