# The Dishwasher: Vampire Smile

A fast-paced, combo-driven 2D action platformer by Ska Studios with a gritty graphic-novel art style. Play as Yuki or The Dishwasher and slash your way through the campaign, the arcade levels and the Dish Challenge.

## Requirements

You need your own copy of the game. No original game files are included.

- Steam Windows depot for The Dishwasher: Vampire Smile (App 268990, Depot 268991)
- Download via the Steam console: `download_depot 268990 268991`

## Installation

1. Copy the contents of your Steam Windows depot into `ports/thedishwashervampiresmile/gamedata/`.
2. Launch the game from the Ports menu.
3. The first start runs a one-time setup (texture conversion and patching). It takes about 20 minutes. Do not turn the device off.
4. During the setup you are asked once which button layout you want: Nintendo-style button colors (for example the R36S) or the standard Xbox layout.

## Controls

| Button | Action |
|--|--|
| A | Jump / Accept |
| B | Grab / Cancel |
| X | Attack |
| Y | Strong attack / Saw |
| R1 | Switch weapons |
| L1 | Switch loadouts |
| R2 | Gun |
| L2 | Magic |
| Select | Inventory |
| Start | Pause / Confirm |

## Notes

- Includes a recolored button-icon texture, only used if you choose the "Nintendo layout".
- Multiplayer/co-op, achievements and leaderboards are not available in this port. The menu entries are greyed out or show an offline message.
- Menus, HUD and screens are scaled to the screen resolution.

## Language

The game language is chosen during the first setup.

To change it later, edit the file `lang.txt` in the port folder
(`ports/thedishwashervampiresmile/lang.txt`) and replace its content with one of the
following codes. The file must contain only this one line.

| Language   | Code          |
|------------|---------------|
| English    | `en_US.UTF-8` (or delete `lang.txt`) |
| Deutsch    | `de_DE.UTF-8` |
| Français   | `fr_FR.UTF-8` |
| Italiano   | `it_IT.UTF-8` |
| Español    | `es_ES.UTF-8` |
| Português  | `pt_PT.UTF-8` |
| 日本語      | `ja_JP.UTF-8` |

If `lang.txt` does not exist, create it with exactly that name. The change takes
effect at the next start of the game, no new setup is required.

## Thanks

- Ska Studios (James Silva) for the game
- Ethan Lee for the Steam port and for FNA
- The MonoMod project
- The whole PortMaster crew, who make all this possible
