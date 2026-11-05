# Cassette Beasts engine for PortMaster (Godot 3.5.2 + FRT 2.1.0)

The engine of the [Cassette Beasts PortMaster port](https://github.com/PortsMaster/PortMaster-New): Godot Engine
3.5.2-stable on [FRT](https://github.com/efornara/frt) 2.1.0, the same base as PortMaster's `frt_3.5.2` runtime
(SDL2 backend, GLES loaded through SDL), plus the patches below. They fit the game into 1 GB of RAM, fix rendering
bugs in the Mali and PowerVR GPU drivers of these handhelds, and remove the walking hitches. The port ships the
result as `cassettebeasts/frt_3.5.2_cb.squashfs`.

Each patch is a Python script that edits a clean source tree and stops with an error if the code it expects is not
there. `apply_all` runs them in order; applied to clean 3.5.2-stable and 2.1.0 checkouts, it reproduces the
source tree of the shipped engine exactly.

## Build

Cross-compiled with clang against a Debian bullseye arm64 root as sysroot (the binary needs glibc 2.29 at most):

```
git clone --depth 1 --branch 3.5.2-stable https://github.com/godotengine/godot.git work/godot
git clone https://github.com/efornara/frt.git work/frt
git -C work/frt worktree add ../frt-2.1.0 2.1.0
bash apply_all work/godot work/frt-2.1.0
WORK=work SYSROOT=/path/to/bullseye-arm64 bash build_frt release module_webm_enabled=no
sudo bash pack_squashfs work/godot/bin/godot.frt.opt.llvm.arm64v8 frt_3.5.2_cb.squashfs
```

`build_frt` links `work/frt-2.1.0` as `godot/platform/frt` and writes a pkg-config wrapper for the sysroot.
`NOSTRIP=1` builds the same code with symbols. The same patched tree builds for PC tests with
`scons platform=x11 tools=no target=release module_webm_enabled=no`.

## Patches

New behavior is off unless a project setting (`override.cfg`) or environment variable switches it on; bug fixes are always on.

| Patch | Setting | What |
|--|--|--|
| `apply_lazy.py` + lazy_texture.{h,cpp} | `rendering/lazy_textures/enabled`, `evict_after_seconds` (30), `print_stats` | StreamTexture::load() reads only the header; the GLES3 renderer decodes + uploads on first bind (13 bind sites) and drops textures not drawn for N s. |
| `apply_lazy_audio.py` | `audio/lazy_ogg_streams` | The binary loader leaves AudioStreamOGGVorbis data in the .oggstr; the stream reads it when a playback starts, frees it after the last one. |
| `apply_render_scale.py` | `rendering/quality/3d_render_scale` (1.0), `3d_render_scale_nearest` | The on-screen viewport renders 3D into a smaller companion render target, blits it up, draws the 2D canvas at full size (sharp UI). GLES3. |
| `apply_objdump.py` | env `GODOT_OBJECT_DUMP=<file>` | Debug aid: class histogram of all live objects on stderr when <file> appears. |
| `apply_mesh_copy.py` | always | GLES: keep CPU copies of mesh vertex/index data (Mali refuses glMapBufferRange for reading: scripts got empty surface arrays, then a segfault); render target failures logged with details on stderr. |
| `lazy_threads.patch` | (lazy textures) | StreamTexture::load on loading threads queues the lazy source for the main thread (a shared Set was modified from threads: heap corruption). |
| `apply_rid_validate.py` | always | Release builds validate material and scene-instance RIDs (debug-build id set, opt-in per owner): stale RIDs from scripts become errors instead of use-after-free. |
| `apply_lazy_samples.py` | `audio/lazy_samples`, `lazy_samples_budget_mb` (16) | AudioStreamSample data stays in the .sample file, loaded on playback into an LRU cache. |
| `apply_lazy_pressure.py` | `rendering/lazy_textures/low_memory_mb` (0) | Below that much MemAvailable (checked every 250 ms) free every lazy texture not drawn in the last second at once. |
| `apply_memstats.py` | `memory/malloc_trim_seconds` (0), `malloc_trim_on_pressure` (true) | glibc heap numbers after the lazy stats line (mallinfo2 looked up at run time); malloc_trim. |
| `apply_shader_evict.py` | `rendering/lazy_shaders/evict_after_seconds` (0) | Compiled ShaderGLES3 variants not bound for N s are deleted (5 s under texture memory pressure); recompiled on next use. |
| `apply_font_stream.py` | `gui/fonts/stream_font_files` | FreeType reads DynamicFont files through a FileAccess stream instead of a whole-file Vector (power-of-two capacity: an 8.5 MB font took 16 MB). |
| `apply_lazy_translations.py` | `locale/lazy_translations` | Only translations of the current and fallback language load at start; set_locale loads others; get_loaded_locales lists all. |
| `apply_viewport_clamp.py` | `rendering/viewports/force_no_hdr`, `force_no_3d_effects`, `force_no_msaa` | Applied in _render_target_allocate, so the root viewport too. Needed because frt has the `mobile` feature: the project's `quality/depth/hdr.mobile=true` beats a plain `hdr=false` in override.cfg. |
| `apply_debug_watch.py` | always | "Shaders: N compiled at T s" once a second while compiling; under texture memory pressure one "Low memory: ..." line per second. |
| `apply_material_pending.py` | always | instance_set_surface_material keeps a material set before the mesh's surfaces arrive (queued VisualServerWrapMT calls from a loading thread); was "Index p_surface = 0 is out of bounds", the material lost for good: puppets and props drawn with the default material ("just their shadows"). |
| `apply_depth_copy.py` | always (matters with NO_3D_EFFECTS) | With the effect buffers off GLES3 never bound DEPTH_TEXTURE/SCREEN_TEXTURE (materials read garbage: the game's render-through sprite shader drew partners/NPCs as dark silhouettes). Before the transparent pass the depth is blitted into a spare depth texture of the render target and bound; the color so far goes into rt->color and is bound as SCREEN_TEXTURE (no mip chain). |
| `apply_init_buffers.py` | (reads `rendering/quality/shadow_atlas/size`, `reflections/atlas_size`) | RasterizerSceneGLES3::initialize() keeps only the 32 cubemap of the omni-shadow / reflection ladders (512..32, ~8 + 17 MB) when the respective atlas size is 0. Note frt has the `mobile` feature: write `shadow_atlas/size.mobile` too. |
| `apply_viewport_cap.py` | `rendering/viewports/max_3d_pixels` (0 = off) | Any 3D viewport with more pixels renders its 3D through the render-scale companion at sqrt(max/pixels) and is blitted up into its own target (ViewportTextures keep working); the root takes the smaller of this and 3d_render_scale. For own-world boss viewports (800x800..1500x1250). |
| `apply_lazy_immediate.py` | (lazy textures) | The immediate-geometry bind (Sprite3D/AnimatedSprite3D chunk texture) touches lazy textures like every other bind site (was never marked as drawn: evicted while on screen). |
| `apply_alpha_prepass_depth.py` | always | Alpha-scissor materials with depth_draw_alpha_prepass write depth in the opaque pass when Godot runs without a depth prepass (vendor list incl. Mali, NO_3D_EFFECTS targets). Before: later opaque geometry painted over them, 3D sprites/posters/NPCs vanished depending on the camera. Stock Godot on Mali has the same bug. |
| `apply_camera_fit.py` | `rendering/camera/fit_aspect` (0 = off) | Screen cameras with KEEP_HEIGHT on a screen narrower than fit_aspect get the projection widened so the horizontal view matches fit_aspect (render, culling, shadows, sky, unproject/project_ray all consistent). 1.777778 on the 1:1 Cube XX: the full 16:9 width (battle fighters no longer cut off), more top/bottom. |
| `apply_frt_joyname.py` (frt) | env `FRT_JOY_NAME`, `FRT_JOY_NAME_MATCH` | Joypads reported under another name (re-adds the GUID's SDL_GAMECONTROLLERCONFIG line under that name); GUID CRC zeroed when SDL_GAMECONTROLLERCONFIG has no exact line. "Nintendo Switch Pro Controller" on Knulli = Switch icons, A/B as printed on the Cube XX. |
| `apply_frt_joyonly.py` (frt) | env `FRT_JOY_ONLY=<text>` | Only joysticks whose SDL name contains the text are opened (for a launcher that turns the handheld's controls into one virtual pad, so the game does not also read the real one). |
| `apply_frt_nojoy.py` (frt) | env `FRT_NO_JOYSTICK=1` | SDL joystick subsystem off: the game sees no gamepad (the port maps the pad to keys; else presses arrive twice). |
| `apply_letterbox.py` | `rendering/camera/letterbox_aspect` (0 = off) | On a screen narrower than that aspect the on-screen viewport draws its 3D into a centered band of it (render target blit, the rest cleared; the port draws its own bars over it) and screen cameras project into the band (unproject/project_ray offset to match). The 2D canvas keeps the whole screen. |
| `apply_aspect_runtime.py` | (letterbox, fit) | The letterbox and fit settings are read on every use instead of once, so the port's Aspect ratio menu row switches them while the game runs. |
| `apply_render_scale_runtime.py` | (`3d_render_scale`) | The 3D render scale is read every frame instead of once, so the port's 3D resolution setting changes it while the game runs (the scaled target follows the new size). After render_scale and viewport_cap. |
| `apply_gdscript_yield_fix.py` | (always) | No crash when a node is freed while one of its scripts is in a `yield` (Godot #74695, use-after-free while clearing pending coroutine states). By Tom Coxon of Bytten Studio (github.com/tcoxon/godot, branch gh74695_3.x); upstream fixed 3.x only in 3.7 (#97464). |
| `apply_shader_cache_sync.py` | `rendering/gles3/shaders/shader_cache_sync`, `shader_cache_size_mb` | Godot's GLES3 program binary cache (glGetProgramBinary/glProgramBinary) with synchronous compilation (upstream only with async compilation, which needs a second GL context frt lacks), every program version cached: a shader compiles once, later sessions load the binary. Folder: XDG_CACHE_HOME/godot/shaders. |
| `apply_bullet_shape_batch.py` | always | Bullet rebuilt a body's whole compound shape on every add_shape (n shapes = ~n^2/2 child inserts); now add_shape marks the body and the compound is rebuilt once before physics uses it (tick start, step, space queries, test_motion). GridMap octant builds (one static body per octant, a shape per cell) went from 116-288 ms to under 50 ms on the Cube XX: the big walking hitches. |
| `apply_rt_flag_skip.py` | always | render_target_set_flag re-allocated the render target (textures + FBOs) on every HDR/NO_3D/NO_SAMPLING/NO_3D_EFFECTS call, changed or not; now an unchanged effective value (viewport clamp included) returns. |
| `apply_rt_lazy_alloc.py` | always | Size/flag changes free the render target and mark it; it is allocated once when first drawn (set_current_render_target, render-scale companions). Viewports coming out of PackedScene::instance() were allocated 2-3 times each: Cassette Beasts draws every NPC's sprite into a Viewport, the town chunks instanced in 164-184 ms on PC (83 % render target allocation), 20 ms after; Cube XX 225 -> ~95 ms. |
| `apply_boot_progress.py` | `application/boot_splash/progress_bar` (+ `progress_*` colors, place, `progress_end`) | Godot draws the boot splash once and then loads all autoloads and the main scene without drawing: Cassette Beasts sat ~13 s on a still image on the RG Cube XX, and black when that one draw was lost. The boot image, composed at screen size, is redrawn with a progress bar after each autoload load, each autoload _ready and the main scene (at most every 250 ms); the game's own loading screen can continue the same bar from `progress_end`. Generic: any Godot 3 game. |
| `apply_instance_steps.py` | used by scripts only (`PackedScene.instance_begin()`) | SceneState::instance split into a resumable per-node step (time budget) and the finish (local resources, connections); `instance()` unchanged. `PackedSceneStepper.step(usec)` / `get_node()` / `get_progress()`. Cassette Beasts builds town chunks (~100 ms in one call on the RG Cube XX) a few ms per frame (PortChunk.step_setup); PC: 20-25 ms chunks in 4-5 steps of ~5-6 ms, identical node trees. Sub-scenes are built whole within a step. |
| `apply_slow_load_log.py` | env `PORT_SLOW_LOAD_MS=<n>` | Debug aid: main-thread ResourceLoader::load calls of n ms or more printed with time and path. |
| `apply_slow_frame_log.py` | env `PORT_SLOW_FRAME_MS=<n>` | Debug aid: frames of n ms or more printed with a phase breakdown (physics scripts/step, idle, deferred, draw); deferred calls of n/2 ms or more printed with class, node and method. |
| `apply_frt_wrapmt.py` (frt) | always | frt created VisualServerRaster without VisualServerWrapMT, so VisualServer calls from loading threads ran GL without a context (incomplete framebuffers, black white-fade loading screen, crashes). Now as platform/x11. |
| `apply_pvr_particles.py` | env `PORT_PVR_PARTICLES=none/guard/finish/off`; default `none` everywhere since 2026-10-10 (was `off` on PowerVR) | Switches for the GPU particle update (transform feedback). The PowerVR GE8300 crash (null read in libGLESv2.so on the feedback draw, Smart Pro) turned out to be programs loaded from the binary shader cache, fixed by `apply_feedback_nocache.py`; guard/finish had not helped because the cached programs were still in use. `off` stays as a fallback (no particle updates: no grass, weather, sprays on that device). |
| `apply_zero_buffers.py` | always (PowerVR renderers only) | glBufferData(..., nullptr) allocations (light/reflection UBOs, material UBO before its parameters, multimesh, immediate buffer) pass a zeroed block on PowerVR. Did not fix the colors (see the next row); kept as hygiene, other GPUs unchanged. |
| `apply_pvr_ubo_ring.py` | always on PowerVR renderers; env `PORT_PVR_UBO_RING=0/1` overrides | The scene, environment, directional light, omni/spot light array and reflection UBOs are re-uploaded in place for every 3D pass (several a frame: NPC sprite Viewports); on the PowerVR GE8300 (TrimUI Smart Pro) the fragment stage, which on a deferred tiler reads them long after the draw, got old/freed memory: positions right, lighting and material colors random per run (beach black/red/white, sprites tinted, neon water). Now each upload goes to the next of 64 buffer objects per UBO and the renderer binds that one; a changed material gets a new buffer object. Smart Pro beach walk with the shader cache off (wrong in every earlier run): correct colors, 2 runs. |
| `apply_pvr_no_halffloat.py` | always on PowerVR renderers; env `PORT_PVR_HALF_FLOAT=1` keeps the engine's detection | The GE8300 driver lists GL_EXT_color_buffer_half_float, but RGBA16F render targets come out garbage-bright: the sky radiance/irradiance maps (ambient light from the sky, scaled by the background energy: 0.15 at night, 0.75 by day) blew the daytime Overworld out (yellow sand; white once the fog maths saw it) while the night looked right. Half-float (and float) framebuffer support is reported off on PowerVR: the engine's RGB10_A2 radiance, RGBA8 2D shadow and no-HDR fallbacks apply. User check on the Smart Pro by day: "looks perfect" (2026-10-09). |
| `apply_pvr_debug.py` | env `PORT_PVR_DEBUG=nofog,nosun,noambient,nobg` (inert without it) | Test switches used for the bisect above (fog off turned the white beach into an overexposed yellow one = the light itself was too bright). Left in the build; no effect unless set. |
| `apply_feedback_nocache.py` | always; env `PORT_FEEDBACK_CACHE=1` caches them again | A transform feedback program created from a program binary (the shader cache: glGetProgramBinary/glProgramBinary) crashes the PowerVR GE8300 driver on its first feedback draw (Smart Pro) and writes nothing on the Mali-G31 (RG Cube XX: GPU particles such as the grass invisible since the shader cache went in); linked from source it works on both. Found with `devtest/pvrtf` (standalone repeat of the engine's particle update on the Smart Pro, 2026-10-10: both binary variants died on the first update, the linked one ran 75 s / 180760 feedback draws) and title screen shots on the Cube XX (no grass with the cache, grass without it and with this patch). Shaders with feedback varyings (particles, blend shapes) are neither looked up in nor stored to the cache, on every renderer. |
| `apply_frt_linebuf.py` (frt) | always | stdout line-buffered at start: launchers pipe the output through tee into log.txt, where block buffering kept the engine's and the game's print() lines in a 4 KB buffer that Select+Start's kill threw away (the R36S log had no engine lines). |
| `apply_frt_joyskip.py` (frt) | env `FRT_JOY_SKIP=<name>|...` (`FRT_JOY_ONLY` wins when set) | Every joystick except those named is opened. The port's launcher names the handheld's built-in controller, which gptokeyb2 turns into keys (the keyboard player, player 1), so only USB/Bluetooth pads reach the game, as co-op players. |
| `apply_frt_joyfirst.py` (frt) | env `FRT_JOY_FIRST=<name>|...`; `FRT_JOY_NAME_MATCH` with `|` alternatives | The named joystick always gets game id 0, even when SDL lists another pad first; its id is exported as `FRT_JOY_FIRST_ID` (Godot's joy GUID here is only "Default Joypad"). The Switch-name rename matches several names, so hid-nintendo's "Pro Controller" / "Joy-Con" get the Nintendo layout and prompts instead of Xbox. |

## License

The patches change Godot and FRT, both MIT: [LICENSE.godot.txt](LICENSE.godot.txt), [LICENSE.frt.txt](LICENSE.frt.txt).
The changes are under the same MIT license. `apply_gdscript_yield_fix.py` applies a fix by Tom Coxon of Bytten
Studio (branch gh74695_3.x of [tcoxon/godot](https://github.com/tcoxon/godot)). The build and apply scripts are 0BSD.
