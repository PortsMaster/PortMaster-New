## Notes

Thanks to [Bytten Studio](https://www.bytten-studio.com/) and [Raw Fury](https://rawfury.com/) for Cassette Beasts, a monster-collecting RPG where you fuse with your partner's tape into new forms.

- **Steam or Epic Games Store version.** Copy `CassetteBeasts.pck` from the game's folder into `ports/cassettebeasts/gamedata/` and launch. No other file is needed; the Steam Windows and Linux packs and the Epic pack all work.
- **DLC (optional):** if you own DLC on Steam, install it in Steam and copy the game's `dlc` folder (`00_cosplay.pck`, `01_pier.pck`, ...) into `ports/cassettebeasts/gamedata/`. The next launch converts it (a few seconds) and the game finds it as on PC.
- The first launch converts the game for 1 GB devices (about 3 minutes): the sound effects become IMA-ADPCM and the large illustrations ETC2. It needs about 450 MB of free space next to the game. If setup fails, the reason is on screen and in `ports/cassettebeasts/patchlog.txt`. After a game update, copy the new `CassetteBeasts.pck` over the old one: the next start notices it and converts it again (the same for updated DLC packs).
- The port runs its own build of the game's engine (Godot 3.5 with FRT), changed to fit the game into 1 GB of RAM and to fix Mali GPU rendering bugs (see Compile). The game runs at 30 fps. The 3D renders at a resolution matched to the screen (about the same detail on a 480x320 screen as on a 720x720 one); Snapdragon devices (Adreno GPU) get the 3D at full resolution with the game's glow, depth of field, shadows and anti-aliasing available and switched on at the first start (60 fps).
- **Settings → Graphics → Aspect ratio** (added by the port): **16:9 letterbox** (default) shows the 3D world exactly as on a 16:9 screen, with the game's menu pattern above and below, **Cropped** fills a narrower screen and cuts off the sides, **Expanded view** keeps the full width and shows more above and below (slower). The title screen always fills the screen. The first start asks which of letterbox and Expanded view to use (with pictures of both); on 16:9 screens the modes look the same, so there is no question and no setting.
- **Settings → Graphics → UI size** (added by the port): the game draws its menus and battle screens for a 1920×1080 TV, so on small screens the text is tiny. **Large** (default) draws them 1.33× bigger, **Larger** 1.5× bigger, **Normal** is the game's own size. Menus that would be too wide at the larger sizes (save files, character creation, party, map) are scaled down just enough to fit. The port's own texts are translated into all of the game's languages.
- **Settings → Graphics → 3D resolution** (added by the port): how sharp the 3D world is drawn, as a share of the screen's resolution. **Auto** (default) picks a value matched to the screen; lower values run faster but look blockier (on an R36S, each 5 % step is worth about 3-4 ms a frame), 100 % is full resolution. Menus and text stay sharp at every setting. Changes apply at once.
- **Settings → Graphics → Ultra Low Tweaks** (added by the port): lighter physics, and buildings, props and characters load closer to you, so distant objects appear a little later. On by default on RK3326 devices (RG351P/M/V, R36S, ...), where the first start explains it and lets you turn it off (keeping it on is recommended there). On those devices running ROCKNIX, the libmali GPU driver runs the game noticeably faster than Panfrost.
- **RK3326 devices (R36S, RG351P/M/V, ...):** playable but slow, about 16 fps while walking (the processor is the limit). The defaults there are Ultra Low Tweaks on and 3D resolution Auto (56 % on a 640x480 screen, 75 % on 480x320). For more speed, set the governors to `performance` (about 20 % faster) and lower **3D resolution** to 50 % or 45 %.
- **Local co-op:** connect a second controller (Bluetooth, or USB where the device supports it) before starting (a controller connected later has no button mapping until the next start). The handheld's own controls are always player 1, and the extra controller joins as player 2 on the game's controller assignment screen: press Start (or L + R) on it while walking around, or use the join prompt in the pause menu. Without an extra controller connected, that screen and prompt do not appear (Switch Pro pads and Joy-Cons in Switch mode get the Nintendo button layout and prompts). If a controller presses A on the title screen instead of the handheld, it shares player 1 with the handheld, as in the PC game.
- Button prompts show **START** and **SELECT** as words for those two buttons, as printed on these handhelds.
- **Name entry:** press A on a text field for the on-screen keyboard (D-pad or left stick, A types, B deletes, Start confirms).
- **Performance:** if your firmware has CPU or GPU governor settings, set them to `performance` for a smoother game.
- Keep **Overworld Streaming** (Graphics) on **Low CPU Usage**: the higher setting only adds work on these devices.
- The port spreads the loading of the world while you walk over several frames and keeps compiled shaders in `ports/cassettebeasts/cache/`, so a new area or monster stutters only the first time it appears. **Settings → Graphics → Shaders → Prepare** compiles them all in advance (about 6 minutes on an RG Cube XX, once; Cancel keeps the place for next time); the title screen offers it once on the first start. The title screen has no store buttons and no update news.
- In battle, the focused cassette button's name is shown above it (the labels on the player are tiny on these screens).
- Saves and settings: `ports/cassettebeasts/conf/CassetteBeasts/`. Logs: `log.txt` and `patchlog.txt` in `ports/cassettebeasts/`, the port scripts' log in `conf/CassetteBeasts/port_options.log`.

## Controls

The handheld's controls reach the game through gptokeyb2 as the keyboard player; the button prompts use the game's Switch icons, so their letters match the printed buttons. The left stick moves in eight directions (extra controllers keep full analog).

| Button | Action |
|--|--|
| D-pad / Left stick | Move, menus |
| A | Confirm, dash |
| B | Back, jump |
| Y | Interact |
| X | Pause menu |
| L1 / L2 | Climb |
| R1 / R2 | Magnetism |
| Select | Map |
| Start | Pause menu |
| Select + Start | Quit |

## Compile

### Engine (`cassettebeasts/frt_3.5.2_cb.squashfs`)

Godot Engine 3.5.2-stable with [FRT](https://github.com/efornara/frt) 2.1.0 (the base of PortMaster's `frt_3.5.2`), plus this port's patches: [Knifethrower/cassettebeasts-frt](https://github.com/Knifethrower/cassettebeasts-frt) has the patches, the build steps and what each patch does (the same files are in `cassettebeasts/tools/src/frt`). Cross-compiled with clang against a Debian bullseye arm64 sysroot (glibc 2.29 at most):

```
git clone --depth 1 --branch 3.5.2-stable https://github.com/godotengine/godot.git work/godot
git clone https://github.com/efornara/frt.git work/frt && git -C work/frt worktree add ../frt-2.1.0 2.1.0
bash tools/src/frt/apply_all work/godot work/frt-2.1.0
WORK=work SYSROOT=/path/to/bullseye-arm64 bash tools/src/frt/build_frt release module_webm_enabled=no
bash tools/src/frt/pack_squashfs work/godot/bin/godot.frt.opt.llvm.arm64v8 frt_3.5.2_cb.squashfs
```

### Converters (`tools/wav_adpcm`, `tools/tex3_convert`)

Built natively in a Debian bullseye arm64 chroot (static libstdc++/libgcc):

```
git clone --depth 1 --branch v1.4.0 https://chromium.googlesource.com/webm/libwebp tools/src/native/third_party/libwebp
bash tools/src/native/build_tools out
```

etcpak (commit 3d716e15) is included in `tools/src/native/third_party/etcpak`.

### Port scripts (`cassettebeasts/port/`)

GDScript loaded by the engine through `override.cfg` (nothing to build): the aspect ratio setting and the letterbox pattern, the splash screen loading under the key art instead of freezing an animation, the game's level streamer with its work spread over frames (new map chunks set up one per frame on the main thread, buildings and props added within a few milliseconds per frame) plus a guard for the ground around the player, the on-screen keyboard, and the title screen and pause menu changes.
