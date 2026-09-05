## Notes

Thanks to [Sixth Floor Labs](http://www.sixthfloorlabs.com/projects/alexandria/) for releasing Project Alexandria under the GPL, an Asteroids-style shooter with genuinely satisfying ODE-driven physics behind its ship movement and combat.

## Controls

| Button | Action |
|--|--|
| D-Pad/Left Stick Up | Thrust |
| D-Pad/Left Stick Down | Retro rockets |
| D-Pad/Left Stick Left/Right | Rotate |
| A | Shoot |
| B | Fire/release Hook |
| X | Beam weapon (hold) |
| Y | Switch gears |
| L1 | Pause |
| R1 | Reel out |
| L2 | Reel in |
| Start | Confirm/advance dialogue |
| Back | Menu |

## Compile

Alexandria is a Python 2 game built on pygame, ODE physics (via pyode), and the old
Numeric array library. None of the three have Python 2 builds in a modern distro, so
they're built from source against the system's real Python 2.7 and SDL 1.2 dev packages.

Dev packages (Ubuntu 22.04):

```
apt-get install -y python2.7-dev libpython2.7-dev python-setuptools \
  libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev \
  libpng-dev libfreetype6-dev libportmidi-dev
```

### 1. ODE 0.7

Its bundled `config.guess`/`config.sub` predate the `aarch64` triplet, so they need
swapping for current ones before configuring.

```
cd ode-0.7
cp /usr/share/automake-1.16/config.guess /usr/share/automake-1.16/config.sub .
chmod +x config.guess config.sub
CFLAGS="-O2 -fPIC" CXXFLAGS="-O2 -fPIC" ./configure --prefix=/opt/ode-0.7
make -j$(nproc)
make install
```

### 2. PyODE 1.2.0

```
cd PyODE-1.2.0
python2 setup.py build_ext \
  --include-dirs=/opt/ode-0.7/include \
  --library-dirs=/opt/ode-0.7/lib
```

### 3. Numeric 24.2

`Packages/RNG/Src/ranf.c` carries a stale local prototype for `gettimeofday()` that
conflicts with the one in modern glibc headers; remove it before building.

```
cd Numeric-24.2
sed -i '/int gettimeofday(struct timeval \*, struct timezone \*);/d;/#if !defined(__sgi)/d;/^#endif$/{0,/gettimeofday/{/^#endif$/d}}' Packages/RNG/Src/ranf.c
python2 setup.py build
```

(Equivalently: open `Packages/RNG/Src/ranf.c` and delete the `#if !defined(__sgi)` /
`int gettimeofday(...)` / `#endif` block around line 152 by hand - it's three lines.)

### 4. pygame 1.9.6

```
cd pygame-1.9.6
python2 setup.py -auto build
```
