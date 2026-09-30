Postal 2 is a 2003 first-person shooter developed by Running with Scissors and originally published by Whiptail Interactive. It is the second entry in the Postal series and runs on Unreal Engine 2. The player controls the Postal Dude through a week of errands in the town of Paradise, Arizona, with the days of the week acting as levels and every task completable in any order, peacefully or violently. The design is summed up by the game's tagline: "Remember, it's only as violent as you are!".

This port runs the x86 Linux build of the game through box86 on ARM devices, and uses the freeware Share the Pain multiplayer build for its shared game data.


> [!IMPORTANT]
> This port does **not** include, and will never include, any copyrighted game
> assets. You must supply your own copy of the game files from Steam, plus the
> freeware multiplayer build.

## Install

Postal 2 needs two sets of files: the freeware *Share the Pain* multiplayer build and the retail 1409 build from Steam.

1. Download the promotional multiplayer (*Share the Pain*) Linux version from ModDB:
   https://www.moddb.com/downloads/postal-2-share-the-pain-mp-linux-version
2. Extract the contents of the archive into the `gamedatamp` folder. It should look like this:

   ```
   [gamedatamp]$ ls
   Animations  Music                          postal2.xpm   System
   KarmaData   postal2                        Sounds        Textures
   Maps        postal2stp-freemp-license.txt  StaticMeshes  Web
   ```

3. In Steam, select the 1409 build (Postal 2, right click, Properties, Game versions and betas, select 1409), then copy the files into the `gamedata` folder. It should look like this:

   ```
   [gamedata]$ ls
   Animations  EmptySteamDepot  KarmaData  Music  Sounds        System    Web
   Cache       Help             Maps       Save   StaticMeshes  Textures
   ```

4. Run **Postal 2 MP (first run).sh** once so the game generates its config files.
5. Press Start+Select to quit once the menu appears.
6. Launch **Postal 2.sh** to play.

## Controls

| Button | Action |
|--|--|
| D-Pad Up / Down | Next / previous weapon |
| D-Pad Left / Right | Next / previous inventory item |
| Left Stick | Move |
| Right Stick | Look |
| A | Use / activate inventory item |
| B | Jump |
| X | Pee (unzip) |
| Y | Crouch |
| L1 | Holster / draw weapon |
| R1 | Kick |
| L2 | Alternate fire |
| L3 | Walk |
| R2 | Fire |
| R3 | Quick health |
| Start | Menu / skip cutscene |
| Select | Show map |
| Guide (hold) | Type text with the D-Pad |
| Start + Select | Quit |

While Guide is held, the D-Pad becomes a character picker so you can enter text without a keyboard: up and down scroll through letters, numbers and symbols, right sends the selected character to the game, and left deletes it. Nothing is drawn on screen, the characters are sent straight to whatever text field the game is showing, so it only does something while the game itself is asking for text, such as a player name.

## Configuration

Game settings can be changed in-game. The controller mapping and other gptokeyb2 settings live in:

```
ports/postal2/postal2.ini
```

## Licenses

This port is distributed with **box86** and **GL4ES**. Bundled libraries retain their respective upstream licenses, with license texts in `postal2/licenses/`. Original game assets are proprietary property of Running with Scissors and are never distributed with this port.
