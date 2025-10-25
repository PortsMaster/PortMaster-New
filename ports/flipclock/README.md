FlipClock
=========

A flip clock screensaver supported by SDL2.
-------------------------------------------

[Project Website](https://flipclock.alynx.one)


## Build From Source

1. Install a C compiler, Meson, Ninja, libc, libm, SDL2 and SDL2_ttf.
2. `mkdir build && cd build && meson setup . .. && meson compile`
3. `./flipclock -f ../dists/flipclock.ttf`
4. If you want to install this to your system, you could use `mkdir build && cd build && meson setup --prefix=/usr --buildtype=release . .. && meson compile && sudo meson install`.

# Configuration

On Linux, program will first use `$XDG_CONFIG_HOME/flipclock.conf`, if `XDG_CONFIG_HOME` is not set or file does not exist, it will use `$HOME/.config/flipclock.conf`. If per-user configuration file does not exist, it will use `/etc/flipclock.conf` or `flipclock.conf` under `sysconfdir` you choosed while building.

