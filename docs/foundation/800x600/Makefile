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

pic-0.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-1.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-2.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-3.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-4.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-5.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-6.png: $(TESTS)/vitamins/magnet-test.scad $(TESTS)/vitamins/magnet-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-7.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-8.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

pic-9.png: $(TESTS)/vitamins/spdt-test.scad $(TESTS)/vitamins/spdt-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"

torus.png: $(TESTS)/foundation/torus-test.scad $(TESTS)/foundation/torus-test.json
	@echo -n -e "\e[33m$(CURDIR)/$@\e[0m: "
	$(SCAD) --imgsize 3200,2400 -d $(patsubst %.png,%.deps,$@) --p $(word 2,$^) --P $(patsubst %.png,%,$@) -o unscaled-$@ $<
	@convert unscaled-$@ -resize $(SIZE) $@
	@rm unscaled-$@
	@echo -e "\e[32mOK\e[0m"
