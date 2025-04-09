
Hexen II: Hammer of Thyrion (uHexen2) - v1.5.9
----------------------------------------------


1. Installation

  1.1 Getting Started
  1.2 Software Requirements
  1.3 Running the Game
  1.4 Sound and Music
  1.5 Networking/Multiplayer
  1.6 Game Saves and Configuration files
  1.7 Fullscreen/Windowed modes and mouse
  1.8 Joystick (gamepad) support

2. Known Problems

  2.1 Sound Problems
  2.2 Lines on Screen
  2.3 Fluxbox

3. General Info

  3.1 Mods
  3.2 Game Console
  3.3 Hardware Acceleration
  3.4 Thanks
  3.5 Links

4. Appendix

----------------------------------------------------------------



1. INSTALLATION
---------------


1.1 Getting Started
-------------------

Hexen II source and the Hammer of Thyrion source port are free, but the
game itself is not: You must have an original copy of the game released
by Raven Software and Activision.  If you don't, then download the demo
version.

Installing the demo version doesn't require any media and/or any extra
effort:  our demo packages contain all requirements.

To install the retail version of the game, you need your original
cdroms: the windows discs released by Raven and Activision back in 1997.
The less common "Xplosive" cdrom published in UK is also supported.
To install the "Portal of Praevus" mission pack, you need your original
mission pack cdrom.  To install the Matrox m3D bundled (oem) version of
the game (also known as "Continent of Blackmarsh"), you need your M3D_2
cdrom.

Download the base binary tarball (e.g., hexen2-1.5.9.i586.tgz) and
extract it. Copy the two files pak0.pak and pak1.pak from your cdrom
into the "data1" directory in your own installation.  The pak file
names should be lower-cased, if not already.  To fix the permissions:
chmod 644 data1/pak*.pak

Hexen II requires its game data to be updated to version 1.11, too.
To patch the pak files, run the included "h2patch" program.  Here are
the md5sums, just in case:

   c9675191e75dd25a3b9ed81ee7e05eff  data1/pak0.pak
   c2ac5b0640773eed9ebe1cda2eca2ad0  data1/pak1.pak

If you have the Portal of Praevus mission pack, copy the pak3.pak
file from your cdrom into the "portals" directory in your own
installation.  To fix the permissions:  chmod 644 portals/pak*
The mission pack data doesn't need patching.  Here is the md5sum of
pak3.pak, just in case:

   77ae298dd0dcd16ab12f4a68067ff2c3  portals/pak3.pak

If you want to install HexenWorld, download the HexenWorld binary
package (e.g., hexenworld-1.5.9.i586.tgz) and extract it in the
same directory you extracted the base uhexen2 tarball. HexenWorld
data doesn't need patching.

Here are the game binaries' names:

   hexen2   -  Hexen II (software rendering)
   glhexen2 -  Hexen II (opengl rendering)
   h2ded    -  Hexen II Dedicated server
   hwcl     -  HexenWorld Client (software rendering)
   glhwcl   -  HexenWorld Client (opengl rendering)
   hwsv     -  HexenWorld Server
   hwmaster -  HexenWorld Master Server


1.2 Software Requirements
-------------------------

   SDL (min.: 1.2.4)	  : Simple DirectMedia Layer libraries.
			    1.2.7 and newer highly recommended.
			    If run on systems with SDL < 1.2.6,
			    anti-aliasing support will be auto-
			    matically disabled.

   To compile your own binaries, you'll need a standard unix build
   environment. See the file COMPILE for details.


1.3 Running the Game:
----------------------

You can run the game from a terminal window: "cd" into the installation
directory and run the binary. For example:
    cd /home/myname/hexen2
    ./glhexen2 [possible options]

The game starts in windowed mode by default: use the "-f" command line
switch to start in fullscreen.  To play the Portals of Praevus mission
pack, use the "-portals" or "-h2mp" command line switch.

Important command-line switches:

 -portals | -h2mp	Run with Portal of Praevus mission pack support
			(only for registered version of Hexen2.)

 -f | -fullscreen	Start fullscreen (can also be set from the menu)

 -w | -window		Start windowed (can also be set from the menu)

 -g | -gllibrary <lib>	Override the OpenGL library to use

 -width   N		Select screen width (can also use the menu)

 -height  N		Optional. Must be used with -width

 -bpp  N		Color depth for GL fullscreen mode

 -conwidth  N		Enables a bigger hud display and readable fonts
			at high resolutions. Valid conwidth values are
			values equal or less than the scr width above:
			Smaller the number, bigger the text. 640 is the
			sanest. Can also be adjusted from the menu.

 -nomouse		Disables mouse usage in game

 -nojoy			Disables joystick (gamepad) probing and usage

 -heapsize  N		Heapsize (memory to allocate, in KB)

 -fsaa N		Enable N sample anti-aliasing (N: 0,2,4) (can
			also be set from the menu)

 -sync | -vsync		Enable syncing with monitor refresh (GL, Nvidia)

 -lm_4			Set lightmap format to RGBA, which is actually
			the default format. RGBA lightmaps are required
			for colored lights. Can be set from the menu.

 -lm_1			Set lightmap format to LUMINANCE. (this was the
			old format that hexen2 originally used and it is
			a little faster than RGBA lightmaps). Can be set
			from the menu.

 -paltex		Enable 8 bit (palettized) textures: saves video
			memory on *very* old low-memory 3D accelerators
			if the proper GL extension is supported. (can be
			set from the menu.)

 -nomtex		Disable multitexture detection/usage

 -no3dfxgamma		Disable special gamma support for Voodoo1/2/Rush
			(if compiled with 3dfx gamma hacks support.)

 -sndoss		Use OSS for audio (default)

 -sndalsa		Use ALSA for audio

 -sndsdl		Use SDL for audio

 -sndbsd		Use sunaudio (for openbsd, netbsd, sun)

 -ossdev		OSS Audio device to use (default: /dev/dsp)

 -alsadev		ALSA Audio device to use (default is "default")

 -sndspeed N		Sampling rate of sound playback (eg 22050,44100)

 -cddev			CD Audio device to use (default is
 			/dev/cdrom for linux, /dev/acd0 for FreeBSD.)
			For windows, use a single drive letter, like:
			glh2 -cddev E

 -nocdaudio		Disable cdrom music

 -nomidi		Disable MIDI driver

 -s | -nosound		Run the game without sound

 -nolan			Disable networking (incompatible with -listen)

 -listen  N		Enable multiplayer with maximum N players

 -protocol N		Run the server using protocol version N, instead
			of the default. Valid values: 18 (the old hexen2
			v1.11 protocol), 19 (default, h2mp protocol).

 -port <portnum>	Change the default port. Default port is 26900
			for hexen2, 26950 for hexenworld server, 26900
			for hexenworld master server.  hexenworld client
			always uses 26901.

 -localip <address>	For Hexen2 only. Changes the ip address embedded
			in the response packets for the serverinfo and
			connect requests to use the cmdline-provided ip
			address. Server still binds to INADDR_ANY and it
			can see the broadcast requests.

 -ip <address>		Enables the server admins to bind to a specific
			IP address on a multi-homed host.  Note: using
			this option will prevent the us from receiving
			broadcast packets, therefore server discovery on
			the LAN will not work if the server is started
			this way.

 -bindip <address>	Same as the -ip option

 -noifscan		Hexen II only. Disables local address detection
			through network interface scan.

 -developer		Enable developer mode early during init phase.

 -condebug | -debuglog	Logs the console output.

 -devlog		Enable full logging even when not in developer
			mode.

 -v | -version		Display the game version
 -h | -help		Display short help message


If you wish to brighten the display, simply use the game's menu entry.
In case that it doesn't work for you, you can use the "xgamma" utility:
Here is the script I use for xgamma:

    xgamma -q -gamma 1.3;  # brighten the display
    ./glhexen2
    xgamma -q -gamma 1;    # restore old brightness

3dfx Voodoo1 and Voodoo2 users can employ the -3dfxgamma command line
switch to activate native 3dfx gamma controls (remember to enable that
option in the Makefile when compiling).


1.4 Sound and Music
-------------------

uHexen2 includes several choices of sound drivers for linux/unix users:
SDL, OSS and ALSA.  The engine tries them and uses the first one which
successfully initializes. You can make the engine to use only a specific
driver by command line arguments, too.

a. SDL sound code
-----------------
SDL audio isolates you from many compatibility issues and is usable on
most Linux distributions.  The "-sndsdl" command line switch tells the
game engine to use SDL audio, but it isn't necessary because SDL audio
is the default.

  ./glhexen2 -sndsdl [other possible arguments]

If you want to force SDL to use a different driver backend than its
default setting, you can export SDL_AUDIODRIVER=drv where "drv" may be
alsa, dsp, pulse, esd or something similar depending on your own setup.
(Note that SDL_AUDIODRIVER=esd can be laggy in my own experience.)


b. OSS sound code
-----------------
The OSS (Open Sound System) code is compatible with most of the Linux
distributions and FreeBSD, but it is known not to work for a few people.
The "-sndoss" command line switch tells the game engine to use OSS:

  ./glhexen2 -sndoss -sndspeed 44100


c. ALSA sound code
------------------
The ALSA driver is for Linux and is based on the ALSA 1.0.x libraries.
Start the game with "-sndalsa" command line switch:

  ./glhexen2 -sndalsa -sndspeed 44100

If ALSA gives you trouble, try using "plughw:0" or "hw:0,0" instead
of the default device. A lot of ALSA installations have a misconfigured
default device. Example:

  ./glhexen2 -sndalsa -alsadev plughw:0 -sndspeed 44100


d. BSD/SUN sound code
---------------------
The sunaudio driver can be used in combination with our experimental
OpenBSD and NetBSD support.  The "-sndbsd" command line switch tells
the game engine to use sunaudio.

If you can't get sound working, the "-nosound" option will disable it,
send a bug report on the project page.


1.4.1 Midi and Music support
----------------------------

On linux/unix, midi background music is implemented using timidity, so,
you'll need GUS-compatible instrument patch files along with a properly
configured timidity.cfg.  You can get a complete set of GUS patches by
downloading the timidity_patches.tar.gz from our site.  Extract it into
your uHexen2 installation directory and midi should be ready to play:
http://sourceforge.net/project/downloading.php?group_id=124987&filename=timidity_patches.tar.gz

Note to the curious:  Configuration file timidity.cfg is searched first
under the user directory, i.e.: ~/.hexen2, then under the installation
directory, then under the common system locations /etc, /etc/timidity,
/usr/share/timidity, /usr/local/share/timidity, /usr/local/lib/timidity
in this order. Full absolute path of timidity.cfg can be specified by
setting the TIMIDITY_CFG environment variable as an override too, e.g.:
  export TIMIDITY_CFG=/usr/local/share/timidity/timidity.cfg

Hammer of Thyrion supports OGG, MP3 and WAV external music files to be
played instead of the original midi files, so you can enjoy the hexen2
music in good quality like they are from the hexen2 cdrom audio tracks.
Ogg playback requires libogg and libvorbis, mp3 playback requires libmad
or libmpg123 depending on your compile-time decision (see the Makefile).
See README.music for more information.


1.5 Networking / Multiplayer
----------------------------

Since version 1.4.2 (engine version 1.19), Hammer of Thyrion binaries
are fully compatible Raven's Windows Hexen II-1.11 binaries.  When run
as a client, it can connect to Raven-1.11 servers and play just fine.
It can playback the demos created with 1.11 version, as well.
On the other hand if a 1.11 client wants to connect to a uhexen2 server,
the server must be started with "-protocol 18" command line argument.
There is no network compatibility with Hexen II protocols older than 18.
Mission pack is, of course, fully network-compatible across platforms.
As for the other Hexen II ports, uHexen2 is compatible with them, too.


1.6 Game Saves and Configuration files
--------------------------------------

Your game saves and configuration files are stored under .hexen2 in
your home folder:  ~/.hexen2  (for demo version, it's ~/.hexen2demo)

Saves and configs for Hexen2 are stored under ~/.hexen2/data1
For the Mission Pack, they are stored under ~/.hexen2/portals


1.7 Fullscreen/Windowed modes and mouse
---------------------------------------

While playing the game, you can switch between fullscreen and windowed
modes by pressing ALT + Enter combination.  Alternatively, you can use
the relevant menu option.  The last setting will be saved to the config
and will be remembered by the game.

You can also change the resolution from the menu system. Again, the last
setting will be saved to the config and will be remembered by the game.

The menu option "Use Mouse" enables/disables mouse usage on the fly.
While in windowed mode, disabling the mouse ungrabs the mouse pointer,
so that you can easily use your desktop.  You can also ungrab/regrab
the mouse pointer by pressing the  CTRL + G  key combination whenever
you want.


1.8 Joystick (gamepad) support
------------------------------

Hammer of Thyrion supports joysticks (gamepads) through SDL. The feature
can be enabled or disabled on the fly by setting joystick to 1 or 0 from
the console.  It is disabled by default.  On the other hand, the -nojoy
command line switch disables all joystick probing and usage.

The "joy_index" cvar defines which joystick to use if more than one are
attached to the computer. The default value of joy_index is 0, i.e. the
first one.

You can setup which axis to query for which movement or look by using
the following cvars from the console.  -1 means 'none', i.e. if you set
any of them to -1, then the corresponding movement or look will not be
queried on the joystick:

	joy_axisside	Axis for left/right movement		0
	joy_axisforward	Axis for forward/backward movement	1
	joy_axisyaw	Axis for looking left/right		2
	joy_axispitch	Axis for looking up/down		3
	joy_axisup	Axis for up/down movement.	-1 (none)

The following cvars the axis deadzone tolerance values for the above,
all defaulting to 0. suggested values range between 0 to 0.01:

	joy_deadzoneside, joy_deadzoneforward,
	joy_deadzoneyaw,  joy_deadzonepitch,
	joy_deadzoneup

The following cvars are the axis movement multiplier (sensitivity) for
the above, all defaulting to 1:

	joy_sensitivityside, joy_sensitivityforward,
	joy_sensitivityyaw,  joy_sensitivitypitch,
	joy_sensitivityup

----------------------------------------------------------------



2. KNOWN PROBLEMS
-----------------


2.1 Sound Problems
------------------

First, we recommend using 44100 or 48000 as the sampling rate with
recent sound chipsets:  use a command line argument like
"-sndspeed 44100".

If you have problems making sound to work correctly, using the arts
sound server may help you:    artsd & ; artsdsp -m glhexen2 -sndoss
You may notice some lag in sound but if all fails this may be a good
enough workaround.

We have reports that some i8x0 sound chips not working correctly with
hexen2, and this is overcome either by using alsa driver of hexen2 at
48000 sampling rate, or by the arts workaround mentioned above.

The ALSA driver may complain about a non-power-of-two buffer size and
unsatisfactory sound may result.  The following was once reported for
an onboard VIA82xx audiocard:

	ALSA: Using device: default
	ALSA: 14867 bytes buffer with mmap interleaved access
	ALSA: WARNING: non-power of 2 buffer size. sound may be
	unsatisfactory. Recommend using either the plughw or hw
	devices or adjusting dmix to have a power of 2 buf size
	ALSA Audio initialized (16 bit, stereo, 44100 Hz)

You may resolve this by using a .asoundrc like the following,

	pcm.alsa_fixh2 {
		type dmix
		ipc_key 2048
		slave {
			pcm "hw:0"
			rate 48000
			period_time 0
			period_size 1024
			buffer_size 16384
			channels 4
		}
	}

and starting uhexen2 with:

	$ glhexen2 -sndalsa -alsadev alsa_fixh2 -sndspeed 48000

(Notice the -sndalsa -alsadev alsa_fixh2 parameters. Tested and
documented by Davide Cendron.)


2.2 Lines on Screen
-------------------

A common problem, especially with 3dfx cards, is flickering lines
across the screen caused by a GL hack which isn't supported today.
To fix this, bring down the console and enter 'gl_ztrick 0'.  With
fresh installations of uhexen2, this option is disabled by default.


2.3 Fluxbox
-----------

Though it's a great window manager, older versions of fluxbox have
issues with some games in fullscreen mode. If this is the case,
hit "ALT + Enter" twice to switch into windowed mode and then back
into fullscreen mode.

----------------------------------------------------------------


3. GENERAL INFO
---------------


3.1 Mods
--------

Running a Hexen II mod is the same as running a Quake mod: You need
to specify its directory name after a -game argument on the command
line. For example, in order to run Fortress of Four Doors:

    ./glhexen2 -game fo4d

If you want to run some mod with mission pack support enabled, use
a command line with -portals argument included. For example:

    ./glhexen2 -portals -game somemod

Fortress of Four Doors is one of the few large mods for Hexen II. It
has a confusing level near the middle, but is otherwise great. Look
around the web for the file fo4d.zip or fo4d.tgz (also available on
our downloads page.)

Also, make sure to check out the botmatch mod "hcbots" available
at our project page.

Rino recently made his two mods available: mpbyrino and mpbyrino2.
The former works fine with Hexen II, whereas the latter needs the
Portal of Praevus expansion pack.  Rino's mods are at:
https://www.facebook.com/pages/RINO/265889100246732

The "Game of Tomes" mod by peewee_rota (aka ThePunKing) is another new
hexen2 mod:  https://github.com/cabbruzzese/gameoftomes/wiki

And then, there is the somewhat incomplete Project Peanut: Developed
by Shanjaq, Project Peanut introduces RPG elements, such as a massive
array of spells, in a very interesting way. Its homepage is at:
http://www.geocities.ws/shanjaq/index.html

Demo note: You need the full retail version of the game in order to
play modified games: mods are not supported in the demo version.


3.2 Game Console
----------------

Games based on the Quake engine have an in game console - toggled by
the '~' key or by the Shift-Escape key combination - from which
variables can be changed.  Some of these affect performance, others
enable features. A brief list follows but for more info see:
http://www.quakewiki.net/archives/console/commands/quake.html

variable	valid values
--------	------------

fov_adapt	 0 or 1	: Disable/enable Hor+ style field of view (FOV)
			  scaling. Default is enabled: your fov will be
			  scaled automatically according to the screen
			  resolution, so that manual fov changing isn't
			  needed.  Opengl and software renderers both
			  supported.

_snd_mixahead	0.1-0.9	: 0.1 = less latency, 0.9 = better performance.
			  Don't play with the default 0.1 value unless
			  you really need to.

snow_active	0 - 255	: 0 = none, 1 = normal amount designated by the
			  map.  Higher acts as a multiplier, very high
			  values may cause massive performance loss in
			  opengl.


3.2.1 Some opengl options
-------------------------------

gl_multitexture	 0 or 1	: Disable/enable multitexture support.  0 is
			  default.  Faster performance if the hardware
			  supports it.  Menu can be used to change the
			  setting (Video Modes -> Multitexturing.)

gl_texture_NPOT	 0 or 1	: Disable/enable non-power-of-two textures.  If
			  the hardware supports it, it'd make a better
			  job with textures, most noticibly with the 2D
			  elements.  0 is default.  Menu can be used to
			  change the setting (Video -> NPOT textures.)
			  NOTE: Some old graphic cards, such as R300 to
			  R500 class ATI Radeons or NVIDIA GeForce FX,
			  may lie about fully supporting this feature:
			  enabling this on such hardware may result in
			  an unplayable slowdown.

gl_texturemode		: GL_NEAREST	(Point sample, least quality)
			  GL_LINEAR	(Bilinear, no mipmaps)
			  GL_NEAREST_MIPMAP_NEAREST
			  GL_NEAREST_MIPMAP_LINEAR
			  GL_LINEAR_MIPMAP_NEAREST (Bilinear: default)
			  GL_LINEAR_MIPMAP_LINEAR (Trilinear: best)
			  Also adjustable from the menu. Bilinear is
			  recommended. If you don't have an ancient
			  graphics card, you should have no trouble
			  running with the trilinear filtering.

gl_texturemode_anisotropy: 1 is the minimum value with no anisotropic
			  filtering.  Values >= 2 will take effect if
			  the hardware has support for it.

gl_constretch	0 or 1	: Disable/enable console background eye candy.


3.2.2 Software renderer options
-------------------------------

sbtrans		0, 1, 2	: HUD (status bar) transparency.
			  0: none (solid, default setting),
			  1: slightly transparent,
			  2: very transparent.

dmtrans		0, 1, 2	: Same as the sbtrans above, but used for the
			  small deathmatch overlay in multiplayer.

contrans	0, 1, 2	: Same as the sbtrans above, but used for the
			  console background transparency.


3.2.3 Other OpenGL options
-------------------------------

gl_coloredlight	 0, 1, 2: Static colored lights.  0 is the white light
			  that hexen2 traditionally uses.
			  Mode 1 is colored lighting.
			  Mode 2 is experimental, which combines white
			  and colored lighting (if available), and can
			  give better results then just colored lighting
			  sometimes. It is also slightly brighter.
			  0 is the default mode.  Can be adjusted from
			  the menu system. Changing this option requires
			  the level to be reloaded.  Colored lighting
			  requires RGBA lightmaps (also selectable from
			  the menu.)

gl_colored_dynamic_lights 0 or 1:
			  Disable/enable colored dynamic lights.  0 is
			  the default. Also adjustable from the menu.

gl_extra_dynamic_lights   0 or 1:
			  Disable/enable extra dynamic lights. 0 is the
			  default. Also adjustable from the menu.

gl_purge_maptex	  0 or 1: Purge opengl textures upon map changes.  The
			  textures won't keep accumulating from map to
			  map, but the levels will load slower. Default
			  is 1. Adjustable from the menu.


3.2.4 Nvidia tweaks
-------------------------------

These are only valid for supported hardware (Geforce and better) with
Nvidia's proprietary linux video drivers installed.

The -sync or -vsync command line switch forces GL redraws to sync with
the monitor refresh for a more stable image. This is equivalent to
setting the environment variable __GL_SYNC_TO_VBLANK to 1.

You can override our -fsaa switch if you set Nvidia-specific environment
variable __GL_FSAA_MODE to an appropriate value.  The details for this
can usually be found in Nvidia's readme file.  Briefly: Geforce 1 and 2
use mode 3 or 4, others 1, 2, 4 or 5.


3.3 Hardware Acceleration
-------------------------

Setting up hardware OpenGL acceleration under Linux used to be a big
deal in the past. Modern linux distros do this automatically now.

Nvidia's drivers for all of their modern video cards are not open
source, and because of this many distributions do not include them.
If your Nvidia card is running slowly, this is probably the cause, you
should visit Nvidia.com to download the linux installer.  In my
experience these drivers are great, but not all versions work 100% with
all cards. If you have a misbehaving Nvidia video card, try a different
driver version.  Linux kernel 2.6.8 / Nvidia driver version 6111 /TnT
card and possibly other cards and kernels have issues with the GL game:
upgrade to 7167 to fix these problems. If you don't want to change your
nvidia driver and the game seems to halt, try using the alt-enter key
combination to switch to windowed mode and redraw the screen. Behavior
is the same for glquake.

3dfx Voodoo1/2 and Voodoo Rush are no longer hardware accelerated under
XFree-4.x and X.org releases. You need Glide, and Mesa compiled against
glide.  For some more detailed info, consult the document README.3dfx.


3.4 Thanks
----------

Thanks to ID Software, Raven Games and Activision for a great game and
for supporting open source software, to Dan Olson and Clément Bourdarias
for the initial Linux port, and to sourceforge.net for hosting us.  Many
thanks to all of our contributors: see the AUTHORS file for a complete
list of them.


3.5 Links
---------

3.5.1  Hammer of Thyrion pages:
-------------------------------

Home page		: http://uhexen2.sourceforge.net/
Project page		: http://sourceforge.net/projects/uhexen2/
SVN Repository		: http://sourceforge.net/p/uhexen2/code/

3.5.2  Hammer of Thyrion ports:
-------------------------------

AmigaOS4 port:
http://os4depot.net/?function=showfile&file=game/roleplaying/uhexen2.lha

Pandora (GP2X) port:
http://dl.openhandhelds.org/cgi-bin/pandora.cgi?0,0,0,0,30,66

PalmOS port: http://www.metaviewsoft.de/

RISC OS port:
http://www.riscository.com/2012/hexen-ii-port-released/
http://www.iconbar.com/forums/viewthread.php?threadid=8455&page=1#120298

3.5.3  Hammer of Thyrion packages / builds:
-------------------------------------------

FreeBSD packages:
http://www.freshports.org/games/uhexen2/

Arch Linux packages:
https://aur.archlinux.org/packages/hexen2/

Gentoo ebuilds:
http://bugs.gentoo.org/show_bug.cgi?id=105780

3.5.4  Other Hexen II ports:
----------------------------

Hexen II PSP port: http://jurajstyk.host.sk/

JLQuake, a Quake1/2/3 and H2/HW engine:
http://sourceforge.net/projects/vquake/

FTEQW, a Q1/QW engine with H2 support:
http://sourceforge.net/projects/fteqw/

Korax's UQE Hexen II: http://www.jacqueskrige.com/

3.5.5  Older, currently inactive Hexen II ports:
------------------------------------------------

Hexen II Mac port : http://macglquake.sourceforge.net/
Hexen II Dreamcast: http://dcquake.sourceforge.net/
JSHexen II	  : http://jurajstyk.host.sk/
Pa3PyX's Hexen II : http://pa3pyx.dnsalias.org/
Kiero's old MorphOS port of Hammer of Thyrion:
		    http://www.binaryriot.org/users/kiero/

3.5.6  Other links:
-------------------

Hexen II resources at gamers.org:
http://www.gamers.org/pub/idgames2/hexen2/
http://www.gamers.org/pub/idgames2/planetquake/hexenworld/

Rino's Hexen II mods:
https://www.facebook.com/pages/RINO/265889100246732

Game of Tomes mod by peewee_rota (aka ThePunKing):
https://github.com/cabbruzzese/gameoftomes/wiki

DarkRavager's Hexen II resources:
http://pages.citenet.net/users/danielm/hexen/hexen.html

Linux Quake HOWTO: http://tldp.org/HOWTO/Quake-HOWTO.html

id Software   : http://www.idsoftware.com/
Raven Software: http://www.ravensoft.com/

SDL homepage  : http://www.libsdl.org/
ALSA homepage : http://www.alsa-project.org/


---------------------------------
APPENDIX  A.  Some Legacy Options
---------------------------------

If, while running around, the screen occasionally twitches up and down,
then disable lookspring by typing "lookspring 0" in the game console.

Lookspring, lookstrafe and keyboard look (+klook) are legacy options
from DOS times for systems without a mouse, which we didn't kill only
for historical reasons. They are pretty much of no use today and we
recommend disabling them if they aren't already. Those options and/or
key bindings are removed from the menu system of Hammer of Thyrion.

For reference, here are what they are meant to do, as written in the old
manuals:

 lookspring:	0 or 1. Returns your view immediately to straight ahead
		when you release the look up / down key. Otherwise, you
		must move forward for a step or two before your view
		snaps back.

 lookstrafe:	0 or 1. If you are using the look up / down key, then
		this option causes you to sidestep instead of turn when
		you try to move left or right.

 keyboard look: If +klook is bound to a key, press that key to use your
		movement keys to look up or down.

 mouse look:	If +mlook is bound to a key, press that key to allow
		your mouse to look up or down (by sliding it forward and
		back), and to remain looking up or down even if you move
		forward.

And here are some legacy opengl options:

 gl_picmip (0, 1, 2): 0 is default. 1 and 2 scale down the textures (low
		quality), but the help screens and some small fonts
		become unreadable and ugly. Was useful with old hardware
		with low memory back at the time. Keep it as 0.

 gl_playermip:	similar to gl_picmip, but was for player skins.

 gl_ztrick (0 or 1): 3% performance hack mostly unsupported today. (See:
		http://forums.insideqc.com/viewtopic.php?p=36082#p36082)
		Keep it as 0.

