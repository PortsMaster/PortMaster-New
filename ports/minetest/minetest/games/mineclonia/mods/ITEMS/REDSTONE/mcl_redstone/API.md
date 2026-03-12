# API for `mcl_redstone`

This mods adds an API for defining custom redstone components. Note that the
API is still subject to minor changes in the future, even though one can expect
most of it to remain the same.

## Example

Here is an example from the redstone torch. The relevant parts for
`mcl_redstone` is in the `_mcl_redstone` field. It defines `get_power` to make
the torch emit power to all surrounding nodes except the node it is wallmounted
on.  The node above the torch is strongly powered indicated by the `dir.y > 0`
return. It also defines `update` to make the torch turn off if the node it is
wallmounted on is powered.

```lua
minetest.override_item("mcl_redstone_torch:redstone_torch_on", {
    paramtype2 = "wallmounted",
    [...]
    _mcl_redstone = {
        connects_to = function(node, dir)
            return true
        end,
        get_power = function(node, dir)
            return minetest.dir_to_wallmounted(dir) ~= node.param2 and 15 or 0, dir.y > 0
        end,
        update = function(pos, node)
            if mcl_redstone.get_power(pos, minetest.wallmounted_to_dir(node.param2))) ~= 0 then
                return {
                    name = "mcl_redstone_torch:redstone_torch_off",
                    param2 = node.param2,
                }
            end
        end,
    },
})
```

The definition for the turned off redstone torch is similar except it turns it
on in `update` and does not have `get_power` (which is equivalent to have it
always return `0`).

```lua
minetest.override_item("mcl_redstone_torch:redstone_torch_off", {
    paramtype2 = "wallmounted",
    [...]
    _mcl_redstone = {
        connects_to = function(node, dir)
            return true
        end,
        update = function(pos, node)
            if mcl_redstone.get_power(pos, minetest.wallmounted_to_dir(node.param2)) == 0 then
                return {
                    name = "mcl_redstone_torch:redstone_torch_on",
                    param2 = node.param2,
                }
            end
        end,
    },
})
```

## Redstone definition

The `_mcl_redstone` field of node definitions is what defines a node as a
redstone component.

```lua
{
    get_power = function(node, dir),
    update = function(pos, node),
    init = function(pos, node),
}
```

### `get_power = function(node, dir)`

Should return the power level going from the node to the direction `dir`.
Returns two values, the power level and a boolean indicating if it will
strongly power a node in that direction. Not defining it is equivalent to
having it always return `0, false`.

### `connects_to = function(node, dir)`

Should return `true` if a neighbouring redstone trail from the direction `dir`
should form a connection to the node.

### `update = function(pos, node)`

The `update` callback gets called when the power level of a surrounding node
changes. It has three arguments:

1. `pos` -- The position of the node
2. `node` -- The node (equivalent to `minetest.get_node(pos)`)

The return value is used for updating the node itself. It should return `nil`
or an object with the following values:

```lua
{
    name = "",       -- Name of node to replace with
    param2 = 0,      -- param2 value of node to replace with
    delay = 1,       -- Delay in ticks until node is replaced
    priority = 1000, -- Priority of update
}
```

The `priority` value is used to determine which update gets prioritized if
multiple overlap. For example, using `priority = 1` when turning on and
`priority = 2` when turning off will make a component with a delayed update
keep its powered-on state when its input is quickly toggled off and on again.
If two overlapping updates have same priority, the first one is prioritized.
Only values > 0 are allowed.

If `nil` is returned the node stays unchanged.

The `update` callback will sometimes be called even though nothing of relevance
has changed. Because of this, nodes that perform actions on redstone pulses
must keep track of their previous power state. This can be done either by
storing a flag in `param2` or by registering a separate powered-on node.

### `init = function(pos, node)`

The `init` callback gets called after a node is placed normally or by
mcl_redstone. It will also be called after the mapblock of the node is loaded.
It has the same type of return value as the `update` callback. It is used for
redstone components (like pressed buttons) that are supposed to deactivate in a
given number of ticks.

If `init` has not been specified it will default to the `update`. For nodes
were this is undesirable (like doors), `init` should be set to an empty
function.

## `mcl_redstone.after(delay, func)`

Calls the function `func` after `delay` ticks.

## `mcl_redstone.get_power(pos, dir)`

Returns the power level coming from `dir` into the node at pos. The direction
is relative to `pos`. So (0, 1, 0) means power coming from the node above for
example. The `dir` argument can be omitted in which case it returns the maximum
power level of all six directions.

If option is `"direct"`, it will not take into account the power going through
opaque nodes.

## `mcl_redstone.update_node(pos)`

Schedule an update to redstone component at `pos`.

## `mcl_redstone.swap_node(pos, node)`

Like `minetest.swap_node` but will trigger redstone updates to surrounding
nodes.

## `mcl_redstone.tick_step()`

When called, does the next redstone tick

## `mcl_redstone.tick_speed`

Variable that holds the ticking interval in seconds. Can be modified to change the interval speed

## `mcl_redstone.is_tick_frozen`

Variable that holds whether the redstone will naturally tick. Can be modified to freeze or unfreeze ticking
