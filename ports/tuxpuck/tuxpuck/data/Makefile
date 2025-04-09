# Makefile for TuxPuck , Copyright Jacob Kroon 2001-2002
CC		= gcc
SOURCES    = pad_png.c puck_png.c tux_png.c glass_png.c scoreboard_png.c \
             arcana_png.c mousebar_png.c title_jpg.c board_jpg.c \
             logo_jpg.c crash_ogg.c nock_ogg.c tux_apps_ogg.c \
             tux_boos_ogg.c tux_eyes_spr.c monos_fnt.c monob_fnt.c \
             piece1_png.c piece2_png.c piece3_png.c piece4_png.c piece5_png.c

#############################################################

OBJS=$(SOURCES:.c=.o)

%.o	: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

libdata.a : $(OBJS)
	ar r libdata.a $(OBJS)
	ranlib libdata.a

$(SOURCES):
	cd ../utils/; $(MAKE)
	../utils/ttf2font ttfs/mono.ttf monos.fnt 30 30
	../utils/data2c monos.fnt monos_fnt
	../utils/ttf2font ttfs/mono.ttf monob.fnt 45 45
	../utils/data2c monob.fnt monob_fnt
	rm *.fnt
	../utils/data2c jpgs/title.jpg title_jpg
	../utils/data2c jpgs/board.jpg board_jpg
	../utils/data2c jpgs/logo.jpg logo_jpg
	../utils/data2c pngs/pad.png pad_png
	../utils/data2c pngs/puck.png puck_png
	../utils/data2c pngs/scoreboard.png scoreboard_png
	../utils/data2c pngs/mousebar.png mousebar_png
	../utils/data2c pngs/glass.png glass_png
	../utils/data2c pngs/piece1.png piece1_png
	../utils/data2c pngs/piece2.png piece2_png
	../utils/data2c pngs/piece3.png piece3_png
	../utils/data2c pngs/piece4.png piece4_png
	../utils/data2c pngs/piece5.png piece5_png
	../utils/data2c sounds/crash.ogg crash_ogg
	../utils/data2c sounds/nock.ogg nock_ogg
	# Tux
	../utils/anim tux/eyes.ac tux_eyes.spr
	../utils/data2c tux_eyes.spr tux_eyes_spr
	rm tux_eyes.spr
	../utils/data2c tux/tux.png tux_png
	../utils/data2c tux/apps.ogg tux_apps_ogg
	../utils/data2c tux/boos.ogg tux_boos_ogg
	# Arcana
	../utils/data2c arcana/arcana.png arcana_png
clean :
	rm -f *~ $(SOURCES) $(OBJS) libdata.a
	rm -rf pngs/.xvpics jpgs/.xvpics
