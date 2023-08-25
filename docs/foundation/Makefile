# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

all: 800x600 dependencies.svg

dependencies.svg: $(FOUNDATION_SOURCES)
	$(DEPS) --foundation

800x600:
	@$(MAKE) -C 800x600 $@

clean:
	@$(MAKE) -C 800x600 $@
	rm -f dependencies.svg
