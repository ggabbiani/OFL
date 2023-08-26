# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# get desired image sizes from current directory name
SIZE		:= $(notdir $(CURDIR))
SOURCES 	:= $(wildcard *.scad)
TARGETS		:= $(SOURCES:.scad=.png)

all: $(TARGETS)

%.png: %.scad
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	@$(SCAD) --imgsize 9600,9600 -d $(@:.png=.deps) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

clean:
	@rm -f *.png *.deps