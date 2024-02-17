ODOX		:= orthodocs
DOC_ROOT	:= $(CURDIR)

# .PHONY: pics

top:
	@$(MAKE) -C $(realpath ..) orthodocs/all

include $(FUNCTIONS)

all: api-docs artifacts/all foundation/all vitamins/all

api-docs: $(LIB_SOURCES)
	@printf "\e[33m$(CURDIR)/$@\e[0m: "
	@$(ODOX) --src-root $(LIB_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . $(LIB_DIRS) -- $(LIB_DIRS) dxf.scad library.scad
	@touch $@
	@printf "\e[32mOK\e[0m\n"

artifacts/%:
	$(call make_sub)

foundation/%:
	$(call make_sub)

vitamins/%:
	$(call make_sub)

clean: artifacts/clean foundation/clean vitamins/clean
	@rm -f *.md
	@rm -f api-docs
