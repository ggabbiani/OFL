# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
DIR 		:= $(subst x, ,$(notdir $(CURDIR)))
SIZE		:= $(word 1,$(DIR)),$(word 2,$(DIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png)
UNSCALED	:= /tmp/unscaled.png

# .PHONY: all

# all: fig_Supported_walls.png fig_Unsupported_walls.png fig_Support_and_overhangs.png
all: $(TARGETS)

%.png: %.scad
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -m make -o $(UNSCALED) --imgsize 9600,9600 -d $@.deps --view axes $<
	convert $(UNSCALED) -resize 256x256 $@
	rm $(UNSCALED)

# %.scad:
# 	@echo "include <OFL/library.scad>" >$@
# 	@echo "__$(basename $@)__();" >>$@

clean:
	rm *.png *.deps