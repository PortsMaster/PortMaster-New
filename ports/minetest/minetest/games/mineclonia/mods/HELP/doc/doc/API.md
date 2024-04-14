# API documentation for the Documentation System
## Core concepts
As a modder, you are free to write basically about everything and are also
relatively free in the presentation of information. There are no
restrictions on content whatsoever.

### Categories and entries
In the Documentation System, everything is built on categories and entries.
An entry is a single piece of documentation and is the basis of all actual
documentation. Categories group multiple entries of the same topic together.

Categories also define a template function which is used to determine how the
final result in the tab “Entry list” looks like. Entries themselves have
a data field attached to them, this is a table containing arbitrary metadata
which is used to construct the final formspec in the Entry tab. It may also
be used for sorting entries in the entry list.

## Advanced concepts
### Viewed and hidden entries
The mod keeps track of which entries have been viewed on a per-player basis.
Any entry which has been accessed by a player is immediately marked as
“viewed”.

Entries can also be hidden. Hidden entries are not visible or otherwise
accessible to players until they become revealed by function calls.

Marking an entry as viewed or revealed is not reversible with this API.
The viewed and hidden states are stored in the file `doc.mt` inside the
world directory. You can safely delete this file if you want to reset
the player states.

### Entry aliases
Entry aliases are alternative identifiers for entry identifiers. With the
exception of the alias functions themselves, for functions demanding an
`entry_id` you can either supply the original `entry_id` or any alias of the
`entry_id`.

## Possible use cases
This section shows some possible use cases to give you a rough idea what
this mod is capable of and how these use cases could be implemented.

### Simple use case: Minetest basics
Let's say you want to write in free form short help texts about the basic
concepts of Minetest or your game. First you could define a category
called “Basics”, the data for each of its entry is just a free form text.
The template function simply creates a formspec where this free form
text is displayed.

This is one of the most simple use cases and the mod `doc_basics` does
exactly that.

### Complex use case: Blocks
You could create a category called “Blocks”, and this category is supposed to
contain entries for every single block (i.e. node) in the game. For this use
case, a free form approach would be very inefficient and error-prone, as a
lot of data can be reused.

Here the template function comes in handy: The internal entry data
contain a lot of different things about a block, like block name, identifier,
custom description and most importantly, the definition table of the block.

Finally, the template function takes all that data and turns it into
sentences which are just concatenated, telling as many useful facts about
this block as possible.

## Functions
This is a list of all publicly available functions.

### Overview
The most important functions are `doc.add_category` and `doc.ad_entry`. All other functions
are mostly used for utility and examination purposes.

If not mentioned otherwise, the return value of all functions is `nil`.

These functions are available:

#### Core
* `doc.add_category`: Adds a new category
* `doc.add_entry`: Adds a new entry

#### Display
* `doc.show_entry`: Shows a particular entry to a player
* `doc.show_category`: Shows the entry list of a category to a player
* `doc.show_doc`: Opens the main help form for a player

#### Query
* `doc.get_category_definition`: Returns the definition table of a category
* `doc.get_entry_definition`: Returns the definition table of an entry
* `doc.entry_exists`: Checks whether an entry exists
* `doc.entry_viewed`: Checks whether an entry has been viewed/read by a player
* `doc.entry_revealed`: Checks whether an entry is visible and normally accessible to a player
* `doc.get_category_count`: Returns the total number of categories
* `doc.get_entry_count`: Returns the total number of entries in a category
* `doc.get_viewed_count`: Returns the number of entries a player has viewed in a category
* `doc.get_revealed_count`: Returns the number of entries a player has access to in a category
* `doc.get_hidden_count`: Returns the number of entries which are hidden from a player in a category
* `doc.get_selection`: Returns the currently viewed entry/category of a player

#### Modify
* `doc.set_category_order`: Sets the order of categories in the category list
* `doc.mark_entry_as_viewed`: Manually marks an entry as viewed/read by a player
* `doc.mark_entry_as_revealed`: Make a hidden entry visible and accessible to a player
* `doc.mark_all_entries_as_revealed`: Make all hidden entries visible and accessible to a player

#### Aliases
* `doc.add_entry_alias`: Add an alternative name which can be used to access an entry

#### Special widgets
This API provides functions to add unique “widgets” for functionality
you may find useful when creating entry templates. You find these
functions in `doc.widgets`.
Currently there is a widget for scrollable multi-line text and a
widget providing an image gallery.



### `doc.add_category(id, def)`
Adds a new category. You have to define an unique identifier, a name
and a template function to build the entry formspec from the entry
data.

**Important**: You must call this function *before* any player joins.

#### Parameters
* `id`: Unique category identifier as a string
* `def`: Definition table with the following fields:
    * `name`: Category name to be shown in the interface
    * `description`: (optional) Short description of the category,
       will be shown as tooltip. Recommended style (in English):
       First letter capitalized, no punctuation at the end,
       max. 100 characters
    * `build_formspec`: The template function (see below). Takes entry data
      as its first parameter (has the data type of the entry data) and the
      name of the player who views the entry as its second parameter. It must
      return a formspec which is inserted in the Entry tab.
    * `sorting`: (optional) Sorting algorithm for display order of entries
        * `"abc"`: Alphabetical (default)
        * `"nosort"`: Entries appear in no particular order
        * `"custom"`: Manually define the order of entries in `sorting_data`
        * `"function"`: Sort by function defined in `sorting_data`
    * `sorting_data`: (optional) Additional data for special sorting methods.
        * If `sorting=="custom"`, this field must contain a table (list form) in which
          the entry IDs are specified in the order they are supposed to appear in the
          entry list. All entries which are missing in this table will appear in no
          particular order below the final specified one.
        * If `sorting=="function"`, this field is a compare function to be used as
          the `comp` parameter of `table.sort`. The parameters given are two entries.
        * This field is not required if `sorting` has any other value
    * `hide_entries_by_default` (optional): If `true`, all entries
      added to this category will start as hidden, unless explicitly specified otherwise
      (default: `false`)

Note: For function-based sorting, the entries provided to the compare function
will have the following format:

    {
        eid = e,	-- unique entry identifier
        name = n,	-- entry name
        data = d,	-- arbitrary entry data
    }

#### Using `build_formspec`
For `build_formspec` you can either define your own function which
procedurally generates the entry formspec or you use one of the
following predefined convenience functions:

* `doc.entry_builders.text`: Expects entry data to be a string.
  It will be inserted directly into the entry. Useful for entries with
  a free form text.
* `doc.entry_builders.text_and_gallery`: For entries with text and
  an optional standard gallery (3 rows, 3:2 aspect ratio). Expects
  entry data to be a table with these fields:
    * `text`: The entry text
    * `images`: The images of the gallery, the format is the same as the
       `imagedata` parameter of `doc.widgets.gallery`. Can be `nil`, in
       which case no gallery is shown for the entry
* `doc.entry_builders.formspec`: Entry data is expected to contain the
  complete entry formspec as a string. Useful if your entries. Useful
  if you expect your entries to differ wildly in layouts.

##### Formspec restrictions
When building your formspec, you have to respect the size limitations.
The help form currently uses a size of 15×10.5 and you must make sure
all entry widgets are inside a boundary box. The remaining space is
reserved for widgets of the help form and should not be used to avoid
overlapping.
Read from the following variables to calculate the final formspec coordinates:

* `doc.FORMSPEC.WIDTH`: Width of help formspec
* `doc.FORMSPEC.HEIGHT`: Height of help formspec
* `doc.FORMSPEC.ENTRY_START_X`: Leftmost X point of bounding box
* `doc.FORMSPEC.ENTRY_START_Y`: Topmost Y point of bounding box
* `doc.FORMSPEC.ENTRY_END_X`: Rightmost X point of bounding box
* `doc.FORMSPEC.ENTRY_END_Y`: Bottom Y point of bounding box
* `doc.FORMSPEC.ENTRY_WIDTH`: Width of the entry widgets bounding box
* `doc.FORMSPEC.ENTRY_HEIGHT`: Height of the entry widgets bounding box

Finally, to avoid naming collisions, you must make sure that all identifiers
of your own formspec elements do *not* begin with “`doc_`”.

##### Receiving formspec events
You can even use the formspec elements you have added with `build_formspec` to
receive formspec events, just like with any other formspec. For receiving, use
the standard function `minetest.register_on_player_receive_fields` to register
your event handling. The `formname` parameter will be `doc:entry`. Use
`doc.get_selection` to get the category ID and entry ID of the entry in question.

### `doc.add_entry(category_id, entry_id, def)`
Adds a new entry into an existing category. You have to define the category
to which to insert the entry, the entry's identifier, a name and some
data which defines the entry. Note you do not directly define here how the
end result of an entry looks like, this is done by `build_formspec` from
the category definition.

**Important**: You must call this function *before* any player joins.

#### Parameters
* `category_id`: Identifier of the category to add the entry into
* `entry_id`: Unique identifier of the new entry, as a string
* `def`: Definition table, it has the following fields:
    * `name`: Entry name to be shown in the interface
    * `hidden`: (optional) If `true`, entry will not be displayed in entry list
      initially (default: `false`); it can be revealed later
    * `data`: Arbitrary data attached to the entry. Any data type is allowed;
      The data in this field will be used to create the actual formspec
      with `build_formspec` from the category definition

### `doc.set_category_order(category_list)`
Sets the order of categories in the category list.
The help starts with this default order:

    {"basics", "nodes", "tools", "craftitems", "advanced"}

This function can be called at any time, but it recommended to only call
this function once for the entire server session and to only call it
from game mods, to avoid contradictions. If this function is called a
second time by any mod, a warning is written into the log.

#### Parameters
* `category_list`: List of category IDs in the order they should appear
  in the category list. All unspecified categories will be appended to
  the end


### `doc.show_doc(playername)`
Opens the main help formspec for the player (“Category list” tab).

#### Parameters
* `playername`: Name of the player to show the formspec to

### `doc.show_category(playername, category_id)`
Opens the help formspec for the player at the specified category
(“Entry list” tab).

#### Parameters
* `playername`: Name of the player to show the formspec to
* `category_id`: Category identifier of the selected category

### `doc.show_entry(playername, category_id, entry_id, ignore_hidden)`
Opens the help formspec for the player showing the specified entry
of a category (“Entry” tab). If the entry is hidden, an error message
is displayed unless `ignore_hidden==true`.

#### Parameters
* `playername`: Name of the player to show the formspec to
* `category_id`: Category identifier of the selected category
* `entry_id`: Entry identifier of the entry to show
* `ignore_hidden`: (optional) If `true`, shows entry even if it is still hidden
  to the player; this will automatically reveal the entry to this player for the
  rest of the game

### `doc.get_category_definition(category_id)`
Returns the definition of the specified category.

#### Parameters
* `category_id`: Category identifier of the category to the the definition
  for

#### Return value
The category's definition table as specified in the `def` argument of
`doc.add_category`. The table fields are the same.

### `doc.get_entry_definition(category_id, entry_id)`
Returns the definition of the specified entry.

#### Parameters
* `category_id`: Category identifier of entry's category
* `entry_id`: Entry identifier of the entry to get the definition for

#### Return value
The entry's definition table as specified in the `def` argument of
`doc.add_entry`. The table fields are the same.

### `doc.entry_exists(category_id, entry_id)`
Checks whether the specified entry exists and returns `true` or `false`.
Entry aliases are taken into account.

#### Parameters
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check for its existence

#### Return value
Returns `true` if and only if:

* The specified category exists
* It contains the specified entry

Otherwise, returns `false`.

### `doc.entry_viewed(playername, category_id, entry_id)`
Tells whether the specified entry is marked as “viewed” (or read) by
the player.

#### Parameters
* `playername`: Name of the player to check
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check

#### Return value
`true`, if entry is viewed, `false` otherwise.

### `doc.entry_revealed(playername, category_id, entry_id)`
Tells whether the specified entry is marked as “revealed” to the player
and thus visible and accessible to the player.

#### Parameters
* `playername`: Name of the player to check
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check

#### Return value
`true`, if entry is revealed, `false` otherwise.

### `doc.mark_entry_as_viewed(playername, category_id, entry_id)`
Marks a particular entry as “viewed” (or read) by a player. This will
also automatically reveal the entry to the player for the rest of
the game.

#### Parameters
* `playername`: Name of the player for whom to mark an entry as “viewed”
* `category_id`: Category identifier of the category of the entry to mark
* `entry_id`: Entry identifier of the entry to mark

### `doc.mark_entry_as_revealed(playername, category_id, entry_id)`
Marks a particular entry as “revealed” to a player. If the entry is
declared as hidden, it will become visible in the list of entries for
this player and will always be accessible with `doc.show_entry`. This
change remains for the rest of the game.

For entries which are not normally hidden, this function has no direct
effect.

#### Parameters
* `playername`: Name of the player for whom to reveal the entry
* `category_id`: Category identifier of the category of the entry to reveal
* `entry_id`: Entry identifier of the entry to reveal

### `doc.mark_all_entries_as_revealed(playername)`
Marks all entries as “revealed” to a player. This change remains for the
rest of the game.

#### Parameters
* `playername`: Name of the player for whom to reveal the entries

### `doc.add_entry_alias(category_id_orig, entry_id_orig, category_id_alias, entry_id_alias)`
Adds a single alias for an entry. If an entry has an alias, supplying the
alias to a function which demand `category_id` and `entry_id` will work as expected.
When using this function, you must make sure the category already exists.

This function could be useful for legacy support after changing an entry ID or
moving an entry to a different category.

#### Parameters
* `category_id_orig`: Category identifier of the category of the entry in question
* `entry_id_orig`: The original (!) entry identifier of the entry to create an alias
  for
* `category_id_alias`: The category ID of the alias
* `entry_id_alias`: The entry ID of the alias

#### Example

    doc.add_entry_alias("nodes", "test", "craftitems", "test2")

When calling a function with category ID “craftitems” and entry ID “test2”, it will
act as if you supplied “nodes” as category ID and “test” as entry ID.

### `doc.get_category_count()`
Returns the number of registered categories.

#### Return value
Number of registered categories.

### `doc.get_entry_count(category_id)`
Returns the number of entries in a category.

#### Parameters
* `category_id`: Category identifier of the category in which to count entries

#### Return value
Number of entries in the specified category.

### `doc.get_viewed_count(playername, category_id)`
Returns how many entries have been viewed by a player.

#### Parameters
* `playername`: Name of the player to count the viewed entries for
* `category_id`: Category identifier of the category in which to count the
  viewed entries

#### Return value
Amount of entries the player has viewed in the specified category. If the
player does not exist, this function returns `nil`.

### `doc.get_revealed_count(playername, category_id)`
Returns how many entries the player has access to (non-hidden entries)
in this category.

#### Parameters
* `playername`: Name of the player to count the revealed entries for
* `category_id`: Category identifier of the category in which to count the
  revealed entries

#### Return value
Amount of entries the player has access to in the specified category. If the
player does not exist, this function returns `nil`.

### `doc.get_hidden_count(playername, category_id)`
Returns how many entries are hidden from the player in this category.

#### Parameters
* `playername`: Name of the player to count the hidden entries for
* `category_id`: Category identifier of the category in which to count the
  hidden entries

#### Return value
Amount of entries hidden from the player. If the player does not exist,
this function returns `nil`.

### `doc.get_selection(playername)`
Returns the currently or last viewed entry and/or category of a player.

#### Parameter
* `playername`: Name of the player to query

#### Return value
It returns up to 2 values. The first one is the category ID, the second one
is the entry ID of the entry/category which the player is currently viewing
or is the last entry the player viewed in this session. If the player only
viewed a category so far, the second value is `nil`. If the player has not
viewed a category as well, both returned values are `nil`.


### `doc.widgets.text(data, x, y, width, height)`
This is a convenience function for creating a special formspec widget. It creates
a widget in which you can insert scrollable multi-line text.

#### Parameters
* `data`: Text to be written inside the widget
* `x`: Formspec X coordinate (optional)
* `y`: Formspec Y coordinate (optional)
* `width`: Width of the widget in formspec units (optional)
* `height`: Height of the widget in formspec units (optional)

The default values for the optional parameters result in a widget which fills
nearly the entire entry page.

#### Return value
Two values are returned, in this order:

* string: Contains a complete formspec definition building the widget
* string: Formspec element ID of the created widget

#### Note
If you use this function to build a formspec string, do not use identifiers
beginning with `doc_widget_text` to avoid naming collisions, as this function
makes use of such identifiers internally.


### `doc.widgets.gallery(imagedata, playername, x, y, aspect_ratio, width, rows, align_left, align_top)`
This function creates an image gallery which allows you to display an
arbitrary amount of images aligned horizontally. It is possible to add more
images than the space of an entry would normally held, this is done by adding
“scroll” buttons to the left and right which allows the user to see more images
of the gallery.

This function is useful for adding multiple illustration to your entry without
worrying about space too much. Adding illustrations can help you to create
entry templates which aren't just lengthy walls of text. ;-)

You can define the position, image aspect ratio, total gallery width and the
number of images displayed at once. You can *not* directly define the image
size, nor the resulting height of the overall gallery, those values will
be derived from the parameters.

You can only really use this function efficiently inside a *custom*
`build_formspec` function definition. This is because you need to pass a
`playername`. You can currently also only add up to one gallery per entry;
adding more galleries is not supported and will lead to bugs.

### Parameters
* `imagedata`: List of images to be displayed in the specified order. All images must
   have the same aspect ratio. It's a table of tables with this format:
    * `imagetype`: Type of image to be used (optional):
        * `"image"`: Texture file (default)
        * `"item"`: Item image, specified as itemstring
    * `image`: What to display. Depending on `imagetype`, a texture file or itemstring
* `playername`: Name of the player who is viewing the entry in question
* `x`: Formspec X coordinate of the top left corner (optional)
* `y`: Formspec Y coordinate of the top left corner (optional)
* `aspect_ratio`: Aspect ratio of all the images (width/height)
* `width`: Total gallery width in formspec units (optional)
* `rows`: Number of images which can be seen at once (optional)
* `align_left`: If `false`, gallery is aligned to the left instead of the right (optional)
* `align_right`: If `false`, gallery is aligned to the bottom instead of the top (optional)

The default values for the optional parameters result in a gallery with
3 rows which is placed at the top left corner and spans the width of the
entry and assumes an aspect ratio of two thirds.

If the number of images is greater than `rows`, “scroll” buttons will appear
at the left and right side of the images.

#### Return values
Two values are returned, in this order:

* string: Contains a complete formspec definition building the gallery
* number: The height the gallery occupies in the formspec

## Extending this mod (naming conventions)
If you want to extend this mod with your own functionality, it is recommended
that you put all API functions into `doc.sub.<name>`.
As a naming convention, if you mod *primarily* depends on `doc`, it is recommended
to use a short mod name which starts with “`doc_`”, like `doc_items`,
`doc_minetest_game`, or `doc_identifier`.

One mod which uses this convention is `doc_items` which uses the `doc.sub.items`
table.


