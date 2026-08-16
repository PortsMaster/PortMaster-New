## Notes

Thanks to [M374LX](https://github.com/M374LX/alexvsbus) for making Alex vs Bus: The Race, a finished 13-level platform runner with a distinct cutscene for every level cleared.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move |
| A/B/X | Jump |
| Start | Pause / Confirm |

## Compile

git clone https://github.com/M374LX/alexvsbus.git
cd alexvsbus

This device has no desktop OpenGL, only OpenGL ES2, so the upstream
Makefile's hardcoded `-DGRAPHICS_API_OPENGL_21` needs to become
`-DGRAPHICS_API_OPENGL_ES2` before building:

sed -i 's/-DGRAPHICS_API_OPENGL_21/-DGRAPHICS_API_OPENGL_ES2/' Makefile
make RAYLIB_BACKEND=SDL2
