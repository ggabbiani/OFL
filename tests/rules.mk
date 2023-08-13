# test execution
%.echo : %.scad
	@echo "testing $*.scad"
	@$(OSCAD) -o $*.echo $*.scad


