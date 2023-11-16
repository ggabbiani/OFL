# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

# .PHONY: all

include $(FUNCTIONS)

top:
	@$(MAKE) -C $(realpath ../..) docs/foundation/all

all: dependencies.svg 800x600/all

dependencies.svg: $(FOUNDATION_SOURCES)
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	@$(DEPS) --foundation
	@echo -e "\e[32mOK\e[0m"

800x600/%:
	$(call make_sub,800x600,"OFL/docs/foundation")

clean:
	@$(MAKE) -C 800x600 $@
	@rm -f dependencies.svg
