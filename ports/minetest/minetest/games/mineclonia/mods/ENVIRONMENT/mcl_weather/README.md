`mcl_weather`
=======================
Weather mod for MineClone 2. Forked from the `weather_pack` mod by xeranas.

Weathers included
-----------------------
* rain
* snow
* thunder

Commands
-----------------------
`weather <weather>`, requires `weather_manager` privilege.

Dependencies
-----------------------
Thunder weather requres [lightning](https://github.com/minetest-mods/lightning) mod.

Configuration prope,  ties
-----------------------
Weather mod for indoor check depends on sunlight propogation check. Some nodes (e.g. glass block) propogates sunlight and thus weather particles will go through it. To change that set `weather_allow_override_nodes=true` in `minetest.conf` file. Be aware that just few nodes will be override and these blocks needs to be re-builded to take effect. Maybe in future other 'cheap' way to check indoor will be available.

Weather mod mostly relies on particles generation however for some small things ABM may be used. Users which do not want it can disable ABM with property `weather_allow_abm=false`.

License of source code:
-----------------------
LGPL 2.1+

Authors of media files:
-----------------------

TeddyDesTodes:
Snowflakes licensed under CC-BY-SA 3.0 by from weather branch at https://github.com/TeddyDesTodes/minetest/tree/weather

  * `weather_pack_snow_snowflake1.png` - CC-BY-SA 3.0
  * `weather_pack_snow_snowflake2.png` - CC-BY-SA 3.0

xeranas:

  * `weather_pack_rain_raindrop_1.png` - CC-0
  * `weather_pack_rain_raindrop_2.png` - CC-0
  * `weather_pack_rain_raindrop_3.png` - CC-0

inchadney (http://freesound.org/people/inchadney/):

  * `weather_rain.ogg` - CC-BY-SA 3.0 (cut from http://freesound.org/people/inchadney/sounds/58835/)

