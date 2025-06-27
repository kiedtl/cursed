all: font.otb font-icons.otb scrots/sdemo.png scrots/charmap.png

font-icons.otb: font-icons.bdf
	tools/otb.pe $?
	mv 'cursed_icons medium.otb' font-icons.otb

font.otb: font.bdf
	tools/otb.pe $?
	mv 'cursed medium.otb' font.otb

scrots/sdemo.png: font.bdf tools/mkff
	cat shortdemo.txt | tools/draw.lua 1 > $@.ff
	ff2png < $@.ff > $@
	rm -f $@.ff
	pngcrush $@ $@.tmp
	mv $@.tmp $@

scrots/charmap.png: font.bdf tools/mkff
	tools/charmap.lua | tools/draw.lua 2 > $@.ff
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
