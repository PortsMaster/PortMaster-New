# Hunger for MineClone 2 [`mcl_hunger`]

* Forked from `hbhunger`, version: 0.5.2

## Using the mod

This mod adds a mechanic for hunger.
This mod depends on the HUD bars mod [`hudbars`], version 1.4.1 or any later version
starting with “1.”.

## About hunger
This mod adds a hunger mechanic to the game. Players get a new attribute called “satiation”:

* A new player starts with 20 satiation points out of 20
* Actions like digging, placing and walking cause exhaustion, which lower the satiation
* Every 800 seconds you lose 1 satiation point without doing anything
* At 1 or 0 satiation you will suffer damage and die in case you don't eat something
* If your satiation is 16 or higher, you will slowly regenerate health points
* Eating food will increase your satiation (Duh!)

## Statbar mode
If you use the statbar mode of the HUD Bars mod, these things are important to know:
As with all mods using HUD Bars, the bread statbar symbols represent the rough percentage
out of 30 satiation points, in steps of 5%, so the symbols give you an estimate of your
satiation. This is different from the hunger mod by BlockMen.

You gain health at 5.5 symbols or more, as 5.5 symbols correspond to 16 satiation points.
You *may* lose health at exactly 0.5 symbols, as 0.5 symbols correspond to 1-2 satiation points.

### Examples

* Eating an apple (from Minetest Game) increases your satiation by 2;
* eating a bread (from Minetest Game) increases your satiation by 4.

## Licensing
This mod is free software.

### Source code

* License: [LGPL v2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)
* Author: by Wuzzy (2015-2016)
* Forked from `hbhunger` for MineClone 2. `hbhunger` in turn was forked from the “Better HUD
  (and hunger)” mod by BlockMen (2013-2015), most code comes from this mod.

### Textures and sounds

* `hbhunger_icon.png`—PilzAdam ([WTFPL](http://www.wtfpl.net/txt/copying/)), modified by BlockMen
* `hbhunger_bgicon.png`—PilzAdam (WTFPL), modified by BlockMen
* `hbhunger_bar.png—Wuzzy` (WTFPL)
* `hbhunger_icon_health_poison.png`—celeron55 ([CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)), modified by BlockMen, modified again by Wuzzy
* `mcl_hunger_bite.1.ogg`, `mcl_hungr_bite.2.ogg`: WTFPL
* `survival_thirst_drink.ogg`: WTFPL
* Everything else: WTFPL, by BlockMen and Wuzzy

