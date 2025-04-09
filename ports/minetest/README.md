This port contains [Minetest](https://www.minetest.net/) and a Minecraft-like game [Mineclonia](https://codeberg.org/mineclonia/mineclonia). More games, mods, and texture packs can be downloaded within the Minetest client.

Thanks to the Perttu Ahola and the Minetest team for creating this awesome game and making it available for free! If you enjoy Minetest please consider [modding](https://rubenwardy.com/minetest_modding_book/en/index.html), [contributing](https://www.minetest.net/get-involved/), or [donating](https://www.minetest.net/get-involved/#donate)!

# Notes
- **Touch screen**
  - Touch screen controls work on supported devices
- **Menus**
  - For some devices menus extend off-screen. All menu items can be adjusted manually though with the config file: `/path/to/your/ports/minetest/minetest.conf`.
    - Settings options are [described here](http://doxy.minetest.net/settings.html)
  - Invisible cursor in menus
- **Low-memory devices**
  - Single-player play requires >1 GB in order to run both the host and client instances. For this reason 1 GB devices should stick to server play because RAM requirements are only ~700 MB. There are public servers available or you can host your own private server!

# Controls
Defaults are below
- Controls can be customized via the keyboard map files at `/path/to/your/ports/minetest/minetest_<num>stick.gptk`
- Useful reference: [Minetest's default keyboard layout](https://wiki.minetest.net/Controls)

## 2-Stick Controls
|Button|Action|
|--|--|
|`Select`|Escape|
|`Start`|Enter|
|`A`|Toggle fly mode|
|`B`|Jump|
|`X`|Toggle minimap|
|`Y`|Drop item|
|`L1`|Sneak|
|`L2`|Toggle fast mode|
|`L3`|Toggle hud|
|`R1`|Punch / mine|
|`R2`|Use / build|
|`Select`+`L1`|Toggle noclip mode|
|`R3`|Debug display (and coordinates)|
|`D-pad up`|Select camera|
|`D-pad down`|Show/hide inventory|
|`D-pad left`|Previous item in hotbar|
|`D-pad right`|Next item in hotbar|
|Left analog stick|Movement|
|Right analog stick|Look|

## 1-Stick Controls
***Note:** At this time mouse emulation is restricted to the `D-pad`, and cannot be moved to `A`/`B`/`X`/`Y` (which might be more natural)*

|Button|Action|
|--|--|
|`Select`|Escape|
|`Start`|Enter|
|`X`|Move forward|
|`B`|Move backward|
|`Y`|Strafe left|
|`A`|Strafe right|
|`L1`|Jump|
|`Select`+`L1`|Drop item|
|`L2`|Sneak|
|`Select`+`L2`|Debug display (and coordinates)|
|`L3`|Toggle hud|
|`R1`|Punch / mine|
|`R2`|Use / build|
|`D-pad up`  |Toggle minimap|
|`D-pad down`|Toggl inventory|
|`D-pad left`|Previous item in hotbar|
|`D-pad right`|Next item in hotbar|
|Left analog stick|Look|

## 0-Stick Controls
***Note:** At this time mouse emulation is restricted to the `D-pad`, and cannot be moved to `A`/`B`/`X`/`Y` (which might be more natural)*

|Button|Action|
|--|--|
|`Select`|Escape|
|`Start`|Enter|
|`X`|move forward|
|`B`|move backward|
|`Y`|strafe left|
|`A`|strafe right|
|`L1`|Use / build|
|`R1`|Punch / mine
|`L2`|Previous item in hotbar|
|`R2`|Next item in hotbar|
|`Select`+`L1`|Toggle inventory|
|`Select`+`L2`|Drop item|
|`Select`+`R1`|Punch / mine
|`Select`+`R2`|Jump|
|`D-pad`  |Look|

# Licenses
- Minetest: [MIT](https://github.com/minetest/minetest.github.io?tab=MIT-1-ov-file#readme)
- Mineclonia: [GPLv3](https://codeberg.org/mineclonia/mineclonia/src/branch/main/LICENSE.txt)
