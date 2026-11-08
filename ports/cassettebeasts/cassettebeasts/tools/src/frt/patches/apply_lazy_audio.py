#!/usr/bin/env python3
"""Lazy Ogg Vorbis data (port patch): with audio/lazy_ogg_streams=true the binary resource loader does
not keep the compressed data of AudioStreamOGGVorbis resources in RAM; the stream reads it from the
resource file when a playback starts and frees it when the last playback ends. Games that preload
their whole soundtrack then hold only the tracks that are playing.
usage: apply_lazy_audio.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'LAZY-AUDIO' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:60], s.count(old))
    return s.replace(old, new)


def loader(s):
    s = once(s, '''		Variant value;

		error = parse_variant(value);
		if (error) {
			return error;
		}

		res->set(name, value);''', '''		// LAZY-AUDIO: leave Ogg Vorbis data in the file, the stream reads it when it plays
		static const bool lazy_ogg = GLOBAL_DEF("audio/lazy_ogg_streams", false);
		if (lazy_ogg && name == "data" && res->is_class("AudioStreamOGGVorbis")) {
			uint64_t pos = f->get_position();
			if (f->get_32() == VARIANT_RAW_ARRAY) {
				uint32_t len = f->get_32();
				uint64_t ofs = f->get_position();
				f->seek(ofs + len);
				_advance_padding(len);
				res->call("_set_lazy_source", file_path, ofs, len);
				continue;
			}
			f->seek(pos);
		}

		Variant value;

		error = parse_variant(value);
		if (error) {
			return error;
		}

		res->set(name, value);''')
    s = once(s, '''	ria->res_path = ria->local_path;
	//ria->set_local_path( Globals::get_singleton()->localize_path(p_path) );
	ria->open(f);

	return ria;''', '''	ria->res_path = ria->local_path;
	ria->file_path = p_path; // LAZY-AUDIO
	//ria->set_local_path( Globals::get_singleton()->localize_path(p_path) );
	ria->open(f);

	return ria;''')
    if '#include "core/project_settings.h"' not in s:
        s = once(s, '#include "resource_format_binary.h"\n', '#include "resource_format_binary.h"\n#include "core/project_settings.h"\n')
    return s


def loader_h(s):
    return once(s, '''	String res_path;
	String type;''', '''	String res_path;
	String file_path; // LAZY-AUDIO: the file actually opened (the .oggstr behind an import remap)
	String type;''')


def ogg_h(s):
    s = once(s, '#include "core/io/resource_loader.h"\n', '#include "core/io/resource_loader.h"\n#include "core/os/mutex.h"\n')
    s = once(s, '''	void clear_data();
''', '''	void clear_data();

	// LAZY-AUDIO: data left in the resource file (audio/lazy_ogg_streams)
	String lazy_path;
	uint64_t lazy_offset = 0;
	uint32_t lazy_len = 0;
	int lazy_users = 0;
	Mutex lazy_mutex;
	bool _lazy_acquire();
	void _set_lazy_source(const String &p_path, uint64_t p_offset, uint32_t p_len);

public:
	void _lazy_release();

private:
''')
    return s


def ogg_cpp(s):
    s = once(s, '''AudioStreamPlaybackOGGVorbis::~AudioStreamPlaybackOGGVorbis() {''', '''AudioStreamPlaybackOGGVorbis::~AudioStreamPlaybackOGGVorbis() {
	struct LazyRelease { // LAZY-AUDIO: after the decoder below is closed
		Ref<AudioStreamOGGVorbis> s;
		~LazyRelease() {
			if (s.is_valid()) {
				s->_lazy_release();
			}
		}
	} lazy_release;
	lazy_release.s = vorbis_stream;''')
    s = once(s, '''Ref<AudioStreamPlayback> AudioStreamOGGVorbis::instance_playback() {
''', '''// LAZY-AUDIO
void AudioStreamOGGVorbis::_set_lazy_source(const String &p_path, uint64_t p_offset, uint32_t p_len) {
	FileAccessRef f = FileAccess::open(p_path, FileAccess::READ);
	ERR_FAIL_COND_MSG(!f, "Cannot open " + p_path);
	PoolVector<uint8_t> tmp;
	tmp.resize(p_len);
	{
		PoolVector<uint8_t>::Write w = tmp.write();
		f->seek(p_offset);
		ERR_FAIL_COND(f->get_buffer(w.ptr(), p_len) != p_len);
	}
	set_data(tmp); // length, decode_mem_size
	clear_data();
	lazy_path = p_path;
	lazy_offset = p_offset;
	lazy_len = p_len;
}

bool AudioStreamOGGVorbis::_lazy_acquire() {
	MutexLock lock(lazy_mutex);
	if (lazy_path.empty()) {
		return data != nullptr;
	}
	if (!data) {
		FileAccessRef f = FileAccess::open(lazy_path, FileAccess::READ);
		ERR_FAIL_COND_V_MSG(!f, false, "Cannot open " + lazy_path);
		uint8_t *buf = (uint8_t *)memalloc(lazy_len);
		f->seek(lazy_offset);
		bool ok = f->get_buffer(buf, lazy_len) == lazy_len;
		if (ok) {
			data = AudioServer::get_singleton()->audio_data_alloc(lazy_len, buf);
			data_len = lazy_len;
		}
		memfree(buf);
		ERR_FAIL_COND_V(!ok, false);
	}
	lazy_users++;
	return true;
}

void AudioStreamOGGVorbis::_lazy_release() {
	MutexLock lock(lazy_mutex);
	if (lazy_path.empty() || lazy_users <= 0) {
		return;
	}
	if (--lazy_users == 0) {
		clear_data();
	}
}

Ref<AudioStreamPlayback> AudioStreamOGGVorbis::instance_playback() {
	_lazy_acquire(); // LAZY-AUDIO
''')
    s = once(s, '''	ClassDB::bind_method(D_METHOD("set_data", "data"), &AudioStreamOGGVorbis::set_data);''',
             '''	ClassDB::bind_method(D_METHOD("set_data", "data"), &AudioStreamOGGVorbis::set_data);
	ClassDB::bind_method(D_METHOD("_set_lazy_source", "path", "offset", "length"), &AudioStreamOGGVorbis::_set_lazy_source); // LAZY-AUDIO''')
    if '#include "core/os/file_access.h"' not in s:
        s = once(s, '#include "audio_stream_ogg_vorbis.h"\n', '#include "audio_stream_ogg_vorbis.h"\n#include "core/os/file_access.h"\n')
    return s


edit('core/io/resource_format_binary.h', loader_h)
edit('core/io/resource_format_binary.cpp', loader)
edit('modules/stb_vorbis/audio_stream_ogg_vorbis.h', ogg_h)
edit('modules/stb_vorbis/audio_stream_ogg_vorbis.cpp', ogg_cpp)
