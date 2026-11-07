#!/usr/bin/env python3
"""Godot 3.5 GLES3 port patch: DEPTH_TEXTURE and SCREEN_TEXTURE work with the effect buffers off.

With RENDER_TARGET_NO_3D_EFFECTS (our rendering/viewports/force_no_3d_effects clamp, or a Viewport set to
3D-no-effects) `rt->buffers.active` is false: the 3D scene renders into level 0 of the SCREEN_TEXTURE mip
chain with rt->depth attached, and render_scene() skips both _prepare_depth_texture/_bind_depth_texture and
the screen-texture bind (they need buffers.active). Materials reading DEPTH_TEXTURE or SCREEN_TEXTURE then
sample whatever is bound: Cassette Beasts' render-through sprite shader (partners, NPCs seen through walls)
compares the scene depth with its own and always took the occluded branch, so characters were drawn as dark
half-transparent silhouettes ("just their shadows"); water, puddles and clouds read garbage.
Now, before the transparent pass: the depth is blitted into a spare depth texture of the render target
(allocated on first use, freed with the target) and bound where DEPTH_TEXTURE expects it; the colour so far is
blitted into rt->color and bound as SCREEN_TEXTURE (no mip chain: lod > 0 reads level 0).

usage: apply_depth_copy.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "DEPTH-COPY-PATCH"


def once(s, old, new):
    assert s.count(old) == 1, (s.count(old), old[:70])
    return s.replace(old, new)


# --- storage: the spare depth texture per render target ---
p = godot / "drivers/gles3/rasterizer_storage_gles3.h"
s = p.read_text()
if MARK not in s:
    s = once(s, """		RenderTarget() :
				fbo(0),
				depth(0),""", """		// %s: copy of the depth buffer for DEPTH_TEXTURE materials when the effect buffers are off
		GLuint depth_copy = 0;
		GLuint depth_copy_fbo = 0;

		RenderTarget() :
				fbo(0),
				depth(0),""" % MARK)
    p.write_text(s)
    print("patched:", p)

p = godot / "drivers/gles3/rasterizer_storage_gles3.cpp"
s = p.read_text()
if MARK not in s:
    i = s.index("void RasterizerStorageGLES3::_render_target_clear(RenderTarget *rt) {")
    old = """	if (rt->depth) {
		glDeleteTextures(1, &rt->depth);
		rt->depth = 0;
	}
"""
    j = s.index(old, i)
    new = old + """	// %s
	if (rt->depth_copy) {
		glDeleteFramebuffers(1, &rt->depth_copy_fbo);
		glDeleteTextures(1, &rt->depth_copy);
		rt->depth_copy = 0;
		rt->depth_copy_fbo = 0;
	}
""" % MARK
    s = s[:j] + new + s[j + len(old):]
    p.write_text(s)
    print("patched:", p)

# --- scene renderer ---
p = godot / "drivers/gles3/rasterizer_scene_gles3.h"
s = p.read_text()
if MARK not in s:
    s = once(s, "\tvoid _bind_depth_texture();\n", """\tvoid _bind_depth_texture();
	void _prepare_depth_texture_copy(GLuint p_current_fbo); // %s
	void _prepare_screen_texture_copy(GLuint p_current_fbo); // %s
""" % (MARK, MARK))
    p.write_text(s)
    print("patched:", p)

p = godot / "drivers/gles3/rasterizer_scene_gles3.cpp"
s = p.read_text()
if MARK not in s:
    s = once(s, "void RasterizerSceneGLES3::_render_mrts(", """// %s: with the effect buffers off the 3D scene renders into the mip chain's level-0 FBO with rt->depth
// attached and DEPTH_TEXTURE was never bound. Copy the depth into a spare texture and bind that.
void RasterizerSceneGLES3::_prepare_depth_texture_copy(GLuint p_current_fbo) {
	RasterizerStorageGLES3::RenderTarget *rt = storage->frame.current_rt;
	if (!rt->depth_copy) {
		glGenTextures(1, &rt->depth_copy);
		glBindTexture(GL_TEXTURE_2D, rt->depth_copy);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT24, rt->width, rt->height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, nullptr);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glGenFramebuffers(1, &rt->depth_copy_fbo);
		glBindFramebuffer(GL_FRAMEBUFFER, rt->depth_copy_fbo);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, rt->depth_copy, 0);
		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		if (status != GL_FRAMEBUFFER_COMPLETE) {
			WARN_PRINT("DEPTH_TEXTURE copy framebuffer incomplete: " + itos(status));
		}
	}
	glBindFramebuffer(GL_READ_FRAMEBUFFER, p_current_fbo);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, rt->depth_copy_fbo);
	glBlitFramebuffer(0, 0, rt->width, rt->height, 0, 0, rt->width, rt->height, GL_DEPTH_BUFFER_BIT, GL_NEAREST);
	glBindFramebuffer(GL_FRAMEBUFFER, p_current_fbo);
	glActiveTexture(GL_TEXTURE0 + storage->config.max_texture_image_units - 9);
	glBindTexture(GL_TEXTURE_2D, rt->depth_copy);
	state.prepared_depth_texture = true;
	state.bound_depth_texture = true;
}

// %s: same for SCREEN_TEXTURE: the colour so far goes into rt->color (not rendered to at this point; the
// post-process copy overwrites it afterwards) and is bound without a mip chain.
void RasterizerSceneGLES3::_prepare_screen_texture_copy(GLuint p_current_fbo) {
	RasterizerStorageGLES3::RenderTarget *rt = storage->frame.current_rt;
	glBindFramebuffer(GL_READ_FRAMEBUFFER, p_current_fbo);
	glReadBuffer(GL_COLOR_ATTACHMENT0);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, rt->fbo);
	glBlitFramebuffer(0, 0, rt->width, rt->height, 0, 0, rt->width, rt->height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
	glBindFramebuffer(GL_FRAMEBUFFER, p_current_fbo);
	glActiveTexture(GL_TEXTURE0 + storage->config.max_texture_image_units - 8);
	glBindTexture(GL_TEXTURE_2D, rt->color);
}

void RasterizerSceneGLES3::_render_mrts(""" % (MARK, MARK))

    s = once(s, """		if (storage->frame.current_rt && storage->frame.current_rt->buffers.active && state.used_depth_texture) {
			_prepare_depth_texture();
			framebuffer_dirty = true;
		}
""", """		if (storage->frame.current_rt && storage->frame.current_rt->buffers.active && state.used_depth_texture) {
			_prepare_depth_texture();
			framebuffer_dirty = true;
		}

		// %s: effect buffers off (NO_3D_EFFECTS): copies instead of nothing
		if (storage->frame.current_rt && !storage->frame.current_rt->buffers.active) {
			if (state.used_screen_texture) {
				_prepare_screen_texture_copy(current_fbo);
			}
			if (state.used_depth_texture) {
				_prepare_depth_texture_copy(current_fbo);
			}
		}
""" % MARK)
    p.write_text(s)
    print("patched:", p)
print("done")
