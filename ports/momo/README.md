## Notes

A small electronic creature that lives in your handheld. The device is its body and the screen is where its eyes are. It notices you, reacts, chatters in a voice of its own, gets bored, dozes, dreams and remembers you between visits.

Every MOMO is born different, with its own voice, eyes and colour, and it gets to know you over days rather than minutes. Give it time: leave it alone, stroke it, tap it a rhythm, then come back later.

MOMO is an original piece by deadquiet42. It is pure Python on PortMaster's `python_3.11` runtime and draws through the system SDL2 library. Its voice is synthesised live; there are no sound files. Thanks to the PortMaster team and testers.

MOMO is freeware. See `momo/licenses/LICENSE.momo.txt`.

## Controls

| Button | Action |
|--|--|
| A | Boop |
| B, X, Y | Startle, play, watch |
| X, tapped | Tap a rhythm and MOMO sings it back |
| D-Pad | Surprise, soothe, tease, greet |
| L1 / R1 | Nudge; hold to stroke |
| L2 / R2 | Poke |
| Left Stick | Draw its attention (where present) |
| Right Stick | Edge, lean in and withdraw (where present) |
| Select, held | Repaint MOMO's colour |
| L1 + R1 + Start, held | Reset: let go after 5 seconds and MOMO forgets you; hold for 10 seconds for a new MOMO |
| Select + Start | Exit |

## Saves

MOMO's identity, memory and a short history are kept in `ports/momo/conf`. Delete that folder to start afresh.

## Compile

Source: https://github.com/deadquiet42/momo

Nothing to compile. `momo_app.py` runs as is on the `python_3.11` runtime.
