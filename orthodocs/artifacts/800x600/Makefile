# include *.deps

SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig_joints_front_view.png fig_joints_right_view.png fig_joints_top_view.png \
	fig-TS15_section.png fig-TS35_section.png fig-TS35D_section.png fig-din_rails.png

include $(FUNCTIONS)

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

###############################################################################
# DIN rails sections
fig-TS15_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.28,4.55,24.95,40),ortho)
	$(call target-epilogue-success)

fig-TS35_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.28,4.55,24.95,80),ortho)
	$(call target-epilogue-success)

fig-TS35D_section.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call top-view,-0.28,9.40,24.95,80),ortho)
	$(call target-epilogue-success)

fig-din_rails.png: $(call test-deps,artifacts/din_rails)
	$(call target-prologue)
	$(call make-picture,$(SIZE),$(call make-camera,38,7.5,25,50.10,0,19.40,200),,--render)
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
