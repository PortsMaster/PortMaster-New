# Documentation System [`doc`]
This mod provides a simple and highly extensible form in which the user
can access help pages about various things and the modder can add those pages.
The mod itself does not provide any help texts, just the framework.
It is the heart of the Help modpack, on which the other Help mods depend.

Current version: 1.3.0

## For players 
### Accessing the help
To open the help, there are multiple ways:

- Use the `/helpform` chat command. This works always.
- If you use one of these mods, there's a help button in the inventory menu:
    - Unified Inventory [`unified_inventory`]
    - Simple Fast Inventory Buttons [`sfinv_buttons`]
    - Inventory++ [`inventory_plus`]

The help itself should be more or less self-explanatory.

This mod is useless on its own, you will only need this mod as a dependency
for mods which actually add some help entries.

### Hidden entries
Some entries are initially hidden from you. You can't see them until you
unlocked them. Mods can decide for themselves how particular entries are
revealed. Normally you just have to proceed in the game to unlock more
entries. Hidden entries exist to avoid spoilers and give players a small
sense of progress.

Players with the `help_reveal` privilege can use the `/help_reveal` chat
command to reveal all hidden entries instantly.

### Maintenance
The information of which player has viewed and revealed which entries is
stored in the world directory in the file `doc.mt`. You can safely reset
the viewed/revealed state of all players by deleting this file. Players
then need to start over revealing all entries.

## For modders and game authors
This mod helps you in creating extensive and flexible help entries for your
mods or game. You can write about basically anything in the presentation
you prefer.

To get started, read `API.md` in the directory of this mod.

Note: If you want to add help texts for items and nodes, refer to the API
documentation of `doc_items`, instead of manually adding entries.
For custom entities, you may also want to add support for `doc_identifier`.

## License of everything
MIT License

## Translation credits

* French: Karamel
* German: Wuzzy
* Portuguese: BrunoMine
