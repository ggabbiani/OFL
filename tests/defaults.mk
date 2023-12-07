# test execution
%.echo : %.scad
	@. $(realpath $*.conf) && $(BIN)/make-test.py $$CAMERA $*

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	@printf "\e[33m$@\e[0m: "
	@(set -a && . $(DEF_CONFS) && . $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	@printf "\e[32mcreated\e[0m\n"
