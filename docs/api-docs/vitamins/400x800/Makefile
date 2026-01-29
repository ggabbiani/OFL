# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard fig_*.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_SCREW_ASSEMBLED.png

include $(FUNCTIONS)

all: $(TARGETS)

fig_SCREW_ASSEMBLED.png: $(call test-deps,vitamins/screw)
	$(call target-prologue)
	$(call make-native-picture,100x200,$(call right-view,0,0.741555,-3.52199,48.1321),ortho,,$@)
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
