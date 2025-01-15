# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard fig_*.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_FL_IEC_FUSED_INLET.png fig_FL_IEC_FUSED_INLET2.png \
fig_FL_IEC_320_C14_SWITCHED_FUSED_INLET.png fig_FL_IEC_INLET.png fig_FL_IEC_INLET_ATX.png \
fig_FL_IEC_INLET_ATX2.png fig_FL_IEC_YUNPEN.png fig_FL_IEC_OUTLET.png \
fig_jack_barrel_default_cutouts.png fig_jack_barrel_preferred_cutouts.png

include $(FUNCTIONS)

all: $(TARGETS)

fig_jack_barrel_default_cutouts.png: $(call test-deps,vitamins/jack)
	$(call target-prologue)
	$(call check-picture,$(SIZE),$(make-camera 3.2,0,3,68.3,0,44.5,94.2219),,--view axes)
	$(call target-epilogue-success)

fig_jack_barrel_preferred_cutouts.png: $(call test-deps,vitamins/jack)
	$(call target-prologue)
	$(call check-picture,$(SIZE),$(make-camera 3.2,0,3,68.3,0,44.5,94.2219),,--view axes)
	$(call target-epilogue-success)

fig_FL_IEC_%.png: iecs.scad iecs.json
	$(call target-prologue)
	$(call make-picture,$(SIZE))
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
