# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

SIZE		:= $(notdir $(CURDIR))

all:	pic-0.png pic-1.png pic-2.png pic-3.png pic-4.png pic-5.png pic-6.png pic-7.png pic-8.png pic-9.png torus.png

clean:
	@rm -f *.png *.deps

pic-0.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-1.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-2.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-3.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-4.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-5.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-6.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-7.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-8.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

pic-9.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@

torus.png: $(TESTS)/foundation/torus-test.scad $(TESTS)/foundation/torus-test.json
	@echo $@
	$(SCAD1) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
