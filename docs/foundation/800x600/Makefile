# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE		:= $(notdir $(CURDIR))
FOUNDATION	:= $(LIB_ROOT)/foundation
PICTURES	:= pic-0.png pic-1.png pic-2.png pic-3.png pic-4.png pic-5.png pic-6.png pic-7.png pic-8.png pic-9.png torus.png

include $(FUNCTIONS)

# include $(pics:.png=.deps)

top:
	@$(MAKE) -C $(realpath ../../..) docs/foundation/800x600/all

all:	$(PICTURES)

clean:
	@rm -f *.png *.deps

pic-0.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-1.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-2.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-3.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-4.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-5.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-6.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json $(LIB_ROOT)/vitamins/magnets.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-7.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json $(LIB_ROOT)/vitamins/spdts.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-8.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json $(LIB_ROOT)/vitamins/spdts.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

pic-9.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json $(LIB_ROOT)/vitamins/spdts.scad
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)

torus.png: $(LIB_ROOT)/vitamins/spdts.scad $(TESTS)/foundation/torus-test.scad $(TESTS)/foundation/torus-test.json
	$(call target-prologue)
	@$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ --ofl-script $<
	@$(IMCMD) unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	$(call target-epilogue-success)
