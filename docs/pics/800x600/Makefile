# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE		:= $(notdir $(CURDIR))
UNSCALED	:= /tmp/unscaled.png

all:	cover.png

# clean:
# 	$(MAKE) -C foundation $@

cover.png: $(EXAMPLES)/rpi4-box.scad $(EXAMPLES)/rpi4-box.json
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -o $(UNSCALED) --imgsize 3200,2400 -d $@.deps --view axes --p $(EXAMPLES)/rpi4-box.json --P cover --camera="7.62939e-7,0,11.925,68.3,0,140.5,281.12" $<
	convert $(UNSCALED) -resize $(SIZE) $@
