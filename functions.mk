# call $(MAKE) using the first target level as destination directory, the rest
# (without first level) is used as new target
define make_sub
$(MAKE) -C $(firstword $(subst /, ,$@)) $(patsubst $(firstword $(subst /, ,$@))/%,%,$@)
endef

COLOR_BOLD_WHITE=\e[1;37m
COLOR_YELLOW	=\e[0;33m
COLOR_GREEN		=\e[1;32m
COLOR_RESET		=\e[0m

define section-prologue
printf ">>>>$(COLOR_BOLD_WHITE)$(if $(1),$(1),$(CURDIR))$(COLOR_RESET) start...\n"
endef

define section-epilogue
printf "$(COLOR_BOLD_WHITE)$(1)$(COLOR_RESET)...end <<<<\n"
endef

define target-prologue
printf "$(COLOR_YELLOW)$(relative-dir)/$@$(COLOR_RESET): "
endef

define target-epilogue
printf "$(if $(1),$(COLOR_GREEN)$(1)$(COLOR_RESET))\n"
endef

define target-epilogue-success
$(call target-epilogue,✔)
endef

define target-epilogue-created
$(call target-epilogue,created)
endef

define target-epilogue-ok
$(call target-epilogue,OK)
endef

define linux-distro
$(shell . /etc/os-release && echo -n $${ID})
endef

define aggregate-prologue
printf "$(COLOR_BOLD_WHITE)$(call relative-dir) $@$(COLOR_RESET): "
endef

define aggregate-epilogue
$(call target-epilogue,[✔])
endef

# returns CURDIR relative to PRJ_ROOT
define relative-dir
$(subst $(PRJ_ROOT)/,,$(CURDIR))
endef

define is-win
$(findstring Windows_NT,$(OS))
endef

define is-linux
$(findstring Linux,$(shell uname -s))
endef

define is-mac
$(findstring Darwin,$(shell uname -s))
endef

# returns 'Windows_NT','Linux' or 'Darwin' according to the underlying
# operating system.
define os
$(if $(call is-win),Windows_NT,$(if $(call is-linux),Linux,$(if $(call is-mac),Darwin,$(error unsupported operating system))))
endef

define which
$(if $(call is-win),where,which)
endef

define scad-path
$(if $(call is-mac),$(shell mdfind "kMDItemCFBundleIdentifier == 'org.openscad.OpenSCAD'"),$(shell $(call which) openscad))
endef

# produce the current target picture from
# $(1)=target resolution in 'openscad' format i.e. 800x600
# $(2)=camera view settings
# $(3)=projection type ('ortho' or 'perspective')
define make-picture
$(let \
	hires,$(shell echo $$(( $(word 1,$(subst x, ,$(1))) * 8 ))$(comma)$$(( $(word 2,$(subst x, ,$(1))) * 8 ))), \
	$(SCAD) --hardwarnings --imgsize $(hires) -o unscaled-$@ -d $(@:.png=.deps) --p $(<:.scad=.json) --P $(@:.png=) $(if $(2),--camera $(2)) $(if $(3),--projection $(3)) --ofl-script $< \
	&& convert unscaled-$@ -resize $(1) $@ \
	&& rm unscaled-$@
)
endef
