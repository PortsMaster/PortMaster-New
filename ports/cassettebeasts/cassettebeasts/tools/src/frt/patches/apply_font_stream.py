#!/usr/bin/env python3
"""Stream DynamicFont files from the pack instead of reading them into memory (port patch).
Godot 3 reads every DynamicFontData file completely into a Vector (capacity rounded up to a power of
two: an 8.5 MB CJK font takes 16 MB) for the whole session. Cassette Beasts loads its CJK fallback fonts
also in English: heaptrack counted 37 MB. With gui/fonts/stream_font_files=true FreeType reads the file
through a FileAccess (an FT_Stream per face) only where it needs glyph data.
usage: apply_font_stream.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'FONT-STREAM' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, old
    return s.replace(old, new)


def font_cpp(s):
    s = once(s, '''#include "core/os/file_access.h"
''', '''#include "core/os/file_access.h"
#include "core/project_settings.h"
''')
    s = once(s, '''Error DynamicFontAtSize::_load() {
	int error = FT_Init_FreeType(&library);

	ERR_FAIL_COND_V_MSG(error != 0, ERR_CANT_CREATE, "Error initializing FreeType.");

	if (font->font_mem == nullptr && font->font_path != String()) {''', '''// FONT-STREAM: FreeType reads the font file through a FileAccess (count 0 = seek only)
static unsigned long _font_stream_read(FT_Stream p_stream, unsigned long p_offset, unsigned char *p_buffer, unsigned long p_count) {
	FileAccess *f = (FileAccess *)p_stream->descriptor.pointer;
	if (!f) {
		return p_count ? 0 : 1;
	}
	if (f->get_position() != p_offset) {
		f->seek(p_offset);
	}
	if (p_count == 0) {
		return 0;
	}
	return (unsigned long)f->get_buffer(p_buffer, p_count);
}

static void _font_stream_close(FT_Stream p_stream) {
	FileAccess *f = (FileAccess *)p_stream->descriptor.pointer;
	if (f) {
		f->close();
		memdelete(f);
	}
	p_stream->descriptor.pointer = nullptr;
}

Error DynamicFontAtSize::_load() {
	int error = FT_Init_FreeType(&library);

	ERR_FAIL_COND_V_MSG(error != 0, ERR_CANT_CREATE, "Error initializing FreeType.");

	bool streamed = false;
	static int stream_fonts = -1; // FONT-STREAM
	if (stream_fonts < 0) {
		stream_fonts = ProjectSettings::get_singleton() && ProjectSettings::get_singleton()->has_setting("gui/fonts/stream_font_files") && bool(ProjectSettings::get_singleton()->get("gui/fonts/stream_font_files")) ? 1 : 0;
	}
	if (stream_fonts && font->font_mem == nullptr && font->font_path != String()) {
		FileAccess *f = FileAccess::open(font->font_path, FileAccess::READ);
		if (!f) {
			FT_Done_FreeType(library);
			ERR_FAIL_V_MSG(ERR_CANT_OPEN, "Cannot open font file '" + font->font_path + "'.");
		}
		memset(&stream, 0, sizeof(FT_StreamRec));
		stream.size = f->get_len();
		stream.pos = 0;
		stream.descriptor.pointer = f;
		stream.read = _font_stream_read;
		stream.close = _font_stream_close;

		FT_Open_Args fargs;
		memset(&fargs, 0, sizeof(FT_Open_Args));
		fargs.flags = FT_OPEN_STREAM;
		fargs.stream = &stream;
		error = FT_Open_Face(library, &fargs, 0, &face);
		if (error) {
			_font_stream_close(&stream); // no-op if FreeType closed it already
		} else {
			streamed = true;
		}
	} else if (font->font_mem == nullptr && font->font_path != String()) {''')
    # the memory path becomes an else-if branch of the stream path
    s = once(s, '''	if (font->font_mem) {
		memset(&stream, 0, sizeof(FT_StreamRec));
		stream.base = (unsigned char *)font->font_mem;''', '''	if (streamed) {
		// FONT-STREAM: opened above
	} else if (font->font_mem) {
		memset(&stream, 0, sizeof(FT_StreamRec));
		stream.base = (unsigned char *)font->font_mem;''')
    return s


edit('scene/resources/dynamic_font.cpp', font_cpp)
