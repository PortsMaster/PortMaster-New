## Notes
Thanks to [The Angband Team] (https://github.com/angband/angband) for creating this gem of a roguelike and making it available for free! 
 
## Controls

| Button | Action |
|--|--| 
select = l (Look around)
start = M (Map)
a = enter (Invoke game menu, select menu item)
b = esc (Cancel)
y = . (Run)
x = + (Alter: auto select any of the commands attack, tunnel, bash, open, disarm)
a+select = y (yes in dialogs for confirmation)
b+select = n (no in dialogs for confirmation)
y+select = i (Inventory list)
x+select = e (Equipment list )
l2 = z (Zap a wand)
l2+select = u (Use a staff)
l1 = c (Character stats)
l1+select = @ (Confirm character kill)
r1 = | (Quiver list)
r2 = h (Fire default ammo at nearest)
r2+select = v (Throw an item)
r1+select = f (Fire an item)
up = 8 (Move up, number 8 for shop)
down = 2 (Move down, number 2 for shop)
left = 4( Move left, number 4 for shop)
right = 6 (Move right, number 6 for shop)
left_analog_up = 7 (Move diagonally, number 7 for shop)
left_analog_right = 9 (Move diagonally, number 9 for shop)
left_analog_down = 3 (Move diagonally, number 3 for shop)
left_analog_left = 1 (Move diagonally, number 1 for shop)
l3 = 5 (Stay still, number 5 for shop)
right_analog_up = g (Pickup an item)
right_analog_right = < (Move upstairs)
right_analog_down = d (Drop item, use in dialogs)
right_analog_left = > (Move downstairs)
r3 = r (Read)

## Compile

```shell
https://github.com/angband/angband.git
cd angband
mkdir build && cd build
cmake .. # choose SDL2 build
make
```