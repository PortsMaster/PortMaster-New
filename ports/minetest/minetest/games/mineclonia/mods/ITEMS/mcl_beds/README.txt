Minetest Game mod: beds
=======================
See license.txt for license information.

Authors of source code
----------------------
Originally by BlockMen (MIT)
Various Minetest developers and contributors (MIT)

Authors of media (textures)
---------------------------
BlockMen (CC BY-SA 3.0)

This mod adds a bed to Minetest which allows to skip the night.
To sleep, rightclick the bed.
Another feature is a controlled respawning. If you have slept in bed your respawn point is set to the beds location and you will respawn there after
death.

Use the mcl_playersSleepingPercentage setting to enable/disable night skipping or set a percentage of how many players need to sleep to skip the night.

mcl_beds.is_night([ time of day ]) - returns wether it's night with optional argument of a minetest time of day value between 0 and 1
