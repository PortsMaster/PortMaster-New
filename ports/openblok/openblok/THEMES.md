THEMES
======

You can customize OpenBlok by creating themes: instead of editing the data files directly, you can load your assets from a custom directory, or configure certain graphical options without the need of changing the source code.

To create a new theme, you have to create a new folder in the `themes` directory, create a `theme.cfg` file, then add your replacement files.


## The theme directory

Themes can be located in the following directories:

- `[CONFIGDIR]/themes`, where `[CONFIGDIR]` is
	- `~/.local/share/openblok` on Linux, and
	- `C:\Users\[USERNAME]\AppData\Roaming\openblok` on Windows.
- `[INSTALLDIR]/data/themes`, where `[INSTALLDIR]` is usually
	- `/usr/share/openblok` on Linux
	- `C\Program Files\openblok` on Windows
	- or where you've extracted the game


## The theme configuration

All theme needs a `theme.cfg` file, where you can list some basic information (title of the theme, the author's name, etc.), or change certain graphical settings (color scheme, visibility of UI elements, etc.).

Here is a full `theme.cfg` file with the default values as an example. Feel free to change or remove the existing parameters. All settings are optional: you don't have to list every existing option in the config file, missing parameters will use their the default values.

```python
# Lines starting with '#' are comments
# This is the 'metadata' block, where you
# can store info about the theme
[meta]
# Text values are between quote marks
author = "John Smith <jsmith@example.com>"
description = "Some fancy theme"
version = "v1.2"

# This block defines the color scheme used in the game
# Accepted values are RGB or RGBA color in hex format
[colors]
# The color of the labels ('Next', 'Hold', ...) and counters
label_normal = #EEEEEE
# Color used for highlighting some texts,
# eg. when the number of remaining lines is almost zero
label_highlight = #FFA500
# Color of the normal text of the pause menu and statistics screen
pause_normal = #EEEEEE
# Color of the highlighted or selected element
pause_highlight = #FFA500
# Text color of the unselected buttons
mainmenu_normal = #006080
# Text color of the selected button and the description text
mainmenu_highlight = #EEEEEE
# Background color of the selected button and the description panel
mainmenu_panel = #2030FF
# Color of the countdown text
countdown = #EEEEEE
# Color of the game over / finished text
game_end = #EEEEEE
# Color of the bonus messages (eg. 'Level up!')
popup = #EEEEEE
# The color of the line clear animation
line_clear = #EEEEEE

# Gameplay-related graphical settings
# For logical values, you can use yes/no/true/false/on/off
[gameplay]
# Draw the labels like 'Next', 'Level', etc.?
draw_labels = yes
# If this is off, all minos will have the same texture,
# but tinted with a different color
# If this is on, you'll need to have a texture file for all
# the different minos: mino_{l,r,s,z,t,i,o,garbage}.png
custom_minos = no
# Tint the ghost texture with the piece color?
tint_ghost = yes
```


## The theme files

After creating the configuration file. you can your replacement files into the theme directory. The directory structure and the file names should match the original (default) theme.

```
yourtheme/
├── theme.cfg
├── graphics/
│   └── # basic graphical assets
├── music/
│   │   # songs will be selected randomly
│   │   # supported formats: OGG, FLAC, MP3
│   ├── menu/ # musics of the main menu
│   └── gameplay/ # musics of the gameplay
├── sfx/
│   └── # sound effects
│       # supported formats: WAV, OGG
└── backgrounds/
    │   # backgrounds will be selected randomly
    │   # supported formats: PNG, JPG
    └── gameplay/
```

If a file is not found, the one from the default theme will be used.
