/*************************************************************************/
/*  lazy_texture.cpp                                                     */
/*************************************************************************/
/* Lazy texture upload (port patch, not upstream Godot): see the header. */
/*************************************************************************/

#include "lazy_texture.h"

void (*LazyTexture::set_source)(RID p_texture, const String &p_path, int p_custom_width, int p_custom_height) = nullptr;
Error (*LazyTexture::load)(const String &p_path, Ref<Image> &r_image) = nullptr;
