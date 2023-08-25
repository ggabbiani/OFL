# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE		:= $(notdir $(CURDIR))

all:	cover.png

cover.png: $(EXAMPLES)/sbc-box.scad $(EXAMPLES)/sbc-box.json
	@$(SCAD) --imgsize 3200,2400 -d $(@:.png=.deps) --p $(EXAMPLES)/sbc-box.json --P cover --camera="7.62939e-7,0,11.925,68.3,0,140.5,281.12" -o unscaled-$@ $(EXAMPLES)/sbc-box.scad
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm -f unscaled-$@

clean:
	@rm -f *.png *.deps
