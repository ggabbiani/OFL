# test execution
%.echo : %.scad
	@source $(realpath $*.conf) && $(OSCAD) $${CAMERA} -o $*.echo $*.scad
	@echo " TESTED"

# source creation
%.scad : %.base %.conf $(TEMPLATE) $(DEF_CONFS)
	@echo -n "$@:"
	@((set -a && source $(DEF_CONFS) && source $(realpath $*.conf) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@
	@echo -n " CREATED"
