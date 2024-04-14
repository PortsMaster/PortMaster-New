# API documentation for `doc_items`
## Introduction
This document explains the API of `doc_items`. It contains a reference of
all functions.

## Quick start
The most common use case for using this API requires only to set some
hand-written help texts for your items.

The preferred way is to add the following optional fields to the
item definition when using `minetest.register_node`, etc.:

* `_doc_items_longdesc`: Long description of this item.
  Describe here what this item is, what it is for, its purpose, etc.
* `_doc_items_usagehelp`: Description of *how* this item can be used.
  Only set this if needed, e.g. standard mining tools don't need this.

Example:

    minetest.register_node("example:dice", {
        description = "Dice",
        _doc_items_longdesc = "A decorative dice which shows the numbers 1-6 on its sides.",
        _doc_items_usagehelp = "Right-click the dice to roll it.",
        tiles = { "example_dice.png" },
        is_ground_content = false,
        --[[ and so on … ]]
    })

When using this method, your mod does not need additional dependencies.

See below for some recommendations on writing good help texts.

If you need more customization, read ahead. ;-)

## New item fields
This mod adds support for new fields of the item definition. They allow for
easy and quick manipulation of the item help entries. All fields are optional.

* `_doc_items_longdesc`: Long description
* `_doc_items_usagehelp`: Usage help
* `_doc_items_image`: Entry image (default: inventory image)
* `_doc_items_hidden`: Whether entry is hidden (default: `false` for air and hand, `true` for everything else)
* `_doc_items_create_entry`: Whether to create an entry for this item (default: `true`)
* `_doc_items_entry_name`: The title of the entry. By default, this is the same as the `description` field
  of the item (discarding text after the first newline). This field is required if the `description` is empty
* `_doc_items_durability`: This field is for describing how long a tool can be used before it breaks. Choose one data type:
   * It it is a `number`: Fixed number of uses before it breaks
   * If it is a `string`: Free-form text which explains how the durability works. Try to keep it short and only use it if the other types won't work

A full explanation of these fields is provided below.

## Concepts
This section explains the core concepts of an item help entry in-depth.

### Factoids
Basically, a factoid is usually a single sentence telling the player a specific
fact about the item. The task of each factoid is to basically convert parts
of the item definition to useful, readable, understandable text.

Example: It's a fact that `default:sand` has the group `falling_node=1`.
A factoid for this is basically just a simple conditional which puts the
the sentence “This block is affected to gravity and can fall.” into the
text if the node is member of said group.

Factoids can be more complex than that. The factoid for node drops needs to
account for different drop types and probabilities, etc.

`doc_items` has many predefined factoids already. This includes all “special”
groups (like `falling_node`), drops, mining capabilities, punch interval,
and much more.

Custom factoids can be added with `doc.sub.items.register_factoid`.

The idea behind factoids is to generate as much information as possible
automatically to reduce redundancy, inconsistencies and the workload of hand-
written descriptions.

### Long description and usage help
Factoids are not always sufficient to describe an item. This is the case
for facts where the item definition can not be used to automatically
generate texts. Examples: Custom formspecs, ABMs, special tool action
on right-click.

That's where the long description and usage help comes into play.
Those are two texts which are written manually for a specific item.

Roughly, the long description is for describing **what** the item is, how it
acts, what it is for. The usage help is for explaining **how** the
item can be used. It is less important for standard mining tools and weapons.

There is no hard length limit for the long description and the usage help.

#### Recommendations for long description
The long description should roughly contain the following info:

* What the item does
* What it is good for
* How it may be generated in the world
* Maybe some background info if you're in a funny mood
* Notable information which doesn't fit elsewhere

The description should normally **not** contain:

* Information which is already covered by factoids, like digging groups,
  damage, group memberships, etc.
* How the item can be used
* Direct information about other items
* Any other redundant information
* Crafting recipes

One exception from the rule may be for highlighting the most important
purpose of a simple item, like that coal lumps are primarily used as fuel.

Sometimes, a long description is not necessary because the item is already
exhaustively explained by factoids.

For very simple items, consider using one of the template texts (see below).

Minimal style guide: Use complete sentences.

#### Recommendations for usage help
The usage help should only be set for items which are in some way special
in their usage. Standard tools and weapons should never have an usage help.

The rule of thumb is this: If a new player who already knows the Minetest
basics, but not this item, will not directly know how to use this item,
then the usage help should be added. If basic Minetest knowledge or
existing factoids are completely sufficient, usage help should not be added.

The recommendations for what not to put into the usage help is the same
as for long descriptions.

#### Template texts
For your convenience, a few template texts are provided for common texts
to avoid redundancy and to increase consistency for simple things. Read
`init.lua` to see the actual texts.

##### Long description
* `doc.sub.items.temp.build`: For building blocks like the brick block in Minetest Game
* `doc.sub.items.temp.deco`: For other decorational blocks.
* `doc.sub.items.temp.craftitem`: For items solely or almost solely used for crafting

##### Usage help
* `doc.sub.items.temp.eat`: For eatable items using the `on_use=minetest.item_eat(1)` idiom
* `doc.sub.items.temp.eat_bad`: Same as above, but eating them is considered a bad idea
* `doc.sub.items.temp.rotate_node`: For nodes with `on_place=minetest.rotate_node`,
  explains placement and rotation

### Entry creation
By default, an entry for each item is added automatically, except for items
without a description (`description == nil`). This behaviour can be changed
on a per-item basis.

By setting the item definition's field `_doc_items_create_entry` to `true`
or `false`you can explicitly define whether this item should get its own
entry.

Suppressing an entry is useful for items which aren't supposed to be directly
seen or obtained by the player or if they are only used for technical
and/or internal purposes. Another possible reason to suppress an entry is
to scrub the entry list of lots of very similar related items where the
difference is too small to justify two separate entries (e.g.
burning furnace vs inactive furnace, because the gameplay mechanics are
identical for both).

### Hidden entries
Hidden entries are entries which are not visible in the list of entries. This
concept directly comes from the Documentation System. The entry will still be
created, it is just not selectable by normal means. Players might be able to
“unlock” an entry later. Refer to the API documentation of the Documentation
System to learn more.

By default, all entries are hidden except air and the hand.

To mark an entry as hidden, add the field `_doc_items_hidden=true` to its
item definition. To make sure an entry is never hidden, add
`_doc_items_hidden=false` instead (this rarely needs to be specified
explicitly).

### Hand and air
The mod adds some default help texts for the hand and the air which are
written in a way that they probably are true for most games out of the
box, but especially the hand help text is kept intentionally vague.
If you want to change these help texts or the entry names or other
attributes, just add `_doc_items_*` fields to the item definition, either
by re-defining or overwriting these items (e.g. with
`minetest.override_item`).

In the mod `doc_minetest_game`, the default hand help text is overwritten
to explain the hand in more detail, especially the hand behaviour in
Creative Mode.

## Functions
This is the reference of all available functions in this API.

### `doc.sub.items.register_factoid(category_id, factoid_type, factoid_generator)`
Add a custom factoid (see above) for the specified category.

* `category_id`: The help category for which the factoid applies:
    * `"nodes"`: Blocks
    * `"tools"`: Tools and weapons
    * `"craftitems"`: Misc. items
    * `nil`: All of the above
* `factoid_type`: Rough categorization of the factoid's content, used to
  optimize the final text display. This currently determines where in the
  entry text the factoid appears. Possible values:
    * For all items:
        * `"use"`: It's about using the item in some way (written right after the fixed usage help)
        * `"groups"`: Group-related factoid (very vague)
        * `"misc"`: Factoid doesn't fit anywhere else, is shown near the end
    * For nodes only:
        * `damage`: Related to player/mob damage or health
        * `movement`: Related to player movement on, in or at node
        * `sound`: Related to node sounds
        * `gravity`: Related to gravity (e.g. falling node)
        * `drop_destroy`: Related to node being destroyed or node dropping as an item
        * `light`: Related to node light (luminance)
        * `mining`: Related to mining
        * `drops`: Related to node drops
* `factoid_generator`: A function which turns item definition into a string
  (see blow)

#### `factoid_generator(itemstring, def)`
`itemstring` is the itemstring of the item to be documented, and `def` is the
complete item definition table (from Minetest).

This function must return a helpful string which turns a part of the item's
definition into an useful sentence or text. The text can contain newlines,
but it must not end with a newline.

This function must **always** return a string. If you don't want to add any text,
return the empty string.

Style guide: Try to use complete sentences and avoid too many newlines.

#### Example
This factoid will add the sentence “This block will extinguish nearby fire.”
to all blocks which are member of the group `puts_out_fire`.

    doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
        if def.groups.puts_out_fire ~= nil then
            return "This block will extinguish nearby fire."
        else
            return ""
        end
    end)


### `doc.sub.items.disable_core_factoid(factoid_name)`
This function removes a core (built-in) factoid entirely, its text will never be displayed in any
entry then.

#### Parameter
`factoid_name` chooses the factoid you want to disable. The following core factoids can be disabled:

* `"node_mining"`: Mining properties of nodes
* `"tool_capabilities"`: Tool capabilities such as digging times
* `"groups"`: Group memberships
* `"fuel"`: How long the item burns as a fuel and if there's a leftover
* `"itemstring"`: The itemstring
* `"drops"`: Node drops
* `"connects_to"`: Tells to which nodes the node connects to
* `"light"`: Light and transparency information for nodes
* `"drop_destroy"`: Information about when the node causes to create its “drop” and if it gets destroyed by flooding
* `"gravity"`: Factoid for `falling_node` group
* `"sounds"`: Infos about sound effects related to the item
* `"node_damage"`: Direct damage and drowning damage caused by nodes
* `"node_movement"`: Nodes affecting player movement
* `"liquid"`: Liquid-related infos of a node
* `"basics"`: Collection of many basic factoids: The custom help texts, pointability, collidability, range, stack size, `liquids_pointable`, “punches don't work as usual”. Be careful with this one!

#### Background
Normally, the core factoids are written in a very general-purpose style, so this function might
not be needed at all. But it might be useful for games and mods which radically break with
some of the underlying core assumptions in Minetest. For example, if your mod completely changes
the digging system, the help texts provided by `doc_items` are probably incorrect, so you can
disable `node_mining` and register a custom factoid as a replacement.

Please do not use this function lightly because it touches the very core of `doc_items`. Try to
understand a core factoid before you consider to disable it. If you think a core factoid is just
broken or buggy in general, please file a bug instead.


### `doc.sub.items.add_friendly_group_names(groupnames)`
Use this function so set some more readable group names to show them
in the formspec, since the internal group names are somewhat cryptic
to players.

`groupnames` is a table where the keys are the “internal” group names and
the values are the group names which will be actually shown in the
Documentation System.

***Note***: This function is mostly there to work around a problem in
Minetest as it does not support “friendly” group names, which means exposing
groups to an interface is not pretty. Therefore, this function may be
deprecated when Minetest supports such a thing.

### `doc.sub.items.get_group_name(internal_group_name)`
Returns the group name of the specified group as displayed by this mod.
If the setting `doc_items_friendly_group_names` is `true`, this might
return a “friendly” group name (see above). If no friendly group name
exists, `internal_group_name` is returned.
If `doc_items_friendly_group_names` is `false`, the argument is always
returned.

### `doc.sub.items.add_notable_groups(groupnames)`
Add a list of groups you think are notable enough to be mentioned in the
“This item belongs to the following groups: (…)” factoid. This factoid
is intended to give a quick rundown of misc. groups which don't fit
to other factoids, yet they are still somewhat relevant to gameplay.

`groupnames` is a table of group names you wish to add.

#### What groups should be added
What is “notable” is subjective, but there are some guidelines:

Do add a group if:

* It is used in an ABM
* It is used for a custom interaction with another item
* It is simple enough for the player to know an item is member of this group
* You want to refer to this group in help texts
* The “don'ts” below don't apply

Do not add a group if:

* It is *only* used for crafting, `connects_to`, mining times or damage groups
* A factoid covering this group already exists
* The group membership itself requires an explanation (consider writing a factoid instead)
* The group has no gameplay relevance
* Group rating is important to gameplay (consider writing a factoid instead)

Groups which are used for crafting or in the `connects_to` field of item
definitions are already automatically added to this factoid.

##### Examples for good additions

* A group where its members can be placed in bookshelves.
  so this group meets the “custom interaction” criterion
* `water` in Minetest Game: Used for water nodes in the obsidian ABM
* `sand` in Minetest Game: Used for the cactus growth ABM, but also crafting.
  Since it is not *only* used for crafting, it is OK to be added

##### Examples for bad additions

* `stick` in Minetest Game: This group appears in many crafting recipes and
  has no other use. It is already added automatically
* A group in which members turn into obsidian when they touch water (ABM):
  This group is not trivial and should be introduced in a factoid instead
* `cracky` in Min
* `dig_immediate`: This group is already covered by the default factoids of this
  mod


## Groups interpretations
Nodes which are technically a liquid will not be considered liquids by this mod
if the group `fake_liquid=1` is used. Useful for stuff like cobwebs.



## Dependencies
If you only add the custom fields to your items, you do *not* need to depend
on this mod. If you use anything else from this mod (e.g. a function), you
probably *do* need to depend (optionally or mandatorily) on this mod.
