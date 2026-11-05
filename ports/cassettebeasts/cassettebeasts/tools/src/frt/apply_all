#!/bin/bash
# Applies every patch, in order, to clean source trees: a Godot 3.5.2-stable checkout and an FRT 2.1.0 checkout.
#   bash apply_all.sh <godot dir> <frt-2.1.0 dir>
# The patch scripts stop with an error when the code they expect is missing. License: 0BSD.
set -e
G=$(realpath "${1:?godot dir}")
F=$(realpath "${2:?frt-2.1.0 dir}")
P=$(dirname "$(realpath "$0")")/patches
py() { for s in "$@"; do echo "== $s"; python3 "$P/$s" "$G"; done; }

# memory: lazy textures and audio, render scale, CPU mesh copies
cp "$P/lazy_texture.h" "$P/lazy_texture.cpp" "$G/servers/visual/"
py apply_lazy.py apply_lazy_audio.py apply_objdump.py apply_render_scale.py apply_mesh_copy.py
echo "== lazy_threads.patch"
patch -d "$G" -p1 --forward --quiet < "$P/lazy_threads.patch"
py apply_rid_validate.py apply_lazy_samples.py apply_lazy_pressure.py apply_memstats.py apply_shader_evict.py \
	apply_font_stream.py apply_lazy_translations.py apply_viewport_clamp.py apply_debug_watch.py
# rendering fixes and the aspect settings
py apply_material_pending.py apply_depth_copy.py apply_init_buffers.py apply_viewport_cap.py \
	apply_lazy_immediate.py apply_alpha_prepass_depth.py apply_camera_fit.py apply_letterbox.py apply_aspect_runtime.py
# hitches and loading
py apply_shader_cache_sync.py apply_bullet_shape_batch.py apply_rt_flag_skip.py apply_rt_lazy_alloc.py \
	apply_boot_progress.py apply_instance_steps.py apply_slow_load_log.py apply_slow_frame_log.py
# PowerVR GE8300 and particle fixes, run-time render scale, the yield crash fix
py apply_pvr_particles.py apply_zero_buffers.py apply_pvr_ubo_ring.py apply_pvr_debug.py apply_pvr_no_halffloat.py \
	apply_feedback_nocache.py apply_render_scale_runtime.py apply_gdscript_yield_fix.py

# frt (the platform)
for s in apply_frt_wrapmt.py apply_frt_nojoy.py apply_frt_joyname.py apply_frt_linebuf.py apply_frt_joyonly.py \
	apply_frt_joyskip.py apply_frt_joyfirst.py; do
	echo "== $s"; python3 "$P/$s" "$F"
done
echo "all patches applied"
