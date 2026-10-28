"""Unity 2023.1+ (Unity 6 included) for `pmunity il2cpp`: a "mixed" IL2CPP build.

From 2023.1 Unity's il2cpp is a NativeAOT program for the editor's own system (the Windows
installer's `il2cpp.exe` is Windows x86-64 code, the macOS one Mach-O, the Linux one x86-64 ELF):
neither the container's .NET nor a handheld's can run it, and no editor exists for Linux on ARM.
The other tools next to it are still .NET programs (UnityLinker.dll, il2cpp-compile.dll, Bee).

The way here: the managed il2cpp of a Unity 2022.3 release (CONVERTERS: the line's last for
metadata 31, Unity 6; one writing metadata 29 for 2023.1 - 2023.2; il2cpp.dll with its Bee build
program) converts the game's assemblies to C++ and writes global-metadata.dat,
and everything the result runs with is the data version's own: its UnityLinker (linked against its
class libraries), the class libraries (`unityaot-linux`), the IL2CPP UnityEngine assemblies of its
player, and the libil2cpp sources the C++ is compiled with, so libil2cpp.so is the runtime its
player's libunity.so was built against. il2cpp finds libil2cpp, the icall list it emits direct calls
from (`libil2cpp/libil2cpp.icalls`) and the sources it compiles next to itself (`il2cpp_root`), so
the build runs from a folder that is the data version's `Editor/Data/il2cpp` with the converter's
`build/` in it:

  <home>/<conv>/converter/il2cpp/build       the converter's il2cpp/build (il2cpp.dll, Bee, ...)
  <home>/<conv>/converter/il2cpp/libil2cpp   its libil2cpp, only read: compared with the data's
  <home>/<ver>/mix-<conv>/il2cpp/            the data version's il2cpp/ (hard links where the file
                                             system has them, else copies) + the converter's build/

What has to agree, checked before anything runs (compat), else the build stops with the
differences: the metadata version libil2cpp reads (`version == N` in vm/GlobalMetadata.cpp) and
the layout of every table of global-metadata.dat (vm/GlobalMetadataFileInternals.h), and the
structures the generated C++ fills in itself (code and metadata registration, codegen modules,
Il2CppType, generic instances and classes, RGCTX definitions, type sizes, interop data: EMITTED).
Unity 2022.3.62f3 and 6000.0 agree on all of them (metadata 31). The functions the generated C++
calls (codegen/il2cpp-codegen.h) are the same up to 2022.3's Tiny-only ones; a name the C++ calls
that the data's libil2cpp lacks would stop the compile with its name.

The C++ build uses the converter's Bee build program (2022.3's compiler flags for libil2cpp, NDK
r23b, the API levels of 2022.3; Unity 6000.0's Android builds use the same NDK) and the data
version's baselib.a.
"""
import json
import os
import re
import shutil

from . import il2cpp_bee as BEE
from . import unity_version as UV

NATIVE_FROM = (2023, 1)          # the first line whose il2cpp is a native program
# the .NET il2cpp that converts, by the global-metadata.dat version the data's libil2cpp reads:
# 2022.3's last release (31, as Unity 6000.0 - 6000.1), a 2022.3 release of metadata 29 (as
# 2023.1 - 2023.2; 2022.3 moved from 29 to 31 between 2022.3.23f1 and 2022.3.36f1)
CONVERTERS = {31: '2022.3.62f3', 29: '2022.3.23f1'}
RECIPE = 1                       # (a mixed folder made by another recipe is made again)

# the structures the generated C++ initializes itself (Il2CppCodeRegistration.cpp,
# Il2CppMetadataRegistration.c, <assembly>_CodeGen.c, Il2CppTypeDefinitions.c, ...) and the
# enums their initializers use: their layouts must be the same in both libil2cpps
EMITTED = (
    'Il2CppCodeRegistration', 'Il2CppMetadataRegistration', 'Il2CppCodeGenModule', 'Il2CppCodeGenOptions',
    'Il2CppTokenRangePair', 'Il2CppRange', 'Il2CppTokenIndexMethodTuple', 'Il2CppTokenAdjustorThunkPair',
    'Il2CppRGCTXDefinition', 'Il2CppRGCTXDefinitionData', 'Il2CppRGCTXConstrainedData', 'Il2CppRGCTXDataType',
    'Il2CppMethodSpec', 'Il2CppGenericMethodFunctionsDefinitions', 'Il2CppGenericMethodIndices',
    'Il2CppGenericInst', 'Il2CppGenericClass', 'Il2CppGenericContext', 'Il2CppType', 'Il2CppArrayType',
    'Il2CppTypeEnum', 'Il2CppTypeDefinitionSizes', 'Il2CppInteropData', 'Il2CppWindowsRuntimeFactoryTableEntry',
)
HEADERS = ('il2cpp-class-internals.h', 'il2cpp-runtime-metadata.h', 'il2cpp-metadata.h', 'il2cpp-blob.h',
           'il2cpp-pinvoke-support.h')
METADATA_HEADER = 'vm/GlobalMetadataFileInternals.h'


# the lines whose libil2cpp agrees with a converter (compat, checked on each line's Windows editor
# installer: 2023.1.8f1, 2023.2.20f1, 6000.0.58f2, 6000.0.61f1, 6000.1.4f1, 6000.2.6f2); later
# ones read another metadata format (6000.3 - 6000.4: version 39, a new header and string literal,
# type and assembly tables; 6000.5: 107, 6000.6: 108, with code registration structures changed
# too), which no .NET il2cpp writes
LINES = ((2023, 1), (2023, 2), (6000, 0), (6000, 1), (6000, 2))
LATER_METADATA = {(6000, 3): 39, (6000, 4): 39, (6000, 5): 107, (6000, 6): 108}


def refusal(version):
    """Why a Unity 2023.1+ version cannot be built mixed (before anything is fetched), or None. The
    build itself checks the fetched sources (prepare)."""
    if not needed(version) or version.line in LINES:
        return None
    mv = LATER_METADATA.get(version.line)
    what = (f'its libil2cpp reads global-metadata.dat version {mv}, which no .NET il2cpp (Unity 2022.3) writes'
            if mv else 'its libil2cpp has not been compared with 2022.3\'s il2cpp yet')
    return (f'Unity {version}: its il2cpp is a native program, and {what}; the IL2CPP route covers '
            f'2017.4 - 2022.3, and 2023.1 - 6000.2 with 2022.3\'s il2cpp (docs/il2cpp.md)')


def needed(version):
    """Whether this Unity version's il2cpp is a native program (2023.1+): its build is mixed."""
    return version.line >= NATIVE_FROM


def _code(text):
    """C source without comments, with whitespace runs made one space."""
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
    text = re.sub(r'//[^\n]*', ' ', text)
    return re.sub(r'\s+', ' ', text).strip()


def definitions(text):
    """{name: normalized definition} of the struct, union and enum definitions in C header text
    (`typedef struct X { ... } X;`, `struct X { ... };`, `typedef enum { ... } X;`)."""
    code = _code(text)
    out = {}
    for m in re.finditer(r'\b(?:typedef\s+)?(struct|union|enum)\s*([A-Za-z_]\w*)?\s*\{', code):
        depth, i = 0, m.end() - 1
        while i < len(code):
            if code[i] == '{':
                depth += 1
            elif code[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        end = code.find(';', i)
        if end < 0:
            continue
        body = code[m.start():end + 1]
        tail = re.match(r'\s*([A-Za-z_]\w*)\s*;', code[i + 1:end + 1])
        for name in {m.group(2), tail and tail.group(1)} - {None}:
            out.setdefault(name, body)
    return out


def metadata_version(libil2cpp):
    """The global-metadata.dat version a libil2cpp source tree reads, or None."""
    p = os.path.join(libil2cpp, 'vm', 'GlobalMetadata.cpp')
    try:
        with open(p, encoding='utf-8', errors='replace') as f:
            m = re.search(r'GlobalMetadataHeader->version\s*==\s*(\d+)', f.read())
    except OSError:
        return None
    return int(m.group(1)) if m else None


def _defs(libil2cpp, names):
    d = {}
    for n in names:
        p = os.path.join(libil2cpp, n)
        if os.path.isfile(p):
            with open(p, encoding='utf-8', errors='replace') as f:
                for k, v in definitions(f.read()).items():
                    d.setdefault(k, v)
    return d


def compat(conv_lib, data_lib):
    """What differs between the converter's libil2cpp and the data version's that a mixed build
    depends on: [] when they agree (the metadata version and file layout, EMITTED)."""
    why = []
    mc, md = metadata_version(conv_lib), metadata_version(data_lib)
    if mc is None or md is None:
        why.append(f'metadata version not found (converter {mc}, data {md})')
    elif mc != md:
        why.append(f'global-metadata.dat version: the converter writes {mc}, this libil2cpp reads {md}')
    fc, fd = _defs(conv_lib, (METADATA_HEADER,)), _defs(data_lib, (METADATA_HEADER,))
    if not fd:
        why.append(f'no {METADATA_HEADER} in the data version\'s libil2cpp')
    changed = sorted(n for n in set(fc) | set(fd) if fc.get(n) != fd.get(n))
    if changed:
        why.append('global-metadata.dat tables laid out differently: ' + ', '.join(changed))
    hc, hd = _defs(conv_lib, HEADERS), _defs(data_lib, HEADERS)
    changed = sorted(n for n in EMITTED if hc.get(n) != hd.get(n))
    if changed:
        why.append('structures the generated C++ fills in laid out differently: ' + ', '.join(changed))
    return why


def converter_wanted(rel):
    """The converter's files a mixed build needs: il2cpp/build (the .NET tools), and libil2cpp's
    headers and GlobalMetadata.cpp (compat only reads them)."""
    if rel.startswith('il2cpp/build/'):
        return True
    return rel.startswith('il2cpp/libil2cpp/') and (rel.endswith('.h') or rel.endswith('vm/GlobalMetadata.cpp'))


def converter_for(data_lib):
    """The converter release for a libil2cpp source tree (by its metadata version), or None."""
    return CONVERTERS.get(metadata_version(data_lib))


def fetch_converter(home, conv, log=print):
    """The converter's il2cpp/build and libil2cpp headers (range reads of its Windows editor
    installer, as fetch_editor; 3.8 MB read, 12 MB on disk), or a full editor of that version
    already in the home. Returns the folder holding il2cpp/."""
    from . import il2cpp as I
    full = os.path.join(home, conv, 'editor')
    if os.path.isfile(os.path.join(full, '.complete')) and os.path.isfile(os.path.join(full, 'il2cpp', 'build', 'deploy', 'il2cpp.dll')):
        return full
    dest = os.path.join(home, conv, 'converter')
    if os.path.isfile(os.path.join(dest, '.complete')):
        return dest
    from . import nsis
    installer = I.editor_installer(conv)
    log(f'converter {conv}: il2cpp/build and libil2cpp\'s headers from {installer}')
    ns = nsis.Nsis(installer)
    deps = {}
    for rel in I.nsis_fetch(ns, lambda p: (lambda r: r if r and r.startswith('il2cpp/build/') and r.endswith('.deps.json') else None)(
            I.editor_rel(p)), dest, log=log):
        with open(os.path.join(dest, rel), encoding='utf-8-sig') as f:
            deps.setdefault(os.path.dirname(rel), set()).update(I.runtime_pack_files(json.load(f)))

    def select(p):
        r = I.editor_rel(p)
        if not r or not converter_wanted(r) or r.endswith('.deps.json'):
            return None
        if r.split('/')[-1].lower() in deps.get(os.path.dirname(r), ()) or r.endswith(('.pdb', '.mdb')):
            return None
        return r
    got = I.nsis_fetch(ns, select, dest, log=log)
    if 'il2cpp/build/deploy/il2cpp.dll' not in got:
        raise SystemExit(f'{installer}: no il2cpp/build/deploy/il2cpp.dll (not a .NET il2cpp)')
    for d in deps:
        for n in os.listdir(os.path.join(dest, d)):
            if n.endswith('.deps.json'):
                os.replace(os.path.join(dest, d, n), os.path.join(dest, d, n + '.orig'))
    with open(os.path.join(dest, '.complete'), 'w') as f:
        json.dump({'version': conv, 'installer': installer, 'files': len(got)}, f, indent=0)
    return dest


def _link_tree(src, dst, skip=()):
    """dst = src's files: hard links where the file system allows them (no space taken), else
    copies (exFAT / FAT32 cards have no links)."""
    for root, dirs, files in os.walk(src):
        rel = os.path.relpath(root, src)
        if rel.split(os.sep)[0] in skip:
            dirs[:] = []
            continue
        os.makedirs(os.path.join(dst, rel), exist_ok=True)
        for n in files:
            s, d = os.path.join(root, n), os.path.normpath(os.path.join(dst, rel, n))
            if os.path.lexists(d):
                os.unlink(d)
            try:
                os.link(s, d)
            except OSError:
                shutil.copy2(s, d)


def prepare(version, editor, home, conv=None, log=print):
    """The mixed folder for this Unity version (made once): returns (an Editor/Data-like folder
    whose il2cpp/ is the data version's with the converter's build/ (see the module's text), the
    converter's version). Stops with the differences when the two libil2cpps disagree on what the
    build needs."""
    data_lib = os.path.join(editor, 'il2cpp', 'libil2cpp')
    conv = conv or converter_for(data_lib)
    if conv is None:
        raise UV.Unsupported(f'Unity {version}: its il2cpp is a native program, and its libil2cpp reads '
                             f'global-metadata.dat version {metadata_version(data_lib)}, which no .NET il2cpp '
                             f'(Unity 2022.3: {", ".join(f"{v} {m}" for m, v in sorted(CONVERTERS.items()))}) writes')
    conv_dir = fetch_converter(home, conv, log)
    conv_lib = os.path.join(conv_dir, 'il2cpp', 'libil2cpp')
    why = compat(conv_lib, data_lib)
    if why:
        raise UV.Unsupported(f'Unity {version}: its il2cpp is a native program, and Unity {conv}\'s .NET il2cpp '
                             f'cannot convert for its libil2cpp: ' + '; '.join(why))
    mix = os.path.join(home, str(version), f'mix-{conv}')
    stamp = {'recipe': RECIPE, 'unity': str(version), 'converter': conv,
             'from': [os.path.relpath(editor, home), os.path.relpath(conv_dir, home)]}
    mark = os.path.join(mix, '.complete')
    try:
        with open(mark) as f:
            done = json.load(f) == stamp
    except (OSError, ValueError):
        done = False
    if not done:
        log(f'il2cpp: Unity {version} has a native il2cpp: converting with Unity {conv}\'s .NET il2cpp for '
            f'{version}\'s libil2cpp (metadata {metadata_version(data_lib)}) -> {mix}')
        shutil.rmtree(mix, ignore_errors=True)
        _link_tree(os.path.join(editor, 'il2cpp'), os.path.join(mix, 'il2cpp'), skip=('build',))
        _link_tree(os.path.join(conv_dir, 'il2cpp', 'build'), os.path.join(mix, 'il2cpp', 'build'))
        # (bee_backend and deploy/il2cpp are the stand-ins pmunity writes: new files, not links)
        for d in ('linux-x64', 'linux-arm64'):
            p = os.path.join(mix, 'il2cpp', 'build', 'deploy', 'bee_backend', d, 'bee_backend')
            if os.path.lexists(p):
                os.unlink(p)
        p = os.path.join(mix, 'il2cpp', 'build', 'deploy', 'il2cpp')
        if os.path.lexists(p):
            os.unlink(p)
        with open(mark, 'w') as f:
            json.dump(stamp, f)
    BEE.install(mix)
    return mix, conv
