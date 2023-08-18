ODOX		:= orthodocs
DOC_ROOT	:= $(CURDIR)

api-docs: $(LIB_SOURCES)
	$(ODOX) --src-root $(SRC_ROOT) --doc-root $(DOC_ROOT) --admonitions --toc --ignore-prefix fl_ '$$fl_' --pkg-deps graph --graphs . artifacts foundation vitamins -- artifacts foundation vitamins dxf.scad library.scad
	@touch $@