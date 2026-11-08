#!/usr/bin/env python3
"""Lazy AudioStreamSample data (port patch, needs apply_lazy_audio.py first): with audio/lazy_samples=true
the binary resource loader leaves sample data in the .sample file; the stream reads it when a playback is
created and keeps it in an LRU cache of audio/lazy_samples_budget_mb (16); samples without active
playbacks are evicted first. Games that preload hundreds of sound effects then hold only recent ones.
usage: apply_lazy_samples.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'LAZY-SAMPLES' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def loader(s):
    # extend the LAZY-AUDIO hook (apply_lazy_audio.py) to AudioStreamSample
    return once(s, '''		static const bool lazy_ogg = GLOBAL_DEF("audio/lazy_ogg_streams", false);
		if (lazy_ogg && name == "data" && res->is_class("AudioStreamOGGVorbis")) {''', '''		static const bool lazy_ogg = GLOBAL_DEF("audio/lazy_ogg_streams", false);
		static const bool lazy_samples = GLOBAL_DEF("audio/lazy_samples", false); // LAZY-SAMPLES
		if (name == "data" && ((lazy_ogg && res->is_class("AudioStreamOGGVorbis")) || (lazy_samples && res->is_class("AudioStreamSample")))) {''')


def sample_h(s):
    s = once(s, '''	virtual void mix(AudioFrame *p_buffer, float p_rate_scale, int p_frames);

	AudioStreamPlaybackSample();
};''', '''	virtual void mix(AudioFrame *p_buffer, float p_rate_scale, int p_frames);

	AudioStreamPlaybackSample();
	~AudioStreamPlaybackSample(); // LAZY-SAMPLES
};''')
    s = once(s, '''	void *data;
	uint32_t data_bytes;

protected:''', '''	void *data;
	uint32_t data_bytes;

	// LAZY-SAMPLES: data left in the resource file, loaded into a shared LRU cache when played
	String lazy_path;
	uint64_t lazy_offset = 0;
	int lazy_users = 0;
	uint64_t lazy_used = 0; // ticks of the last acquire (LRU)
	bool lazy_cached = false;
	void _set_lazy_source(const String &p_path, uint64_t p_offset, uint32_t p_len);
	bool _lazy_acquire();
	void _lazy_drop(); // lazy mutex held

public:
	void _lazy_release();

protected:''')
    return s


FUNCS = '''
// LAZY-SAMPLES
static Mutex lazy_sample_mutex;
static List<AudioStreamSample *> lazy_sample_cache;
static uint64_t lazy_sample_bytes = 0;
static uint64_t lazy_sample_ticks = 0;

void AudioStreamSample::_set_lazy_source(const String &p_path, uint64_t p_offset, uint32_t p_len) {
	MutexLock lock(lazy_sample_mutex);
	_lazy_drop();
	if (data) {
		AudioServer::get_singleton()->audio_data_free(data);
		data = nullptr;
	}
	lazy_path = p_path;
	lazy_offset = p_offset;
	data_bytes = p_len; // length is known without the data (get_length)
}

void AudioStreamSample::_lazy_drop() {
	if (lazy_cached) {
		lazy_sample_cache.erase(this);
		lazy_sample_bytes -= data_bytes;
		lazy_cached = false;
		if (data) {
			AudioServer::get_singleton()->audio_data_free(data);
			data = nullptr;
		}
	}
}

bool AudioStreamSample::_lazy_acquire() {
	MutexLock lock(lazy_sample_mutex);
	if (lazy_path.empty()) {
		return data != nullptr;
	}
	if (!data) {
		FileAccessRef f = FileAccess::open(lazy_path, FileAccess::READ);
		ERR_FAIL_COND_V_MSG(!f, false, "Cannot open " + lazy_path);
		int alloc_len = data_bytes + DATA_PAD * 2;
		uint8_t *buf = (uint8_t *)AudioServer::get_singleton()->audio_data_alloc(alloc_len);
		memset(buf, 0, alloc_len);
		f->seek(lazy_offset);
		if (f->get_buffer(buf + DATA_PAD, data_bytes) != data_bytes) {
			AudioServer::get_singleton()->audio_data_free(buf);
			ERR_FAIL_V_MSG(false, "Short read in " + lazy_path);
		}
		data = buf;
		lazy_sample_cache.push_back(this);
		lazy_sample_bytes += data_bytes;
		lazy_cached = true;
		// evict least recently used samples that are not playing
		static const uint64_t budget = uint64_t(MAX(1, int(GLOBAL_DEF("audio/lazy_samples_budget_mb", 16)))) << 20;
		List<AudioStreamSample *>::Element *E = lazy_sample_cache.front();
		while (lazy_sample_bytes > budget && E) {
			List<AudioStreamSample *>::Element *N = E->next();
			AudioStreamSample *s = E->get();
			if (s != this && s->lazy_users == 0) {
				s->_lazy_drop();
			}
			E = N;
		}
	} else if (lazy_cached) {
		lazy_sample_cache.move_to_back(lazy_sample_cache.find(this));
	}
	lazy_users++;
	lazy_used = ++lazy_sample_ticks;
	return true;
}

void AudioStreamSample::_lazy_release() {
	MutexLock lock(lazy_sample_mutex);
	if (!lazy_path.empty() && lazy_users > 0) {
		lazy_users--; // data stays cached until evicted
	}
}

AudioStreamPlaybackSample::~AudioStreamPlaybackSample() {
	if (base.is_valid()) {
		base->_lazy_release();
	}
}

Ref<AudioStreamPlayback> AudioStreamSample::instance_playback() {
	_lazy_acquire(); // LAZY-SAMPLES'''


def sample_cpp(s):
    s = once(s, '''
Ref<AudioStreamPlayback> AudioStreamSample::instance_playback() {''', FUNCS)
    # get_data on a lazy sample (scripts): load it for the copy
    s = once(s, '''PoolVector<uint8_t> AudioStreamSample::get_data() const {
	PoolVector<uint8_t> pv;
''', '''PoolVector<uint8_t> AudioStreamSample::get_data() const {
	PoolVector<uint8_t> pv;
	AudioStreamSample *self = const_cast<AudioStreamSample *>(this); // LAZY-SAMPLES
	bool lazy = !lazy_path.empty();
	if (lazy) {
		self->_lazy_acquire();
	}
''')
    s = once(s, '''			memcpy(w.ptr(), dataptr + DATA_PAD, data_bytes);
		}
	}
''', '''			memcpy(w.ptr(), dataptr + DATA_PAD, data_bytes);
		}
	}
	if (lazy) {
		self->_lazy_release();
	}
''')
    s = once(s, '''AudioStreamSample::~AudioStreamSample() {
''', '''AudioStreamSample::~AudioStreamSample() {
	{
		MutexLock lock(lazy_sample_mutex); // LAZY-SAMPLES
		_lazy_drop();
	}
''')
    s = once(s, '''	ClassDB::bind_method(D_METHOD("set_data", "data"), &AudioStreamSample::set_data);''',
             '''	ClassDB::bind_method(D_METHOD("set_data", "data"), &AudioStreamSample::set_data);
	ClassDB::bind_method(D_METHOD("_set_lazy_source", "path", "offset", "length"), &AudioStreamSample::_set_lazy_source); // LAZY-SAMPLES''')
    for inc in ('#include "core/os/mutex.h"\n', '#include "core/project_settings.h"\n', '#include "servers/audio_server.h"\n'):
        if inc not in s:
            s = once(s, '#include "core/os/file_access.h"\n', '#include "core/os/file_access.h"\n' + inc)
    return s


edit('core/io/resource_format_binary.cpp', loader)
edit('scene/resources/audio_stream_sample.h', sample_h)
edit('scene/resources/audio_stream_sample.cpp', sample_cpp)
