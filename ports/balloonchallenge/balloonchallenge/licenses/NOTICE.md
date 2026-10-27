# Notice: what is whose

This is an unofficial port of **Balloon Challenge v2.0**. It is not affiliated with, endorsed by or
supported by Soleau Software or William Soleau.

## The game

*Balloon Challenge* © 1993-1995 William Soleau / Soleau Software. All rights in the game, its program,
graphics, fonts, text and documentation remain with their owner.

- **Shareware files.** The shareware release (`BALLOONC.EXE`, `BALLOONC.OV0`-`OV3`, `BALLOON1.JFT`-`BALLOON3.JFT`,
  `BALLOONC.DOC`, `BALC_REG.DOC`, `SOLSOFT.DOC`, `FILE_ID.DIZ`, `AVEXTRA.TXT`) may be passed along unmodified
  together with builds of this port, under the terms the game states itself: "This is a Shareware copy of Balloon Challenge. You are
  free to pass this game along to your friends or local BBS." The files are not covered by this project's
  license.
- **The program binary.** The port's executable contains a translation of the shareware `BALLOONC.EXE` into
  native code, generated at build time by this project's tools (static recompilation). That translated part
  is derived from the original program and is not licensed by this project.
- **Registered version.** Files of the registered version are never included. A player who owns them can add
  them; the port then runs in registered mode.
- **Not in this repository.** No game files, no recompiled output, no generated code derived from the program,
  and no notes that quote the game's text or code (see `.gitignore`).

## This project

The port's own code, tools and documentation: © the Balloon Challenge port contributors, licensed under the
GNU General Public License, version 2 or (at your option) any later version. See `LICENSE`.

The runtime reproduces the behaviour of the DOSBox-X emulator (GPL-2.0-or-later) where the original program
depends on it, and the build embeds BIOS/DOS stub code captured from a DOSBox-X reference machine; the GPL
license of the port keeps both compatible. The DOSBox-X instrumentation used for verification
(`tools/dosbox/dosbox-x-rea-instrumentation.patch`) is a modification of DOSBox-X and is
distributed under its license.

`reference/mem_entry.bin` is the memory of a DOSBox-X machine (BIOS, DOS, the DOSBox-X shell) at the moment
the game's program starts, with the program area blanked (no bytes of the game); the build rebuilds that
area from the shareware `BALLOONC.EXE` by running the EXE's own unpacking code. `reference/VGA.TXT` and
`reference/BREAK.TXT` are timing measurements of that machine.

The corresponding source of a binary build is this repository at the matching revision; the input it is
generated from is the shareware `BALLOONC.EXE`.

## Third-party software

- **SDL2** (zlib license): used through the system library; not bundled.
- **Build-time only, not distributed:** iced-x86 (MIT), Unicorn (GPL-2.0), deark (MIT), CMake, GCC, Python.
