# include *.deps

SIZE		:= $(notdir $(CURDIR))
CURR_BASE	:= $(notdir $(CURDIR:/$(SIZE)=))
PICTURES	:= fig-FL_TSP_E1515.png fig-FL_TSP_E2020.png fig-FL_TSP_E2020t.png fig-FL_TSP_E2040.png fig-FL_TSP_E2060.png fig-FL_TSP_E2080.png fig-FL_TSP_E3030.png fig-FL_TSP_E3060.png fig-FL_TSP_E4040.png fig-FL_TSP_E4040t.png fig-FL_TSP_E4080.png
CMD			:= $(SCAD) --hardwarnings --imgsize $(subst x,$(COMMA),$(SIZE)) --projection ortho --camera=0,0,0,0,0,0,200 --viewall

top:
	@$(MAKE) -C $(realpath ../../..) orthodocs/artifacts/256x256/all

include $(FUNCTIONS)

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

fig-FL_TSP_E1515.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E2020.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E2020t.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E2040.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E2060.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E2080.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E3030.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E3060.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E4040.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E4040t.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)

fig-FL_TSP_E4080.png: $(TESTS)/$(CURR_BASE)/tprofiles-test.scad $(TESTS)/$(CURR_BASE)/tprofiles-test.json
	$(call target-prologue)
	$(CMD)  -d $(@:.png=.deps) --p $(word 2,$^) --P $(@:.png=) -o $@ --ofl-script $<
	$(call target-epilogue-success)
