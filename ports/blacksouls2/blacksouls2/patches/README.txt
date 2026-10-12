This folder is mounted above Game.rgss3a. A loose folder next to the engine is
not: where the same file exists in both, the archive wins. So anything meant to
replace the game's own content goes in here.

Two things usually do: the publisher's free patch for the reduced Steam build,
and a translation that replaces only part of the game. Put their content
folders directly inside this one.

    patches/
    |-- Data/
    |-- Graphics/
    |-- Audio/     (only if it ships one)
    |-- Movies/    (only if it ships one)
    `-- Fonts/     (only if it ships one)

If the patch updated Game.rgss3a itself rather than leaving loose folders, copy
that archive over instead and leave this folder alone.

A translation that ships the whole game instead, with its own Data, Graphics and
Audio, is not an overlay. Put it in the port folder as the game and leave this
one empty. Keeping both costs twice the space for nothing.

If an archive wraps everything in one top level folder, copy that folder's
contents, not the folder itself. Leave out Game.exe, System/, *.dll, *.vdf,
Game.rvproj2 and its own Game.ini. Delete the folders to go back.

Back up your saves before changing this folder. A save belongs to the script set
that made it, and this bit during testing: a save made against the full data
would not load against the reduced Steam scripts. The game says nothing, the
load screen just buzzes and stays there. Putting the data back the way it was
when the save was made fixes it.

See README.md one level up for the rest.
