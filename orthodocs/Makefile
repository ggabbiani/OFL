# ODOX		:= orthodocs --verbosity error
ODOX		:= orthodocs --verbosity off
# ODOX		:= orthodocs
# ODOX		:= orthodocs --verbosity debug
DOC_ROOT	:= $(CURDIR)

# .PHONY: pics

top:
	@$(MAKE) -C $(realpath ..) orthodocs/all

include $(FUNCTIONS)

all: api-docs artifacts/all foundation/all vitamins/all

api-docs: $(LIB_SOURCES)
	$(call target-prologue)
	@$(ODOX) --src-root $(LIB_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . $(LIB_DIRS) -- $(LIB_DIRS) dxf.scad library.scad
	@touch $@
	$(call target-epilogue-success)

artifacts/%:
	$(call make_sub)

foundation/%:
	$(call make_sub)

vitamins/%:
	$(call make_sub)

clean: artifacts/clean foundation/clean vitamins/clean
	@rm -f *.md
	@rm -f api-docs
