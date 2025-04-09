# =============================================================================
# Rocks'n'Diamonds - McDuffin Strikes Back!
# -----------------------------------------------------------------------------
# (c) 1995-2015 by Artsoft Entertainment
#                  Holger Schemel
#                  info@artsoft.org
#                  https://www.artsoft.org/
# -----------------------------------------------------------------------------
# graphics/gfx_classic/Makefile
# =============================================================================

# -----------------------------------------------------------------------------
# configuration
# -----------------------------------------------------------------------------

RND = ../../rocksndiamonds

RM = rm -f

# EXT = pcx
EXT = png

FILES = RocksBusy.$(EXT)		\
	RocksDC.$(EXT)			\
	RocksDC2.$(EXT)			\
	RocksDF.$(EXT)			\
	RocksDoor.$(EXT)		\
	RocksDoor2.$(EXT)		\
	RocksDoorMM.$(EXT)		\
	RocksEMC.$(EXT)			\
	RocksElements.$(EXT)		\
	RocksFontBig.$(EXT)		\
	RocksFontDC.$(EXT)		\
	RocksFontEM.$(EXT)		\
	RocksFontMedium.$(EXT)		\
	RocksFontSmall.$(EXT)		\
	RocksHeroes.$(EXT)		\
	RocksMM.$(EXT)			\
	RocksMore.$(EXT)		\
	RocksSP.$(EXT)			\
	RocksScreen.$(EXT)		\
	RocksToons.$(EXT)		\
	RocksTouch.$(EXT)		\
					\
	RocksCE.$(EXT)			# dynamically generated from template


# -----------------------------------------------------------------------------
# build targets
# -----------------------------------------------------------------------------

all: $(FILES)

%.pcx: %.ilbm
	ilbmtoppm $< | ppmtopcx > $@

%.png: %.ilbm
	ilbmtoppm $< | pnmtopng > $@

RocksCE.png: RocksCE-template.ilbm
ifneq ("$(wildcard RocksCE-template.ilbm)","")
	$(RND) -e "create CE image ."
	bmptoppm RocksCE.bmp | pnmtopng > $@
	$(RM) RocksCE.bmp
endif

RocksCE-template.ilbm:

clean:
	@for i in $(FILES); do			\
		echo "$(RM) $$i";		\
		$(RM) $$i;			\
	done
	$(RM) RocksCE.ilbm
