.PHONY: 800x600 foundation

all: 800x600 architecture.png foundation

800x600:
	@$(MAKE) -C $@

architecture.png: architecture.drawio
	@drawio --export --format png --output $(CURDIR)/$@ $<

foundation:
	@$(MAKE) -C $@

clean:
	@rm -f architecture.png
