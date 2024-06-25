top:
	@$(MAKE) -C $(realpath ../..) orthodocs/artifacts/all

include $(FUNCTIONS)

all: 256x256/all 800x600/all

256x256/%:
	$(call make_sub)

800x600/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@
