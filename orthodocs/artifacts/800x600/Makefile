# include *.deps

SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig_joints_front_view.png fig_joints_right_view.png fig_joints_top_view.png
comma		:= ,
front_view	:= 0$(comma)1.51$(comma)-1.91$(comma)90$(comma)0$(comma)0$(comma)31.23
right_view	:= 0$(comma)1.51$(comma)-1.91$(comma)90$(comma)0$(comma)90$(comma)31.23
top_view	:= 0$(comma)1.51$(comma)-1.91$(comma)0$(comma)0$(comma)0$(comma)31.23

define make-picture
$(SCAD) --hardwarnings --imgsize "6400,4800" -o unscaled-$@ -d $(@:.png=.deps) --p $(<:.scad=.json) --P $(@:.png=) --camera $(2) --projection $(3) --ofl-script $<; \
convert unscaled-$@ -resize $(SIZE) $@;
rm unscaled-$@;
endef

include $(FUNCTIONS)

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

fig_joints_front_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,9600,$(front_view),ortho)
	$(call target-epilogue-success)

fig_joints_right_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,9600,$(right_view),ortho)
	$(call target-epilogue-success)

fig_joints_top_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,9600,$(top_view),ortho)
	$(call target-epilogue-success)
