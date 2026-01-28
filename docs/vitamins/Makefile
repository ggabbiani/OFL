# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

# .PHONY: all

include $(FUNCTIONS)

.DEFAULT_GOAL := help

all: dependencies.svg

dependencies.svg: $(VITAMINS_SOURCES)
	$(call target-prologue)
	@$(DEPS) --vitamins
	$(call target-epilogue-success)

clean:
	@rm -f dependencies.svg

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
