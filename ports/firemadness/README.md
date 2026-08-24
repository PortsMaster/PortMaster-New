## Notes

Thanks to [Eugene Loza](https://gitlab.com/EugeneLoza/FireMadness) for making this fast, addictive CrossFire-inspired bullet hell shooter, where every enemy bot you destroy grows back tougher.

## Controls

| Button | Action |
|--|--|
| Left stick / D-pad | Move |
| Right stick / Face buttons (diamond) | Fire (direction matches the button's position) |

## Compile

Requires Free Pascal Compiler, Lazarus, and [Castle Game Engine](https://github.com/castle-engine/castle-engine) (built from source, its own build tool needs bootstrapping first).

```
apt-get install fpc lazarus libgles2-mesa-dev libxmu-dev
git clone https://github.com/castle-engine/castle-engine.git
cd castle-engine
export CASTLE_ENGINE_PATH="$(pwd)"
./tools/build-tool/castle-engine_compile.sh
```

Then, from the FireMadness source directory, with `CastleEngineManifest.xml` requesting the
Xlib+EGL window backend (`CASTLE_WINDOW_XLIB` and `OpenGLES` defines) instead of the default
GTK3 backend:

```
git clone https://gitlab.com/EugeneLoza/FireMadness.git
cd FireMadness
"$CASTLE_ENGINE_PATH/tools/build-tool/castle-engine" package --os=linux --cpu=aarch64
```
