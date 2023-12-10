Wetspot II remake v0.9

C/SDL port by Dmitry Smagin
dmitry.s.smagin@gmail.com
https://github.com/dmitrysmagin/wetspot2
https://dmitrysmagin.github.io/

original QB45 version by Angelo Mottola
a.mottola@gmail.com

Originally Wetspot II was written by Angelo Mottola (Enhanced Creations) in
1997-98. While being programmed in QuickBasic 4.5 it used some obscure
techniques like machine code injecting, EMS memory using and programming
SB Pro / 16 hardware directly. This allowed to reach the quality previously
unthinkable for a QuickBasic games.

Unfortunately, in 2020 you can play this game using Dosbox if you are lucky
enough to set everything up correctly, keeping in mind that the original
site is no longer available (archived in fact).
https://geocities.restorativland.org/SiliconValley/Lakes/7303/

This is a full re-implementation of game engine entirely in pure C/SDL made
in 2013-2014. This allows porting to any platform supporting SDL: windows,
linux, freebsd and others. All graphics, sound effects and even adlib midi
music is preserved to retain the old DOS feel.

Initially this remake was planned as an exclusive for GCW-Zero handheld and
was released for it with different music due to some concerns:
http://www.gcw-zero.com/news.php?id=8

Some differences with the original game:
- Included all 3rd party level packs available: chris2, funk, nekro, return,
  ricland, seav, squinky, surprise, wafn.
- Palette fade in/out effects are dropped
- Menu item 'OPTIONS' is dropped, because there's nothing to tune
- Cursor movement in the menu is not animated
- While in game the level timer is now shown in the status bar
- The score font is different when you pick up bonuses

Compiling from sources:
- Both SDL and SDL2 are supported:
  > make SDL2=1     # build with SDL2
  or
  > make            # use old SDL
- You need SDL2, SDL2_gfx and SDL2_mixer libs (or SDL, SDL_gfx and SDL_mixer for SDL build)
