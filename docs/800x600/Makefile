# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps) $(FUNCTIONS)

.DEFAULT_GOAL := help

SIZE	:= $(notdir $(CURDIR))

all:	cover.png	## make pictures (currently just the project cover)

cover.png: $(EXAMPLES)/sbc-box.scad $(EXAMPLES)/sbc-box.json
	$(call target-prologue)
	$(call check-picture,$(SIZE),$(call make-camera,7.62939e-7,0,11.925,68.3,0,320.5,281.12),,--view axes)
	$(call target-epilogue-success)

clean:	## pictures cleanup
	@rm -f *.png *.deps

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
