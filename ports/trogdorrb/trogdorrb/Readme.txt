/----------------------------\
| Trogdor: Reburninated v2.4 |
\----------------------------/

1. Custom Music
2. GameCube
3. Linux

---------------------------
| Section 1: Custom Music |
---------------------------

Custom music should be placed in /music/custom, with each song having the same name as its original counterpart ("menu", "stinkoman_level_day", etc).

WAV and OGG files are both supported, and you can convert your music using this script:
https://github.com/Mode8fx/Trogdor-Reburninated/blob/main/Scripts/convert_audio_for_systems.bat

It is recommended to use WAV on very low-end devices; it doesn't matter on other devices, but OGG is smaller, so you may want to use that.

If you decide to also replace sound effects, you can use the same script above. Both WAV and OGG will have the same performance in-game, but initial load time will be longer for OGG (maybe much longer depending on the system).

-----------------------
| Section 2: GameCube |
-----------------------

Put the Trogdor-RB folder in the root of your homebrew-storing device, otherwise audio won't load and you won't be able to save.

Trogdor-Reburninated.dol does not have to be in this folder.

--------------------
| Section 3: Linux |
--------------------

Don't play this! It is recommended that you install the PortMaster version instead! (Same game, just packaged better)
https://portmaster.games/detail.html?name=trogdorrb

But if you really want to use this version instead...

Keep the music and sfx folders in the same directory as the executable.

Alternatively, you can put them in ~/.local/share/.trogdorrb (probably /home/user/.local/share/.trogdorrb).

Whichever directory recognizes these assets is also where save data will go.