English | [Español](https://github.com/lowlevel-1989/quixjs/blob/master/games/fearandhunger/README.es.md)

[![Buy Me A Coffee](https://raw.githubusercontent.com/lowlevel-1989/quixjs/master/docs/coffee.svg)](https://ko-fi.com/lowlevel1989)

If you want [quixjs](https://github.com/lowlevel-1989/quixjs) to keep getting updates and support,
you can support the project by buying me a coffee.

## Notes

Thanks to Miro Haverinen for creating Fear & Hunger. This port only runs
the game, on quixjs: https://github.com/lowlevel-1989/quixjs.

Needs Fear & Hunger **1.4.1** for Windows (itch.io or Steam).

## Controls

| Button | Action |
|--|--|
| D-Pad / left stick | Move |
| A | OK |
| B | Cancel |
| X | Skill |
| Y | Menu |
| L1 / R1 | Previous / next character or page, in the menus |
| (you choose it in Controls) | Torch |
| (you choose it in Controls) | Phase |
| Select + L1 | Magnifier: a box that enlarges; d-pad or sticks move it, R1 / L1 zoom, Y / X size, A centers, Start pins it (the gamepad goes back to the game) and unpins it, B closes |
| Select + R1 | Screenshot (in `screenshots/`) |
| Select + R2 | Back to the port menu |
| Select + Start | Quit |

Mods (on): [rumble](mods/rumble/README.md) (vibration), [party-bars](mods/party-bars/README.md) (Hunger, Body and Mind on the map; L1 / R1 change the member).

## Compile

```
git clone https://github.com/lowlevel-1989/quixjs.git
cd quixjs
make portmaster PORT=fearandhunger
```

It builds `build/fearandhunger.zip`.

## Install

To use this port you need the game: Fear & Hunger 1.4.1 for Windows, which
you can buy on itch.io (https://mirohaver.itch.io/fear-hunger) or on Steam
(https://store.steampowered.com/app/1002300/).

1. **Get the game files.** Download the Windows version 1.4.1 from itch.io
   and unzip it on your PC, or, on Steam, install the game and open its
   folder (in the library, right click on the game, Manage, Browse local
   files). The port only needs the folder `www/`.

2. **Install the port.** Copy `fearandhunger.zip`, without unzipping it, into
   the `autoinstall` folder of PortMaster on the SD card of your device:

   | System | `autoinstall` folder |
   |--|--|
   | ROCKNIX, AmberELEC, JELOS, uOS | `/roms/ports/PortMaster/autoinstall/` |
   | ArkOS | `/roms/tools/PortMaster/autoinstall/` |
   | muOS | `/mmc/MUOS/PortMaster/autoinstall/` |
   | Knulli | `/userdata/system/.local/share/PortMaster/autoinstall/` |

   Then open PortMaster on the device: when it starts it installs the zip by
   itself (with the image that EmulationStation shows) and removes it from
   `autoinstall`. You can close PortMaster after that.

3. **Copy the game.** Compress the folder `www/` of step 1 into a zip named `www.zip` (on
   Windows: right click on `www`, Send to, Compressed (zipped) folder) and copy
   it into `ports/fearandhunger/`, next to `port.toml`, in the
   ports folder of your device (where `Fear and Hunger.sh` is). It must end up like this:

   ```
   ports/
     Fear and Hunger.sh
     fearandhunger/
       port.toml
       www.zip
   ```

   On ROCKNIX the ports folder is `/roms/ports/` (`/storage/roms/ports/` over
   SSH).

   Best: a zip without compression (with 7-Zip: Compression level, Store; on
   Linux or macOS: `zip -0 -r`). A compressed one also works: the first time
   the game starts it is prepared (a moment, only once).

   If your file has another name, write it in `ports/fearandhunger/port.toml`, in
   `rom = "www.zip"`.

4. **Play.** Restart EmulationStation (or update its list of games) and open
   Fear & Hunger from Ports.

To update the port, do step 2 again with the new zip. The game and your saves
and achievements (`gamedata/www/save/`) stay.

Without PortMaster: unzip the zip into the ports folder. Then
EmulationStation may not show the image of the port.

## port.toml

**port.toml** tells quixjs where the game is and where saves go. Paths are relative to the folder that holds port.toml.

```toml
rom      = "www.zip"
game_dir = "www"
```

- `rom`: the `www/` folder of the game (the one with `data/`, `js/` ...) zipped and placed next to port.toml.
- `game_dir`: the folder inside the zip where the game starts. When you zip a folder on Windows, the folder itself ends up inside the zip, so this tells quixjs where to look.
- Saves go to `gamedata/`, next to port.toml, so `www.zip` is never modified.

```
port.toml
www.zip
  www/
    data/
    js/
    ...
gamedata/
```

## Android

You need the game and two files from the releases of quixjs
(https://github.com/lowlevel-1989/quixjs/releases), the latest version
(`VERSION` in the names is its number):

- `quixjs-VERSION-android-arm64.apk`: the app
- `fearandhunger-VERSION-portmaster.zip`: the port

1. Install the `.apk` on the phone.
2. On your PC, unzip `fearandhunger-VERSION-portmaster.zip`. You get the folder
   `fearandhunger/`.
3. Copy the game (`www.zip`, step 3 of Install) into `fearandhunger/`, next to `port.toml`. It ends up like this:

   ```
   fearandhunger/
     port.toml
     www.zip
   ```

4. Zip the folder `fearandhunger/` and copy the `.zip` to the phone.
5. In quixjs, tap "Import game" and choose that `.zip`. Then tap the game
   and Play.
