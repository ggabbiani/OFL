# call $(MAKE) using the first target level as destination directory, the rest
# (without first level) is used as new target
define make_sub
$(MAKE) -C $(firstword $(subst /, ,$@)) $(patsubst $(firstword $(subst /, ,$@))/%,%,$@)
endef

COLOR_BOLD_WHITE=\e[1;37m
COLOR_YELLOW	=\e[0;33m
COLOR_RED		=\e[1;31m
COLOR_GREEN		=\e[1;32m
COLOR_RESET		=\e[0m

define color
$(shell printf "$(1)")
endef

define msg-info
$(info $(call color,$(COLOR_GREEN))[*INF*] $(1)$(call color,$(COLOR_RESET)))
endef

define msg-warn
$(warn $(call color,$(COLOR_YELLOW))[*WRN*]$(1)$(call color,$(COLOR_RESET)))
endef

define msg-error
$(error $(call color,$(COLOR_RED))[*ERR*]$(1)$(call color,$(COLOR_RESET)))
endef

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

# when passing openscad multiple '-o' parameters, the dependency file is
# targeted to the last of them that could be a temporary. This macro changes the
# target to $@
define fix-target-dependencies
sed '1s|.*:|$@:|' --in-place $@.deps
endef

# if $(1) contains 'similarity' executes $(2), otherwise executes 'true'
# define if-similarity
# 	$(if $(findstring similarity,$(1)),$(2),$(3))
# endef

# rename target if exists
# define backup-target
# 	test ! -e $@ || mv -f $@ $@.orig
# endef

# makes target and check for exact structural similarity to the git committed
# one.
# if similar keeps the original otherwise keeps new and rise an error
# $(1)=target resolution in 'openscad' format i.e. 800x600
# $(2)=camera view settings
# $(3)=projection type ('ortho' or 'perspective')
# $(4)=other parameter(s)
define check-picture
	$(BIN)/make-picture.py --resolution $(1) $(if $(2),--camera=$(2)) $(if $(3),--projection=$(3)) --ofl-script $< --make-deps $@.deps $(4) $@
	$(IMCMD) unscaled-$@ -resize $(1) new-$@ &>/dev/null
	rm unscaled-$@
	git checkout -- $@
	($(IMG_DIFF) $@ new-$@ && rm new-$@) || (mv new-$@ $@ && false)
	$(call fix-target-dependencies)
endef

# makes target and check for exact structural similarity to the git committed one
# if similar keeps the original otherwise keeps the new
# $(1)=target resolution in 'openscad' format i.e. 800x600
# $(2)=camera view settings
# $(3)=projection type ('ortho' or 'perspective')
# $(4)=other parameter(s)
define make-picture
	$(BIN)/make-picture.py --resolution $(1) $(if $(2),--camera=$(2)) $(if $(3),--projection=$(3)) --ofl-script $< --make-deps $@.deps $(4) $@
	$(IMCMD) unscaled-$@ -resize $(1) new-$@ &>/dev/null
	rm -f unscaled-$@
	git checkout -- $@
	($(IMG_DIFF) -v 0 $@ new-$@ && rm new-$@) || mv new-$@ $@
	$(call fix-target-dependencies)
endef

define make-camera
$(1)$(COMMA)$(2)$(COMMA)$(3)$(COMMA)$(4)$(COMMA)$(5)$(COMMA)$(6)$(COMMA)$(7)
endef

# creates OpenSCAD camera settings for the front view
# $(1),$(2),$(3) translations
# $(4) distance
define front-view
$(call make-camera,$(1),$(2),$(3),90,0,0,$(4))
endef

# creates OpenSCAD camera settings for the front view
# $(1),$(2),$(3) translations
# $(4) distance
define right-view
$(call make-camera,$(1),$(2),$(3),90,0,90,$(4))
endef

# creates OpenSCAD camera settings for the front view
# $(1),$(2),$(3) translations
# $(4) distance
define top-view
$(call make-camera,$(1),$(2),$(3),0,0,0,$(4))
endef

# returns the scad, conf and json full path for the provided test type/name
# $(1) : <artifacts|foundation|vitamins>/<test esoteric name>
define test-deps
$(TESTS)/$(1)-test.scad $(TESTS)/$(1)-test.json
endef

define wget
$(shell $(call which) $(if $(call is-mac),curl,wget)) $(if $(call is-mac),$(1) -o $(2),-O $(2) $(1)) &>/dev/null
endef
