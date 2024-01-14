# =============================================================================
# Rocks'n'Diamonds - McDuffin Strikes Back!
# -----------------------------------------------------------------------------
# (c) 1995-2015 by Artsoft Entertainment
#                  Holger Schemel
#                  info@artsoft.org
#                  https://www.artsoft.org/
# -----------------------------------------------------------------------------
# Makefile
# =============================================================================

# -----------------------------------------------------------------------------
# configuration
# -----------------------------------------------------------------------------

# command name of your favorite ANSI C compiler
# (this must be set to "cc" for some systems)
CC = gcc

# command name of GNU make on your system
# (this must be set to "gmake" for some systems)
MAKE = make

# directory for read-only game data (like graphics, sounds, levels)
# (this directory is usually the game's installation directory)
# default is '.' to be able to run program without installation
# RO_GAME_DIR = .
# use the following setting for Debian / Ubuntu installations:
# RO_GAME_DIR = /usr/share/games/rocksndiamonds

# directory for writable game data (like highscore files)
# (if no "scores" directory exists, scores are saved in user data directory)
# default is '.' to be able to run program without installation
# RW_GAME_DIR = .
# use the following setting for Debian / Ubuntu installations:
# RW_GAME_DIR = /var/games/rocksndiamonds

# uncomment if system has no joystick include file
# JOYSTICK = -DNO_JOYSTICK

# path for cross-compiling (only needed for non-native Windows build)
CROSS_PATH_WIN32 = /usr/local/cross-tools/i686-w64-mingw32
CROSS_PATH_WIN64 = /usr/local/cross-tools/x86_64-w64-mingw32


# -----------------------------------------------------------------------------
# there should be no need to change anything below
# -----------------------------------------------------------------------------

.EXPORT_ALL_VARIABLES:

SRC_DIR = src
ANDROID_DIR ?= build-projects/android

MAKE_CMD = $(MAKE) -C $(SRC_DIR)
MAKE_CMD_ANDROID = $(MAKE) -C $(ANDROID_DIR)


# -----------------------------------------------------------------------------
# build targets
# -----------------------------------------------------------------------------

all:
	@$(MAKE_CMD)

cross-win32:
	@PATH=$(CROSS_PATH_WIN32)/bin:${PATH} $(MAKE_CMD) PLATFORM=cross-win32

cross-win64:
	@PATH=$(CROSS_PATH_WIN64)/bin:${PATH} $(MAKE_CMD) PLATFORM=cross-win64

android-prepare:
	@$(MAKE_CMD_ANDROID) prepare

android-package:
	@$(MAKE_CMD_ANDROID) package

android-clean:
	@$(MAKE_CMD_ANDROID) clean

android: android-package

emscripten:
	@emmake $(MAKE_CMD) PLATFORM=emscripten

clean:
	@$(MAKE_CMD) clean

clean-git:
	@$(MAKE_CMD) clean-git

clean-android: android-clean


# -----------------------------------------------------------------------------
# development targets
# -----------------------------------------------------------------------------

MAKE_ENGINETEST = ./Scripts/make_enginetest.sh
MAKE_LEVELSKETCH = ./Scripts/make_levelsketch_images.sh

auto-conf:
	@$(MAKE_CMD) auto-conf

conf-time:
	@$(MAKE_CMD) conf-time

conf-hash:
	@$(MAKE_CMD) conf-hash

run: all
	@$(MAKE_CMD) run

gdb: all
	@$(MAKE_CMD) gdb

valgrind: all
	@$(MAKE_CMD) valgrind

tags:
	$(MAKE_CMD) tags

depend dep:
	$(MAKE_CMD) depend

enginetest: all
	$(MAKE_ENGINETEST)

enginetestcustom: all
	$(MAKE_ENGINETEST) custom

enginetestfast: all
	$(MAKE_ENGINETEST) fast

enginetestnew: all
	$(MAKE_ENGINETEST) new

leveltest: all
	$(MAKE_ENGINETEST) leveltest

levelsketch_images: all
	$(MAKE_LEVELSKETCH)


# -----------------------------------------------------------------------------
# distribution targets
# -----------------------------------------------------------------------------

MAKE_DIST = ./Scripts/make_dist.sh

dist-clean:
	@$(MAKE_CMD) dist-clean

dist-clean-android:
	@$(MAKE_CMD_ANDROID) dist-clean

dist-build-linux:
	@BUILD_DIST=TRUE $(MAKE)

dist-build-win32:
	@BUILD_DIST=TRUE $(MAKE) cross-win32

dist-build-win64:
	@BUILD_DIST=TRUE $(MAKE) cross-win64

dist-build-mac:
	@BUILD_DIST=TRUE $(MAKE)

dist-build-android:
	@BUILD_DIST=TRUE $(MAKE) android

dist-build-emscripten:
	@BUILD_DIST=TRUE $(MAKE) emscripten

dist-package-linux:
	$(MAKE_DIST) package linux

dist-package-win32:
	$(MAKE_DIST) package win32

dist-package-win64:
	$(MAKE_DIST) package win64

dist-package-mac:
	$(MAKE_DIST) package mac

dist-package-android:
	$(MAKE_DIST) package android

dist-package-emscripten:
	$(MAKE_DIST) package emscripten

dist-copy-package-linux:
	$(MAKE_DIST) copy-package linux

dist-copy-package-win32:
	$(MAKE_DIST) copy-package win32

dist-copy-package-win64:
	$(MAKE_DIST) copy-package win64

dist-copy-package-mac:
	$(MAKE_DIST) copy-package mac

dist-copy-package-android:
	$(MAKE_DIST) copy-package android

dist-copy-package-emscripten:
	$(MAKE_DIST) copy-package emscripten

dist-upload-linux:
	$(MAKE_DIST) upload linux

dist-upload-win32:
	$(MAKE_DIST) upload win32

dist-upload-win64:
	$(MAKE_DIST) upload win64

dist-upload-mac:
	$(MAKE_DIST) upload mac

dist-upload-android:
	$(MAKE_DIST) upload android

dist-upload-emscripten:
	$(MAKE_DIST) upload emscripten

dist-deploy-emscripten:
	$(MAKE_DIST) deploy emscripten

dist-package-all:
	$(MAKE) dist-package-linux
	$(MAKE) dist-package-win32
	$(MAKE) dist-package-win64
	$(MAKE) dist-package-mac
	$(MAKE) dist-package-android
	$(MAKE) dist-package-emscripten

dist-copy-package-all:
	$(MAKE) dist-copy-package-linux
	$(MAKE) dist-copy-package-win32
	$(MAKE) dist-copy-package-win64
	$(MAKE) dist-copy-package-mac
	$(MAKE) dist-copy-package-android
	$(MAKE) dist-copy-package-emscripten

dist-upload-all:
	$(MAKE) dist-upload-linux
	$(MAKE) dist-upload-win32
	$(MAKE) dist-upload-win64
	$(MAKE) dist-upload-mac
	$(MAKE) dist-upload-android
	$(MAKE) dist-upload-emscripten

dist-deploy-all:
	$(MAKE) dist-deploy-emscripten

dist-release-all: dist-package-all dist-copy-package-all dist-upload-all

package-all: dist-package-all

copy-package-all: dist-copy-package-all

upload-all: dist-upload-all

deploy-all: dist-deploy-all

release-all: dist-release-all
