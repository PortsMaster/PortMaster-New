#ifdef TFE_CLIP_DISCARD_FALLBACK
in float v_TfeClipDistance[8];
#define TFE_APPLY_CLIP_DISCARD() \
	for (int tfeClip_i = 0; tfeClip_i < 8; tfeClip_i++) { \
		if (v_TfeClipDistance[tfeClip_i] < 0.0) { discard; } \
	}
#else
#define TFE_APPLY_CLIP_DISCARD()
#endif
