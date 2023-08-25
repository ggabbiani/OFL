ODOX		:= orthodocs
DOC_ROOT	:= $(CURDIR)

.PHONY: pics

all: api-docs pics

api-docs: $(LIB_SOURCES)
	@$(ODOX) --src-root $(LIB_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . $(LIB_DIRS) -- $(LIB_DIRS) dxf.scad library.scad
	@touch $@

pics:
	@$(MAKE) -C foundation

clean:
	@rm -f *.md
	@rm -f api-docs
	@$(MAKE) -C foundation $@
