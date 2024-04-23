# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

# .PHONY: all

include $(FUNCTIONS)

top:
	@$(MAKE) -C $(realpath ../..) docs/artifacts/all

all: dependencies.svg

dependencies.svg: $(ARTIFACTS_SOURCES)
	$(call target-prologue)
	@$(DEPS) --artifacts
	$(call target-epilogue-success)

clean:
	@rm -f dependencies.svg
