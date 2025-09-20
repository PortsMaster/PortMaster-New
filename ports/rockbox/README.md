## Notes
---
#### Setting Database Scan Directory

Would ***highly*** suggest setting database scan directory before scanning/building the database. Have `Database` highlighted, press `START` button to pull up the database menu and scroll down and select the `Select directories to scan` option.

Press `A` to enter highlighted directories. Once you have you your main music folder highlighted, press `A` again until the folder icon turns into a "play" symbol. Press `B` to exit and press `A` to save changes, then `A` again to initialize database.

When it finishes, restart Rockbox.

#### Extending/Disabling Backlight Timeout

By default, Rockbox has a 15 second display timeout. If you would like to extend (or disable) this feature... go to `Settings > General Settings > Display > LCD Settings > Backlight`.

#### Enable Lock-key Exemptions

If you would like to use media keys to control Rockbox while locked (bluetooth/usb), go to `Settings > General Settings > System > Advanced Key Lock`. Set `Enabled` to `Yes` and then under `Settings` toggle `Exempt Play`, `Exempt Seek` and `Exempt Skip` on.

#### Installing Themes:

`Note: Themes created pre-4.0 may not display correctly even if listed as working with 4.0/dev build.`

Download any themes from the `Ipod Classic` section [here](https://themes.rockbox.org/index.php?target=ipod6g) and extract. Copy the contents inside the `.rockbox` folder into the `rockbox` directory. 

Make sure to restart Rockbox to fix theme paths before applying a theme.

## Controls
---
Controls more or less follow the RG Nano port of Rockbox, see [the manual from the dev builds](https://download.rockbox.org/manual/rockbox-rgnano.pdf) for more info as well as plugin controls.

#### In Menu:

|   Button   |       Action      |
|:----------:|:-----------------:|
|   DPAD UP  |      Move UP      |
|  DPAD DOWN |     Move DOWN     |
|  DPAD LEFT |      Page UP      |
| DPAD Right |     Page DOWN     |
|   Press A  |    Enter/Accept   |
|   Press B  |        Back       |
|   Press X  |        WPS        |
|   Press Y  |     Main Menu     |
|    START   |    Context Menu   |
|   Hold L1  |   Stop Playback   |
|     L1     |  Hotkey Function  |
|     R1     | Quick Screen Menu |
|    L2+R2   |    Lock / Hold    |
|  START+R2  |  Shutdown (Exit)  |

<br>

#### In WPS (What's Playing Screen):

`Note: Volume controls are separate from system volume.`

|      Button     |                        Action                       |
|:---------------:|:---------------------------------------------------:|
|     DPAD UP     |                      Volume UP                      |
|    DPAD DOWN    |                     Volume Down                     |
|    DPAD LEFT    |             Restart Song / Previous Song            |
|  Hold DPAD LEFT |                        Rewind                       |
|    DPAD RIGHT   |                      Next Song                      |
| Hold DPAD RIGHT |                     Fast-Forward                    |
|     Press A     |                     Play / Pause                    |
|      Hold A     |                 Pause and Main Menu                 |
|     Press B     |                      Main Menu                      |
|     Press X     |                      Track Info                     |
|     Press Y     | Return to `FILE BROWSER` / `DATABASE` / `PLAYLISTS` |
|      START      |                     Context Menu                    |
|        L1       |      WPS Hotkey Function<br>(Default: Playlist)     |
|        R1       |                  Quick Screen Menu                  |
|     Hold R1     |                     Pitch Screen                    |
|      L2+R2      |                     Lock / Hold                     |

<br>

## Useful Links:
---
[Themes (Ipod Classic).](https://themes.rockbox.org/index.php?target=ipod6g)  
[Source for PortMaster build.](https://github.com/IncognitoMan/rockbox)

## Thanks
---
[Rockbox Team](https://www.rockbox.org/) - For creating Rockbox.  
[Hairo](https://github.com/Hairo) - For helping with this port (battery status, plugins and path shenanigans).  
[Dia](https://github.com/Dia2809) - libsdl2_scaler shim that was the last piece of the puzzle for Portmaster.