# include *.deps

SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig_joints_front_view.png fig_joints_right_view.png fig_joints_top_view.png \
	fig-TS15_section.png fig-TS35_section.png fig-TS35D_section.png

include $(FUNCTIONS)

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

###############################################################################
# din rails sections
fig-TS15_section.png: $(TESTS)/artifacts/din_rails-test.scad $(TESTS)/artifacts/din_rails-test.json
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call make-camera,-0.28,4.55,24.95,0,0,0,40),ortho)
	$(call target-epilogue-success)

fig-TS35_section.png: $(TESTS)/artifacts/din_rails-test.scad $(TESTS)/artifacts/din_rails-test.json
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call make-camera,-0.28,4.55,24.95,0,0,0,80),ortho)
	$(call target-epilogue-success)

fig-TS35D_section.png: $(TESTS)/artifacts/din_rails-test.scad $(TESTS)/artifacts/din_rails-test.json
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call make-camera,-0.28,9.40,24.95,0,0,0,80),ortho)
	$(call target-epilogue-success)

###############################################################################
# joints projection views
fig_joints_front_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call front-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)

fig_joints_right_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call right-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)

fig_joints_top_view.png: $(TESTS)/artifacts/joints-test.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)
