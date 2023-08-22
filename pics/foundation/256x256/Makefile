# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png)

# .PHONY: all

# all: fig_Supported_walls.png fig_Unsupported_walls.png fig_Support_and_overhangs.png
all: $(TARGETS)

%.png: %.scad
	@$(SCAD) --imgsize 9600,9600 -d $@.deps $<
	@convert $(UNSCALED) -resize $(SIZE) $@
	@rm $(UNSCALED)

# %.scad:
# 	@echo "include <OFL/library.scad>" >$@
# 	@echo "__$(basename $@)__();" >>$@

clean:
	@rm -f *.png *.deps