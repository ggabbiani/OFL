# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps) $(FUNCTIONS)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE	:= $(notdir $(CURDIR))
# .PHONY	:= all

top:
	@$(MAKE) -C $(realpath ../..) docs/800x600/all

all:	cover.png

cover.png: $(EXAMPLES)/sbc-box.scad $(EXAMPLES)/sbc-box.json
	@printf "$(CURDIR)/$@: "
	@$(SCAD) --imgsize 3200,2400 --p $(EXAMPLES)/sbc-box.json --P cover --camera="7.62939e-7,0,11.925,68.3,0,320.5,281.12" -o /tmp/unscaled-$@ $(EXAMPLES)/sbc-box.scad
	@convert /tmp/unscaled-$@ -resize $(SIZE) $@
	@rm -f /tmp/unscaled-$@
	@printf "\e[32mOK\e[0m\n"

clean:
	@rm -f *.png *.deps
