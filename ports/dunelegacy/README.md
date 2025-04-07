### Controls

The Dune Legacy manual is available [here](https://dunelegacy.sourceforge.net/website/manual.html).

With two analog sticks:

| Button            | Action                                      |
| :---------------- | :------------------------------------------ |
| D-pad             | Scroll screen                               |
| Left stick        | Mouse                                       |
| A                 | Select                    Left mouse button |
| B                 | Order unit to move to attack position     A |
| X                 | Order unit to move to position            M |
| Y                 | Order unit to move to capture structure   C |
| L1                | Repair selected structure                 R |
| L2                | Return selected harvester                 H |
| R1                | Next construction yard                    G |
| R2                | Next factory / other builder              F |
| R3                | Mouse slow                                  |
| Right stick up    | Upgrade structure                         U |
| Right stick down  | Request carryall drop                     D |
| Right stick left  | Place structure                           P |

With function key held:

| Button            | Action                                      |
| :---------------- | :------------------------------------------ |
| L1                | Toggle game time display                  T |
| R1                | Skip 10 seconds                          F4 |
| R2                | Skip 2 minutes                           F6 |

On devices with one analog stick, use the D-pad instead of the right stick. Scroll screen by moving the mouse to the edge.

### Acknowledgements
Thanks to the original Dune II teams at Westwood Studios and Virgin Games for the original game, and to the Dune Legacy team for the excellent reimplementation.

Thanks to kloptops for his [sim_cursor library](https://github.com/kloptops/SDL_sim_cursor).

### Port information
This port contains two binaries. Both contain small patches to reduce flicker and to set up paths appropriately for the port. One also adds a software cursor using kloptops' sim_cursor library for platforms that don't display the vanilla cursor.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/dunelegacy/dunelegacy/BUILDING.md) for building instructions.
