"""A small reader of .NET assembly metadata (ECMA-335, partition II): type and method names, P/Invoke
declarations (ImplMap -> ModuleRef), method signatures and field constants. Enough to see which
native libraries a game's managed code calls, with which argument types, without running or
decompiling anything. Pure Python, no dependencies."""
import bisect
import struct

# metadata table numbers
MODULE, TYPEREF, TYPEDEF, FIELDPTR, FIELD, METHODPTR, METHODDEF, PARAMPTR, PARAM = range(9)
CONSTANT, NESTEDCLASS, CLASSLAYOUT, MODULEREF, IMPLMAP, ASSEMBLYREF = 0x0B, 0x29, 0x0F, 0x1A, 0x1C, 0x23

# coded index kinds: (tag bits, tables)
CODED = {
    'TypeDefOrRef': (2, (TYPEDEF, TYPEREF, 0x1B)),
    'HasConstant': (2, (FIELD, PARAM, 0x17)),
    'HasCustomAttribute': (5, (METHODDEF, FIELD, TYPEREF, TYPEDEF, PARAM, 0x09, 0x0A, MODULE, 0x0E, 0x17, 0x14, 0x11,
                               MODULEREF, 0x1B, 0x20, ASSEMBLYREF, 0x26, 0x27, 0x28, 0x2A, 0x2C, 0x2B)),
    'HasFieldMarshal': (1, (FIELD, PARAM)),
    'HasDeclSecurity': (2, (TYPEDEF, METHODDEF, 0x20)),
    'MemberRefParent': (3, (TYPEDEF, TYPEREF, MODULEREF, METHODDEF, 0x1B)),
    'HasSemantics': (1, (0x14, 0x17)),
    'MethodDefOrRef': (1, (METHODDEF, 0x0A)),
    'MemberForwarded': (1, (FIELD, METHODDEF)),
    'Implementation': (2, (0x26, ASSEMBLYREF, 0x27)),
    'CustomAttributeType': (3, (None, None, METHODDEF, 0x0A, None)),
    'ResolutionScope': (2, (MODULE, MODULEREF, ASSEMBLYREF, TYPEREF)),
    'TypeOrMethodDef': (1, (TYPEDEF, METHODDEF)),
}
# columns: 1/2/4 fixed, 'S' string, 'G' guid, 'B' blob, int = index into that table, str = coded index
SCHEMA = {
    0x00: (2, 'S', 'G', 'G', 'G'),
    0x01: ('ResolutionScope', 'S', 'S'),
    0x02: (4, 'S', 'S', 'TypeDefOrRef', FIELD, METHODDEF),
    0x03: (FIELD,),
    0x04: (2, 'S', 'B'),
    0x05: (METHODDEF,),
    0x06: (4, 2, 2, 'S', 'B', PARAM),
    0x07: (PARAM,),
    0x08: (2, 2, 'S'),
    0x09: (TYPEDEF, 'TypeDefOrRef'),
    0x0A: ('MemberRefParent', 'S', 'B'),
    0x0B: (1, 1, 'HasConstant', 'B'),
    0x0C: ('HasCustomAttribute', 'CustomAttributeType', 'B'),
    0x0D: ('HasFieldMarshal', 'B'),
    0x0E: (2, 'HasDeclSecurity', 'B'),
    0x0F: (2, 4, TYPEDEF),
    0x10: (4, FIELD),
    0x11: ('B',),
    0x12: (TYPEDEF, 0x14),
    0x13: (0x14,),
    0x14: (2, 'S', 'TypeDefOrRef'),
    0x15: (TYPEDEF, 0x17),
    0x16: (0x17,),
    0x17: (2, 'S', 'B'),
    0x18: (2, METHODDEF, 'HasSemantics'),
    0x19: (TYPEDEF, 'MethodDefOrRef', 'MethodDefOrRef'),
    0x1A: ('S',),
    0x1B: ('B',),
    0x1C: (2, 'MemberForwarded', 'S', MODULEREF),
    0x1D: (4, FIELD),
    0x1E: (4, 4),
    0x1F: (4,),
    0x20: (4, 2, 2, 2, 2, 4, 'B', 'S', 'S'),
    0x21: (4,),
    0x22: (4, 4, 4),
    0x23: (2, 2, 2, 2, 4, 'B', 'S', 'S', 'B'),
    0x24: (4, ASSEMBLYREF),
    0x25: (4, 4, 4, ASSEMBLYREF),
    0x26: (4, 'S', 'B'),
    0x27: (4, 4, 'S', 'S', 'Implementation'),
    0x28: (4, 4, 'S', 'Implementation'),
    0x29: (TYPEDEF, TYPEDEF),
    0x2A: (2, 2, 'TypeOrMethodDef', 'S'),
    0x2B: ('MethodDefOrRef', 'B'),
    0x2C: (0x2A, 'TypeDefOrRef'),
}

# ELEMENT_TYPE_*
E_VOID, E_BOOL, E_CHAR, E_I1, E_U1, E_I2, E_U2, E_I4, E_U4, E_I8, E_U8, E_R4, E_R8, E_STRING = range(1, 0x0F)
E_PTR, E_BYREF, E_VALUETYPE, E_CLASS, E_VAR, E_ARRAY, E_GENERICINST, E_TYPEDBYREF = range(0x0F, 0x17)
E_I, E_U, E_FNPTR, E_OBJECT, E_SZARRAY, E_MVAR, E_CMOD_REQD, E_CMOD_OPT = 0x18, 0x19, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20
E_SENTINEL, E_PINNED = 0x41, 0x45
PRIM = {E_BOOL: 'bool', E_CHAR: 'char', E_I1: 'sbyte', E_U1: 'byte', E_I2: 'short', E_U2: 'ushort', E_I4: 'int',
        E_U4: 'uint', E_I8: 'long', E_U8: 'ulong', E_R4: 'float', E_R8: 'double', E_I: 'IntPtr', E_U: 'UIntPtr',
        E_STRING: 'string', E_OBJECT: 'object', E_VOID: 'void', E_TYPEDBYREF: 'TypedReference'}
PRIM_SIZE = {E_BOOL: 1, E_CHAR: 2, E_I1: 1, E_U1: 1, E_I2: 2, E_U2: 2, E_I4: 4, E_U4: 4, E_I8: 8, E_U8: 8,
             E_R4: 4, E_R8: 8, E_I: 4, E_U: 4}


class NotAssembly(Exception):
    pass


class Assembly:
    """Metadata of one PE file with a CLI header."""

    def __init__(self, path):
        self.path = path
        with open(path, 'rb') as f:
            self.d = d = f.read()
        if d[:2] != b'MZ' or len(d) < 0x40:
            raise NotAssembly(path)
        pe = struct.unpack_from('<I', d, 0x3c)[0]
        if d[pe:pe + 4] != b'PE\0\0':
            raise NotAssembly(path)
        nsec, = struct.unpack_from('<H', d, pe + 6)
        optsz, = struct.unpack_from('<H', d, pe + 20)
        opt = pe + 24
        magic, = struct.unpack_from('<H', d, opt)
        dirs = opt + (96 if magic == 0x10b else 112)
        self.secs = [struct.unpack_from('<IIII', d, opt + optsz + 40 * i + 8) for i in range(nsec)]
        cli_rva, cli_size = struct.unpack_from('<II', d, dirs + 14 * 8)
        if not cli_rva:
            raise NotAssembly(path)
        cli = self.off(cli_rva)
        md_rva, _ = struct.unpack_from('<II', d, cli + 8)
        md = self.off(md_rva)
        if d[md:md + 4] != b'BSJB':
            raise NotAssembly(path)
        vlen, = struct.unpack_from('<I', d, md + 12)
        p = md + 16 + vlen
        nstreams, = struct.unpack_from('<H', d, p + 2)
        p += 4
        self.streams = {}
        for _ in range(nstreams):
            so, ss = struct.unpack_from('<II', d, p)
            e = d.index(b'\0', p + 8)
            name = d[p + 8:e].decode()
            self.streams[name] = (md + so, ss)
            p = (e + 4) & ~3
        self._tables()

    def off(self, rva):
        for vsize, va, rsize, raw in self.secs:
            if va <= rva < va + max(vsize, rsize):
                return rva - va + raw
        raise NotAssembly(f'{self.path}: rva {rva:#x} outside the sections')

    # ---- heaps
    def string(self, i):
        o = self.streams['#Strings'][0] + i
        return self.d[o:self.d.index(b'\0', o)].decode('utf-8', 'replace')

    def blob(self, i):
        o = self.streams['#Blob'][0] + i
        n, o = self.cuint(o)
        return self.d[o:o + n]

    def cuint(self, o, d=None):
        d = self.d if d is None else d
        b = d[o]
        if b < 0x80:
            return b, o + 1
        if b < 0xC0:
            return ((b & 0x3f) << 8) | d[o + 1], o + 2
        return ((b & 0x1f) << 24) | (d[o + 1] << 16) | (d[o + 2] << 8) | d[o + 3], o + 4

    # ---- tables
    def _tables(self):
        d = self.d
        name = '#~' if '#~' in self.streams else '#-'
        o = self.streams[name][0]
        heaps = d[o + 6]
        valid, = struct.unpack_from('<Q', d, o + 8)
        o += 24
        self.nrows = {}
        for t in range(64):
            if valid >> t & 1:
                self.nrows[t], = struct.unpack_from('<I', d, o)
                o += 4
        if heaps & 0x40:
            o += 4                                       # extra data (uncompressed streams)
        sizes = {'S': 4 if heaps & 1 else 2, 'G': 4 if heaps & 2 else 2, 'B': 4 if heaps & 4 else 2}
        self.tables = {}
        for t in sorted(self.nrows):
            if t not in SCHEMA:
                raise NotAssembly(f'{self.path}: unknown metadata table {t:#x}')
            # fixed-size columns are written 1/2/4, table indices as table numbers: the indices into
            # tables 2 (TypeDef) and 4 (Field) are listed in INDEX_COLS
            css = [self._colsize(t, k, c, sizes) for k, c in enumerate(SCHEMA[t])]
            rowsize = sum(css)
            n = self.nrows[t]
            self.tables[t] = (o, rowsize, css, n)
            o += rowsize * n

    # columns that are table indices although their table number is 1, 2 or 4
    INDEX_COLS = {(0x02, 4): FIELD, (0x03, 0): FIELD, (0x09, 0): TYPEDEF, (0x0F, 2): TYPEDEF, (0x10, 1): FIELD,
                  (0x12, 0): TYPEDEF, (0x15, 0): TYPEDEF, (0x19, 0): TYPEDEF, (0x1D, 1): FIELD, (0x29, 0): TYPEDEF,
                  (0x29, 1): TYPEDEF}

    def _colsize(self, t, k, c, sizes):
        if (t, k) in self.INDEX_COLS:
            return 2 if self.nrows.get(self.INDEX_COLS[(t, k)], 0) < 65536 else 4
        if isinstance(c, int) and c in (1, 2, 4):
            return c
        if c in sizes:
            return sizes[c]
        if isinstance(c, str):
            bits, tabs = CODED[c]
            big = max((self.nrows.get(x, 0) for x in tabs if x is not None), default=0)
            return 2 if big < (1 << (16 - bits)) else 4
        return 2 if self.nrows.get(c, 0) < 65536 else 4

    def rows(self, t):
        cache = self.__dict__.setdefault('_rows', {})
        if t not in cache:
            cache[t] = self._rows_of(t)
        return cache[t]

    def _rows_of(self, t):
        if t not in self.tables:
            return []
        o, rs, css, n = self.tables[t]
        out = []
        for i in range(n):
            p = o + i * rs
            row = []
            for s in css:
                row.append(self.d[p] if s == 1 else struct.unpack_from('<H' if s == 2 else '<I', self.d, p)[0])
                p += s
            out.append(row)
        return out

    def count(self, t):
        return self.nrows.get(t, 0)

    @staticmethod
    def coded(kind, v):
        bits, tabs = CODED[kind]
        return tabs[v & ((1 << bits) - 1)], v >> bits      # (table, 1-based row)

    # ---- derived views
    def types(self):
        """[(namespace, name, flags, extends(table,row), first field, first method)] with full names of
        nested types (Outer/Inner) and each type's field and method row ranges (1-based, end exclusive)."""
        if hasattr(self, '_types'):
            return self._types
        td = self.rows(TYPEDEF)
        nested = {r[0]: r[1] for r in self.rows(NESTEDCLASS)}
        nf, nm = self.count(FIELD) + 1, self.count(METHODDEF) + 1
        out = []
        for i, (flags, name, ns, ext, fl, ml) in enumerate(td):
            fe = td[i + 1][4] if i + 1 < len(td) else nf
            me = td[i + 1][5] if i + 1 < len(td) else nm
            out.append({'ns': self.string(ns), 'name': self.string(name), 'flags': flags,
                        'extends': self.coded('TypeDefOrRef', ext), 'fields': (fl, fe), 'methods': (ml, me)})
        for i, t in enumerate(out):
            full, k, seen = t['name'], i + 1, set()
            while k in nested and k not in seen:
                seen.add(k)
                k = nested[k]
                full = out[k - 1]['name'] + '/' + full
                t['ns'] = out[k - 1]['ns']
            t['full'] = (t['ns'] + '.' if t['ns'] else '') + full
        self._types = out
        return out

    def _owner(self, key, row):
        """The type whose member list (key 'methods' or 'fields') holds row: the last type whose list
        starts at or before it (lists are in TypeDef order, contiguous)."""
        ts = self.types()
        starts = self.__dict__.setdefault('_starts', {})
        if key not in starts:
            starts[key] = [t[key][0] for t in ts]
        i = bisect.bisect_right(starts[key], row) - 1
        while i >= 0 and not ts[i][key][0] <= row < ts[i][key][1]:
            i -= 1                                 # (types with empty lists share a start)
        return ts[i] if i >= 0 else None

    def type_of_method(self, mrow):
        return self._owner('methods', mrow)

    def type_of_field(self, frow):
        return self._owner('fields', frow)

    def typeref_name(self, row):
        scope, name, ns = self.rows(TYPEREF)[row - 1]
        n, s = self.string(name), self.string(ns)
        return (s + '.' if s else '') + n

    def type_name(self, tab, row):
        if tab == TYPEDEF:
            return self.types()[row - 1]['full']
        if tab == TYPEREF:
            return self.typeref_name(row)
        return '?'

    def pinvokes(self):
        """[{'module', 'entry', 'type', 'method', 'sig'}] for every P/Invoke declaration."""
        mods = [self.string(r[0]) for r in self.rows(MODULEREF)]
        methods = self.rows(METHODDEF)
        out = []
        for flags, fwd, entry, scope in self.rows(IMPLMAP):
            tab, row = self.coded('MemberForwarded', fwd)
            if tab != METHODDEF or not 1 <= row <= len(methods) or not 1 <= scope <= len(mods):
                continue
            m = methods[row - 1]
            t = self.type_of_method(row)
            name = self.string(m[3])
            out.append({'module': mods[scope - 1], 'entry': self.string(entry) or name, 'method': name,
                        'type': t['full'] if t else '?', 'sig': self.method_sig(self.blob(m[4]))})
        return out

    def field_constants(self):
        """{'Namespace.Type.field': value} of the literal fields (int, uint, string, bool...)."""
        fields = self.rows(FIELD)
        out = {}
        for typ, _, parent, val in self.rows(CONSTANT):
            tab, row = self.coded('HasConstant', parent)
            if tab != FIELD or not 1 <= row <= len(fields):
                continue
            t = self.type_of_field(row)
            b = self.blob(val)
            v = None
            if typ in (E_I4, E_U4) and len(b) == 4:
                v = struct.unpack('<i' if typ == E_I4 else '<I', b)[0]
            elif typ in (E_I8, E_U8) and len(b) == 8:
                v = struct.unpack('<q' if typ == E_I8 else '<Q', b)[0]
            elif typ in (E_I2, E_U2) and len(b) == 2:
                v = struct.unpack('<h' if typ == E_I2 else '<H', b)[0]
            elif typ in (E_I1, E_U1, E_BOOL) and len(b) == 1:
                v = b[0]
            elif typ == E_STRING:
                v = b.decode('utf-16-le', 'replace')
            elif typ == E_CLASS:
                v = None                                   # null reference
            if t:
                out[t['full'] + '.' + self.string(fields[row - 1][1])] = v
        return out

    # ---- signatures: a type is ('prim', E_x) | ('ptr', t) | ('byref', t) | ('valuetype', name, (tab,row))
    #      | ('class', name) | ('array', t) | ('fnptr',) | ('generic', ...)
    def _type(self, b, o):
        e = b[o]; o += 1
        while e in (E_CMOD_REQD, E_CMOD_OPT):
            _, o = self.cuint(o, b)
            e = b[o]; o += 1
        if e == E_PINNED:
            return self._type(b, o)
        if e in PRIM:
            return ('prim', e), o
        if e in (E_PTR, E_BYREF):
            t, o = self._type(b, o)
            return ('ptr' if e == E_PTR else 'byref', t), o
        if e in (E_VALUETYPE, E_CLASS):
            v, o = self.cuint(o, b)
            tab, row = self.coded('TypeDefOrRef', v)
            name = self.type_name(tab, row)
            return (('valuetype' if e == E_VALUETYPE else 'class'), name, (tab, row)), o
        if e == E_SZARRAY:
            t, o = self._type(b, o)
            return ('array', t), o
        if e == E_ARRAY:
            t, o = self._type(b, o)
            _, o = self.cuint(o, b)
            n, o = self.cuint(o, b)
            for _ in range(n):
                _, o = self.cuint(o, b)
            n, o = self.cuint(o, b)
            for _ in range(n):
                _, o = self.cuint(o, b)
            return ('array', t), o
        if e == E_GENERICINST:
            k = b[o]; o += 1
            v, o = self.cuint(o, b)
            n, o = self.cuint(o, b)
            for _ in range(n):
                _, o = self._type(b, o)
            return (('valuetype' if k == E_VALUETYPE else 'class'), 'generic', None), o
        if e in (E_VAR, E_MVAR):
            _, o = self.cuint(o, b)
            return ('class', 'generic parameter'), o
        if e == E_FNPTR:
            _, o = self._sig(b, o)
            return ('fnptr',), o
        raise ValueError(f'element type {e:#x}')

    def _sig(self, b, o):
        cc = b[o]; o += 1
        if cc & 0x10:
            _, o = self.cuint(o, b)
        n, o = self.cuint(o, b)
        ret, o = self._type(b, o)
        ps = []
        for _ in range(n):
            if b[o] == E_SENTINEL:
                o += 1
            t, o = self._type(b, o)
            ps.append(t)
        return (ret, ps), o

    def method_sig(self, b):
        try:
            return self._sig(b, 0)[0]
        except (ValueError, IndexError):
            return None

    def field_sig(self, b):
        try:
            return self._type(b, 1)[0] if b and b[0] == 0x06 else None
        except (ValueError, IndexError):
            return None

    def typedef_layout(self, row):
        """(base type name, [(field name, type)] of the instance fields, explicit size or None)."""
        t = self.types()[row - 1]
        tab, r = t['extends']
        base = self.type_name(tab, r) if r else None
        fields = self.rows(FIELD)
        out = []
        for i in range(t['fields'][0], t['fields'][1]):
            flags, name, sig = fields[i - 1]
            if flags & 0x10:                               # static
                continue
            out.append((self.string(name), self.field_sig(self.blob(sig))))
        size = None
        for pack, sz, parent in self.rows(CLASSLAYOUT):
            if parent == row and sz:
                size = sz
        return base, out, size, t['flags']

    def assembly_refs(self):
        return [self.string(r[6]) for r in self.rows(ASSEMBLYREF)]

    def typeref_scope(self, row):
        """The assembly name a TypeRef points into (None for nested or module-local scopes)."""
        scope = self.rows(TYPEREF)[row - 1][0]
        tab, r = self.coded('ResolutionScope', scope)
        if tab == ASSEMBLYREF:
            return self.string(self.rows(ASSEMBLYREF)[r - 1][6])
        return None
