## Notes
Thanks to the [Pierre Sarrazin](http://perso.b2b2c.ca/~sarrazip/dev/afternoonstalker.html) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|A| Shoot|
|B| Start Game|

## Compile

```shell
wget http://perso.b2b2c.ca/~sarrazip/dev/flatzebra-0.2.0.tar.gz
cd flatzebra-0.2.0/

// Replace Joystick Initation

Joystick::Joystick()
:   joystick(NULL),
    previousButtonStates(),
    currentButtonStates(),
    xAxis(),
    yAxis()
{
    xAxis[0] = xAxis[1] = 0;
    yAxis[0] = yAxis[1] = 0;
    // Joystick initialization is disabled
}

// In GameEngine.cpp, replace the existing fontFilePath initialization with:

string fontFilePath;
const char* customPath = getenv("AFTERNOON_STALKER_DATA");
if (customPath != nullptr) {
    fontFilePath = string(customPath) + "/font_13x7.xpm";
} else {
    fontFilePath = getDirPathFromEnv(PKGPIXMAPDIR, "PKGPIXMAPDIR") + "font_13x7.xpm";
}
fixedWidthFontPixmap = createTextureFromFile(fontFilePath);  // may throw

./configure
make

wget http://perso.b2b2c.ca/~sarrazip/dev/afternoonstalker-1.2.0.tar.gz
cd afternoonstalker-1.2.0
./configure
# adjust prefix_path inside Makefile
make
```