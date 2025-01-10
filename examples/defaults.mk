# example execution (actually unused, we use picture test in place of)
%.echo		: %.scad
	$(call target-prologue)
	$(SCAD) --hardwarnings -o $*.echo --ofl-script $<
	$(call target-epilogue-success)

# example tests performed through image structure test
pic-%.png	: %.scad %.json
	$(call target-prologue)
	$(call check-picture,800x600,,,--view axes)
	$(call target-epilogue-success)
