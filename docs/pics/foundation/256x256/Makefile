# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
DIR 	= $(subst x, ,$(notdir $(CURDIR)))
SIZE	= $(word 1,$(DIR)),$(word 2,$(DIR))

%.png: %.scad
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -m make -o $@ --imgsize $(SIZE) -d $@.deps --view axes $<

%.scad:
	@echo "include <OFL/library.scad>" >$@
	@echo "__$(basename $@)__();" >>$@

all: fig_Supported_walls.png fig_Unsupported_walls.png fig_Support_and_overhangs.png

clean:
	rm *.png *.deps *.scad