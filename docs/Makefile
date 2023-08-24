# a do nothing ... for now!

all: architecture.png

clean:
	@rm -f architecture.png

architecture.png: architecture.drawio
	@drawio --export --format png --output $(CURDIR)/$@ $<
