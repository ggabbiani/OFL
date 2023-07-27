# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# SIZE	= 48,48
SIZE	= 128,128

%.png: %.scad
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -m make -o $@ --imgsize $(SIZE) -d $@.deps --view axes $<

%.scad:
	@echo "include <OFL/library.scad>" >$@
	@echo "__$(basename $@)__();" >>$@

.PHONY: all clean

all: fig_Supported_walls.png fig_Unsupported_walls.png fig_Support_and_overhangs.png

clean:
	rm *.png *.deps *.scad