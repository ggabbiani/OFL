include $(FUNCTIONS)

# .PHONY: 800x600 artifacts foundation vitamins

top:
	@$(MAKE) -C $(realpath ..) docs/all

all: 800x600/all architecture.png artifacts/all foundation/all vitamins/all

800x600/%:
	$(call make_sub,800x600,"OFL/docs")

architecture.png: architecture.drawio
	@drawio --export --format png --border 10 --output $(CURDIR)/$@ $<
	@echo -n "$(CURDIR)/$@: "
	@echo -e "\e[32mOK\e[0m"

artifacts/%:
	$(call make_sub,artifacts,"OFL/docs")

foundation/%:
	$(call make_sub,foundation,"OFL/docs")

vitamins/%:
	$(call make_sub,vitamins,"OFL/docs")

clean:
	@rm -f architecture.png
	@$(MAKE) -C 800x600 $@
	@$(MAKE) -C artifacts $@
	@$(MAKE) -C foundation $@
	@$(MAKE) -C vitamins $@
