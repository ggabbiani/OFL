include $(FUNCTIONS)

.DEFAULT_GOAL := help

all: 256x256/all 800x600/all

256x256/%:
	$(call make_sub)

800x600/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@
	@$(MAKE) -C 800x600 $@

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
