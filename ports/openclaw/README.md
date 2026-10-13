## Notes

Thanks to [Petr Jašíček](https://github.com/pjasicek/OpenClaw) for OpenClaw and Cebion for the original PortMaster port.

This experimental update adds MPEG cutscenes, editable controller bindings, working options pages, barrel carrying/throwing fixes, and display resolution, aspect ratio, image size and zoom settings. The added menus currently use Portuguese labels. Default controls: R2 fires, L2 uses the sword, L1 picks up/throws a barrel; change these under Controls.

The changes were developed with assistance from AI (Codex) and tested by the contributor on an RX6H with ArkOS/PortMaster. They are not yet validated across supported firmwares. See TESTING.md.

### Cutscenes

Movies are not included. Supply your own original CLAW0–CLAW8 videos, convert them to MPEG-1 video with MP2 audio and place CLAW0.mpg through CLAW8.mpg in openclaw/movies/. Missing movies are skipped. Example:

```sh
ffmpeg -i CLAW0.avi -map 0:v:0 -map 0:a:0 -vf "fps=30000/1001,setpts=PTS-STARTPTS" -r 30000/1001 -af "asetpts=PTS-STARTPTS" -c:v mpeg1video -q:v 3 -g 30 -bf 0 -pix_fmt yuv420p -c:a mp2 -b:a 192k -ar 44100 -ac 2 -f mpeg CLAW0.mpg
```

The engine does not implement level 14; its movie can be replayed if supplied.

### Source and build

Corresponding engine source and build notes: [experimental v0.4 release](https://github.com/Estives45/PortMaster-New/releases/tag/openclaw-experimental-v0.4). The source is based on pjasicek/OpenClaw commit 5ee5740ca98377c76b13b50c84f610b0066a4717. The decoder is pl_mpeg (MIT); OpenClaw is GPL-3.0.

The current ARM64 build uses Zig 0.13.0 with its static LLVM C++ runtime and the firmware's shared SDL2/system libraries. A build using the standard PortMaster toolchain and shared C++ runtime remains pending before acceptance. No new system libraries or graphics drivers are bundled.
