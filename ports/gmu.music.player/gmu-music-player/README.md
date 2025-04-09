# The Gmu Music Player

Copyright (c) 2006-2021 Johannes Heimansberg

http://wej.k.vu/projects/gmu/

## Introduction

Gmu is a music player application. It was initially developed for
the GP2X handheld, but has since then been adapted to run on a
variety of other devices, including ordinary computers and lots of
handheld devices.

Gmu is built in a modular way and supports various frontends and
decoders for supports of different user interfaces and file formats
respectively.

Gmu's most used frontend is the SDL based frontend which gives the
user a graphical user interface optimized for control through
buttons. Besides that, Gmu comes with a web frontend which allow Gmu
to be controlled through a web browser both locally and remotely.
There is also a command line tool (``gmuc``) for controlling Gmu
through a terminal, again both locally and remotely.

Supported audio formats include MP3, MP2, Ogg Vorbis, Speex, Ogg
Opus, FLAC, Musepack, WavPack and lots of module formats through
different module decoder libraries (ranging from MikMod for devices
with low end CPUs to OpenMPT for devices with a more capable CPU
delivering a higher quality).

Gmu is open source software, licensed under the GPLv2 and comes
without any warranty. For details see file ``COPYING``. Gmu has been
written by me, Johannes Heimansberg.

Table of contents
-----------------

1. Installation
2. Program information
 - 2.1 Supported file formats
 - 2.2 Usage
3. Controls
 - 3.1 GP2X defaults
 - 3.2 Dingoo A320/A330 defaults
 - 3.3 Ben NanoNote defaults
 - 3.4 Custom key mappings
4. Command line arguments
5. Config file
6. Additional plugins and tools
 - 6.1 Log bot
 - 6.2 gmuc Gmu Ncurses interface
 - 6.3 IR remote control plugin (LIRC)
 - 6.4 HTTP frontend
7. Libraries used by Gmu

Build instructions can be found in the BUILD.txt file.


## 1. Installation

The installation process depends on the device Gmu is going to be
installed on. Some devices come with Gmu preinstalled, for other
devices there is a package installable by the package manager used
on that device (e.g. ipkg or opkg). For other devices you just need
to extract the Gmu ZIP archive on the memory card (or internal memory).

### GP2X & Wiz release
To run the player start ``gmu-gp2x.gpu`` or ``gmu-wiz.gpu`` depending
on which device you are using.

On the Wiz the Start button is labled "Menu". Both are the same.

### Dingoo A320 release
Make sure you use a recent version of Dingux and its root filesystem
(uclibc based). 

To make running Gmu on the Dingoo a little easier, I've included
a shell script called ``gmu.dge``. Simply execute that script from a
file browser or menu application (like dmenu). Previously this
script was called ``gmu.goo``, but since the ``.dge`` extension has
been becoming more popular for executables on Dingux, I've chosen to
rename it to ``gmu.dge``.

### Ben NanoNote release
The Ben NanoNote come with Gmu preinstalled. If you use an older 
Firmware image or want to upgrade Gmu, you can use opkg to do that.
To install Gmu with opkg run:

```
opkg install gmu_0.9.1-1_xburst.ipk
```

Once Gmu has been installed on the NanoNote, you can run it by
executing ``gmu``.
Make sure you are using a recent kernel and rootfs. Older versions
contain errors that might prevent Gmu from running.
If you have been upgrading from an older Gmu version, you might need
to remove the ``/root/.config/gmu`` directory before starting Gmu.

## 2.1 Supported file formats

Audio file formats are supported through decoder plugins, so 
file format support may vary from one platform to another. For
the following file formats there are decoder plugins available:

- Ogg Vorbis (.ogg)
- MP3 (.mp3)
- MP2 (.mp2)
- Musepack (.mpc)
- FLAC (.flac)
- Speex (.spx)
- Ogg Opus (.opus)
- WavPack (.wv, .wvc)
- Module formats (including MOD, IT, STM, S3M, XM, 669, ULT among others)
- M3U (Gmu can read and write .m3u playlists)
- PLS (Gmu can read .pls playlists)

The decoder plugins use external libraries for decoding the
specific audio files. Those libraries must be available for
the target platform for the decoder plugins to work.

## 2.2 Usage

Gmu supports multiple frontends. This section describes the
SDL frontend.
Other frontends include the log frontend, which does nothing 
but log played files to a text file, the LIRC frontend, which 
can be used to control Gmu with a IR remote control with the 
help of LIRC and the gmuhttp frontend, which exposes a 
WebSocket-based interface that can be accessed through
a web browser, as well as through the ``gmuc`` Gmu command line
client.

### 2.2.1 The Screen

Gmu comes with a graphical frontend and is being controlled 
through buttons. Its screen is divided into three part: The
display area, the content area and the footer area.
The display area shows information about the player's state,
like the currently played track (track title, bit rate, sampling
rate, stereo/mono), playback state (through symbols: play, pause),
and play time. Besides that, important information are also being 
displayed through text messages appearing instead of the track title.
A blinking play/pause symbol denotes that playback of an internet 
audio stream is being prepared for playback and the data are currently 
pre-buffered for smooth playback.

In the main content area Gmu shows different information depending on
which screen has been selected. There are three main screens: The
file browser (for browsing local files and adding files to the playlist),
the playlist (consists of the audio tracks Gmu is going to play; Audio
tracks can be selected and played immediately or queued for playback).
The third screen is the track info screen, which shows various 
information about the current track, including cover graphics and lyrics 
(if available) and a graphical spectrum analyzer.

Gmu comes with an in-program help screen with information on most
button mappings and functions. Also see chapter 3 in this file.

### 2.2.2 Internet audio streams

To play internet audio streams, you need to download a playlist file 
from the audio stream's website and open that file with Gmu. Both 
common playlist file formats (m3u and pls) are supported. Currently
Gmu supports MPEG audio, Ogg Vorbis and Ogg Opus for internet audio
streams. More audio file formats might be supported in future versions.


## 3. Controls

When running Gmu for the first time, Gmu shows an introduction 
screen where most functions and their button mappings are explained.
This screen can be opened again at any time by activating the help
function. The button mappings listed in this file, might be slightly
out-of-date. If some button does not seem to work as expected, you
could have a look at the .keymap file that is being used to verify
the button mapping. See 3.4 for more information about .keymap files.

## 3.1 GP2X defaults

These are the default controls. You can remap all button by creating
your own keymap file. See below for details. These key mappings
assume that the stick click is available, which is not the case for
GP2X-F200 units. When using a GP2X-F200 edit the ``gmu.gp2x.conf``
file with a text editor and change the line ``KeyMap=gp2x.keymap``
to ``KeyMap=gp2x-f200.keymap`` to use the ``gp2x-f200.keymap`` file
or create your own keymap file. With the ``gp2x-f200.keymap`` file
the left shoulder button is used as the modifier key instead of the
stick click.

### Global

```
R            - Skip to next track in playlist/Start playback
L            - Skip to previous track in playlist
CLICK+R      - Seek 10 seconds forward (**)
CLICK+L      - Seek 10 seconds backward (**)
START        - Pause/resume playback
X            - Stop playback
CLICK+START  - Exit player
SELECT       - Toggle file browser/playlist view/track info
VOL+/-       - Increase/lower volume
CLICK+SELECT - Toggle hold (LCD is turned off in hold state)
CLICK+A      - Program info
CLICK+VOL-   - Toggle time elapsed/remaining
```

### File browser

```
A            - Play file without adding it to the playlist
B            - Add selected file to the playlist/Change directory
Y            - Add selected directory and all sub directories
CLICK+B      - Insert selected file after selected playlist item
CLICK+X      - Delete selected file (*)

Playlist:
A            - Change play mode (continue, repeat all, 
               repeat track, random, random+repeat)
B            - Play selected track
Y            - Remove selected track
CLICK+Y      - Clear playlist
CLICK+X      - Delete the file of the selected track (*)
```

### Track info viewer

```
A            - Show/hide cover artwork
B            - Show/hide text
```

(*) These actions are disabled by default. If you want 
to be able to delete files from the file browser and/or
playlist browser, you need to uncomment these lines in
your ``default.keymap`` file:

```
#FileBrowserDeleteFile=Mod+X
#PlaylistDeleteFile=Mod+X
```

Simply remove the ``#`` to enable these key mappings.


## 3.2 Dingoo A320/A330 defaults

The default key mapping for the Dingoo A320/A330 is as follows:

### Global

```
R            - Skip to next track in playlist/Start playback
L            - Skip to previous track in playlist
SELECT+R     - Seek 10 seconds forward (**)
SELECT+L     - Seek 10 seconds backward (**)
X            - Pause/resume playback
SELECT+X     - Stop playback
SELECT+START - Exit player
START        - Toggle file browser/playlist view/track info
LEFT/RIGHT   - Increase/lower volume
SELECT+A     - Program info
SELECT+LEFT  - Toggle time elapsed/remaining
```

### File browser

```
A            - Play file without adding it to the playlist
B            - Add selected file to the playlist/Change directory
Y            - Add selected directory and all sub directories
SELECT+B     - Insert selected file after selected playlist item
```

### Playlist

```
A            - Change play mode (continue, repeat all, 
               repeat track, random, random+repeat)
B            - Play selected track
Y            - Remove selected track
SELECT+Y     - Clear playlist
SELECT+RIGHT - Enqueue selected item

Track info viewer:
A            - Show/hide cover artwork
B            - Show/hide text
```


## 3.3 Ben NanoNote defaults

The default key mapping for the Ben NanoNote is as follows:

### Global

```
M            - Skip to next track in playlist/Start playback
N            - Skip to previous track in playlist
Alt+M        - Seek 10 seconds forward (**)
Alt+N        - Seek 10 seconds backward (**)
P            - Pause/resume playback
Alt+X        - Stop playback
Alt+Q        - Exit player
Tab          - Toggle file browser/playlist view/track info
Volume Up/Dn - Increase/lower volume
Alt+A        - Program info
T            - Toggle time elapsed/remaining
F1           - Help
```

### File browser

```
A            - Play file without adding it to the playlist
Enter        - Add selected file to the playlist/Change directory
Y            - Add selected directory and all sub directories
Alt+Enter    - Insert selected file after selected playlist item
```

### Playlist

```
R            - Change play mode (continue, repeat all, 
               repeat track, random, random+repeat)
Enter        - Play selected track
Y            - Remove selected track
Alt+Y        - Clear playlist
Q            - Enqueue selected item
S            - Save playlist
```

### Track info viewer

```
A            - Show/hide cover artwork
B            - Show/hide text
```

(**) Seeking does not work with all file formats.


## 3.4 Custom key mappings

You can customize Gmu's key mappings if you don't like the defaults. 
To do that open the .keymap file in a text editor or copy it to a
new file with the ``.keymap`` extension (such as ``my.keymap``) and
open that one in an editor. The name of the default ``.keymap`` file
depends on which device you are using. E.g. on a Dingoo it is called
``dingoo.keymap``, while on a Wiz it is called ``wiz.keymap``.

The first thing you need to know is, that Gmu uses one button as a
meta key (modifier). If that key is pressed, all other buttons have
a different meaning. This way you can have twice as many (minus one)
functions mapped to the keys as you could have without a meta key.
First, you should choose one of the buttons as you meta key. You can
change it by editing the ``Modifier=`` line. By default it is set to

```
Modifier=STICK_CLICK
```

on the GP2X and

```
Modifier=SELECT
```

on the Dingoo.

If you prefer to use the START button for example, you would have to
change it to

```
Modifier=START
```

All other functions can be defined the same way
(``Function=Button``), with the exception that you can use the
previously defined meta key in the definitions. You can do that by
using ``Mod+`` followed by the button name.
Lets say you want to map the random function to the ``Y`` button when
the modifier (meta) button is pressed you would do it by changing the
``PlaylistToggleRandomMode`` line as follows:

```
PlaylistToggleRandomMode=Mod+Y
```

Among the possible buttons are:
``A``, ``B``, ``X``, ``Y``, ``START``, ``SELECT``, ``L``, ``R``, ``VOL+``,
``VOL-``, ``STICK_CLICK``, ``STICK_LEFT``, ``STICK_RIGHT``, ``STICK_UP``
and ``STICK_DOWN``.

Depending on the device Gmu is running on, there can be less or more
available buttons. For each device there is a button definition file
``gmuinput.[device].conf`` with all available buttons and their key
codes, e.g. on the GP2X the file is usually called ``gmuinput.gp2x.conf``.
The button definition file is referenced from the main Gmu config
file via the ``SDL.InputConfigFile`` key, e.g.
``SDL.InputConfigFile=gmuinput.gp2x.conf``.

There are a few alternate keymap example files included.
To use them, edit your ``gmu.conf`` with a text editor and change
the ``KeyMap=default.keymap`` line accordingly.


## 4. Command line arguments

Gmu now accepts files to be added through the command line. This can
be useful, if you want to run Gmu through a file manager. You can
add multiple files on the command line and they will be added to the
playlist and playback will be started automatically.

#### Example

```
./gmu song1.mp3 another_song.ogg cool_tune.s3m list.m3u
```

This would add the three files and the contents of the playlist file
``list.m3u`` to the playlist in the given order and start playback
with the first song.

To enable the random playback mode you can use the ``-r`` flag.

#### Example

```
./gmu -r list.m3u
```

With the ``-s`` option you can load another theme instead of the default
theme specified in the configuration file.

#### Example

```
./gmu -s theme_name
```

## 5. Config file

Gmu's config file name again depends on the device you are using.
On the GP2X it is called gmu.gp2x.conf, while on the Dingoo it is
called gmu.dingoo.conf. It is a plain text file, with UNIX linebreaks.
You can open it in any real text editor, such as vim, Geany, or 
Notepad++ (Windows only). Do not use Notepad or (which is even worse)
Wordpad.

__Please note:__ Most of the following options can be changed through
the Gmu setup tool (up to Gmu version 0.6.3) without editing the config
file.

## Supported options

### Gmu.DefaultFileBrowserPath

You can use this to define the path where the file browser will start.
It is set to ``.`` by default, which is the current directory. You can
set it to any path you like. Both absolute and relative paths can be
used. Make sure the path exists otherwise gmu will fall back to its
current directory.

### SDL.DefaultSkin

With this option you can specify the default skin which Gmu loads if no
``-s`` parameter is used. By default it is set to ``default-modern``.
There are a few other themes included with Gmu by default, which can be
used instead. Please note that from Gmu 0.7.0_BETA8 onwards, Gmu uses a
new more advanced theme format. Versions 0.7.0_BETA8 and newer are no
longer compatible with the classic skin file format.

### SDL.KeyMap

With this option you can specify the key map file Gmu loads
on start up. By default it is set to ``default.keymap``.

### Gmu.RememberLastPlaylist

This option can be set to ``yes`` or ``no``. If set to ``yes`` (which is
the default) gmu will save its playlist on exit and restore it the next
time gmu is started. Gmu stores the playlist in a file called
``playlist.m3u`` located in Gmu's directory.
You can disable this behaviour by setting it to ``no``.

### SDL.AutoSelectCurrentPlaylistItem

This option can be set to ``yes`` or ``no``. If set to yes Gmu moves the
cursor to the current playlist item each time a new track begins.

### SDL.AllowVolumeControlInHoldState

This option can be set to ``yes`` or ``no``. When set to ``yes`` you can
adjust the volume even if the player is in the hold state. The default
is ``no``.

### SDL.SecondsUntilBacklightPowerOff

When this option is set to any number greater than zero, the screen
backlight will be turned of after the given number of seconds of
inactivity. Any key press turns it back on again. The action of the key
you used to turn it on again is executed normally. If you just want to
turn the screen on again, press the stick button.

### SDL.EnableCoverArtwork

This option can be set to ``yes`` or ``no``. If set to ``yes`` Gmu tries
to find a cover artwork for the current track and displays it in the
track info view.

### SDL.CoverArtworkFilePattern

This option tells Gmu for what files it should search as a cover image.
It is set to ``cover.jpg;*.jpg`` by default. Gmu will use the first file
that matches the given patterns. Allowed wildcards are ``*`` (which
means any number of arbitrary characters), the ``?`` (which means
exactly one arbitrary character) and the $ sign (which stands for the 
file name of the current file without its extension). Besides those you
can use any other character. Those characters match themselves.
Gmu searches for the cover image in the same directory where the current
file is located. You can use multiple patterns each seperated by a
semicolon (;). The first pattern given has the highest priority.
With ``cover.jpg;*.jpg`` Gmu would try to find a cover.jpg in the
directory first and if it is not found it would try any other jpg file.   

#### Examples

``CoverArtworkFilePattern=cover*.jpg`` matches every filename
that starts with "cover" followed by any number of characters
including 0), followed by ".jpg".

``CoverArtworkFilePattern=cover?a.png`` matches every filename
that starts with "cover" followed by one arbitrary character,
followed by "a.png".

``CoverArtworkFilePattern=cover.jpg`` matches the file called
"cover.jpg" and nothing else.

Assuming the current file is called great_song.ogg with this
pattern:

```
CoverArtworkFilePattern=$.jpg;$.png;cover.jpg 
```

Gmu tries to find a file called great_song.jpg first, then 
(if the first one was not found) great_song.png and if even
that was not found, it tries to find cover.jpg. 


If no file is found that matches the given pattern, no cover will be
displayed. Gmu will resize the image to fit on the screen if neccessary,
but using HUGE images should be avoided as it slows down the cover
loading and could even cause Gmu to run out of memory on devices with
little memory, if the dimensions of the image are very large (such as 
3000 x 2000 pixels which would need 17 MB in memory even if the jpg file
is much smaller in file size). Recent Gmu versions no longer run out of
memory but refuse to load files with large dimensions.

### SDL.CoverArtworkLarge

This option can be set to ``yes`` or ``no``. If set to ``yes``
Gmu scales the cover image to fit the screen's width.
You can scroll up and down to see the whole image if its
height is larger than the screen height.
If the option is set to ``no`` (which is the default) Gmu
scales the image so that its width is at most half the
screen width. The actual width depends on the image 
proportions as Gmu keeps the aspect ratio of the image.

### SDL.SmallCoverArtworkAlignment

This option can be set to ``left`` or ``right``. If set to
``left`` and large cover artwork is disabled, the cover 
artwork will be aligned on the left side and the text
on the right side. When set to ``right`` it is the other
way round. It is set to ``right`` by default.

### SDL.LoadEmbeddedCoverArtwork

This option can be set to ``first``, ``last`` or ``no``. If set
to ``first`` Gmu tries to load a cover image embedded in 
the audio file first and if that is not available Gmu 
tries to load an image file matching the given pattern.
If set to ``last`` Gmu will try to load a cover image from
file first and if none is found it tries to load an image
from the song meta data.
If set to ``no`` Gmu will not try to load a cover from the
meta data at all.
This option has no effect if ``EnableCoverArtwork`` is set to
``no``.
``LoadEmbeddedCoverArtwork`` is set to ``first`` by default.

### Gmu.LyricsFilePattern

This option tells Gmu for what files it should search as
a lyrics text file. It is set to "$.txt;*.txt" by default.
Gmu will use the first file that matches the given patterns.
Allowed wildcards are * (which means any number of 
arbitrary characters), the ? (which means exactly one
arbitrary character) and the $ sign (which stands for the 
file name of the current file without its extension). Besides
those you can use any other character. Those characters match
themselves.
Gmu searches for the lyrics text file in the same directory
where the current file is located. Gmu auto-detects the
charset used in the text file. The charset can be either UTF-8
or ISO-8859-1.
For examples how to use this option have a look at the examples
in the ``CoverArtworkFilePattern`` section.

### Gmu.FileSystemCharset

This option can be either set to ``UTF-8`` or ``ISO-8859-1``. It
selects the charset of the file system. By default it is
set to ``UTF-8``. If file names appear with weird characters
in Gmu's file browser you might want to try setting it
to ``ISO-8859-1``.

### Gmu.PlaylistSavePresets

This option is a semicolon separated list of .m3u 
file names. Up to ten file names can be specified here.
When saving a playlist in Gmu you can choose one filename
out of this list as the target file name.

### Gmu.DefaultPlayMode

This option can be set to ``continue``, ``repeatall``, ``repeat1``,
``random`` or ``random+repeat``.
In ``continue`` mode Gmu plays one track after another and stops
after playing the last track in the playlist.
In ``repeatall`` mode Gmu repeatedly plays all tracks in the 
playlist.
In ``repeat1`` mode Gmu repeatedly plays the currently selected
track.
In ``random`` mode Gmu plays all tracks in the playlist in random
order.
In ``random+repeat`` mode Gmu repeatedly plays all tracks in the
playlist in random order.
No matter which play mode has been selected through this option,
you can still select another play mode from within Gmu. When
``RemeberSettings`` is set to ``yes`` Gmu stores the selected play
mode on exit as the new ``DefaultPlayMode``.

### SDL.TimeDisplay

This option can be either set to ``elapsed`` or ``remaining``.
When set to ``elapsed`` Gmu shows the elapsed time of each
track by default, otherwise Gmu shows the remaining time
(if total track time is available). This option is set
to ``elapsed`` by default. No matter what this option is
set to, you can always toggle the time display from
within Gmu. The default keymapping for this is 
STICK_CLICK + VOL-.

### SDL.Scroll

This option can be set to ``auto``, ``always`` or ``never``. 
If it is set to ``auto`` Gmu decides if it is neccessary to
scroll the title or not depending on the title's length
and the available display space. If set to ``always`` the 
title scrolls no matter if it fits into the display's 
width or not. If it is set to ``never`` the title never 
scrolls, even if it does not fit into the display's width.

### SDL.BacklightPowerOnOnTrackChange

This option can be set to either ``yes`` or ``no``. When set
to ``yes`` that display backlight is turned on again each
time a new track starts. If ``SecondsUntilBacklightPowerOff``
is set to ``0`` this option does not do anything.

### Gmu.FileBrowserFoldersFirst

This option can be set to either ``yes`` or ``no``. When set
to ``yes`` all folder will be shown before the regular files.
When set to ``no`` all files are shown in alphabetical order.

### Gmu.RememberSettings

This option can be set to either ``yes`` or ``no``. When set
to ``yes`` Gmu remembers settings such as the time display
setting and the selected play mode.

### Gmu.VolumeControl

This option can be set to ``Software``, ``Hardware`` or
``Software+Hardware``. In software volume control mode Gmu
sets its volume solely by scaling the signal in software.
This works on every hardware supported, so it is a safe
way of controlling the volume. Also, very small volume
changes are possible this way. The downside of this method
is, that at lower volumes it can have a audible influence
on the sound quality. Hardware volume control on the other
hand uses the sound devices hardware mixer to control the
volume. The advantage is that there is no quality loss. A
disadvantage of this method is that the volume steps might
be too large. To combine the advantages of both methods,
while trying to avoid the biggest disadvantages of both
methods, there is a third option "Software+Hardware"
available, which uses software volume control only for the
lowest volume steps. For everything above a the minimum
hardware volume level, only hardware volume control is being
used.

### Gmu.Volume

This option can be set to an positive integer value. The
largest valid value depends on which volume control method
has been selected. For software volume control the maximum
value is 16. For hardware volume control it is 100, while
in ``Software+Hardware`` mode the maximum is 116.
Higher values result in higher volumes. You don't need to
set this manually in the config file. Gmu remembers its
volume setting on exit when the ``RememberSettings`` option
is set to ``yes``.

### Gmu.AutoPlayOnProgramStart

This option can be set to either "yes" or "no". When set
to "yes" Gmu starts playback right after the program has 
been started. You don't need to press a button unless the
playlist is empty. When using this option, Gmu plays the
first track in the playlist, or an arbitrary track when in
random playmode.

### Gmu.ResumePlayback

This option can be set to either "yes" or "no". When set
to "yes" Gmu starts playback right after the program has 
been started and resumes playback exactly where Gmu was
terminated on the last run. If Gmu was terminated while
not playing a track, Gmu does not resume playing on the
next run. You probably want to enable this feature when
listening to large files such as podcasts.
ResumePlayback is enabled by default.

### Gmu.Shutdown

With the shutdown option it is possible to tell Gmu to
shutdown itself either after a number of minutes or after
the last track in the playlist has been played. To configure
Gmu to shut down after 30 minutes the following line should
be added to the configuration file:

```
Shutdown=30
```

To tell Gmu to shut down when reaching the end of the playlist
the line should be:

```
Shutdown=-1
```

To disable the shut down timer it should be

```
Shutdown=0
```

All of these configurations can be set from within Gmu. With
the default key mapping it would be ``Meta+DOWN``. By pressing
these buttons you can select various power down  timer
configurations (off, 15, 30, 60 minutes, power down after last
track).
After shutting down Gmu can execute a command to power down
the device. This command can be configured through the
ShutdownCommand option.

### Gmu.ShutdownCommand

With this option you can set the command to be executed when
Gmu shuts itself down (see Shutdown option). By default it is
set to:

```
ShutdownCommand=/sbin/poweroff
```

Powering down the device does not work on the GP2X-F100 and -F200
as these devices have a mechanical power switch.

### SDL.FileBrowserSelectNextAfterAdd

This option allows you to decide wether you want the selection in 
the file browser to advance to the next file after adding a file to
the playlist. It can be set to "yes" or "no".

### SDL.Fullscreen

With this option the fullscreen mode can be enabled or disabled
on start-up.  It can be set to "yes" or "no". On some devices
disabling fullscreen is useless. This is the case for most devices
running SDL on a framebuffer device instead of an X server.

### Gmu.ReaderCache

This option is used to set the HTTP read cache size. It is set in
values of KB (kilo bytes). The minimum size is 256 KB, while the
maximum size is 4096 KB.

#### Example

```
ReaderCache=256
```

Usually you should leave it at its default value, although on 
rather unstable network connections increasing the size might help
permitting playback of http audio streams without interruption.

### Gmu.ReaderCachePrebufferSize

This option is used to set the amount of data to be prebuffered,
before starting playback of an http audio stream. The minimum
prebuffer size is 0, while the maximum prebuffer size is 3/4 of
the ReaderCache size. Setting it to half of the reader cache size
is usually recommended.


## 6. Additional plugins and tools

## 6.1 LogBot

The logbot allows you to write all played tracks to a log file.
The file format is as follows (CSV). Each line represents one
track and consists of the following things:

```
Date+Time;"Artist";"Title";"Album";Length
```

Date+Time looks something like ``Sat Dec 26 11:42:23 2009``.
Length is stored as "Minutes:Seconds", e.g. ``3:42``.

The logbot can be configured through some options in the config
file. The following options are available:

### Log.Enable

This option can be either set to "yes" or "no". When set to
"no" the log bot will be disabled. This is the default.

#### Example

```
Log.Enable=yes
```

### Log.File

This option should contain the filename of the desired logfile
including its full path. If the path is ommitted, the logfile will
be placed in Gmu's working directory (which is usually the
Gmu installation directory. It defaults to "gmu.log".

#### Examples

```
Log.File=/var/log/gmu.log
```

or

```
Log.File=tracks.log
```

### Log.MinimumPlaytimeSec

This option can contain a non-negative integer number. It defines
the minimum number of seconds that need to be played for the track
to be written to the logfile. If you want the track to be written
to the logfile even if it is skipped immediately, set this option
to 0. Make sure to also have a look at the following option.
In case a track is shorter than the minimum playtime it will be
written to the log anyway.

#### Example

```
Log.MinimumPlaytimeSec=30
```

### Log.MinimumPlaytimePercent

This option is similar to the previous one, except that you do not
specify an absolute number of seconds, but a percentage. Both, this
option and the previous one, will always be evaluated. So if you
have set Log.MinimumPlaytimeSec = 30 and Log.MinimumPlaytimePercent
= 50 and your current track's length is 4:00, the track needs to be
played for at least two minutes to be written to the logfile. If the
track's length was only 0:50, the track would need to be played for
at least 30 seconds, even though 50 percent of 50 seconds would be
equal to 25 seconds.

#### Example

```
Log.MinimumPlaytimePercent = 50
```


## 6.2 gmuc Gmu Ncurses interface

``gmuc`` is a new ncurses based interface for Gmu. It works over the
network, so it can be used to control Gmu running on another 
computer. The UI should be pretty self-explanatory, as it is closely
modeled around Gmu's SDL interface. The keys can/will differ from
the SDL interface, though. The actual key bindings are shown on the
last line in the terminal.

The most imporant ones are:

### Global

```
q - Quit gmuc (Ctrl+C also quits gmuc)
n - Play next track
b - Play previous track
p - Play/Pause
s - Stop playback
Tab - Switch to next window
+ - Increase volume
- - Decrease volume
```

### Playlist

```
Del - Remove selected track
c - Clear entire playlist
m - Change play mode
```

### File browser

```
a - Add file or directory to playlist
ENTER - Change directory
```

``gmuc`` has its own config file, which is by default located in
``~/.config/gmu/gmuc.conf``. Another config file location can be
specified on the command line through the ``-c`` parameter.
The config file will be created when gmuc is started for the first
time. It currently contains three keys: ``Host``, ``Password`` and
``Color``. ``Host`` and ``Password`` specify the hostname and
password to use for connecting to the Gmu server. Obviously, the
password has to match the password set in the main Gmu config file
(key: ``gmuhttp.Password``). It has to be at least nine (9)
characters long.
The ``Color`` option specifies, whether ``gmuc`` should use colors
for its interface.
To be able to connect to the Gmu http server from another host,
gmuhttp needs to be configured to not only listen on the local
interface (which is the default). This can be configured through the
config key ``gmuhttp.Listen`` in Gmu's main config file.

To listen on all available network interfaces, set it to ``All``:

```
gmuhttp.Listen=All
```

To listen on the local interface only, set it to ``Local``:

```
gmuhttp.Listen=Local
```


## 6.3 IR remote control plugin (LIRC)

Gmu comes with a plugin which allows the user to control Gmu with a
IR remote control on plattforms that have LIRC compatible hardware.
This plugin is not enabled by default, but is included with Gmu's
source.
To use the plugin LIRC needs to be configured properly with a 
compatible IR receiver present on the system running Gmu. Once
LIRC is configured properly, the ``~/.lircrc`` config file needs to
be altered, so that can Gmu receive commands from the remote
control. For each function you need to add some lines to the file,
e.g.:

```
begin
    prog = gmu
    button = KEY_PLAY
    config = toggle_play_pause
end
```

Gmu supports the following functions to be controlled by IR remote
control: ``toggle_play_pause``, ``next``, ``prev``, ``stop``,
``volume_up``, ``volume_down``.

## 6.4 HTTP frontend

Gmu includes an http plugin that features a small web server with
web socket support. The web server listens on port ``4680`` and is
configured to listen on the loop back interface only, by default.
You can change the configuration so that it listens on all
interfaces, though.

All config options for this plugin start with the prefix
``gmuhttp.``.

To use this frontend with a web browser, you need a modern web
browser with WebSocket support. As of this writing, both Firefox 18
and Chromium/Chrome 24 support WebSocket and have been tested with
Gmu. Other browser might or might not support WebSocket yet.
Internet Explorer 9 is known to not support WebSocket yet.
The http frontend can also be accessed through the ncurses-based
``gmuc `` Gmu command line interface.
In any case, to use this frontend, you need a password, which can be
set through the ``gmuhttp.Password`` config file option.
gmuc has its own config file (usually located in 
``~/.config/gmu/``), which contains the Gmu host information as well
as the password.


## 7. Libraries used by Gmu

- SDL >=1.2.14 / SDL2 >= 2.0.5 (mandatory)
- SDL_image >=1.2.4 / SDL2_image >= 2.0.5 (required by SDL_frontend)
- SDL_gfx >=2.0.13 / SDL2_gfx >= 1.0.0 (optional for SDL_frontend)
- tremor >=1.0.0 (optional, required by Vorbis decoder)
- libmikmod >=3.1.11 (optional, required by Module decoder)
- libmodplug (optional, required by an alternative module decoder)
- libopenmpt (optional, required by another alternative module decoder)
- libmpg123 >=1.8.1 (optional, required by MPEG decoder)
- libmpcdec >=1.2.6 (optional, required by Musepack decoder)
- libFLAC >=1.2.1 (optional, required by FLAC decoder)
- WavPack >=4.6.0 (optional, required by WavPack decoder)
- speex >= 1.2_rc1 (optional, required by speex decoder)
- libopus and libopusfile (optional, required by the Opus decoder)
- libogg (optional, required by the Opus and Speex decoders)
- ncurses 5.9 (used by gmuc)
