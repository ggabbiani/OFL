top:
	@$(MAKE) -C $(realpath ../..) orthodocs/foundation/all

all: 256x256/all

256x256/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@
