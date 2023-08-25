.PHONY: 800x600 artifacts foundation vitamins

all: 800x600 architecture.png artifacts foundation vitamins

800x600:
	@$(MAKE) -C $@

architecture.png: architecture.drawio
	@drawio --export --format png --border 10 --output $(CURDIR)/$@ $<
	@echo -n "$(CURDIR)/$@: "
	@echo -e "\e[32mOK\e[0m"

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
