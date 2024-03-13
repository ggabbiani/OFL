# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png) fig_2d_frame.png

top:
	@$(MAKE) -C $(realpath ../../..) orthodocs/foundation/256x256/all

include $(FUNCTIONS)

all: $(TARGETS)

fig_2d_frame.png: $(TESTS)/foundation/square-test.scad
	$(info $$CAMERA is [${CAMERA}])
	@printf "\e[33m$(CURDIR)/$@\e[0m: "
	@source $(TESTS)/foundation/square-test.conf && $(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ --p $(TESTS)/foundation/square-test.json --P $(@:.png=) $$CAMERA $$PROJECTION $<
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
