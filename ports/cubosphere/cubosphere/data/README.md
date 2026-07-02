# Cubosphere [reborn] — data repository
This repo contain data files for cubosphere. Pretty useless without code.

## How does the build system work?
This `CMakeLists.txt` is incuded from the code repo one.  Formerly the data was split into different folders based on how it was installed, but now they are all organized in the same structure as the installed data.  This is done for easier development.

## Other folders
* `desktop` — Linux-specific files for the Applications menu (has its own `CMakeLists.txt`)
* `origins` — Some images which are used as the source for different files (`.xcf` is the recommended format for images).
