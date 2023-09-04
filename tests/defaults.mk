# test execution
%.echo : %.scad
	@source $(realpath $*.conf) && $(OSCAD) $${CAMERA} -o $*.echo $<

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	@echo -n -e "\e[33m$@\e[0m: "
	@(set -a && source $(DEF_CONFS) && source $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	@echo -e "\e[32mOK\e[0m"
