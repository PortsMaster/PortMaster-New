## Notes

Thanks to [Magnus Auvinen and the Teeworlds contributors](https://github.com/teeworlds/teeworlds) for creating this game, a tight little 2D shooter where the grappling hook matters more than the gun. It connects straight to the public server list, so there are real people to play against the moment it launches.

## Requirements

Ready to run as-is: the client, both server modes, the bundled map set, and the on-screen keyboard are all included in this zip, no separate download needed. The first launch unpacks the compressed game data, so allow a little extra time and free space on that launch. Just make sure PortMaster itself is up to date; it self-updates whenever it's run, so this is normally already the case.

"Vanilla (Client)" needs Wi-Fi to reach the public server list. "Vanilla (Server)" and "Bot Server" both launch their own dedicated server in the background and join it automatically with the built-in client, so both work fully offline as real single-device singleplayer -- Bot Server fills the empty slots with AI bots, Vanilla Server just gives you an empty map to explore. Wi-Fi is only needed on top of that if you want other people on the same LAN to join in too.

This port is the vanilla Teeworlds 0.7.5 client. DDNet/DDraceNetwork servers (including servers advertising DDraceNetwork Mod 0.6) are not supported; they may accept the connection but use protocol and gameplay features this client cannot interpret correctly, such as freeze/deep-freeze and custom HUD state.

Menus use the active SDL display dimensions for their logical canvas, including square 720x720 displays where the original fixed layout overflowed.

## Controls

| Key | Action |
|--|--|
| Left Stick | Move |
| Right Stick | Aim |
| D-Pad Left/Right | Move (same as left stick) |
| D-Pad Up | Jump |
| D-Pad Down | Menu (Escape) |
| A | Fire |
| B | Next weapon |
| X | Jump |
| Y | Previous weapon |
| L1 | Hook |
| R1 | Fire |
| Start | Chat |
| Select + D-Pad Down | Toggle on-screen keyboard |
| Guide | Menu |

Movement lives on both the left stick and D-Pad left/right. Jump is doubled up too (X and D-Pad Up), since it's the single most-pressed button in the game. Fire is on both A and R1 (a face button plus a trigger, so either grip style works), and hook gets its own dedicated shoulder button (L1).

Hold L2 for a second layer:

| Key + L2 | Action |
|--|--|
| A | Team chat |
| B | Whisper |
| X | Show chat log |
| Y | Statboard |
| D-Pad Up | Scoreboard |
| L1 | Vote yes |
| R1 | Vote no |
| R2 | Screenshot |
| Start | Emoticon |

Hold R2 for spectator controls:

| Key + R2 | Action |
|--|--|
| D-Pad Left | Spectate previous |
| D-Pad Right | Spectate next |
| Back | Toggle spectator mode |

## Menu

Launching "Teeworlds.sh" opens a picker (D-Pad to move, A or B to confirm) with three options:

- **Vanilla (Client)**: the regular online client. Connects straight to the public server list, so there are real people to play against the moment it launches.
- **Vanilla (Server)**: starts a local dedicated server on the device (8 players, deathmatch by default, LAN-only, no master server registration) and automatically joins it with the built-in client, so you're straight into the game rather than staring at an empty server console. Anyone else on the same network can also connect in from their own Teeworlds client at the device's IP, port 8303. Edit `teeworlds/server.cfg` to change the gametype or player count, or set `sv_register 1` for internet-facing hosting instead.
- **Bot Server**: vanilla Teeworlds has no offline mode, it's pure PvP. This option runs a community server mod ([nheir's bMod](https://github.com/nheir/teeworlds/tree/server_bot0.7)) that fills empty slots with simple AI bots (pathfinding, weapon prediction, no teamwork), then automatically joins it with the built-in client the same way Vanilla (Server) does -- so this is the real single-device offline singleplayer option. Edit `teeworlds/server_bot.cfg` to change the bot count (`sv_bot_slots`).

Both server options open the **map picker** first (see below) to choose a map, then start the server on that map and drop you straight in as a player. Quit back out of the match (Escape/Guide, then Disconnect) to stop the server and return to the picker.

## Map picker

Picking Vanilla (Server) or Bot Server opens a three-column map browser before the server starts: **Official** (the 16 vanilla maps), **Favorites** (anything you've starred, persisted between launches), and **Others** (every other map bundled in `teeworlds/data/maps/`, alphabetical -- around 685). Only one column has "focus" at a time, shown by the highlighted border; browsing and buttons only affect the focused column.

| Key | Action |
|--|--|
| D-Pad Up/Down | Move selection up/down within the focused column |
| L1 | Quick-scroll up a full screen of rows |
| R1 | Quick-scroll down a full screen of rows |
| Y (or D-Pad Left/Right) | Switch focus to the next column (Official → Favorites → Others → back to Official) |
| X | Toggle the highlighted map as a favorite |
| A or B | Confirm: use the highlighted map and start the server |
| L2 (or Guide, where present) | Cancel: start the server on whatever map is already set in its `.cfg` |
| Select + D-Pad Down | Open the on-screen keyboard to search by typing (see below) |
| Start | Backspace the last typed search character |

Typing a search filters all three columns at once to matching map names. This is the fastest way to find something specific in the ~685-entry Others column rather than scrolling through it -- hold Select and tap D-Pad Down to bring up the keyboard, type, then close the keyboard the same way (Select + D-Pad Down again) and confirm your pick as normal.

**Bot Server and large maps:** Bot Server's AI needs to build a pathfinding map before anyone can join, and that step gets dramatically slower the bigger/more complex the map is -- this is a real limit of the bot AI itself, not something better hardware fixes. The Others column has already been pruned down to maps that stay within a reasonable startup time, but a couple of the Official maps (`dm2` in particular) are themselves large enough to take up to a minute -- if Bot Server ever seems to hang right after picking a map, that's why, it should still connect, just slowly. Vanilla (Server) doesn't have this AI step at all, so it isn't affected regardless of map size -- if a specific map matters more than bots do, host it there instead.

## On-screen keyboard

Hold Select and tap D-Pad Down to open a full QWERTY on-screen keyboard ([OmniOSK](https://github.com/binarycounter/OmniOSK)) for typing chat messages, server addresses, or player names without a physical keyboard. The same Select+Down chord closes it again. While it's open: D-Pad moves focus around the grid, Start confirms/selects the highlighted key, hold Select+B backspaces, hold Select+X switches character pages (letters/numbers/symbols). Selecting the on-screen Submit key sends the text to the game and closes the keyboard on its own.

Since Select is the keyboard-toggle modifier, the in-game menu lives on the Guide/Home button (client only; not present on every device) -- D-Pad Down works as a standalone Escape too, for devices without one.

## Compile

Run these commands from this port directory in an AArch64 Ubuntu build environment with the PortMaster SDL2 development environment available:

```bash
git clone --branch 0.7.5 --depth 1 https://github.com/teeworlds/teeworlds.git teeworlds-src
patch -d teeworlds-src -p1 < patches/teeworlds-square-display-ui.patch
cmake -S teeworlds-src -B teeworlds-build -DCMAKE_BUILD_TYPE=Release -DCLIENT=ON -DDOWNLOAD_GTEST=OFF -DPREFER_BUNDLED_LIBS=ON
cmake --build teeworlds-build --target teeworlds
```
