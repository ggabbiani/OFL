# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard fig_*.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_FL_IEC_FUSED_INLET.png fig_FL_IEC_FUSED_INLET2.png \
fig_FL_IEC_320_C14_SWITCHED_FUSED_INLET.png fig_FL_IEC_INLET.png fig_FL_IEC_INLET_ATX.png \
fig_FL_IEC_INLET_ATX2.png fig_FL_IEC_YUNPEN.png fig_FL_IEC_OUTLET.png

# $(info $$SOURCES is [${SOURCES}])
# $(info $$TARGETS is [${TARGETS}])

top:
	@$(MAKE) -C $(realpath ../../..) orthodocs/vitamins/256x256/all

include $(FUNCTIONS)

all: $(TARGETS)

fig_FL_IEC_%.png: iecs.scad iecs.json
	$(call target-prologue)
	$(call make-picture,$(SIZE))
	$(call target-epilogue-success)

clean:
	@rm -f *.png *.deps
