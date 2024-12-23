# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps) $(FUNCTIONS)
SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig_joints_front_view.png fig_joints_right_view.png fig_joints_top_view.png \
	fig-TS15_section.png fig-TS35_section.png fig-TS35D_section.png fig-din_rails.png \
	fig_tnut_right_view.png fig_tnut_top_view.png

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

###############################################################################
# DIN rails sections
fig-TS15_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.28,-0.95,0,40),ortho)
	$(call target-epilogue-success)

fig-TS35_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.28,-1.95,0,80),ortho)
	$(call target-epilogue-success)

fig-TS35D_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.44,-4.8,0,80),ortho)
	$(call target-epilogue-success)

fig-din_rails.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call make-camera,38,-7.5,25,55,0,25,200),,--render)
	$(call target-epilogue-success)

###############################################################################
# joints projection views
fig_joints_front_view.png: $(call test-deps,artifacts/joints)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call front-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)

fig_joints_right_view.png: $(call test-deps,artifacts/joints)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call right-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)

fig_joints_top_view.png: $(call test-deps,artifacts/joints)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,0,1.51,-1.91,31.23),ortho)
	$(call target-epilogue-success)

###############################################################################
# tnuts projection views
fig_tnut_top_view.png: $(call test-deps,artifacts/tnut)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,0,-0.11,6.48,26.39),ortho)
	$(call target-epilogue-success)

fig_tnut_right_view.png: $(call test-deps,artifacts/tnut)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call right-view,0,0.05,6.65,49.99),ortho)
	$(call target-epilogue-success)
