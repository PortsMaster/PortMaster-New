"""Conversion step `audio`: the game's DecompressOnLoad clips kept where their PCM fits (cfg['audio']).

Unity decodes a clip marked DecompressOnLoad to 16-bit PCM when the clip loads and keeps that PCM
for as long as the clip is loaded; a CompressedInMemory clip keeps its Vorbis data instead, and
FMOD's mixer decodes it every time it plays, on the handheld's CPU, whose busy time a warm handheld
takes from the GPU's clock (docs/profiling.md: in Hollow Knight's King's Pass the loops the old
rule below had switched cost the mixer 8 points of a core). The sound is the same either way: the
same Vorbis data, decoded by the same decoder, once or while it plays. So the game's own choice is
kept, except where its PCM would not fit a 1 GB handheld: a long Vorbis clip marked
DecompressOnLoad is switched to CompressedInMemory only to keep a scene's PCM within the port's
budget, the scene's own clips before the resident ones (below), the largest first (a loop of a few
seconds that plays all the time costs the mixer as much as a song of minutes, for a fraction of its
memory).

What a scene keeps loaded: the clips of its own shared assets file (sharedassets<n>.assets: the
assets the build put there are the ones scene n uses) and every clip its PreloadData lists (the
assets it uses from other files: resources.assets, earlier scenes' shared assets). The first
`resident_scenes` scenes of the build (the start scene and the title, where games create the
objects they keep from scene to scene: Hollow Knight's atmosphere loops) count as loaded in every
scene. Clips that no scene uses (loaded by scripts: Resources.Load) keep the length rule.

  pcm_budget_mb      the PCM of the DecompressOnLoad clips a scene keeps loaded, at most (MiB; all
                     formats count). Only the length rule's clips are switched, so a scene whose
                     short clips alone pass the budget keeps the length rule. None: the length rule
                     for every clip (the step until 2026-10-24, written for Cuphead's Devil fight:
                     53 MiB of PCM in what its scene loads with every clip as the game has it)
  compressed_min_s   the length rule: a DecompressOnLoad Vorbis clip of at least this many seconds
                     may be kept compressed in memory (with no budget: is)
  resident_scenes    the first scenes counted as loaded in every scene
"""
from .unity_io import Loaded, collect

DEFAULTS = {'pcm_budget_mb': 16, 'compressed_min_s': 2.0, 'resident_scenes': 2}
DECOMPRESS_ON_LOAD, COMPRESSED_IN_MEMORY = 0, 1
VORBIS = 1


class Clip:
    __slots__ = ('name', 'load', 'fmt', 'length', 'rate', 'channels')

    def __init__(self, name, load, fmt, length, rate, channels):
        self.name, self.load, self.fmt = name, load, fmt
        self.length, self.rate, self.channels = length, rate, channels

    @property
    def pcm(self):
        """Bytes of the 16-bit PCM Unity decodes it to."""
        return int(round(self.length * self.rate)) * self.channels * 2


def scene_of(rel):
    """sharedassets<n>.assets -> n (scene n's own assets and its PreloadData), else None."""
    n = rel[len('sharedassets'):-len('.assets')] if rel.startswith('sharedassets') and rel.endswith('.assets') else ''
    return int(n) if n.isdigit() else None


def plan(clips, scenes, budget, min_s, resident=2):
    """Which clips to keep compressed in memory.

    clips: {key: Clip}; scenes: {scene index: set of the keys it keeps loaded}; budget: bytes of PCM
    a scene may hold, None for the length rule alone; resident: how many of the first scenes count
    as loaded in every scene. Only the length rule's clips (DecompressOnLoad Vorbis of min_s seconds
    or more) are ever switched, so the budget can only keep more of the game's own choice than the
    length rule does. A scene over the budget switches its own clips first, the largest first, then
    the resident ones (they are loaded, and switched, everywhere), the largest first.
    Returns (set of keys to switch, {scene: bytes of PCM it holds})."""
    def switchable(k):
        c = clips[k]
        return c.load == DECOMPRESS_ON_LOAD and c.fmt == VORBIS and c.length >= min_s
    used = set().union(*scenes.values()) if scenes else set()
    switch = {k for k in clips if switchable(k) and (budget is None or k not in used)}
    if budget is None:
        return switch, {}
    base = set().union(*(s for i, s in scenes.items() if i < resident))
    left = {}
    for i in sorted(scenes):
        held = [k for k in scenes[i] | base if clips[k].load == DECOMPRESS_ON_LOAD and k not in switch]
        total = sum(clips[k].pcm for k in held)
        order = sorted((k for k in held if switchable(k)), key=lambda k: (i >= resident and k in base, -clips[k].pcm, k))
        for k in order:
            if total <= budget:
                break
            switch.add(k)
            total -= clips[k].pcm
        left[i] = total
    return switch, left


def read(lf, rel):
    """(clips {pid: Clip}, the PreloadData's clip references [(file, pid)]) of one loaded file."""
    import os
    clips, refs = {}, []
    ext = [os.path.basename(e.path) for e in lf.sf.externals]
    for pid, o in lf.objects():
        t = o.type.name
        if t == 'AudioClip':
            tt = o.read_typetree()
            clips[pid] = Clip(tt['m_Name'], tt['m_LoadType'], tt['m_CompressionFormat'], tt['m_Length'],
                              tt['m_Frequency'], tt['m_Channels'])
        elif t == 'PreloadData':
            for p in o.read_typetree().get('m_Assets', ()):
                fid = p['m_FileID']
                if 0 <= fid <= len(ext):
                    refs.append((rel if fid == 0 else ext[fid - 1], p['m_PathID']))
    return clips, refs


def _survey(job, files):
    clips, scenes, refs = {}, {}, {}
    for rel in files:
        lf = Loaded(job.path_in(rel))
        c, r = read(lf, rel)
        lf.close()
        collect()
        clips.update(((rel, pid), x) for pid, x in c.items())
        n = scene_of(rel)
        if n is not None:
            scenes[n] = {(rel, pid) for pid in c}
            refs[n] = r
    for n, r in refs.items():
        scenes[n] |= {k for k in r if k in clips}
    return clips, scenes


def run(job):
    c = dict(DEFAULTS, **job.cfg.get('audio', {}))
    cfg = {k: c[k] for k in DEFAULTS}
    files = job.list('', lambda n: n.endswith('.assets'))
    st = job.state.get('audio')
    if st is None:
        # the decision needs every file's clips: made once, before any file is written (an in-place
        # setup that is stopped and started again goes on with the same list)
        clips, scenes = _survey(job, files)
        budget = None if c['pcm_budget_mb'] is None else int(c['pcm_budget_mb'] * 2 ** 20)
        switch, left = plan(clips, scenes, budget, c['compressed_min_s'], c['resident_scenes'])
        kept = [k for k, x in clips.items() if x.load == DECOMPRESS_ON_LOAD and x.fmt == VORBIS and k not in switch]
        by_file = {}
        for rel, pid in switch:
            by_file.setdefault(rel, []).append(pid)
        top = max(left.items(), key=lambda kv: kv[1]) if left else None
        mib = lambda ks: sum(clips[k].pcm for k in ks) / 2 ** 20  # noqa: E731
        st = {'cfg': cfg, 'switch': {rel: sorted(p) for rel, p in by_file.items()},
              'summary': (f'{len(switch)} clips kept compressed in memory ({mib(switch):.1f} MiB of PCM), '
                          f'{len(kept)} decompressed on load as the game has them ({mib(kept):.1f} MiB); ' +
                          (f'budget {c["pcm_budget_mb"]:g} MiB a scene, the most a scene holds '
                           f'{top[1] / 2**20:.1f} MiB (scene {top[0]})' if top else
                           f'every clip of {c["compressed_min_s"]:g} s or longer'))}
        job.state['audio'] = st
        job.save_state()
    elif st.get('cfg') != cfg:
        job.log(f'audio: the clips were chosen with {st.get("cfg")} before; kept (files may be converted already)')
    for rel in files:
        pids = set(st['switch'].get(rel, ()))
        if not pids or job.is_done('audio', rel):
            continue
        lf = Loaded(job.path_in(rel))
        for pid, o in lf.objects('AudioClip'):
            if pid in pids:
                t = o.read_typetree()
                if t['m_LoadType'] == DECOMPRESS_ON_LOAD:
                    t['m_LoadType'] = COMPRESSED_IN_MEMORY
                    o.save_typetree(t)
        job.write(rel, lf.save())
        lf.close()
        collect()
        job.mark_done('audio', rel)
    job.log('audio: ' + st['summary'])
