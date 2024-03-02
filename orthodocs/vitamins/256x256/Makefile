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
	@printf "\e[33m$(CURDIR)/$@\e[0m: "
	@$(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ --p iecs.json --P $(@:.png=) $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@printf "\e[32mOK\e[0m\n"

%.png: %.scad
	@printf "\e[33m$(CURDIR)/$@\e[0m: "
	@$(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@printf "\e[32mOK\e[0m\n"

clean:
	@rm -f *.png *.deps
