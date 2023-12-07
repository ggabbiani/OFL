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
	@printf "\e[33m$(CURDIR)/$@\e[0m: "
	@$(DEPS) --artifacts
	@printf "\e[32mOK\e[0m\n"

clean:
	@rm -f dependencies.svg
