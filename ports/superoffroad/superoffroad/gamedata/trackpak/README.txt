Optional: the arcade game's tracks.

Copy your own MAME ROM sets of the arcade Super Off-Road into this
folder to race on the arcade's tracks:

  offroad.zip     the original arcade game (its eight tracks)
  offroadt.zip    the Track-Pak (eight new tracks)

Either works alone. The zips can be split or merged sets, or the chip
files can be unzipped here instead (in this folder or one folder below).
SORP recognises the chips it needs by their checksums, not their names.

Then, in the options (Select):

  arcade roms    on: race on the arcade's tracks
  arcade mode    original, track-pak, or all 16

"arcade roms" appears only when a set is found here, and "arcade mode"
only while "arcade roms" is on; it offers only the modes whose sets
were found. The DOS game's files in
gamedata are still needed: the trucks and the screens are the DOS
game's.

With the sound board's chips too, the arcade's tracks have the arcade's
own sound: its music, effects and engine, from its sound board's
program. Without them, they have the DOS game's.

While "arcade roms" is on, the nation list in registration has a
second page with the arcade's other eight nations (Belgium to Swiss),
their flags drawn in the DOS game's colours.

The rest of the video chips add nothing to a race; they let the sprite
viewer (F3) show every one of the arcade's sprites.

The chips SORP reads from each set:
  offroad:  u58t, u59t, u57t, u56t (program); u93, u94, u95 (tiles);
            u92, u69, u90, u67 (tile map); u4t, u5t (sprites)
            u13t, u14t, u15t, u25t, u26t, u27t (sound; optional)
            u6t, u7t, u8t (the other sprites, for F3; optional)
  offroadt: the same places from the Track-Pak, and u3t, u8t (the
            scenery in front of the trucks); u57t from offroad;
            u2t, u6t, u7t (the other sprites, for F3; optional)
