#!/usr/bin/env python3
"""GLES3: no half-float render targets on PowerVR GPUs (port patch; renderer name contains "PowerVR").

The GLES3 renderer renders the sky's radiance and irradiance maps (the ambient and reflected light from the sky),
HDR render targets and the 2D shadow buffers into RGBA16F textures when GL_EXT_color_buffer_half_float is
listed. The PowerVR Rogue GE8300 driver (TrimUI Smart Pro, 1.19.6345021) lists it, but what comes out of such a
target is garbage-bright: by day (background energy 0.75) the sky ambient blew the whole Overworld out (yellow
sand, white with fog), at night (0.15) it only looked slightly off (2026-10-09; fog/ambient bisect with
apply_pvr_debug.py). Here the half-float capability is turned off for PowerVR renderers: the engine's own
fallbacks apply (RGB10_A2 radiance/irradiance, RGBA8 2D shadows, no HDR). PORT_PVR_HALF_FLOAT=1 keeps the
engine's detection (test switch). Other GPUs: unchanged.
usage: apply_pvr_no_halffloat.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'PVR-NO-HALFFLOAT-PATCH'


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


p = os.path.join(G, 'drivers/gles3/rasterizer_storage_gles3.cpp')
s = open(p, encoding='utf-8').read()
if MARK in s:
    print('already patched')
    sys.exit(0)
s = once(s, '''	config.framebuffer_half_float_supported = config.extensions.has("GL_EXT_color_buffer_half_float") || config.framebuffer_float_supported;
''', '''	config.framebuffer_half_float_supported = config.extensions.has("GL_EXT_color_buffer_half_float") || config.framebuffer_float_supported;
	{
		// PVR-NO-HALFFLOAT-PATCH (apply_pvr_no_halffloat.py): PowerVR half-float render targets come out
		// garbage-bright (sky radiance = blown-out daylight): use the engine's RGB10_A2 / RGBA8 fallbacks there
		const char *r = (const char *)glGetString(GL_RENDERER);
		if (r && strstr(r, "PowerVR") && OS::get_singleton()->get_environment("PORT_PVR_HALF_FLOAT") != "1") {
			config.framebuffer_float_supported = false;
			config.framebuffer_half_float_supported = false;
			print_line("pvr: half-float render targets off");
		}
	}
''')
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: drivers/gles3/rasterizer_storage_gles3.cpp')
