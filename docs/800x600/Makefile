# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps) $(FUNCTIONS)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE	:= $(notdir $(CURDIR))

top:
	@$(MAKE) -C $(realpath ../..) docs/800x600/all

all:	cover.png

cover.png: $(EXAMPLES)/sbc-box.scad $(EXAMPLES)/sbc-box.json
	$(call target-prologue)
	$(call check-picture,$(SIZE),$(call make-camera,7.62939e-7,0,11.925,68.3,0,320.5,281.12),,--view axes)
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
