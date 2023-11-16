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
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	@$(DEPS) --vitamins
	@echo -e "\e[32mOK\e[0m"

clean:
	@rm -f dependencies.svg
