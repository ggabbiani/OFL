# test execution
%.echo : %.scad
	@source $(realpath $*.conf) && $(OSCAD) $${CAMERA} -o $*.echo $<

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	@echo $@
	@(set -a && source $(DEF_CONFS) && source $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
