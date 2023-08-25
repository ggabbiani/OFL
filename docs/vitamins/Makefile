# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

.PHONY: all

all: dependencies.svg

dependencies.svg: $(VITAMINS_SOURCES)
	@$(DEPS) --vitamins

clean:
	@rm -f dependencies.svg
