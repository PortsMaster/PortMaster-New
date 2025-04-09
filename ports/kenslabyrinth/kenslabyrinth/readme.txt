	LAB3D/SDL
	=========

LAB3D/SDL is a port of Ken's Labyrinth to modern operating systems, using
OpenGL for graphics output and the SDL library to provide user input, sound
output, threading and graphics. Music output is through Adlib emulation or
MIDI (MIDI only on Windows, Linux and other operating systems with
OSS-compatible sound APIs).

Previous versions have been tested on Windows 98, Windows ME, Windows XP,
SuSE Linux 9.1, Debian Linux 2.2, SunOS 5.8 (Solaris 8) and
FreeBSD 4.7.

Improvements over the original Ken's Labyrinth:

- Runs natively on 32-bit Windows or Unix.
- Supports big-endian CPUs.
- Uses OpenGL to provide hardware accelerated, anti-aliased graphics with
  trilinear interpolation in true colour (where available).
- High-resolution software rendering.
- Multiple simultaneous sound effects.
- Improved (albeit not Ken-approved) General MIDI music.
- Adlib emulation for accurate music playback on standard hardware.
- Many bug fixes.

        Credits
	-------  

Design, code and Adlib emulation by:	LAB3D/SDL code by:
Ken Silverman				Jan Lönnberg
http://www.advsys.net/ken		http://koti.mbnet.fi/lonnberg/

Artwork by:				Board maps by:
Mikko Iho				Andrew Cotter
Ken Silverman
Andrew Cotter				Sound effects by:
					Ken Silverman
Music by:				Andrew Cotter
Ken Silverman
					LAB3D/SDL testing by:
					Ken Silverman
					Danny Desse'

Installation instructions can be found in install.txt.

Execution instructions can be found in run.txt.

Frequently asked questions are answered in faq.txt.

Technical comments about Ken's Labyrinth and LAB3D/SDL can be found in
comments.txt.

	Version 0.9 - 26/08/2002
	------------------------

Changes:

- Code converted to ANSI C with POSIX or Win32 libraries (more or less).
- Input rewritten for SDL.
- Graphics rewritten for SDL/OpenGL.
- Sound rewritten for SDL.
- Music rewritten for OSS MIDI.
- Music rewritten for Windows MIDI.
- Removed shareware messages from intro.
- Replaced out-of-date ordering info with copyright notice.
- Minor cosmetic improvements to episode/skill selection.
- User-selectable resolution (add -res width height to command line).
- Windowed mode added (-win to command line).
- Sound (-nosound) and music (-nomusic) can be disabled from command line.

Fixed bugs:

- Data corruption bug in large open spaces (monster-in-earshot search routine
  overflowed mrotbuf).
- Action key/button now only repeats when drinking from a fountain.
- Vertical movement now stops even on very fast machines.
- Completing an episode doesn't mess up the potion and cloak status any more.
- New game menu can now be cancelled correctly.

	Version 0.91 - 02/09/2002
	-------------------------

Changes:

- New setup routine.
- Key definitions no longer translated to US PC keys.
- Tidied up some invalid function definitions, unused variables and such.
- Some code simplifications.
- Cleaned up some of the code that was translated from assembly.
- Code now compiles without warning with full optimisation and warnings.
- Eliminated last vestiges of old VGA page swapping code.

Fixed bugs:

- Mute command no longer leaves notes on in music.
- Load/save menu no longer leaves files open.

	Version 0.92 - 04/09/2002
	-------------------------

Changes:

- Original game files may now have both upper case and lower case names.
- Improved handling of missing files.
- Adlib emulation added.
- Field of view increased to match original.
- Added frame rate counter.
- Keyboard repeat added.
- Main loop delay routine rewritten to improve frame rate.
- More predefined resolutions.
- Added my home page to copyright notice.

Fixed bugs:

- Corrected file permission bug when writing files.
- Keys released while asking for player name no longer get stuck.
- Fixed auto-repeating screen capture key.
- Game over text background colour change fixed.
- Minor cosmetic fixes to setup menu.

	Version 0.921 - 09/09/2002
	--------------------------

Changes:

- Status bar now glides up/down when toggled as in 320x200 mode in original.
- Faster processing of muted sound.
- User-adjustable sound (F5/F6) and music (F7/F8) volume (ingame only).
- Cheat options in setup menu (as requested by Ken).
- Stereo sound added.
- Various cleanups for clarity.
- Started cleanup of alignment/endianness problems.

Fixed bugs:

- Overwriting screen captures now overwrites existing file instead of
  modifying it.
- Fixed minor graphics glitch when viewing main menu while dying.
- Fixed minor audio glitch in episode 1 and 2 end sequences.
- Up and down movement (A/Z) now equally fast.

	Version 0.93 - 16/09/2002
	-------------------------

Changes:

- Endianness issues fixed.
- Added gamma correction setting (F9/F10).
- Doubled maximum volume.
- Next board cheat key no longer repeats.
- Adlib emulation now synchronised to sound output instead of game timer.
- User-adjustable sound buffer size.
- Stereo "Ouch!" noises.
- Lower default sound buffer size.
- Added option to use sound out for timing (use only on low-latency systems).

Fixed bugs:

- Fixed delayed update of map position on death.

	Version	0.931 - 04/10/2002
	--------------------------

Changes: 

- Sound buffer sizes now selected in milliseconds.
- Changed default sound buffer size to 11.8 ms.
- Texture colour depth user selectable.
- Disabled experimental sound timer mode due to compatibility problems.
- Sound and music channel amount can now be toggled separately.
- Symbolic link "setup" added for easier access to setup menu (Linux binary
  only).
- Batch file "setup.bat" added for easier access to setup menu (Windows binary
  only).

	Version	0.94 - 30/10/2002
	-------------------------

Changes: 

- Rewrote status bar code for efficient status bar sliding and variable
  padding of status bar.
- Added support for integer scaling of 2D graphics.
- Modified -res parameter to also specify simulated 2D graphics resolution.
- Moved hiscore box down 20 pixels.
- Changed default sound to stereo.
- Running game without a settings file runs setup.

	Version	0.941 - 11/11/2002
	--------------------------

Changes: 

- Improved OpenGL diagnostics output to help solve compatibility problems.
- Added 1280x960 mode to setup program.

	Version 0.942 - 6/12/2002
	-------------------------

Changes:

- Rewrote screen mode selection to allow custom mode definition.

Fixed bugs:

- Setting an illegal resolution with integer scaling no longer prevents you
  from running the game.

	Version 0.943 - (unreleased)
	----------------------------

Changes:

- Further improved OpenGL diagnostics.

	Version 1.0 - 2/2/2003
	----------------------

Changes:

- Added icon.

	Version 2.0 - 23/12/2003
	------------------------

Changes:

- Support for Ken's Labyrinth v1.0 (Advanced Systems shareware version) and
  v1.1 (Advanced Systems registered version).

	Version 2.1 - 6/1/2004
	----------------------

Changes:

- Support for Ken's Labyrinth v2.0 (Epic Megagames shareware version).

	Version 2.2 - 30/7/2004
	-----------------------

Changes:

- Write permission no longer needed for data files.
- Sound effects can be replaced without changing hardcoded file size.
- Improved timing code.
- Support for aspect ratios other than 4:3.
- Minor Win32 header include fix for latest MinGW.

Fixed bugs:

- Fixed crashes when using -res option with too few (2 or 3) parameters.

	Version 2.3 - 22/8/2004
	-----------------------

Changes:

- Improved colour scheme in setup menu.
- Added autodetection of screen resolutions.

Fixed bugs:

- Fixed several widescreen-related bugs.

	Version 2.31 - 29/8/2004
	------------------------

Changes:

- Simplified resolution menu.
- Brightened setup menu help text.

	Version 2.32 - 11/10/2004
	-------------------------

Changes:

- Lower case file names also valid for v1.x save games.
- Upper case file names also valid for v1.x boards.dat and story.kzp.

Fixed bugs:

- Fixed incorrect warp behaviour in LAB3D v1.x.

	Version 3.0 - 29/11/2013
	------------------------

Changes:

- Added software rendering support.
- Work around judder on (some?) current Radeon Windows drivers.
- Stop using deprecated GL_CLAMP_TO_EDGE texturing.

Fixed bugs:

- Support hardware sound buffer sizes that are not a power of two.

	Version 3.0.1 - 02/12/2013
	--------------------------

Changes:
- Add preliminary install support to Makefile to support packaging.

The following is an excerpt from Ken Silverman's original documentation for
the Ken's Labyrinth 2.1 source release:

----------------------------------------------------------------------------

"Ken's Labyrinth" Copyright (c) 1992-1993 Ken Silverman
Ken Silverman's official web site: "http://www.advsys.net/ken"

----------------------------------------------------------------------------

July 1, 2001:

Some people have been pestering me to release the Ken's Labyrinth source
code, so I've decided that it was time to give it out to everyone. This is
the code from the full version of Ken's Labyrinth (LABFULL.ZIP) It is made
to compile in Microsoft C 6.00A (PLEASE NOTE that this is NOT Microsoft
Visual C++ 6.0, but actually an old 16-bit DOS compiler that was released
by Microsoft way back in 1990.) I have never tried compiling the code in
anything else, and I don't even want to think about it, so please don't ask!

----------------------------------------------------------------------------

KEN'S LABYRINTH SOURCE CODE LICENSE TERMS:                        07/01/2001

[1] I give you permission to make modifications to my Ken's Labyrinth source
    and distribute it, BUT:

[2] Any derivative works based on my Ken's Labyrinth source may be
    distributed ONLY through the INTERNET and free of charge - no
    commercial exploitation whatsoever.

[3] Anything you distribute which uses a part of my Ken's Labyrinth source
    code MUST include the following message somewhere in the archive:

    "Ken's Labyrinth" Copyright (c) 1992-1993 Ken Silverman
    Ken Silverman's official web site: "http://www.advsys.net/ken"

    Including this README.TXT file along with your distribution is the
    recommended way of satisfying this requirement.

[4] Technical support: The code is so old that I am NOT interested in wasting
    my time answering questions about it. If you can't figure out how to
    compile the code, or you can't figure out what the code is doing,
    then that's your problem.
