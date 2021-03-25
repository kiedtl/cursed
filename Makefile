all: scrots/sdemo.png scrots/charmap.png

scrots/sdemo.png: font.bdf tools/mkff
	cat shortdemo.txt | tools/draw.lua > $@.ff
	ff2png < $@.ff > $@
	rm -f $@.ff
	pngcrush $@ $@.tmp
	mv $@.tmp $@

scrots/charmap.png: font.bdf tools/mkff
	tools/charmap.lua | tools/draw.lua > $@.ff
	ff2png < $@.ff > $@
	rm -f $@.ff
	pngcrush $@ $@.tmp
	mv $@.tmp $@

tools/mkff: tools/mkff.c

.PHONY: clean
clean:
	rm -f tools/mkff
	rm -f tools/charmap.png
	rm -f tools/sdemo.png
