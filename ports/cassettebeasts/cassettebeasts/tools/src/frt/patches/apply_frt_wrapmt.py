#!/usr/bin/env python3
"""FRT 2.1.0 (Godot 3) port patch: create the visual server like Godot's X11 platform, wrapped in
VisualServerWrapMT unless the render thread model is "unsafe". Without the wrapper, VisualServer calls
from a game's background loading threads run GL on a thread without a context (incomplete framebuffers,
"status 0", races in the renderer, crashes). With "single-safe" (the default) the wrapper queues calls
from other threads and runs them on the main thread.
usage: apply_frt_wrapmt.py <frt dir>   (idempotent)
"""
import os, sys

p = os.path.join(sys.argv[1], 'frt_godot3.cc')
s = open(p, encoding='utf-8').read()
if 'WRAPMT-PATCH' in s:
    print('already patched: frt_godot3.cc')
    sys.exit(0)
old = '''		visual_server_ = memnew(VisualServerRaster);
		visual_server_->init();'''
new = '''		visual_server_ = memnew(VisualServerRaster);
		// WRAPMT-PATCH: as platform/x11 (calls from loading threads are queued for the main thread)
		if (get_render_thread_mode() != RENDER_THREAD_UNSAFE) {
			visual_server_ = memnew(VisualServerWrapMT(visual_server_, get_render_thread_mode() == RENDER_SEPARATE_THREAD));
		}
		visual_server_->init();'''
assert s.count(old) == 1
s = s.replace(old, new)
if '#include "servers/visual/visual_server_wrap_mt.h"' not in s:
    inc = '#include "servers/visual/visual_server_raster.h"\n'
    assert s.count(inc) == 1, 'include anchor'
    s = s.replace(inc, inc + '#include "servers/visual/visual_server_wrap_mt.h"\n')
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: frt_godot3.cc')
