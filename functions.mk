# call $(MAKE) using the first target level as destination directory, the rest
# (without first level) is used as new target
define make_sub
	$(MAKE) -C $(firstword $(subst /, ,$@)) $(patsubst $(firstword $(subst /, ,$@))/%,%,$@)
endef
