# Minimal API for `doc_identifier`
## Introduction
The tool can identify blocks and players natively, and also handles falling
nodes (`__builtin:falling_node`) and dropped items (`__builtin:item`) on its
own.

However, the identifier can't “identify” (=open the appropriate entry) custom
objects because the mod doesn't know which help entry to open (if there is
any). One example would be the boat object (`boats:boat`) from the boats mod
in Minetest Game.
If the player tries to use the tool on an unknown object, an error message is
shown.

Because of this, this mod provides a minimal API for mods to assign a help
entry to an object type: `doc_identifier.register_object`.

## `doc.sub.identifier.register_object(object_name, category_id, entry_id)`
Registers the object/entity with the internal name `object_name` to the
entry `entry_id` in the category `category_id`.
It is in the modder's responsibility to make sure that both the category and
entry already exist (use `doc.entry_exists` or depend (optionally or not) on
the respective mods) at the time of the function call, otherwise, stability can
not be guaranteed.

Returns `nil`.

### Example
From `doc_minetest_game`:

    if minetest.get_modpath("doc_identifier") ~= nil then
        doc.sub.identifier.register_object("boats:boat", "craftitems", "boats:boat")
    end

This enables the tool to be used on the boat object itself. The conditional is
an idiom to check for the existence of this mod.

## Note on dependencies
If you just need `doc.sub.identifier.register_object` using only an **optional**
dependency for your mod is probably enough.

