# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_2d_frame.png

top:
	@$(MAKE) -C $(realpath ../../..) orthodocs/foundation/256x256/all

include $(FUNCTIONS)

all: $(TARGETS)

fig_2d_frame.png: $(TESTS)/foundation/square-test.scad
	$(call target-prologue)
	@source $(TESTS)/foundation/square-test.conf && $(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ --p $(TESTS)/foundation/square-test.json --P $(@:.png=) $$CAMERA $$PROJECTION --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

%.png: %.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
