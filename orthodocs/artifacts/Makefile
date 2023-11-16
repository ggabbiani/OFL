top:
	@$(MAKE) -C $(realpath ../..) orthodocs/artifacts/all

include $(FUNCTIONS)

all: 256x256/all

256x256/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@
