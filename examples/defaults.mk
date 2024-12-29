# example execution
%.echo : %.scad
	$(call target-prologue)
	$(SCAD) --hardwarnings -o $*.echo --ofl-script $<
	$(call target-epilogue-success)
