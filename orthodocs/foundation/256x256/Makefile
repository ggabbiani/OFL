# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_2d_frame.png \
fig_3d_cylinder_defaults.png fig_3d_cube_defaults.png fig_3d_prism_defaults.png \
fig_3d_sphere_defaults.png fig_3d_pyramid_defaults.png

include $(FUNCTIONS)

all: $(TARGETS)

fig_3d_pyramid_defaults.png: $(call test-deps,foundation/3d)
	$(call target-prologue)
	$(call make-picture,$(SIZE),,,--view axes)
	$(call target-epilogue-success)

fig_3d_sphere_defaults.png: $(call test-deps,foundation/3d)
	$(call target-prologue)
	$(call make-picture,$(SIZE),,,--view axes)
	$(call target-epilogue-success)

fig_3d_prism_defaults.png: $(call test-deps,foundation/3d)
	$(call target-prologue)
	$(call make-picture,$(SIZE),,,--view axes)
	$(call target-epilogue-success)

fig_3d_cube_defaults.png: $(call test-deps,foundation/3d)
	$(call target-prologue)
	$(call make-picture,$(SIZE),,,--view axes)
	$(call target-epilogue-success)

fig_3d_cylinder_defaults.png: $(call test-deps,foundation/3d)
	$(call target-prologue)
	$(call make-picture,$(SIZE),,,--view axes)
	$(call target-epilogue-success)

fig_2d_frame.png: $(call test-deps,foundation/square)
	$(call target-prologue)
	source $(TESTS)/foundation/square-test.conf && \
	$(call make-picture,$(SIZE),,,$$CAMERA $$PROJECTION)
	$(call target-epilogue-success)

%.png: %.scad
	$(call target-prologue)
	$(call make-picture,$(SIZE))
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
