Match-3 trash pile defender by PUNKCAKE Delicieux. You're a scavenger
droid bound to a trash pit — organize tiles with per-type matching
rules, recycle trash into automated defenses, and keep rival
scavengers from stealing your pile. Single-player plus couch co-op /
versus, 10-30 minute runs.

## Thank You
Thanks again to PUNKCAKE Delicieux for such a fun little handheld
diversion.  Also thanks to the Darling project for the basis of the
machismo loader.

## Installation
You'll need a legitimate Mac build of the game.

### itch.io
1. Buy Scavenger of Dunomini on [itch.io](https://punkcake.itch.io/scavenger-of-dunomini) 
2. From your itch library (or the itch desktop app), download the **macOS** build. You'll get a `.zip` containing `scavenger_of_dunomini.app`.
3. Unzip and drop `scavenger_of_dunomini.app` into the port's `gamedata/` directory

### Steam
1. Buy Scavenger of Dunomini on [Steam](https://store.steampowered.com/app/2320410/Scavenger_of_Dunomini/).
2. Open the Steam console by entering `steam://open/console` in your browser, then run:
   ```
   download_depot 2320410 2320412
   ```
   Steam will print the path where files were saved.
3. Place the game's `.app` bundle in the port's `gamedata/` directory:

## How to Play
Defend your trash pile in a match-3 where every tile type has its own rule. Pick tiles up, carry them around, and group them to recycle into resources. Spend resources from the construction menu to build turrets and upgrades. Meanwhile rival scavengers raid the pile to steal tiles and escape; kick or block them.
Keep the pile below the red laser line at the top. Run ends when your 3hp are exhausted.

## Controls
```
| Pad                     | Action                               |
|-------------------------|--------------------------------------|
| D-pad Left / Right      | Move your Scavenger                  |
| D-pad Down              | Pick up the tile under you           |
| D-pad Up (holding tile) | Drop tile beneath you                |
| D-pad Up (empty-handed) | Open construction menu               |
| A                       | Pick up a tile next to you / toss it |
| X                       | Kick (wall-jump while climbing)      |
```

## Technical Details
This port uses [Machismo](https://github.com/bmdhacks/machismo) to load the arm64 Mach-O binary on aarch64 Linux.

## License
The Machismo loader is licensed under GPL v3.0. Game assets are proprietary and must be purchased from itch.io or Steam.
