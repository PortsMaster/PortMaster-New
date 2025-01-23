## Notes

Source: [EvilJagaGenius](https://github.com/EvilJagaGenius/q2pro-pm)
Forked from: [skullernet](https://github.com/skullernet/q2pro)

Place the contents from the folders of your Quake 2 install to the matching folders in ports/q2pro/.  If you have the Nightdive remaster, add the contents of its baseq2/ folder to ports/q2pro/rerelease/, and copy Q2Game.kpf to ports/q2pro/.

Credit and thanks to Andrey Nazarov (Skuller) for Q2Pro.  Many thanks to Slayer366 as well for testing and help with scripts.

| Action | No-stick | 1-stick | 2-stick |
|--|--|--|--|
| Move | D-pad | Left stick | Left stick |
| Look | ABXY | ABXY | Right stick |
| Shoot | R1 | R1 | R1 |
| Jump | L1 | L1 | L1, A |
| Crouch | L2 | L2 | L2, B |
| Zoom | N/A | R2 | R2 |
| Inventory | R2+D-pad | D-pad | D-pad, X, Y |
| Menu | Start | Start | Start |
| Help computer | Select | Select | Select |

Build instructions:
```shell
git clone https://github.com/EvilJagaGenius/q2pro-pm
cd q2pro-pm
meson setup builddir
meson configure -Dsystem-wide=false builddir
meson configure -Dlibcurl=disabled builddir
meson configure -Dx11=disabled builddir
meson configure -Dwayland=disabled builddir
meson configure -Dsdl2=enabled builddir
meson compile -C builddir
```
To enable Wayland (e.g. Rocknix):
```shell
meson configure -Dwayland=enabled builddir
```
To use the legacy (GLES 1) renderer instead of GLSL:
```shell
meson configure -Dopengl-es1=true builddir
```

