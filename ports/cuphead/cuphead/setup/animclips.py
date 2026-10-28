"""animclips.txt for the port helper's off-screen animator culling (CUPHEAD_ANIMCULL, helper/
Tuning.cs): for every animation clip of the game, what it animates, read from the game's own files.

One line per clip name: <name> TAB <flag> TAB <comma-separated path hashes of the transforms it animates>
  S  only SpriteRenderer curves and no animation events (may be stopped entirely while off screen)
  H  only SpriteRenderer and Transform curves (may go unevaluated off screen if no animated transform
     carries a collider; the helper checks that against the object's hierarchy)
  -  anything else (collider sizes, objects switched on and off, script fields, ...): left alone
In a player build a clip keeps its curves as m_MuscleClip plus m_ClipBindingConstant.genericBindings,
one binding per animated property: typeID 4 = Transform, 212 = SpriteRenderer; path = CRC-32 of the
transform's path below the animator. A name used by several clips gets the most restrictive flag.
"""
import re
from pmunity.unity_io import Loaded

STEP = 'animclips'
OUT = 'animclips.txt'
FILES = re.compile(r'(sharedassets\d+|resources)\.assets$')     # where Cuphead keeps all its clips
RANK = {'S': 0, 'H': 1, '-': 2}


def run(job):
    if job.is_done(STEP, OUT):
        return
    clips = {}                                                  # name -> [flag, set of path hashes]
    n = 0
    for rel in job.list('', lambda name: bool(FILES.match(name))):
        lf = Loaded(job.path_in(rel))
        for _, o in lf.objects('AnimationClip'):
            t = o.read_typetree()
            binds = (t.get('m_ClipBindingConstant') or {}).get('genericBindings') or []
            types = {b.get('typeID') for b in binds}
            events = len(t.get('m_Events') or [])
            flag = 'S' if events == 0 and types <= {212} else 'H' if types <= {212, 4} else '-'
            paths = {int(b.get('path', 0)) for b in binds if b.get('typeID') == 4}
            c = clips.setdefault(t.get('m_Name', ''), [flag, set()])
            if RANK[flag] > RANK[c[0]]:
                c[0] = flag
            c[1] |= paths
            n += 1
        lf.close()
    lines = [f'{name}\t{f}\t{",".join(str(p) for p in sorted(ps))}' for name, (f, ps) in sorted(clips.items()) if name]
    job.write(OUT, ('\n'.join(lines) + '\n').encode('utf-8'))
    job.mark_done(STEP, OUT)
    counts = {k: sum(1 for f, _ in clips.values() if f == k) for k in 'SH-'}
    job.log(f'animclips: {n} clips, {len(lines)} names (S {counts["S"]}, H {counts["H"]}, other {counts["-"]})')


STEPS = {STEP: run}         # a pmunity convert plugin (--plugin convert/animclips.py)
