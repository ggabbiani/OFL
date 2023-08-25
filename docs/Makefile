.PHONY: 800x600 artifacts foundation vitamins

all: 800x600 architecture.png artifacts foundation vitamins

800x600:
	@$(MAKE) -C $@

architecture.png: architecture.drawio
	@drawio --export --format png --output $(CURDIR)/$@ $<

artifacts:
	@$(MAKE) -C $@

foundation:
	@$(MAKE) -C $@

vitamins:
	@$(MAKE) -C $@

clean:
	@rm -f architecture.png
	@$(MAKE) -C 800x600 $@
	@$(MAKE) -C artifacts $@
	@$(MAKE) -C foundation $@
	@$(MAKE) -C vitamins $@
