## Notes

Thanks to [Bartosz Bojarowski](https://store.steampowered.com/search/?developer=Bartosz%20Bojarowski) for creating Lost Flame, a traditional roguelike whose turn-based melee is won or lost on positioning.

- Requires the game from [Steam](https://store.steampowered.com/app/856570/Lost_Flame/). Copy `LostFlame.jar` from the game folder (any OS build) into `ports/lostflame`.
- The first launch patches your copy of the jar, once, in under a minute. If it fails, `patchlog.txt` in `ports/lostflame` names the class that did not match; the port is made for game version 1.0.0.7c.

---

This port uses the Westonpack runtime and libcrusty to provide X11 and OpenGL 2
compatibility on devices that do not support them natively.

---

## Controls

| Key | Action |
|--|--|
| D-Pad / Left stick | Move (D-Pad diagonals: press two directions) |
| A | Main action, action menu |
| B | Wait, cancel |
| X | Action menu bindings |
| Y | Auto-explore |
| L1 / R1 | Previous / next skill |
| L2 | Hold: diagonal movement. Use quick slot 7 (in the inventory: bind the selected item to it) |
| R2 | Confirm move. Use quick slot 8 (in the inventory: bind the selected item to it) |
| R3 | Hold: Ctrl modifier |
| Start | Settings |
| Select + A / B / X / Y | Inventory / map / advanced skills / character overview |
| Select + D-Pad left / up / right / down | Tumble / look / parry / kick |
| Select + L1 | Swap primary and secondary weapon |
| Select + R1 | Swap weapon hands |
| Select + Start | Exit |

All bindings are remappable in-game under Controls.
