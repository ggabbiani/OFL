# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE		:= $(notdir $(CURDIR))
UNSCALED	:= /tmp/unscaled.png

all:	cover.png torus.png

clean:
	rm *.png *.deps

cover.png: $(EXAMPLES)/rpi4-box.scad $(EXAMPLES)/rpi4-box.json
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -o $(UNSCALED) --imgsize 3200,2400 -d $@.deps --view axes --p $(EXAMPLES)/rpi4-box.json --P cover --camera="7.62939e-7,0,11.925,68.3,0,140.5,281.12" $(EXAMPLES)/rpi4-box.scad
	convert $(UNSCALED) -resize $(SIZE) $@

torus.png: $(TESTS)/foundation/torus-test.scad $(TESTS)/foundation/torus-test.json
	OPENSCADPATH="/home/giampa/projects:${OPENSCADPATH}" openscad -o $(UNSCALED) --imgsize 3200,2400 -d $@.deps --view axes --p $(TESTS)/foundation/torus-test.json --P torus $(TESTS)/foundation/torus-test.scad
	convert $(UNSCALED) -resize $(SIZE) $@
