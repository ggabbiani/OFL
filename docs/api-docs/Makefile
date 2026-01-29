# ODOX		:= orthodocs --verbosity error
# ODOX		:= orthodocs --verbosity off
ODOX		:= orthodocs
# ODOX		:= orthodocs --verbosity debug
# ODOX		:= orthodocs --verbosity warn
DOC_ROOT	:= $(CURDIR)

# .PHONY: pics

include $(FUNCTIONS)

.DEFAULT_GOAL := help

all: orthodocs artifacts/all foundation/all vitamins/all	## extracts api documentation from sources

orthodocs: $(LIB_SOURCES)	## run orthodocs
	$(call target-prologue)
	$(ODOX) --src-root $(LIB_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . $(LIB_DIRS) -- $(LIB_DIRS) dxf.scad library.scad
	touch $@
	$(call target-epilogue-success)

artifacts/%:	## extracts artifacts api documentation from sources
	$(call make_sub)

foundation/%:	## extracts foundation api documentation from sources
	$(call make_sub)

vitamins/%:		## extracts vitamins api documentation from sources
	$(call make_sub)

clean: artifacts/clean foundation/clean vitamins/clean	## clean api documentation
	@rm -f *.md
	@rm -f orthodocs

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
