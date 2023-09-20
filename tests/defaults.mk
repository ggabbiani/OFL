# test execution
%.echo : %.scad
	@source $(realpath $*.conf) && $(BIN)/make-test.sh $$CAMERA --silent $*

# source creation
%.scad : %.conf $(TEMPLATES) $(DEF_CONFS)
	@echo -n -e "\e[33m$@\e[0m: "
	@(set -a && source $(DEF_CONFS) && source $(realpath $*.conf) && envsubst <$(TEMPLATE_DIR)/$${TEST_TEMPLATE}) >$@
	@echo -e "\e[32mcreated\e[0m"
