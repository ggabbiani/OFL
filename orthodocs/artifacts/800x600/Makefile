# include *.deps

SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig_joints_front_view.png fig_joints_right_view.png fig_joints_top_view.png
front_view	:= 0$(COMMA)1.51$(COMMA)-1.91$(COMMA)90$(COMMA)0$(COMMA)0$(COMMA)31.23
right_view	:= 0$(COMMA)1.51$(COMMA)-1.91$(COMMA)90$(COMMA)0$(COMMA)90$(COMMA)31.23
top_view	:= 0$(COMMA)1.51$(COMMA)-1.91$(COMMA)0$(COMMA)0$(COMMA)0$(COMMA)31.23

include $(FUNCTIONS)

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

fig_joints_front_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(front_view),ortho)
	$(call target-epilogue-success)

fig_joints_right_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(right_view),ortho)
	$(call target-epilogue-success)

fig_joints_top_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(top_view),ortho)
	$(call target-epilogue-success)
