![Application Icon](/pkg/icon.png)
# Heboris C7-EX SDL2 - unofficial version (YGS2K EX)

This version contains the source code for Heboris C7-EX. It requires a C
compiler supporting C99 and the CMake utility, and the libraries for SDL 2.0,
SDL 2.0 mixer, SDL 2.0 image, and PhysicsFS.

## Default Keyboard Controls
The keyboard controls can be reset to defaults at any time by holding the
Escape key for at least one second; a screen with instructions will then be
displayed.

Player 1:
* Up: Arrow up
* Down: Arrow down
* Left: Arrow left
* Right: Arrow right
* A: Z
* B: X
* C: C
* D: V
* Give up: Q
* Pause: W

Player 2:
* Up: Numpad/Keypad 8
* Down: Numpad/Keypad 5
* Left: Numpad/Keypad 4
* Right: Numpad/Keypad 6
* A: Numpad/Keypad 1
* B: Numpad/Keypad 2
* C: Numpad/Keypad 3
* D: Numpad/Keypad 0
* Give up: Page up
* Pause: Page down

## Installing Flatpak Version on Linux
The benefit of using the Flatpak release package over building it yourself is
it's built with a recent compiler (improved optimizations) and bundled with
recent-version libraries, rather than having to settle on older libraries on
some distros, like Ubuntu. The total installation size of Flatpak and necessary
components is quite large, but the Flatpak package should work on any Linux
distribution supporting Flatpak:
```sh
# Ubuntu, etc. Replace with whatever your distro requires to get Flatpak installed.
sudo apt-get install flatpak

# You might not have to run these first two lines, but there's no harm in running them if you don't need to.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install runtime/org.freedesktop.Platform/x86_64/21.08

flatpak install ~/Downloads/HeborisC7EX-SDL2-Linux.flatpak

# You might need to log out and then log back in for the HeborisC7EX-SDL2
# application to show up in application menus.
```

## Setup On Ubuntu

If using Git to get the source code, rather than downloading a zip of it from GitHub:
```sh
sudo apt-get install git
```

Building dependencies:
```sh
sudo apt-get install gcc cmake libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libphysfs-dev
```

## Setup in Windows MSYS2

If using Git to get the source code, rather than downloading a zip of it from GitHub:
```sh
pacman -Syu git
```

Building dependencies:
```sh
pacman -Syu mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-SDL2 mingw-w64-x86_64-SDL2_mixer mingw-w64-x86_64-SDL2_image mingw-w64-x86_64-physfs
```

## Download, Build, and Run Without Installing

```sh
git clone https://github.com/nightmareci/HeborisC7EX-SDL2
cd HeborisC7EX-SDL2
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/HeborisC7EX-SDL2
```

## Selecting a MIDI Soundfont if MIDI Doesn't Work

At least on Windows and macOS, it seems MIDI always works fine, but not always
on Linux. If MIDI music doesn't seem to work, you can manually select a
soundfont like this, on Linux:

```sh
SDL_SOUNDFONTS='/usr/share/soundfonts/default.sf2' ./build/HeborisC7EX-SDL2
```

Provide a full path to a .sf2 file after `SDL_SOUNDFONTS=` to select the
soundfont you want to use.

On Linux, soundfont packages install their .sf2 files in
`/usr/share/soundfonts`, though you can use any .sf2 soundfont you want, such
as those just downloaded from some website.

A soundfont is not included, because they're quite large. But here are some
free soundfont sources; you'll probably want to stick with General MIDI ("GM") ones:

* [Soundfonts 4U](https://sites.google.com/site/soundfonts4u/)
* [Ultimate List of Free Soundfonts - TriSamples](https://trisamples.com/free-soundfonts/)
* [Links to SoundFonts](http://www.synthfont.com/links_to_soundfonts.html)

Unfortunately, there are some dead links on those pages, but some links still work.

## Download and Package for Windows

For Windows, building with VCPKG and Visual Studio/MSVC is the officially
supported method. The packaging script requires you have x64, x86, and ARM64
support with Visual Studio set up, as it produces builds for those platforms.

For now, only packaging of portable builds is supported. Installable build
support might be added in the future, where they're provided as installers.

```bat
REM First, install x86, x64, and ARM64 support in the Visual Studio installer.

REM Install required packages for all platforms. You'll need to have the working directory of your shell in the VCPKG install root for these lines.
REM As of the time this was written, sdl2-mixer[opusfile] is broken, so you can't install SDL 2 mixer with Opus support. The game will work fine without it.
.\vcpkg install --triplet x64-windows sdl2 sdl2-image[core] sdl2-mixer[libflac,libmodplug,libvorbis,mpg123,nativemidi] physfs
.\vcpkg install --triplet x86-windows sdl2 sdl2-image[core] sdl2-mixer[libflac,libmodplug,libvorbis,mpg123,nativemidi] physfs
.\vcpkg install --triplet arm64-windows sdl2 sdl2-image[core] sdl2-mixer[libflac,libmodplug,libvorbis,mpg123,nativemidi] physfs

REM Have your working directory somewhere for source repos here.
git clone https://github.com/nightmareci/HeborisC7EX-SDL2
cd HeborisC7EX-SDL2
REM Starting at the root of the VCPKG install/repo, vcpkg.cmake is at [vcpkg-root]\scripts\buildsystems\vcpkg.cmake
.\pkg\windows\pkg.bat path\to\vcpkg.cmake . build-pkg
REM All the builds will be in separate ZIPs in the build-pkg directory.
```

## Download and Package for macOS

The macOS packaging script will just use the libraries you have installed.
Homebrew or MacPorts will work, though only MacPorts can provide Universal
builds of the libraries, so packages built with Homebrew aren't suitable for
distribution.

The "Installable Mac App" version will work unnotarized, though users will have to
approve it, and will get the "Apple could not verify..." message.
```sh
git clone https://github.com/nightmareci/HeborisC7EX-SDL2
cd HeborisC7EX-SDL2
./pkg/macos/pkg.sh 'Installable Mac App' . build-pkg
```

You can also create a "Portable Mac App" version; distribution of this version
basically requires you have an Apple Developer subscription, so the app can get
access to the folder it's in. But building it for use on the same system it was
built on works fine, and is a convenient way to have it easy to customize the
theme. The "Portable Mac App" version requires the built app be in the folder with the
other files (`res` folder, etc.).
```sh
./pkg/macos/pkg.sh 'Portable Mac App' . build-pkg
```

A third type, "Portable", creates a command line binary with the libraries in
a separate `libs` folder. It's similar to "Portable Mac App" in usage, as you
can modify the files and still run it, but you can easily have terminal output
with it, and run it from command line.
```sh
./pkg/macos/pkg.sh Portable . build-pkg
```

The packaging script can optionally take a codesigning identity, so you can
sign the app for future notarization. By default, it uses adhoc signing if no
identity is provided.
```sh
./pkg/macos/pkg.sh 'Portable Mac App' . build-pkg 'Apple Developer Codesigning ID'
```

## Download and Package for Linux

AppImage:
```sh
git clone https://github.com/nightmareci/HeborisC7EX-SDL2
cd HeborisC7EX-SDL2
./pkg/linux/pkg-appimage.sh . build-appimage
```

Flatpak:
```sh
git clone https://github.com/nightmareci/HeborisC7EX-SDL2
cd HeborisC7EX-SDL2
./pkg/linux/pkg-flatpak.sh . build-flatpak
```

## Input Via GPIO
You must install `libgpiod` in order to build support for GPIO.

Raspberry Pi OS installation:
```sh
sudo apt install libgpiod-dev
```

Set `ENABLE_LINUX_GPIO_INPUT` when running CMake, then build:
```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_LINUX_GPIO_INPUT=1
cmake --build build
./build/HeborisC7EX-SDL2
```

No efforts will be made to support Linux systems without support for
`libgpiod`; recent Linux kernel versions support it, just upgrade to something
that supports it. It's a hard requirement, because it's the most appropriate
way for a game written in C to access GPIO for input, as it doesn't require
root access. Plus, `libgpiod`, being a built-in Linux kernel feature, is
supported on all systems with GPIO, not just Raspberry Pi.

TODO: Implement full configuration of GPIO pin settings, only shown in-game if
enabled in a build. For now, this is the pin layout, intended only for
Raspberry Pi, based on the layout set in Texmaster, with the addition of the
"give up" input:

* Pin 1 or Pin 17: 3.3V; connect a GPIO pin to one of the connections on a button, 3.3V to the other connection.
* GPIO5 / Pin 29: Up
* GPIO13 / Pin 33: Down
* GPIO6 / Pin 31: Left
* GPIO12 / Pin 32: Right
* GPIO19 / Pin 35: A
* GPIO16 / Pin 36: B
* GPIO26 / Pin 37: C
* GPIO20 / Pin 38: D
* GPIO21 / Pin 40: Give Up
* GPIO4 / Pin 7: Pause

## Debugging Tips

Regardless of the package type used for building, you can add a command line
argument for the path where resources are read from and data files are written,
making the game behave similarly to old Heboris versions, but explicitly
setting where all files are. This feature can be used to get debugging working
in IDEs, by setting that command line argument to where the source root is.

An alternative to using the explicit resource/data directory command line
argument is to use the `WorkingDir` package type when building (the default if
`PACKAGE_TYPE` isn't provided to the CMake configuration step) and configuring
your IDE to run the game with its working directory set to the source root.
This option isn't available in all IDEs, however.

## Changes

 - Port to use SDL 2.0 so it (probably) works on all SDL 2.0-supported platforms.
 - Change to a CMake build system.
 - Convert all source code from C++ to C.
 - Convert source code to UTF-8, so the Japanese comments are easy to work with
   on modern systems. Text strings used in-game remain Shift-JIS, though.
 - Move the script sources from merely being included in gamestart.c, out to
   being individually compiled. Massively improves compile time on multi-core,
   bad-single-threaded-performance systems.
 - Implement full support for configuration of all game inputs, for both
   keyboard and joystick input.
 - Implement advanced joystick input, allowing any mapping of joystick inputs
   to game inputs.
 - Convert to exclusively use fully cross-platform APIs, like SDL_render for
   hardware-accelerated graphics.
 - Implement comprehensive display mode settings. Vsync is included in this.
   Also includes scaling to fill the display, with a correct 4:3 aspect ratio
   viewport.
 - Revise how save data is managed, guaranteeing the format is identical across
   all platforms.
 - Fix the "low detail" 320x240 graphics setting.
 - Implement guaranteed-long-term-correct frame timing; part of that system is
   efficiently timed screen updates, only when appropriate.
 - Use PhysicsFS for file and directory access; now the game can create missing
   directories for save data. This was necessary for an "installable" version
   of the game, where the save data directory is outside the game's
   resources/program directory.

## Todo

This repository will be maintained for bug fixes, non-new-content enhancements
(like new video settings), and ports.

 - Implement automated packaging of builds. At least support Windows, macOS, and
   desktop Linux.
 - Add a prerecorded copy of the default MIDI music and corresponding support
   for the "simple" BGM type for non-MIDI formats, as an option for systems
   without immediately working MIDI playback.

## Definitely Not Legal Advice

This software is copyrighted to Kenji Hoshimoto, but the distribution terms are
currently unknown. So, to be polite, only distribute it noncommercially, and
keep the source code available, because that's basically how it's been
distributed for its whole history.

## Heboris Overview

```text
Original changelog and description of heboris is included in the files
changelog.txt and heboris.txt.

----------------------------------------------------
1. 8 Selectable Rules
----------------------------------------------------
You can select 8 different rotation rules.

HEBORIS     : TGM1 and TGM2 style. Same as original heboris rotation.
TI-ARS      : TGM3 style. T and I piece have special ground kick(It works only once!).
TI-WORLD    : SRS, you can move 10 times, or rotate 8 times.
ACE-SRS     : SRS, you can move 128 times, or rotate 128 times
              Fast drop is slower than TI-WORLD.
ACE-ARS     : TGM-ACE style rotation rule. Really strange!
              Fast drop is slower than TI-ARS.
ACE-ARS2    : Same as ACE-ARS, except soft drop and hard drop.
              Fast drop is slower than TI-ARS.
DS-WORLD    : SRS, you can rotate or move infinity!
              Fast drop is slower than TI-WORLD.
SRS-X       : Original rotation rule based on SRS. But you can use Zangi-moves!
              You can move 24 times, or rotate 12 times.
              And C-botton is "180 degree rotarion" with original wall kicks.
D.R.S       : If you have ever played DTET,let's use this!
              Added T and I ground kick(only once!) to it.

----------------------------------------------------
2. Special modes
----------------------------------------------------
You can play these extra modes.

BIG MODE
 Start BEGINNER,MASTER,20G,DEVIL, or ACE mode
 with holding C botton.
 Blocks are always 2 times bigger.

SCORE TRIAL in BEGINNER mode
 Select BEGINNER mode and press Hold botton once.
 Default of BEGINNER mode is fireworks trial.
 But this is score trial.
 There are no Lv-stop before Lv100 and Lv200, and
 support Item block will appear.
 Goal is Lv300. If you reached Lv300 so quickly,
 you'll get time bonus.
 Back to Back will be better than combos...

ITEM MODE
 Select MASTER , 20G, or DEVIL mode and press Hold botton once (twice in DEVIL mode).
 Item blocks apeear,but attack items affects yourself.

HEBO+
 Select MASTER or 20G mode and press Hold botton twice.
 Sometimes pattern garbage appears.

TOMOYO E-Heart (ACE-Target)
 Select TOMOYO mode and press right arrow key once(twice).
 Other stages from other game(TGM-ACE).
 Always, place of platinum blocks are randomized.

TOMOYO F-Point
 Select TOMOYO mode and press left arrow key once.
 18 mimutes score challenge. (100 stages)

ANOTHER
 Select ACE mode and press right arrow key once.
 It's faster than ACE mode.

HELL
 Select ACE mode and press right arrow key twice.
 The speed is.....WTF!

OLD STYLE
 Select ACE mode and press right arrow key three times.
 Two kinds of old classic ###rises (Decided by "ARS or SRS")

DEVIL- (MINUS)
 If DEVIL-DOOM is too fast for you, let's try.
 Select DEVIL mode and press Right arrow once.

DEATH+
 Select DEVIL mode and press Hold botton once.
 Only one next display and no Hold!

(NOTE:You can use DEVIL- and DEATH+ together.
 And If you use HEBORIS rotation, you can train T.A DEATH.)

ROT.RELAY
 Select SIMPLE mode (40LINES or ULTRA2min) and press Hold botton once.
 Play 40LINES or ULTRA2min with ALL rotation rules.
 Top-out does not become gameover,but penalty will be added.

----------------------------------------------------
3. Add-ons
----------------------------------------------------

See the res folder and the corresponding .txt files in the subdirectories
for information regarding changing aspects of the game. You can alter the
graphics, bgm, sound effects, and backgrounds from there.

---------------------------------------------------
5. License
---------------------------------------------------

(c) 1998-2002 Kenji Hoshimoto
```
