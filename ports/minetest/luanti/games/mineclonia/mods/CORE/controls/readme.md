
controls library for minetest

![](https://github.com/mt-mods/controls/workflows/luacheck/badge.svg)
[![ContentDB](https://content.minetest.net/packages/BuckarooBanzay/controls/shields/downloads/)](https://content.minetest.net/packages/BuckarooBanzay/controls/)

# Overview

Utility library for control press/hold/release events

# API

## Supported controls

* jump
* right
* left
* LMB
* RMB
* sneak
* aux1
* down
* up
* zoom
* dig
* place

## callbacks

```lua
controls.register_on_press(function(player, control_name)
	-- called on initial key-press
	-- control_name: see above
end)

controls.register_on_release(function(player, control_name, time)
	-- called on key-release
	-- control_name: see above
	-- time: seconds the key was pressed
end)

controls.register_on_hold(function(player, control_name, time)
	-- called every globalstep if the key is pressed
	-- control_name: see above
	-- time: seconds the key was pressed
end)
```


# References

used by https://github.com/Arcelmi/minetest-bows.git
Original repo: https://github.com/Arcelmi/minetest-controls

# License

LGPL 2.1 (see `LICENSE` file)
