# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

all:
	@$(MAKE) -C 800x600 $@
	@$(MAKE) -C 256x256 $@

clean:
	@$(MAKE) -C 800x600 $@
	@$(MAKE) -C 256x256 $@
