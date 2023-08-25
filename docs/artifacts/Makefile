# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

.PHONY: all

all: dependencies.svg

dependencies.svg: $(ARTIFACTS_SOURCES)
	@$(DEPS) --artifacts

clean:
	@rm -f dependencies.svg
