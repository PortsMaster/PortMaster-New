
This is Dodgin' Diamond II

With sound & music where available.

** Required **

DD2 needs SDL 1.2.x and SDL_Mixer.

You can find both needed libraries at http://www.libsdl.org/

You can get newest version of this package at:

   http://www.usebox.net/jjm/dd2/

** Install **

UNIX Instructions

In the root directory of DD2 package:

$ ./configure
$ make
$ su
$ make install
$ exit
$ dd2

You may read the generic INSTALL file.

Win32 Instructions

The game doesn't need any installation. Just unzip the
package and run dd2.exe. In case of error (eg. the game
doesn't start), check stderr.txt file in dd2.exe directory.

** Configuration **

You can change player control, sound and graphic mode in
the configuration screen of the game.

By now you must restart DD2 in order to activate graphic
configuration changes.

** Keyboard **

Player 1: UP, DOWN, LEFT, RIGHT, RIGHT CONTROL
Player 2: w, s, a, d, LEFT CONTROL

There are reports of systems with just one control key. In those
systems you should use 'm' key instead RIGHT CONTROL. To enable
this alternative fire key, configure with:

$ ./configure --enable-alternate-fire-key 

** Joystick **

Player 1: Joystick 1 (if available)
Player 2: Joystick 2 (if available)

Use the pad to move, first button to fire and second button to
pause/resume the game.

In the menu, use up/down, first button to select, and second
button to exit.

In the hiscore entry, use up/down to select letters, right to
enter, second button to delete and first button to finish.

** Troubleshooting **

Some common issues:

1. Your computer is very old (slow) and the game doesn't
run properly (Win32/X11).

 You can try changing sound quality in the configuration
 screen. Better sound requires a faster computer.

2. You graphic card doesn't support SDL's 320x200 8bpp full
screen mode properly (Win32).

 That's not frequent, but may happen. You can set 'windowed'
 graphic mode in the configuration screeen. Setup Windows
 resolution to 640x480 and it will be playable in a window.

3. You cannot run DD2 in full screen mode (X11).

 SDL's full screen mode it's only supported under Win32. If
 you run it in full screen mode probably it will change your
 display  to the closest screen mode available (if you don't
 have 320x200 in your mode list). If you wanna play it 320x200
 full screen, add this mode to your X11 configuration.

 Check the FAQ about using SDL: http://www.libsdl.org/faq.php.

4. The sound doesn't work; or the sound works bad and/or
the programs does 'Segmentation Fault' at exit (UNIX).

 This may be due you're running an audio daemon (esd, artsd)
 and SDL tries OSS API with /dev/dsp by default.

 You can use SDL_AUDIODRIVER environment variable to set the
 name of the driver you wanna use. The drivers available depend
 on your SDL installation.

 In order to use esd driver, execute in a bash alike shell:

 	SDL_AUDIODRIVER="esd" dd2

 Check the FAQ about using SDL: http://www.libsdl.org/faq.php.

5. My joystick/gamepad doesn't respond correctly (UNIX/Win32).

 You must calibrate your device. Under UNIX systems you
 should use jscal (If available). Under Win32 you should
 follow vendor instructions.

6. When I press alt+tab while playing on fullscreen mode all the graphics 
get corrupted when I continue playing the game (Win32).

 I don't have a windows system to try to fix that. I think it's something
 related to SDL usage of Direct X surfaces, but I don't know.

 By now the best way to avoid this problem is to not press alt+tab!

7. The game doesn't work on MAC OS X.

 DD2 uses SDL_DOUBLEBUF and that feature is not supported on MAC OS X.

 However since version 1.2.6 SDL has experimental code that should make
 it work, but I have no reports about it working.

8. I have a problem that is not listed here!

 Check the FAQ about using SDL: http://www.libsdl.org/faq.php.

 If you don't find a solution in that FAQ, just drop me a mail.

** Development scenario **

DD2 is being developed with...

 FreeBSD 4.8 (versions of dd2 pre 0.1)
 Debian GNU/Linux 3.0 (Woody)
 SoundTracker 0.6.6
 Gimp 1.2.3

** Feedback **

This software is BETA, so you should notice bugs or things not
finished. In case of bugs, please report them to:

	 "Juan J. Martinez" <jjm@usebox.net>

** DD2 LICENSE **

    Dodgin' Diamond 2, a shot'em up arcade
    Copyright (C) 2003,2004 Juan J. Martinez <jjm@usebox.net>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License Version 2 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

****

About libraries distributed with DD2 binaries (Win32)
-----------------------------------------------------

SDL RUN-TIME ENVIRONMENT: SDL.DLL and SDL_MIXER.DLL

The Simple DirectMedia Layer (SDL for short) is a cross-platfrom library
designed to make it easy to write multi-media software, such as games and
emulators.

SDL_mixer is a sample multi-channel audio mixer library. It supports any
number of simultaneously playing channels of 16 bit stereo audio, plus a
single channel of music, mixed by the popular MikMod MOD, Timidity MIDI,
Ogg Vorbis, and SMPEG MP3 libraries.

The Simple DirectMedia Layer library source code is available from:
http://www.libsdl.org/

SDL_mixer library source code is available from:
http://www.libsdl.org/projects/SDL_mixer/

These libraries are distributed under the terms of the GNU LGPL license:
http://www.gnu.org/copyleft/lesser.html

****

