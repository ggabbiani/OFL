# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

.PHONY: all

all: dependencies.svg
	@$(MAKE) -C 800x600 $@

dependencies.svg: $(FOUNDATION_SOURCES)
	@echo -n "$(CURDIR)/$@: "
	@$(DEPS) --foundation
	@echo -e "\e[32mOK\e[0m"

clean:
	@$(MAKE) -C 800x600 $@
	@rm -f dependencies.svg
