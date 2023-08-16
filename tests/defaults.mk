# test execution
%.echo : %.scad
	@source $(realpath $*.conf) && $(OSCAD) $${CAMERA} -o $*.echo $*.scad
	@echo " OK"

# source creation
%.scad : %.base %.conf $(TEMPLATES) $(DEF_CONFS)
	@echo -n "$@:"
	@((set -a && source $(DEF_CONFS) && source $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) && cat $(@:.scad=.base)) >$@
	@echo -n " CREATED"
