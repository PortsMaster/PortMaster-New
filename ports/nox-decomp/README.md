# Nox-Decomp

An excellent action/RPG hybrid with very unique gameplay. 
Your name is Jack Mower, a 20th century dude who just happened to be sucked into the world of Nox via his TV set. 
The world is in danger and you have to save it! But before you embark on your epic 
journey you must choose your path: warrior, wizard, or conjurer.

Unofficial **Nox (2000)** source port to Linux based on decompiled code from playnox.xyz and neuromancer/nox-decomp.

[sookyboo/nox-decomp](https://github.com/sookyboo/nox-decomp)

Single player (all classes) and multiplayer on the internet and LAN work great!


> **Note:** This project does **not** include any Nox game assets. You must own a legitimate copy of Nox to play.

* * *

## Thanks

Thanks to my wife for giving me the time to work on this.

Thanks to my brother for playing this game with me when I was growing up.

Thanks to OpenNox for implementing a modern lobby server which enables internet games and for labeling functions in their code which made navigating the code easier.

Thanks to klops, JanTrueno, Dia, Fraxinus88, OGM, Ganimoth, NotYerAvgPorter, Hades-Arcadius, MrGiKILL and Cebion for contributing fixes, advice and testing.

Thanks to szhublox and Lovyxia from the [NoX RPG Unofficial discord](https://discord.gg/4bYwu68) for testing, good suggestions and knowing the original game so well.

Thanks to szhublox for the following:

- finding the original decompiled binary version 1.2b with sha256: e6e1b56029f8871c25d0caf8bcedf7bf1699580d0dc24c90d79eb27e9d7e05b2
- pairing on obliterate rendering fixes, finding where the spell renders and uncovering a hint of where to look for a fix.
- test videos of force of nature, obliterate and mana drain problems.
- fixing rendering for Ring of Fire spell.
- fixing summon counter for lich lord.
- helping to track down a fix for playing dialog audio without conversion
- massive amounts of testing to get nox-decomp into a very well working and faithful to the original state!

Also thanks to the PortMaster team for the work they do - porting is a lot of work!

* * *

## Credits

-  **Westwood Studios** – for creating Nox.
-  **awesie** from playnox.xyz for originally publishing the source code
-  **neuromancer** – original Linux port work in [nox-decomp](https://github.com/neuromancer/nox-decomp). [GitHub](https://github.com/neuromancer/nox-decomp)
-  Sookyboo (for fixing 16bit cursor color, solo game fix, audio fixes, performance fixes, rendering fixes, game logic fixes, arm32bit crashes, adding video support, opennox lobby internet game support, windows support, steamdeck support, gamepad support)
-  szhublox (finding original binary, spell rendering fixes, npc summon fixes, tons of testing)
-  Everyone in the Nox community keeping the game alive.

* * *

## Known Issues
The game is fully playable on PortMaster, SteamDeck with flatpack, Linux and Windows for both single player and multiplayer and all classes warrior, wizard and conjurer!

* Minor - 16-bit graphics work perfectly - 8-bit support has been removed
* Minor - all text is legible - but there might be distortion based on your scaling settings and resolution enabling smoothing with NOX_LINEAR_SCALING on small consoles may fix.
* Minor - On low power devices fade ins and fade outs are slightly slower
* There has been a reported seg fault on Solo Quest on level 7 - we have not been able to replicate it but no other issues are known.

## Multiplayer
"Multiplay->Westwood Online" menu item doesn't work anymore because the Westwood Studios company is no longer operating.
Internet multiplayer games can be accessed from "Multiplay->Network" and are the first servers listed.

LAN games have a default name of "User Game"
"Host Game/Host Quest" can be used to host a game on your LAN/WiFi network locally.

Internet multiplayer games: The "Kor) Newbies" server makes the game exit but this happens on OpenNox too so might be a bad server.
The "Kor) Newbies" server has been excluded from the multiplayer list for now. 

## Korean Language
Make a `gamefiles/app/Dialog` directory before installing the game and copy the Korean dialog files there. 
Please note that dialog conversion will take around 20min for English and another 20min for the Korean audio files.

## Getting the Game Data

Copy the GOG installer "setup_nox_*.exe" into gamefiles directory. Then run the game.
Extraction of the GOG installer will take around 10 minutes and conversion of the dialog audio files will take 20min. 

## Tips
-   It is worth watching the game story video introduction once in the main menu by pressing "Play Intro" it does play once on the first launch.
-   You can change how the left analogue stick works by pressing **START** + **L1** for mouse mode or **START** + **R1** for absolute mode or **START** + **R1** + **R2** for absolute mode with inverted run button
-   Your device might be able to handle better graphics - when in the game go to main menu->options (**Select**) experiment with these:
  -   High Res Front Walls
  -   High Res Floors
  -   Soft Shadow Edge
  -   Render Particle Glow
  -   Fade Objects
  -   Render Bubbles (in mana and health viles)
  -   Draw Front Walls (I prefer this off)
  -   Translucent Front Walls
-   If you want to save your graphics settings exit the game from the menus not the **Select** + **Start** shortcut (after saving your config you can exit with the shortcut)  
-   Save often using **Start + Right D-Pad** and load often with **Start + Left D-Pad**.
-   Running into things like chests, doors, switches, tree stumps will open them.
-   If inventory / book / merchant / video is open press **Select** to exit any of them quickly. 
-   Use **L2** to slow down the mouse for picking up items, navigating menus or issuing commands to creatures as a conjurer
-   If you are a conjurer you can issue commands to your creatures in the top right window
-   Small screens might make the game harder
  -   Opening the mini map on each level can make it easier (**Start + A**)
  -   Zooming the map can help you find unexplored areas 
-   Something almost always comes out of a chest look carefully for items like arrow quivers
-   Take time to organise your spell lists - you can drag spells from the book
  -   Spell buttons/analog stick are clockwise from the order on the bottom of the screen for first four
  -   The last/fith spell at the bottom of the screen can be used with **L1 + R1**
  -   Cycle through your spell set ups with **L1 + Up D-Pad/Down D-Pad** press the little square to drag spells from your spell book into the different spell rows
  -   A spell ordering I like and is easy to memorise: Up for healing, down for dealing heavy damage, right for running/evading/hiding, left for slowing/hindering/confusing enemy, L1 + R1 for prep/shield spells
-   You can drag and drop items from your inventory
-   Most obstacles can be overcome with thinking, prepping, saving and reloading - rather than mouse speed
-   Most of the levels are completely different and have different challenges for the three classes Conjurer, Wizard and Warrior. It is worth playing through all of them. Conjurers can control creatures and have spells, Wizards can't control creatures but have powerful spells, Warriors have no magic but are stronger and faster and have special skills. 
-   Multiplayer is extremely fun too - I encourage you to try it with friends - Online games and local WiFi/LAN games co-op and versus are possible up to 32 players.
-   You can see what the status icons are with your inventory open by hovering over them.
-   Weapons and armour do eventually break unless you repair them - break boxes/walls with a cheap weapon and repair your favourites.
-   Look for tree stumps, secret walls and areas - they often reward you with items/gold that can help you finish the level or game.
-   Different merchants have different prices - keep your original shirt and use it to compare selling prices at different merchants to get the best deal.
-   Later in the game it is possible to set traps and these are sometimes useful for tough enemies but not always.
-   There are versions of Nox-Decomp available for SteamDeck, Windows and Docker images for servers [sookyboo/nox-decomp](https://github.com/sookyboo/nox-decomp). 
-   Full controller mapping listing below

## Crash debuging 

Although there are no known persistent crashes in the wizard and conjurer campaigns and multiplayer.

There may be crashes on parts of the game that haven't been tested so save often.

If you experience a consistent crash on a particular event.

Zip up and send me your save game folder conf/Save on the portmaster discord server.
You will also need to tell me the name/time of the save and describe what
action you took to make the game crash so that I can test the fix works. 
Please report crashes or I can't fix them for everyone. 

If you are technical you can get a stack trace with this:
```
# How to debug
# while ! pid=$(pgrep noxd); do sleep 0.1; done;  gdb -p "$pid"
# launch the game from the launcher 
# in gdb type c to continue
# play the game until the crash
# on crash type bt in gdb to get stack trace
```

Why not OpenNox - OpenNox has an added layer of complexity to convert to ARM32. 
Working through this project may actually help get OpenNox working on ARM32 one day.

* * *

## About

-   **Game:** Nox
-   **Original developer / publisher:** **Westwood Studios**
-   **Fixed project:** [sookyboo/nox-decomp](https://github.com/sookyboo/nox-decomp)
-   **Archived project:** [neuromancer/nox-decomp](https://github.com/neuromancer/nox-decomp)
-   **License:** Public Domain (Unlicense-style, following the original repository’s intent). [neuromancer/nox-decomp](https://github.com/neuromancer/nox-decomp)


* * *

## Building from Source

In the src directory run

```
 docker buildx build --platform=linux/arm64 --progress=plain -f Dockerfile -t noxdecomp-build . && docker create --name noxdecomp_tmp noxdecomp-build && docker cp noxdecomp_tmp:/build/nox-decomp/build/src/out ./noxd && docker rm noxdecomp_tmp
```

If not building on an arm machine you may need to do this: https://docs.docker.com/build/building/multi-platform/#install-qemu-manually

```
docker run --privileged --rm tonistiigi/binfmt --install all
```

* * *

## Controller Configuration (gptk)

These mappings assume you are using **gptk** (Gamepad-to-Keyboard).



### General Input Behaviour

-   **D-Pad / Left Analog:** Move the mouse cursor.
-   **Right Analog (Cardinal Directions):** Quick-cast or select spell slots (1–4).
-   **Mouse buttons:** Mapped to core gameplay (attack / interact / move).
-   **Trigger / Shoulder buttons:** Spell inversion and spell hotkey layer.
-   **Start / Select / Guide:** Map, console, quick save/load, and spell inversion.


* * *

### Base Layer (Default Controls)

| Button             | Keyboard / Mouse | Action in Nox                                                                 |
|--------------------|------------------|-------------------------------------------------------------------------------|
| **A**              | Mouse Left       | Primary action – attack / interact / confirm                                  |
| **B**              | Mouse Right      | Walk / run / secondary action                                                 |
| **X**              | Mouse Middle     | Jump                                                                          |
| **Y**              | `V`              | Switch equipped weapons                                                       |
| **D-Pad**          | Mouse movement   | Move cursor                                                                   |
| **Left Analog**    | Mouse movement   | Move cursor                                                                   |
| **Right Analog ↑** | `A`              | Spell slot  1                                                                 |
| **Right Analog →** | `S`              | Spell slot 2                                                                  |
| **Right Analog ↓** | `D`              | Spell slot 3                                                                  |
| **Right Analog ←** | `F`              | Spell slot 4                                                                  |
| **L2**             | Slow Mouse       | Reduce speed while moving                                                     |
| **R2**             | Mouse Left       | Alternate primary attack / interact                                           |
| **L1 (hold)**      | —                | Enter **Spell Hotkey Layer**                                                  |
| **R1**             | `Shift`          | Invert spell (modifier)                                                       |
| **Guide**          | `q`              | Open inventory                                                                |
| **Select**         | `Esc`            | Main menu / skip video / cancel / exit inventory / exit book / exit merchants |
| **Start (hold)**   | —                | Enter **Utility Layer** (map, console, save/load)                             |

* * *

### Spell Hotkey Layer (Hold **L1**)

While holding **L1**, buttons are remapped to give fast access to spell slots and spellbook navigation:

Spells start clockwise. Right thumb stick also starts clockwise. 

| Button (L1 held) | Keyboard | Action in Nox        |
|------------------|----------|----------------------|
| **X**            | `A`      | Spell slot 1         |
| **A**            | `S`      | Spell slot 2         |
| **B**            | `D`      | Spell slot 3         |
| **Y**            | `F`      | Spell slot 4         |
| **R1**           | `G`      | Spell slot 5         |
| **R2**           | `X`      | Health Potion        |
| **L2**           | `C`      | Mana Potion          |
| **D-Pad Up**     | `W`      | Move spell sets up   |
| **D-Pad Down**   | `E`      | Move spell sets down |
| **D-Pad Right**  | `R`      | Cycle spell sets     |
| **D-Pad Left**   | `B`      | Open spell book      |

This layer is intended to let you manage and cast spells quickly without reaching for the keyboard.

* * *

### Utility Layer (Hold **Start**)

While holding **Start**, the face buttons and D-Pad control map functions and quick save/load:

| Button (Start held) | Keyboard                   | Action in Nox                                                           |
|---------------------|----------------------------|-------------------------------------------------------------------------|
| **D-Pad Left**      | `F4`                       | Quick load                                                              |
| **D-Pad Right**     | `F2`                       | Quick save                                                              |
| **X**               | `2`                        | Zoom **out** minimap                                                    |
| **A**               | `Tab`                      | Toggle minimap                                                          |
| **B**               | `1`                        | Zoom **in** minimap                                                     |
| **R2**              | `T`                        | Set Trap                                                                |
| **L2**              | `Z`                        | Poison Potion                                                           |
| **L1**              | mouse mode                 | Left Analogue Stick Mouse Mode                                          |
| **R1**              | absolute mode              | Left Analogue Stick Mouse Mode Absolute Mode                            |
| **R1** + **R2**     | absolute mode inverted run | Left Analogue Stick Mouse Mode Absolute Mode invert run button function |
| **Right Analog ↑**  | `F1`                       | Open/close console                                                      |
| **Right Analog →**  | cycle cheats               | Cycle cheats in console                                                 |
| **Right Analog ←**  | cycle cheats               | Cycle cheats in console                                                 |
| **Right Analog ↓**  | apply active cheat         | Apply selected cheat in console                                         |
| **Y**               | cancel active cheat        | cancel active cheat                                                     |

This layer centralises all “meta” controls (saving, loading, console, and map) on the controller.

God mode has been modified so that it doesn't alter your spells/creature knowledge.

WARNING: With cheats sage mode messes with your spells and spell levels - and is disabled by default in nox.gptk2.ini. 
Sage gives you all spells, unset sage removes ALL spells including ones you learned the hard way.
Recommend not enabling sage mode unless you know what you're doing and save before.
If you enable it the game might remember and may mess with your spells in future saves.


Please Note: That for cheats to work it requires a new version of gptokeyb2 included with PortMaster. 
You may have to update to the latest PortMaster in order for it to work.

### Multiplayer Layer (Hold **Start** and **Guide**)

While holding **Start** and **Guide**

| Button (Start and Guide held) | Keyboard                                | Action in Nox                           |
|-------------------------------|-----------------------------------------|-----------------------------------------|
| **Right Analog ↑**            | `F1`                                    | Open/close console                      |
| **Right Analog →**            | cycle chat responses or character names | cycle chat responses or character names |
| **Right Analog ←**            | cycle chat responses or character names | cycle chat responses or character names |
| **Right Analog ↓**            | apply active response or character name | apply active response or character name |
| **Y**                         | cancel active text                      | cancel active text                      |

Please Note: That for multiplayer chat / character name selectionto work it requires a new version of gptokeyb2 included with PortMaster.
You may have to update to the latest PortMaster in order for it to work.

* * *

## Legal

-   **nox-decomp** is a fan-made, non-commercial project.
-   Nox™ and all related assets, names, and trademarks are the property of **Westwood Studios** and/or their respective rights holders.
-   This project is not affiliated with, endorsed by, or sponsored by Westwood Studios / Electronic Arts or any current rights holder of Nox.

## Advanced Options

### Internet Lobby env vars 
These are the default assumed values for these env vars if not present:
```
export NOX_NO_INTERNET_SERVERS=0 # 1 switches off internet access but keeps LAN access, 0 allows internet access

export NOX_LOBBY_LIST=nox.nwca.xyz:8088,noxdecomp.qzz.io,noxdecomp2.qzz.io
export NOX_LOBBY_PATH="/api/v0/games/list"

export NOX_LOBBY_CONNECT_TIMEOUT=2000 # in milliseconds
export NOX_SERVER_CACHE_TTL=30 # How long to cache internet game queries - minimum 30 seconds

# If there are bad servers that crash the game they can be filtered using this list
export NOX_BAD_SERVER_IPS="127.1.1.1,127.1.1.2"
export NOX_BAD_SERVER_NAMES="VeryBadServerName1,VeryBadServerName2"

# these register the game on opennox lobby
export NOX_LOBBY_REGISTER_ENABLE=0
export NOX_LOBBY_REGISTER_PERIOD=20
export NOX_LOBBY_REGISTER_PATH=/api/v0/games/register
export NOX_SERVER_MODE=ctf
export NOX_SERVER_VERS=1.2

# this is to automatically open udp port 18590 when hosting games on a router that supports UPNP
export NOX_UPNP_ENABLE=0
export NOX_UPNP_DEBUG=0
export NOX_UPNP_PORT=18590
export NOX_UPNP_PROTO=udp
export NOX_UPNP_TIMEOUT_MS=2000
```

### Control server and env vars
The control server allows you to control nox with mouse clicks and keyboard presses
It is useful for testing and also starting multiplayer games in an automated way.

```
export NOX_CONTROL_SERVER=1
export NOX_CONTROL_SERVER_PASSWORD=secret
export NOX_CONTROL_SERVER_BIND=127.0.0.1
export NOX_CONTROL_SERVER_PORT=2323

export NOX_SKIP_INTRO_MOVIES=1 # useful if issuing commands at boot
export NOX_CONTROL_SERVER_SLEEP_SCALE=1 # some ennvironments might be slow so you can increase the sleep time between commands 
export NOX_CONTROL_SERVER_BOOT="macro server;" # You can issue control server commands on start

# The macro server uses some env vars and sets up a multiplayer game
export NOX_SERVER_NAME=NoxDecompServer # when starting a game what the server is called 
export NOX_SERVER_SYSOP=secret # set the sysop password to secret for multiplayer games
export NOX_SERVER_LESSONS=15
export NOX_SERVER_TIME:0
export NOX_SERVER_DEFAULT_MAP:capflag # game type becomes whatever the map default is

export NOX_CAPTURE_INPUT=0   # prints out real user mouse input but mostly useless too noisy 
```

### Other env vars
```
export NOX_SKIP_INTRO_MOVIES=0 # default is 1 - skip the logo movies at the start of the game

# NOX_LIMIT_RANGE_ON_RUN_GAMEPAD - useful for gamepads and steam deck 
# limits the range of the mouse when running but only if starting close to center or passing through center
export NOX_LIMIT_RANGE_ON_RUN_MOUSE=0 #default is 0
export NOX_LIMIT_RANGE_ON_RUN_GAMEPAD=1 #default is 1
export NOX_LIMIT_RANGE_ON_RUN_RADIUS=110 # default is 110 - the radius of the circle

# Built in gamepad support
export NOX_GAMEPAD=1
export NOX_GAMEPAD_INI="$PWD/nox.gptk2.ini" # Mapping file based on gptokeyb2 must be present to work

export NOX_GAMEPAD_EXIT=1 # when pressing start and select exit game 

export NOX_GAMEPAD_AUTOSWAP_XBOX=1 # swap A and B automatically for xbox/nintendo controllers 
export NOX_GAMEPAD_FLIP_ABXY=0 # manually swap A and B buttons
export NOX_GAMEPAD_LOG=0 # for debbuging gamepad issues  

export NOX_GAMEPAD_RIGHT_STICK_THRESHOLD=20000
export NOX_GAMEPAD_RIGHT_STICK_CENTER_THRESHOLD=8000
export NOX_GAMEPAD_RIGHT_STICK_REARM=1 # 1 enables one shot mode and 0 is repeat mode  

export NOX_LINEAR_SCALING=1 # when scaling don't keep things pixel perfect but apply smoothing
export NOX_INTEGER_SCALING=0 # only scale to the highest integer value that fits in the screen don't use floats to fit exactly on screen
```
