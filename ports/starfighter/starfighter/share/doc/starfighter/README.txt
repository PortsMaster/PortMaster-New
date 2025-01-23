This file has been dedicated to the public domain, to the extent
possible under applicable law, via CC0. See
http://creativecommons.org/publicdomain/zero/1.0/ for more
information. This file is offered as-is, without any warranty.

========================================================================

If you are reading this, this is an ARM retro handheld port of the
original project done for Portmaster.  The original starfighter can be
found at:

https://pr-starfighter.github.io/

This fork originates from:

https://github.com/bmdhacks/starfighter

========================================================================

Thank you for downloading Project: Starfighter!

Project: Starfighter is a space shoot 'em up game originally developed
by Parallel Realities in 2002, and released in 2003. You assume the role
of Chris Bainfield in his quest to put an end to WEAPCO, the weapons
corporation which has enslaved the galaxy.

If you played one of the versions of Project: Starfighter distributed by
Parallel Realities, you might notice some differences in this version
compared to the original:

* The graphics, sounds, and music are all completely different. This is
  because most of the original media was not properly licensed, and
  therefore needed to be replaced to make the game 100% libre. Most of
  this work was done by the previous project at SourceForge; the current
  project completed that work by adding music and replacing one
  non-libre graphic that got into version 1.2 by mistake.

* Much of the dialog has been changed. There are various reasons for
  this; some of these include fixing bad writing, making the dialog
  match new music queues, and giving the characters more personality.

* There are several gameplay changes. These changes were mostly done to
  balance the game better. The original game is contained in the Classic
  difficulty option, which is nearly identical to the original
  experience. A few small differences (mainly old bugs that were not
  left in) do exist, and they are explained on the following page:
  https://pr-starfighter.github.io/old.html

* Typing "humansdoitbetter" in the title screen no longer enables
  cheats. This is actually because the switch to SDL2 broke the original
  feature, and rather than fixing it, we just replaced it with something
  else. We'll let you figure out what the new method to access the cheat
  menu is. 😉

------------------------------------------------------------------------

PLAYING THE GAME

The basic controls are the arrow keys, Ctrl, Space, Shift, and Escape.
Other keys on they keyboard can also be used in case of keyjamming or if
you simply prefer other controls; alternative keys include the keypad,
ZXC, ASD, <>?, and 123. A gamepad or joystick can also be used.

The basic objective of Project: Starfighter is simply to complete all
missions. Exactly what entails completing a mission varies and is
explained in-game.

In the system overview screen, various sections can be accessed by
clicking the icons on the bottom of the screen. You can also use the
keyboard or a gamepad if you prefer (use the arrows to move the cursor
and the fire button to "click" on things).

Other than that, have fun, and good luck!

------------------------------------------------------------------------

COMPILING FROM SOURCE

If you are an end-user, it is easiest to use an existing binary
distribution if possible.  If you want or need to compile yourself,
however, instructions follow.

Note: Developers compiling the source code from the Git repository,
please first see the GENERATING CONFIGURE SCRIPT AND BUILDING LOCALES
section below.

Project: Starfighter depends on the following libraries to build:

* SDL2 <http://libsdl.org>
* SDL2_image <http://www.libsdl.org/projects/SDL_image/>
* SDL2_mixer <http://www.libsdl.org/projects/SDL_mixer/>
* SDL2_ttf <http://www.libsdl.org/projects/SDL_ttf/>

Once you have all dependencies installed,  do the following from the
Project: Starfighter base directory:

    ./configure
    make
    make install

This will perform a system-wide installation, which is recommended for
most users.  For most Linux systems, an icon should be added to your
menu which you can then use to run Starfighter; if not, you can use the
launcher found in the "misc" directory or run the "starfighter" command
manually.

If you would prefer a "run in place" build, you should instead do the
following from the Project: Starfighter base directory:

    ./configure SF_RUN_IN_PLACE=1
    make
    mv src/starfighter .

For Windows and MacOS, a run in place build is preferred. Note that the
final step (moving the Starfighter binary out from the src directory) is
required; in particular, failure to do so under MacOS leads to a failure
to load data (images, sounds, fonts) needed by Starfighter.

On Linux and most other POSIX systems, you can instead build a run in
place build with the following commands:

    ./configure SF_RUN_IN_PLACE=1
    make
    mv misc/starfighter.sh .

For Linux, this method is preferred as the binary itself often cannot be
run by double-clicking, and the starfighter.sh script also automatically
sets the current working directory, making it suitable for launchers.

Run "./configure --help" to see all options for compiling.

------------------------------------------------------------------------

GENERATING CONFIGURE SCRIPT AND BUILDING LOCALES

If you contribute to Project: Starfighter's source code, you will need
to know how to generate a configure script and build locales needed for
compiling the program. NOTE: This is for developers and other people
compiling source code taken from the Git repository. End-users simply
compiling releases of Starfighter from source can ignore this section.

The following components are required to generate the configure script:

* Autoconf
* Automake
* pkg-config

And the following is required to build locales:

* Python

Once these dependencies are installed, simply do the following from a
terminal window:

    ./autogen.sh

The Python script build.py may fail on MacOS due to a missing msgfmt
program. msgfmt is part of gettext and the version that ships on a Mac
does not include the msgfmt utility. This can be solved by using gettext
from Homebrew:

    brew install gettext
    export PATH="$(brew --prefix gettext)/bin:$PATH"

If for some reason you need to remove all generated files from your
directory, you can do so via the following command (requires Git):

    git clean -fdx

Note: automatically generated files are listed in .gitignore, so you
generally don't actually have to do this. This is mainly useful for
build tests.
