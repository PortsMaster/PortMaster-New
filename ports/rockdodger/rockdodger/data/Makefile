PACKAGENAME=rockdodger

prefix = $(DESTDIR)/usr/local
datarootdir = $(prefix)/share
datadir = $(datarootdir)
bindir = $(exec_prefix)/bin
docdir = $(datarootdir)/doc/$(PACKAGENAME)
mandir = $(datarootdir)/man
localstatedir = $(prefix)/var
gamesdir = $(localstatedir)/games

INSTALL = /usr/bin/install
DATAFILES=$(wildcard *.bmp) $(wildcard *.png) $(wildcard *.aiff) $(wildcard *.wav) $(wildcard *.mod) $(wildcard iff.*)
IMAGES = $(wildcard ./images/*.png) $(wildcard ./images/*.bmp) $(wildcard ./images/*.xpm) $(wildcard ./images/*.ilbm)

all:
	@echo "prefix = $(prefix)"
	@echo datadir = $(datadir)
	@echo PACKAGENAME = $(PACKAGENAME)

install:
	$(INSTALL) -d $(datadir)/$(PACKAGENAME)/images
	cp $(DATAFILES) $(datadir)/$(PACKAGENAME)
	cp $(IMAGES) $(datadir)/$(PACKAGENAME)/images

uninstall:
	rm -rf $(datadir)/$(PACKAGENAME)/

.PHONY: all clean install uninstall dist

