/*************************************************************************/
/*  lazy_texture.h                                                       */
/*************************************************************************/
/* Lazy texture upload (port patch, not upstream Godot).                 */
/*                                                                       */
/* With rendering/lazy_textures/enabled, StreamTexture::load() reads only */
/* the file header and registers the file with the renderer instead of   */
/* decoding and uploading it. The GLES3 renderer decodes and uploads a   */
/* texture the first time it is bound for drawing, and frees the GPU     */
/* copy of textures not drawn for rendering/lazy_textures/               */
/* evict_after_seconds (0 = never). Games that preload far more textures */
/* than they draw then need GPU memory only for what is on screen.       */
/*************************************************************************/

#ifndef LAZY_TEXTURE_H
#define LAZY_TEXTURE_H

#include "core/image.h"
#include "core/rid.h"
#include "core/ustring.h"

struct LazyTexture {
	// Set by a renderer that supports lazy upload (GLES3), when enabled.
	static void (*set_source)(RID p_texture, const String &p_path, int p_custom_width, int p_custom_height);
	// Set by StreamTexture: decode the .stex file at p_path into r_image.
	static Error (*load)(const String &p_path, Ref<Image> &r_image);
};

#endif // LAZY_TEXTURE_H
