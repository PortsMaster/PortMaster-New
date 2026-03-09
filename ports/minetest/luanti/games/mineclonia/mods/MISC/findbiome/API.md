# Find Biome API

This mod has two public functions:

## `findbiome.find_biome(pos, biomes, res, checks)`

Attempts to find a position of any biome listed in `biomes`, starting the search from `pos`.
The algorithm will start check positions around `pos`, starting at `pos` and extend its
search outwards. As soon as any of the listed biomes is found, the algorithm terminates
and the biome position is returned.

### Parameters

* `pos`: Position at where to start the search
* `biomes`: List of the technical names of the biomes to search for
* `res`: (optional): Size of search grid resolution (smaller = more precise, but also smaller area) (default: 64)
* `checks`: (optional): Number of points checked in total (default: 16384)

### Return value

Returns `<biome position>, <success>`.

* `<biome position>` is the position of a found biome or `nil` if none was found
* `<success>` is `true` on success and `false` on failure.

### Additional notes

* This function checks nodes on a square spiral going outwards from `pos`
* Although unlikely, there is *no 100% guarantee* that the biome will always be found if
  it exists in the world. Very small and/or rare biomes tend to get “overlooked”.
* The search might include different Y levels than provided in `pos.y` in order
  to find biomes that are restricted by Y coordinates
* If the mapgen `v6` is used, this function only works if the mod `biomeinfo` is
  active, too. See the `biomeinfo` mod for more information
* Be careful not to check too many points, as this can lead to potentially longer
  searches which may freeze the server for a while

## `findbiome.list_biomes()`

Lists all registered biomes in the world.

### Parameters

None.

### Return value

Returns `<success>, <biomes>`.

* `<success>` is `true` on success and `false` on failure.
* `<biomes>` is a table.
  * If there are no errors, it will be a list of all registered biomes, in alphabetical order.
  * If there is an error, it will be a table with the first element being an error message.
  * Possible errors:
    * `v6` mapgen is used and `biomeinfo` mod is not enabled.
    * Not all mods have loaded into the world yet.

### Additional notes

* If no biomes have been registered, `<biomes>` will be an empty table, but it still counts as success if there was no error.
* If the mapgen `v6` is used, this function only works if the mod `biomeinfo` is
  active, too. See the `biomeinfo` mod for more information.
* The error messages are always sent in English so the API user can check for them. It is possible to then use a translator on the returned value before showing it to the player, if that is what is wanted. See how errors are handled by the chat command.
* It is better to just check the success value, unless the error message may interfere with other functions.
