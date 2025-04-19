### Rocknix

This port is not compatible with Rocknix libmali -- please use the system menus to switch to Panfrost.

### Controls

| Button     | Action           |
| :--------- | :--------------- |
| D-pad      | Movement         |
| Left stick | Movement         |
| A          | Jump             |
| B          | Open door        |
| X          | Rewind time      |
| Y          | Drop/pickup ring |
| L1         | Rewind faster    |
| R1         | Fast forward     |
| L3         | FPS display      |

In puzzle screens:

| Button     | Action       |
| :--------- | :----------- |
| D-pad      | Movement     |
| Left stick | Movement     |
| A          | Rotate piece |
| X          | Hold piece   |

### Acknowledgements

Thank you to [Jonathan Blow](http://number-none.com/blow/) for the original game. Thanks to ptitSeb for [box86](https://github.com/ptitSeb/box86) and to BinaryCounter for [Westonpack](https://github.com/binarycounter/Westonpack/wiki), without both of which this port would not be possible.

Thanks to Jeod for the love launcher that the language selector is based on.

Thanks to BinaryCounter, klops and Cebion for help with the port.

### Port information

The port uses box86 and Westonpack to run an i386 X11 linux binary on arm platforms that do not have X11 support. An X11-enabled libSDL 2.0.16 is preloaded as described [here](https://github.com/binarycounter/Westonpack/wiki/SDL2-on-X11-Example) on top of the system libSDL. The binary is also patched to remove a check for ARB_draw_buffers, which fails unnecessarily.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/braid/braid/BUILDING.md) for instructions for building the SDL library.
