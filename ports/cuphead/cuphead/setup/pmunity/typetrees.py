"""Type trees UnityPy's bundled ones get wrong for some Unity versions.

A desktop build's main data has no type trees: UnityPy reads its objects with the trees it ships
(UnityPy 1.25.4: Unity 3.4 - 6000.7 alphas), taking the newest one not newer than the data's
version. A release that added a field after UnityPy's snapshot (6000.6.3f1's PlayerSettings has
`captureStartupLogsBaked`, which UnityPy's 6000.6 alpha tree lacks) then fails to read
("Expected to read 892 bytes, but only read 888 bytes"). The fields such releases added are known
from the players' own type tree code (libunity's `Transfer<GenerateTypeTreeTransfer>` functions,
read with tools/re/strrefs.py and the player's symbols); FIELDS lists them. Otherwise the bytes
left over at the end are kept as unknown fields. A fixed tree is only used when UnityPy's own one
does not read the object and the fixed one reads it exactly (every byte), so this never changes
data that UnityPy reads correctly, and (read(obj, edits)) only when the fields to change come
before every place the missing bytes can be.

A release can also lack a field UnityPy's tree for it has: the trees are snapshots of sampled
releases, each applying from its release on, so a field added in a later patch of a line (or
backported to it) shows up for the earlier patches too (6000.2.6f2's UnityConnectSettings has no
InsightsSettings, which UnityPy's tree has from 6000.2.0b7 on: "read_bool out of bounds"). Then
UnityPy's trees of the class for the other versions it knows are tried, nearest first, and one
that reads every byte is used (neighbours()).

    tree, node = read(obj)       # node: the tree used (None: UnityPy's own)
    save(obj, tree, node)
"""
import re
import struct

# class name -> [(field it follows, type, name, aligned)]: fields Unity releases added after the
# type trees UnityPy ships
FIELDS = {
    # 6000.6.3f1 (PlayerSettingsState::Transfer: after insecureHttpOption). 6000.0.58f2 and
    # 6000.3.11f1 data are 4 bytes longer than UnityPy's trees too, and a 4-byte field fits there
    # only among the last fields (after organizationId; androidUseSwappy and the other fields
    # android_data edits come long before), so the same tree reads and writes them exactly.
    'PlayerSettings': [('insecureHttpOption', 'bool', 'captureStartupLogsBaked', True)],
}
ALIGN = 0x4000                      # kAlignBytesFlag
SIZES = {'bool': 1, 'UInt8': 1, 'SInt8': 1, 'char': 1, 'SInt16': 2, 'UInt16': 2, 'int': 4,
         'unsigned int': 4, 'float': 4, 'SInt64': 8, 'UInt64': 8, 'double': 8}


def _with_fields(node, fields):
    """A copy of a class tree with the given top-level fields inserted (None if a field it follows
    is missing, or every field is already there)."""
    nodes = node.to_dict_list()                 # pre-order, m_Level 0 = the class
    added = 0
    for after, typ, name, aligned in fields:
        top = [i for i, d in enumerate(nodes) if d['m_Level'] == 1]
        names = [nodes[i]['m_Name'] for i in top]
        if name in names:
            continue
        if after not in names:
            return None
        i = top[names.index(after)] + 1
        while i < len(nodes) and nodes[i]['m_Level'] > 1:      # past the field's own children
            i += 1
        d = dict(nodes[top[0]])
        d.update(m_Type=typ, m_Name=name, m_ByteSize=SIZES[typ], m_Version=1, m_Children=[],
                 m_TypeFlags=0, m_MetaFlag=ALIGN if aligned else 0)
        nodes.insert(i, d)
        added += 1
    if not added:
        return None
    for k, d in enumerate(nodes):
        d['m_Index'] = k
        d.pop('m_Children', None)
    return type(node).from_list(nodes)


def candidates(obj):
    """Fixed trees for obj's class, most likely first."""
    fields = FIELDS.get(obj.type.name)
    if not fields:
        return []
    base = obj._get_typetree_node()
    out = []
    for n in range(len(fields), 0, -1):          # all the fields, then fewer (older releases)
        for k in range(len(fields) - n + 1):
            t = _with_fields(base, fields[k:k + n])
            if t is not None:
                out.append(t)
    return out


_SHORT = re.compile(r'Expected to read (\d+) bytes, but only read (\d+) bytes')


def _reads(obj, node):
    try:
        return obj.read_typetree(nodes=node)
    except (ValueError, IndexError, KeyError, EOFError, OverflowError, MemoryError, struct.error):
        return None


def _earliest_gap(obj, base, k):
    """The first top-level field after which k unknown bytes make the object read exactly (the
    earliest place a field the tree lacks can be), or None."""
    names = [c.m_Name for c in base.m_Children]
    typ = {1: 'UInt8', 2: 'UInt16', 4: 'int', 8: 'SInt64'}.get(k)
    if typ is None:
        return None
    for i, n in enumerate(names):
        for aligned in (False, True):
            t = _with_fields(base, [(n, typ, '_probe', aligned)])
            if t is not None and _reads(obj, t) is not None:
                return i
    return None


def _shape(node):
    return tuple((d['m_Level'], d['m_Type'], d['m_Name'], d['m_MetaFlag']) for d in node.to_dict_list())


def _top(node):
    return [(c.m_Type, c.m_Name) for c in node.m_Children]


def neighbours(obj):
    """UnityPy's trees of obj's class for the other Unity versions it knows (older ones nearest
    first, then newer ones), different from the tree it reads obj with; [] for an object with its
    own type tree in the file or a class UnityPy has no trees for."""
    st = getattr(obj, 'serialized_type', None)
    if st is not None and getattr(st, 'node', None):
        return []
    try:
        from UnityPy.helpers import Tpk
        entries = [(v, c) for v, c in Tpk.get_typetree().ClassInformation[obj.class_id] if c is not None]
        ver = obj.version
        own = _shape(obj._get_typetree_node())
    except Exception:  # noqa: BLE001 - no trees to offer
        return []
    older = [c for v, c in entries if v <= ver]
    newer = [c for v, c in entries if v > ver]
    out, seen = [], {own}
    for c in older[::-1] + newer:
        try:
            n = Tpk.generate_node(c)
        except Exception:  # noqa: BLE001
            continue
        k = _shape(n)
        if k not in seen:
            seen.add(k)
            out.append(n)
    return out


def read(obj, edits=()):
    """(tree, node): the object read with UnityPy's tree, or else with a fixed one that reads all
    of its bytes (node is then that tree, to save with). The fixed trees: FIELDS for the class,
    else the bytes UnityPy's tree leaves over kept as unknown fields at the end (the fields a release
    added at the end: 2023.2.20f1's PlayerSettings is 1 byte longer). With `edits` (fields the caller
    will change), a fixed tree is only taken when the bytes the tree lacks cannot sit before any of
    them (no shorter field of that size fits there), so those fields are read where they are."""
    try:
        return obj.read_typetree(), None
    except ValueError as ex:
        first = ex
    m = _SHORT.search(str(first))
    base = obj._get_typetree_node()
    if edits and m:
        names = [c.m_Name for c in base.m_Children]
        last = max((names.index(e) for e in edits if e in names), default=-1)
        gap = _earliest_gap(obj, base, int(m.group(1)) - int(m.group(2)))
        if gap is not None and gap < last:
            raise ValueError(f'{obj.type.name}: {first}; the missing field could be before {names[gap + 1]}, '
                             f'which this conversion edits: no fixed type tree used') from first
    for node in candidates(obj):
        if _reads(obj, node) is not None:
            return obj.read_typetree(nodes=node), node
    if m and 0 < int(m.group(1)) - int(m.group(2)) <= 16:
        node = base
        for i in range(int(m.group(1)) - int(m.group(2))):     # unknown bytes, one after the other
            node = node and _with_fields(node, [(node.m_Children[-1].m_Name, 'UInt8', f'_unknown_{i}', False)])
        if node is not None and _reads(obj, node) is not None:
            return obj.read_typetree(nodes=node), node
    # another version's tree that reads every byte; with edits, only one whose fields up to the last
    # edited one are those of UnityPy's own tree (the edited fields are then where it reads them)
    names = [c.m_Name for c in base.m_Children]
    last = max((names.index(e) for e in edits if e in names), default=-1)
    for node in neighbours(obj):
        if edits and (last < 0 or _top(node)[:last + 1] != _top(base)[:last + 1]):
            continue
        if _reads(obj, node) is not None:
            return obj.read_typetree(nodes=node), node
    raise first


def save(obj, tree, node=None):
    if node is None:
        obj.save_typetree(tree)
    else:
        obj.save_typetree(tree, nodes=node)
