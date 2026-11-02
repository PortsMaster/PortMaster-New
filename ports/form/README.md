## Notes

FORM is an experimental audiovisual sculpture by deadquiet42. It is pure maths: a body of points, a drone and tuned strikes, all generated in real time and shaped by the controls. It is a nod to the demoscene and to 90s and 00s drone and IDM. It rests silent until touched, and each launch varies slightly. Headphones recommended.

Thanks to the PortMaster team and testers.

Built for handhelds with two analogue sticks that click for L3 and R3, plus L1, R1, L2 and R2.

FORM is a small native program using the system SDL2 library, with no bundled libraries, samples or fonts.

FORM is freeware, distributed through PortMaster with the author's permission. See `form/licenses/LICENSE.form.txt`.

## Controls

| Button | Action |
|--|--|
| Right Stick | Turn (it keeps turning when you let go) |
| Left Stick | Twist |
| D-Pad | Strike from that side; hold to bend it away |
| A | Expand |
| B | Compress |
| X | Twist sharply |
| Y | Colour |
| L1 | Hold still (damp) |
| R1 | Resonate |
| L2 / R2 | Pull / push |
| L3 | High tick |
| R3 | Low knock |
| A + B, Y + R1, L2 + R2 | Their own chords and shapes |
| Start | Let go of everything |
| Select + Start | Exit |

## Compile

    git clone https://github.com/deadquiet42/form.git
    cd form
    gcc -O2 -s form.c -o form $(sdl2-config --cflags --libs) -lm -lpthread

Build on an aarch64 device or chroot with the SDL2 development files. The release binary was cross compiled with clang 18 and lld against glibc 2.17 symbol versions.
