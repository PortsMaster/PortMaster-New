# `mcl_pressureplates` API

This API allows for registering pressure plates.

## `mcl_pressureplates.register_pressureplate(basename, def)`

Register pressureplate from pressure plate definition `def`. It will register
the nodes `mcl_pressureplates:pressure_plate_<basename>_on` and
`mcl_pressureplates:pressure_plate_<basename>_off`.

The pressureplate definition should have the following fields:

```lua
{
    description = "",       -- Description of pressure plate
    texture = "",           -- Texture of the pressure plate
    recipeitem = "",        -- Item used to craft the pressure plate
    sounds = {},            -- Sounds
    groups = {},            -- Group memberships
    longdesc = "",          -- Long description for documentation

    weighted = nil,
    -- Nil for unweighted pressure plates. For weighted pressure plates, how
    -- many entities need to be on it for one level of power output.

    activated_by = "",
    -- Table specifying which entities will trigger the pressure plate.
    --
    -- Possible fields:
    -- * player=true: Player
    -- * mob=true: Mob
    --
    -- By default it is triggered by all entities.
}
```
