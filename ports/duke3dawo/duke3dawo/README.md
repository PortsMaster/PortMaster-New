# Duke Nukem 3D: 20th Anniversary World Tour - Stopgap Compatibility Layer for EDuke32
This package provides support for playing Duke Nukem 3D: 20th Anniversary World Tour with the conveniences of the EDuke32 source port.

## Instructions
Download the latest build of EDuke32 and extract it to your World Tour folder, usually `C:\Program Files (x86)\Steam\SteamApps\common\Duke Nukem 3D Twentieth Anniversary World Tour`, or wherever you have installed the game.
Download and extract the Stopgap as well, or place a release .zip file into EDuke32's autoload folder and enable the autoload feature.

For the time being, normal maps only work with `r_pr_artmapping 0`, for the same reason texture filtering is incompatible with the artmapping feature.

### Console Variable Customization Options
- New Duke voice acting. Use `setvar voice <value>` in the console to configure. 0 - 2016 voice, 1 - 1996 voice except during Episode 5, 2 - 1996 voice except new lines only
- Developer commentary. Use `setvar commentary <value>` in the console to configure. 0 - off, 1 - on, 2 - show but don't allow playback

## Links
- [Duke Nukem 3D: 20th Anniversary World Tour](http://store.steampowered.com/app/434050/)
- [EDuke32 Nightly Builds](http://dukeworld.duke4.net/eduke32/synthesis/)
- [Stopgap Forum Thread](https://forums.duke4.net/topic/8966-/)

## To-Do List
- Invert green channel of normal maps via def token
- Classic mini-HUD armor box
- Status bar number positioning adjustments
- RTS new voice support
- Episode 5 credits

## Credits

### Organizer
- Hendricks266

### Additional Thanks
- Nuke.YKT
- NightFright
- mwnn
- asdf33
- LeoD
