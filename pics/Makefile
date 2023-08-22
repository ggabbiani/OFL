# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

# SIZE		:= $(notdir $(CURDIR))
UNSCALED	:= /tmp/unscaled.png
SCAD		:= OPENSCADPATH="$(SRC_ROOT):${OPENSCADPATH}" openscad -m make -o $(UNSCALED) --view axes

export SCAD UNSCALED

all:
	@$(MAKE) -C foundation $@
	@$(MAKE) -C 800x600 $@

clean:
	@$(MAKE) -C foundation $@
	@$(MAKE) -C 800x600 $@
