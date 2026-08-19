## Notes

Thanks to [Martin Bickel and the ASC-HQ team](http://www.asc-hq.org) for ASC, a deep free hex wargame in the Battle Isle tradition that's still going strong after decades.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move mouse cursor |
| Right Analog | Move map cursor (arrow keys) |
| A | Select / mark field (mouse left) |
| B | Drag & drop - move/reposition unit (mouse right) |
| X | Slow mouse (precision cursor) |
| Y | Move unit / confirm action |
| L1 | Attack |
| L2 | Repair unit |
| R1 | End turn |
| R2 | Refuel unit |
| Select + L1 | Place/remove mines |
| Select + L2 | Toggle reaction fire |
| Select + R1 | Zoom in |
| Select + R2 | Zoom out |
| Start | Confirm dialog (Enter) |
| Select | Menu / cancel (Esc) |

## Compile

### 1. Build libsigc++ 1.2

The code uses the real `SigC::` 1.2 API directly (not the incompatible `sigc::` 2.0 namespace),
and modern distros only ship 2.0:

```
curl -LO https://download.gnome.org/sources/libsigc++/1.2/libsigc++-1.2.7.tar.gz
tar xzf libsigc++-1.2.7.tar.gz
cd libsigc++-1.2.7
```

The tarball's bundled `config.guess`/`config.sub` predate aarch64 and won't recognize the build
host, so `./configure` fails with "unable to guess system type" unless they're replaced first:

```
curl -o scripts/config.guess https://git.savannah.gnu.org/cgit/config.git/plain/config.guess
curl -o scripts/config.sub https://git.savannah.gnu.org/cgit/config.git/plain/config.sub
./configure --prefix=/usr/local
make
make install
ldconfig
```

### 2. Build ASC

```
git clone https://github.com/Cebion/asc_2.6.git
cd asc_2.6
CPPFLAGS="-I/usr/include/freetype2" CXXFLAGS="-std=gnu++98" ./configure
make
```

### 3. Build sdl1.2-compat with software cursor 

```
git clone https://github.com/Cebion/sdl12-compat.git
cd sdl12-compat
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release .
cmake --build build
```
