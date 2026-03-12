# API for adding Mineclonia fences
This API allows you to add fences and fence gates.
The recommended function is `mcl_fences.register_fence_and_fence_gate`.

## ` mcl_fences.register_fence_def = function(name, definitions)`
Adds a fence with crafting recipe. A single node is created.

### Parameter
* `name`: A part of the itemstring of the node to create. The node name will be “`<modname>:<id>`”
* `definitions`: A table with node definitions. The table must contain at least the following parameters:
    * `description`: User-visible name (e.g. S("My Fence"))
    * `tiles`: Texture to apply on the fence (all sides)
    * `groups`: Table of groups to which the fence belongs to
    * `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
    * `sounds`: Node sound table for the fence
    * `_mcl_blast_resistance`: Blast resistance (if unsure, pick the blast resistance of the material node)
    * `_mcl_hardness`: Hardness (if unsure, pick the hardness of the material node)
    * `_mcl_fences_baseitem`: an itemstring of the fence's base material (e.g. "mcl_core:wood_acacia")

`definitions` may contain some optional fields. In addition to special fields common to other nodes, it may contain the following dedicated fields:
* `_mcl_fences_stickreplacer`: an itemstring used to define whether the fence crafting recipe will use another item in place of the sticks. (_**Used on Nether Brick Fences that use "mcl_nether:netherbrick" instead of the stick**_)

### Return value
The full itemstring of the new fence node.

Notes: Fences will always have the group `fence = 1`. They will always connect to solid nodes (group `solid = 1`).

## `mcl_fences.register_fence_gate_def = function(name, definitions)`
Adds a fence gate with crafting recipe. This will create 2 nodes.

### Parameters
* `name`: A part of the itemstring of the nodes to create. The node names will be “`<modname>:<id>_gate`” and “`<modname>:<id>_gate_open`”
* `definitions`: A table with node definitions. The table must contain at least the following parameters:
    * `description`: User-visible name (`description`)
    * `tiles`: Texture to apply on the fence gate (all sides)
    * `groups`: Table of groups to which the fence gate belongs to
    * `sounds`: Node sound table for the fence gate
    * `_mcl_blast_resistance`: Blast resistance (if unsure, pick the blast resistance of the material node)
    * `_mcl_hardness`: Hardness (if unsure, pick the hardness of the material node)
    * `_mcl_fences_baseitem`: an itemstring of the fence gate base material (e.g. "mcl_core:wood_acacia")

`definitions` may contain some optional fields. In addition to special fields common to other nodes, it may contain the following dedicated fields:
* `_mcl_fences_stickreplacer`: an itemstring used to define whether the fence crafting recipe will use another item in place of the sticks. (_**Used on Nether Brick Fence Gates that use "mcl_nether:netherbrick" instead of the stick**_)
* `_mcl_fences_sounds`: a table that can contain two special keys. These keys are:
    * `open`: a table that can contain the definitions of the sound that will be played when the fence gate is opened
    * `close`: a table that can contain the definitions of the sound that will be played when the fence gate is closed

Both tables can contain these two parameters:
* `spec`: a string with the sound spec. The default, if not set, is doors_fencegate_[state (open or close)]
* `gain`: a floating number with the sound volume gain value. By default, if not defined, the gain value is 0.3. The value must be a number between 0.0 and 1.0

Notes: Fence gates will always have the group `fence_gate = 1`. The open fence gate will always have the group `not_in_creative_inventory = 1`.

### Return value
This function returns 2 values, in the following order:

1. Itemstring of the closed fence gate
2. Itemstring of the open fence gate

## `mcl_fences.register_fence_and_fence_gate_def = function(name, commondefs, fencedefs, gatedefs)`
Registers a fence and fence gate. This is basically a combination of the two functions above. This is the recommended way to add a fence / fence gate pair.
This will register 3 nodes in total with crafting recipes. (**_used in mclx_fences in the red brick nether fence and gate registration._**)

* `name`: A part of the itemstring of the nodes to create.
* `commondefs`: a table with node definitions that will be common to both fence and fence gate. Some recommended definitions for this field are:
    * `tiles`
    * `sounds`
    * `_mcl_blast_resistance`
    * `_mcl_hardness`
    * `_mcl_fences_baseitem`
    * `_mcl_fences_stickreplacer`

* `fencedefs`: a table with the definitions used in fences. It must contain the `description` of the fence. May contain other fields common to other nodes
* `gatedefs`: a table with the definitions used in fence gates. It must contain the `description` of the fence gate. May contain other fields common to other nodes

### Return value
This function returns 3 values, in this order:

1. Itemstring of the fence
2. Itemstring of the closed fence gate
3. Itemstring of the open fence gate

## Old definitions that are still supported

## ` mcl_fences.register_fence = function(id, fence_name, texture, groups, connects_to, sounds)`
Adds a fence without crafting recipe. A single node is created.

### Parameter
* `id`: A part of the itemstring of the node to create. The node name will be “`<modname>:<id>`”
* `fence_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence (all sides)
* `groups`: Table of groups to which the fence belongs to
* `hardness`: Hardness (if unsure, pick the hardness of the material node)
* `blast_resistance`: Blast resistance (if unsure, pick the blast resistance of the material node)
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence

### Return value
The full itemstring of the new fence node.

Notes: Fences will always have the group `fence=1`. They will always connect to solid nodes (group `solid=1`).

## `mcl_fences.register_fence_gate = function(id, fence_gate_name, texture, groups, sounds, sound_open, sound_close, sound_gain_open, sound_gain_close)`
Adds a fence gate without crafting recipe. This will create 2 nodes.

### Parameters
* `id`: A part of the itemstring of the nodes to create. The node names will be “`<modname>:<id>_gate`” and “`<modname>:<id>_gate_open`”
* `fence_gate_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence gate (all sides)
* `groups`: Table of groups to which the fence gate belongs to
* `hardness`: Hardness (if unsure, pick the hardness of the material node)
* `blast_resistance`: Blast resistance (if unsure, pick the blast resistance of the material node)
* `sounds`: Node sound table for the fence gate
* `sound_open`: Sound to play when opening fence gate (optional, default is wooden sound)
* `sound_close`: Sound to play when closing fence gate (optional, default is wooden sound)
* `sound_gain_open`: Gain (0.0-1.0) of the opening fence gate sound (optional, default is 0.3)
* `sound_gain_close`: Gain (0.0-1.0) of the closing fence gate sound (optional, default is 0.3)

Notes: Fence gates will always have the group `fence_gate=1`. The open fence gate will always have the group `not_in_creative_inventory=1`.

### Return value
This function returns 2 values, in the following order:

1. Itemstring of the closed fence gate
2. Itemstring of the open fence gate

## `mcl_fences.register_fence_and_fence_gate = function(id, fence_name, fence_gate_name, texture, groups, connects_to, sounds, sound_open, sound_close, sound_gain_open, sound_gain_close)`
Registers a fence and fence gate. This is basically a combination of the two functions above. This is the recommended way to add a fence / fence gate pair.
This will register 3 nodes in total without crafting recipes.

* `id`: A part of the itemstring of the nodes to create.
* `fence_name`: User-visible name (`description`) of the fence
* `fence_gate_name`: User-visible name (`description`) of the fence gate
* `texture`: Texture to apply on the fence and fence gate (all sides)
* `groups`: Table of groups to which the fence and fence gate belong to
* `hardness`: Hardness (if unsure, pick the hardness of the material node)
* `blast_resistance`: Blast resistance (if unsure, pick the blast resistance of the material node)
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence and the fence gate
* `sound_open`: Sound to play when opening fence gate (optional, default is wooden sound)
* `sound_close`: Sound to play when closing fence gate (optional, default is wooden sound)
* `sound_gain_open`: Gain (0.0-1.0) of the opening fence gate sound (optional, default is 0.3)
* `sound_gain_close`: Gain (0.0-1.0) of the closing fence gate sound (optional, default is 0.3)

### Return value
This function returns 3 values, in this order:

1. Itemstring of the fence
2. Itemstring of the closed fence gate
3. Itemstring of the open fence gate
