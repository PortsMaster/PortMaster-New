# Shotgun King: The Final Checkmate
A chess roguelike where you're the Black King armed with a
shotgun. Blast your way through procedurally generated chess boards!

## Thanks
A huge thank you to PUNKCAKE Délicieux for such an amazing game. Also
to the Darling project for the basis for the machismo loader.

## Installation
You'll need a legitimate Mac build of the game. Two options:

### itch.io
1. Buy Shotgun King on [itch.io](https://punkcake.itch.io/shotgun-king) from PUNKCAKE Délicieux. Purchasing on itch also grants a free Steam key.
2. From your itch library (or the itch desktop app), download the **macOS** build. You'll get a `.zip` containing `shotgun_king.app`.
3. Unzip and drop `shotgun_king.app` into the port's `gamedata/` directory (see layout below).

### Steam
1. Buy Shotgun King on [Steam](https://store.steampowered.com/app/1972440/Shotgun_King_The_Final_Checkmate/).
2. Open the Steam console by entering `steam://open/console` in your browser, then run:
   ```
   download_depot 1972440 1972442
   ```
   After the download, Steam will print the path where files were saved.
3. Place the game's `.app` bundle in the port's `gamedata/` directory:
```
shotgunking/
└── gamedata/
    └── shotgun_king.app/
```

## Controls
D-pad moves the king, R2 fires the shotgun. Aiming depends on
how many analog sticks your device has:

- **Two sticks:** right stick aims (default).
- **One stick:** the left stick is folded into aim — push it any
  direction to aim there.
- **No sticks:** hold **L2** to turn the d-pad into a mouse cursor,
  then press **R2** (or **A**) to fire.

## Technical Details
This port uses [Machismo](https://github.com/bmdhacks/machismo) to load the arm64 Mach-O binary on aarch64 Linux.

## License
The Machismo loader is licensed under GPL v3.0
