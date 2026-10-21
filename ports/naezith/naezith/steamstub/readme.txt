This is not a Steam emulator, and it does not break, bypass or circumvent any DRM or license
check. Remnants of Naezith makes no ownership checks, and this library implements none: if the
game asked whether the game is owned, every such query would answer false.

The game requires the Steam API to start (with the real libsteam_api.so and no Steam client it
prints "STEAM API Init failed" and exits, even with a steam_appid.txt). This stand-in only tells
the game that Steam is running but the user is not logged on. The game then uses its own offline
mode ("OFFLINE MODE: can't submit scores"), and achievement calls go nowhere. Every other Steam
interface method returns 0.

You still need your own copy of the game from Steam; no game files are included in this port.

The source (steamstub.c) is included and MIT licensed (see licenses/LICENSE.steamstub.txt).
Build: gcc -shared -fPIC -O2 -o libsteam_api.so steamstub.c

Credit: this stub is based on BinaryCounter's Steam stub from the Papers, Please PortMaster port.
