# test execution
%.echo : %.scad
	@$(OSCAD) -o $*.echo $*.scad
	@echo " TESTED"

# source creation
%.scad : %.base %.conf $(TEMPLATE) $(DEF_CONFS)
	@echo -n "$@:"
	@((set -a && source $(DEF_CONFS) && source ./$(@:.scad=.conf) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@
	@echo -n " CREATED"
