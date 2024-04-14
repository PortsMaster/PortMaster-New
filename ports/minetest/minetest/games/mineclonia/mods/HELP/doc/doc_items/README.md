# Item Help [`doc_items`] (Version 1.2.0)
## Description
Automatically generated help texts of blocks, tools, weapons, crafting
items and other items.

The goal is to tell the player as much about basically almost all items as
possible, making it very convenient to look up simple things.

The ultimate goal of this mod is that eventually all relevant items have
a complete in-game documentation so no item leaves you confused.

This mod is useful to learn the hard facts about practically all items, like
how much damage weapon XYZ deals or whether you can dig that block.
This mod does *not* give you long explanations about how to use certain
nontrivial things, like the furnace from Minetest Game. This info might be
provided by other mods and insert it into the help.

This mod provides 3 new help categories (using the
Documentation System [`doc`]):

* Blocks (e.g. dirt, stone, wooden stair)
* Tools and weapons (e.g. wooden pickaxe, steel sword, screwdriver)
* Misc. items (e.g. dye, stick, flour)

Entries are automatically added. The information in the entries is
mostly automatically generated. It contains information about a wide range
of topics:

* Blocks
    * Physics
    * Digging properties
    * Drops (including probabilities)
    * Liquid information
    * Pointability
    * Luminance
    * Much more
* Tools and weapons
    * Mining capabilities
    * Damage
    * Durability
    * More
* All items
    * Range
    * Stack size
    * Group memberships
    * Other information added by mods

This mod also allows for mods to adding custom written description
and usage help texts in free-form and even custom automatically generated texts
for mod-specific information like flammability in Minetest Game. This is
one of the core features of this mod; the mod relies on other mods to
provide their custom help texts for a complete help.

If you find a particular item which is lacking an explanation on usage,
request the mod author to add `doc_items` support.

## API
This mod has an API so that modders can add their own custom help texts,
custom factoids (single pieces of information extracted from the
item definition) and more.

For example, if your mods have some complex items which need
explanation, this mod can help you in adding help texts for them.

Read `API.md` to learn more.

## License
Everything in this mod is licensed under the MIT License.

## Translation credits
French: Karamel
German: Wuzzy
Portuguese: BrunoMine
