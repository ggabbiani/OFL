# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

# .PHONY: all

include $(FUNCTIONS)

top:
	@$(MAKE) -C $(realpath ../..) docs/vitamins/all

all: dependencies.svg

dependencies.svg: $(VITAMINS_SOURCES)
	$(call target-prologue)
	@$(DEPS) --vitamins
	$(call target-epilogue-success)

clean:
	@rm -f dependencies.svg
