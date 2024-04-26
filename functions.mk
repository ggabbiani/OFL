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

define _win_
$(findstring Windows_NT,$(OS))
endef

define _linux_
$(findstring Linux,$(shell uname -s))
endef

define _mac_
$(findstring Darwin,$(shell uname -s))
endef

# returns 'Windows_NT','Linux' or 'Darwin' according to the underlying
# operating system.
define os
$(if $(call _win_),Windows_NT,$(if $(call _linux_),Linux,$(if $(call _mac_),Darwin)))
endef
