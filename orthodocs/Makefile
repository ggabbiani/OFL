ODOX		:= orthodocs
DOC_ROOT	:= $(CURDIR)

api-docs: $(LIB_SOURCES)
	$(info "Sources: $(LIB_SOURCES)")
	$(ODOX) --src-root $(LIB_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . $(LIB_DIRS) -- $(LIB_DIRS) dxf.scad library.scad
	@touch $@