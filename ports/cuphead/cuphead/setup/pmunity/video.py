"""Hidden/VideoDecodeAndroid for the Android player: the shader Unity's Android VideoPlayer draws
video frames with (libunity: ScriptMapper::FindShader("Hidden/VideoDecodeAndroid"), passes
RGBAExternal_To_RGBA and RGBASplitExternal_To_RGBA, found by name ignoring case; the same in
the 2017.4 - 2022.3 players). An Android build's unity_builtin_extra carries Unity's copy; a desktop
build's has only the desktop Hidden/VideoDecode, so without this the player logs "Could not find
material Hidden/VideoDecodeAndroid" and never shows a frame.

The programs are our own (video_decode_android.shader: GLSL ES 3.00, samplerExternalOES), written
for the runtime's SurfaceTexture (runtime/media/um_surface.c), whose external texture holds the
decoded YUV 4:2:0 picture: the conversion to RGB happens in the shader, with the coefficients
Unity's desktop players use for decoded video, so a clip looks as it does there.

The Shader object is built on the data's own Hidden/VideoDecode (its layout is that Unity
version's): name and passes replaced, the two passes made from its FLIP_RGBA_TO_RGBA and
FLIP_RGBASPLIT_TO_RGBA (vertex inputs, parameters _MainTex / _MainTex_ST / _AlphaParam and render
state as Unity's video passes have them), one GLES3 program each, no other platform. It goes into
unity_builtin_extra under a free path id, and globalgamemanagers' ScriptMapper gets its name.
"""
import copy
import os
import re

from .shaders import blob as B
from .shaders import convert as C

NAME = 'Hidden/VideoDecodeAndroid'
TEMPLATE = 'Hidden/VideoDecode'
# (pass of the new shader, desktop pass it is made from)
PASSES = (('RGBAExternal_To_RGBA', 'FLIP_RGBA_TO_RGBA'), ('RGBASplitExternal_To_RGBA', 'FLIP_RGBASPLIT_TO_RGBA'))
GLSL = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'video_decode_android.shader')
PREFERRED_PATH_ID = 16001       # next to Hidden/VideoDecode's 16000 (any free id works)


BT709_OFF = 'const bool UM_BT709 = false;'


def programs(bt709=False):
    """{pass name: GLSL program source (both stages, Unity's #ifdef VERTEX / FRAGMENT form)}, with
    the YCbCr conversion Unity's desktop players give VP8 / VP9 clips (bt709 False) or H.264 /
    HEVC ones (True)"""
    with open(GLSL, encoding='utf-8') as f:
        text = f.read()
    if text.count(BT709_OFF) != len(PASSES):
        raise ValueError(f'{GLSL}: expected one "{BT709_OFF}" per pass')
    if bt709:
        text = text.replace(BT709_OFF, 'const bool UM_BT709 = true;')
    out = {}
    for m in re.finditer(r'^//// pass (\S+)\n(.*?)(?=^//// pass |\Z)', text, re.S | re.M):
        out[m.group(1)] = m.group(2).strip() + '\n'
    missing = [p for p, _ in PASSES if p not in out]
    if missing:
        raise ValueError(f'{GLSL}: no program for {missing}')
    return out


def _pass_name(p):
    st = p.get('m_State') or {}
    return st.get('m_Name') or p.get('m_Name') or ''


def build(template_tree, bt709=False):
    """The Hidden/VideoDecodeAndroid Shader typetree made from a Hidden/VideoDecode one."""
    t = copy.deepcopy(template_tree)
    pf = t['m_ParsedForm']
    if pf['m_Name'] != TEMPLATE:
        raise ValueError(f'template is {pf["m_Name"]}, not {TEMPLATE}')
    # a Windows build's has GLES3 programs translated from Direct3D 11 (the shaders step) instead,
    # laid out as Unity's GL programs of that version
    plat, typ = next(((pl, ty) for pl, ty in ((B.PLATFORM_GLCORE, B.GPU_GLCORE32), (B.PLATFORM_GLES3PLUS, B.GPU_GLES3))
                      if pl in t['platforms']), (None, None))
    if plat is None:
        raise ValueError(f'{TEMPLATE} has no OpenGL Core (or translated GLES3) programs to take the layout from')
    progs = programs(bt709)
    blobs = B.ShaderBlobs(t)
    src = C.platform_entries(t, plat, blobs)
    ss = pf['m_SubShaders'][0]
    by_name = {_pass_name(p).upper(): p for p in ss['m_Passes']}
    new_passes, entries, remap = [], [], {}

    def take(i):
        """the new blob index of GLCore entry i (copied once)"""
        if i not in remap:
            e = src[i]
            e = e.copy() if e is not None else None
            if isinstance(e, B.Entry):
                e.gpu_type = B.GPU_GLES3
            remap[i] = len(entries)
            entries.append(e)
        return remap[i]

    for new, old in PASSES:
        p = by_name.get(old)
        if p is None:
            raise ValueError(f'{TEMPLATE} has no pass {old}')
        p = copy.deepcopy(p)
        p['m_State']['m_Name'] = new.upper()
        if 'm_Name' in p and isinstance(p['m_Name'], str) and p['m_Name']:
            p['m_Name'] = new.upper()
        code_entries = set()
        for st in C.STAGES:
            prog = p.get(st)
            if not prog:
                continue
            lists = []
            if prog.get('m_SubPrograms') is not None:
                lists.append((prog['m_SubPrograms'], None))
            players = prog.get('m_PlayerSubPrograms')
            if players:
                for tier, lst in enumerate(players):
                    lists.append((lst, prog['m_ParameterBlobIndices'][tier]))
            for lst, pbi in lists:
                keep = [k for k, sp in enumerate(lst) if sp['m_GpuProgramType'] == typ]
                subs = []
                for k in keep:
                    sp = copy.deepcopy(lst[k])
                    sp['m_GpuProgramType'] = B.GPU_GLES3
                    sp['m_BlobIndex'] = take(lst[k]['m_BlobIndex'])
                    if st == 'progVertex':
                        code_entries.add(sp['m_BlobIndex'])
                    subs.append(sp)
                if pbi is not None:
                    pbi[:] = [take(pbi[k]) if pbi[k] >= 0 else pbi[k] for k in keep]
                lst[:] = subs
        if not code_entries:
            raise ValueError(f'{TEMPLATE} pass {old}: no OpenGL Core 3.2 program')
        for i in code_entries:
            e = entries[i]
            if not isinstance(e, B.Entry):
                raise ValueError(f'{TEMPLATE} pass {old}: program entry {i} does not parse')
            e.code = progs[new].encode('utf-8')
            e.keywords = []
            if e.local_keywords is not None:
                e.local_keywords = []
        if isinstance(p.get('m_Platforms'), list):
            p['m_Platforms'] = [B.PLATFORM_GLES3PLUS]
        new_passes.append(p)
    ss['m_Passes'] = new_passes
    pf['m_SubShaders'] = [ss]
    pf['m_Name'] = NAME
    if isinstance(t.get('m_Name'), str) and t['m_Name']:
        t['m_Name'] = NAME
    for plat in list(blobs.platforms):
        blobs.remove(plat)
    blobs.set_entries(B.PLATFORM_GLES3PLUS, entries, [0] * len(entries), 1)
    blobs.store()
    return t


def add_to_builtin_extra(sf, log=print, bt709=False):
    """Adds Hidden/VideoDecodeAndroid to a loaded unity_builtin_extra (UnityPy SerializedFile) that
    has Hidden/VideoDecode. Returns the new path id, or None (no template, or already there)."""
    template = None
    for pid, o in sf.objects.items():
        if o.type.name != 'Shader':
            continue
        name = o.read_typetree()['m_ParsedForm']['m_Name']
        if name == NAME:
            return None
        if name == TEMPLATE:
            template = o
    if template is None:
        return None
    tree = build(template.read_typetree(), bt709)
    pid = PREFERRED_PATH_ID
    while pid in sf.objects:
        pid += 1
    new = copy.copy(template)
    new.path_id = pid
    new.data = None
    new.save_typetree(tree)
    sf.objects[pid] = new
    log(f'video: {NAME} added to unity_builtin_extra (path id {pid}, passes '
        f'{", ".join(p for p, _ in PASSES)}; {"BT.709 (H.264 / HEVC clips)" if bt709 else "BT.601 (VP8 / VP9 clips)"})')
    return pid


def map_shader(ggm_sf, path_id, notes):
    """globalgamemanagers: ScriptMapper name -> the shader in unity_builtin_extra."""
    fid = next((i + 1 for i, e in enumerate(ggm_sf.externals) if e.path.lower().endswith('unity_builtin_extra')), None)
    if fid is None:
        notes.append(f'video: globalgamemanagers does not reference unity_builtin_extra; {NAME} not mapped')
        return False
    for o in ggm_sf.objects.values():
        if o.type.name != 'ScriptMapper':
            continue
        t = o.read_typetree()
        m = t['m_Shaders']
        lst = m['m_ObjectToName'] if isinstance(m, dict) else m
        ptr = {'m_FileID': fid, 'm_PathID': path_id}
        have = [i for i, e in enumerate(lst) if e[1] == NAME]
        # a desktop build lists the name with a null pointer (the editor maps every built-in
        # shader name; the other platforms' ones point nowhere)
        if have and (lst[have[0]][0].get('m_FileID') or lst[have[0]][0].get('m_PathID')):
            return False
        if have:
            lst[have[0]] = type(lst[have[0]])((ptr, NAME))
        else:
            lst.append((ptr, NAME))
        o.save_typetree(t)
        notes.append(f'ScriptMapper: {NAME} -> unity_builtin_extra:{path_id}')
        return True
    notes.append(f'video: no ScriptMapper in globalgamemanagers; {NAME} not mapped')
    return False


def path_id_for(builtin_extra_path):
    """The path id add_to_builtin_extra gives the shader in that file (None: it adds none)."""
    import UnityPy
    sf = UnityPy.load(builtin_extra_path).file
    names = {}
    for pid, o in sf.objects.items():
        if o.type.name == 'Shader':
            names[o.read_typetree()['m_ParsedForm']['m_Name']] = pid
    if NAME in names or TEMPLATE not in names:
        return None
    pid = PREFERRED_PATH_ID
    while pid in sf.objects:
        pid += 1
    return pid


def has_template(path):
    """True if a unity_builtin_extra file has Hidden/VideoDecode (byte search: cheap)."""
    try:
        with open(path, 'rb') as f:
            return TEMPLATE.encode() in f.read()
    except OSError:
        return False


# ---------------------------------------------------------------- the game's clips

def sniff(path, offset, size):
    """The video codec of the clip at [offset, offset + size) of path: 'vp8', 'vp9', 'h264',
    'hevc', or the container ('webm', 'mp4') when the codec is not seen, or None."""
    try:
        with open(path, 'rb') as f:
            f.seek(offset)
            head = f.read(min(size, 1 << 16))
            tail = b''
            if size > 1 << 16:                          # an MP4's moov may be at the end
                f.seek(offset + max(size - (1 << 20), 1 << 16))
                tail = f.read(min(size - (1 << 16), 1 << 20))
    except OSError:
        return None
    if head[:4] == b'\x1a\x45\xdf\xa3':
        for tag, codec in ((b'V_VP8', 'vp8'), (b'V_VP9', 'vp9'), (b'V_MPEG4/ISO/AVC', 'h264'), (b'V_MPEGH/ISO/HEVC', 'hevc')):
            if tag in head:
                return codec
        return 'webm'
    if head[4:8] in (b'ftyp', b'moov', b'mdat', b'free', b'wide', b'skip'):
        for tag, codec in ((b'avc1', 'h264'), (b'avc3', 'h264'), (b'hvc1', 'hevc'), (b'hev1', 'hevc')):
            if tag in head or tag in tail:
                return codec
        return 'mp4'
    return None


def clip_codecs(data_dir):
    """{codec: count} of the VideoClips in a game's data folder (their data in *.resource files)."""
    import UnityPy
    out = {}
    for n in sorted(os.listdir(data_dir)):
        if not (n.endswith('.assets') or re.match(r'^level\d+$', n)):
            continue
        try:
            env = UnityPy.load(os.path.join(data_dir, n))
        except Exception:
            continue
        for o in env.objects:
            if o.type.name != 'VideoClip':
                continue
            er = o.read_typetree().get('m_ExternalResources') or {}
            src = (er.get('m_Source') or '').split('/')[-1]
            codec = sniff(os.path.join(data_dir, src), er.get('m_Offset', 0), er.get('m_Size', 0)) if src else None
            out[codec or 'unknown'] = out.get(codec or 'unknown', 0) + 1
    return out


def wants_bt709(data_dir, log=print):
    """True when the game's clips are H.264 / HEVC (macOS / Windows builds): Unity's desktop players
    convert those with BT.709; VP8 / VP9 (Linux builds) with Unity's own BT.601 constants."""
    codecs = clip_codecs(data_dir)
    hd = codecs.get('h264', 0) + codecs.get('hevc', 0)
    sw = codecs.get('vp8', 0) + codecs.get('vp9', 0)
    if codecs:
        log(f'video: clips {codecs}: {"BT.709" if hd > sw else "BT.601"} conversion'
            + (' (clips of both kinds: the more common one; the others are converted with it too)' if hd and sw else ''))
    return hd > sw
