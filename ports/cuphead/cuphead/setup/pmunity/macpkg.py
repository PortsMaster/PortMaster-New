"""Unpack macOS installer packages (.pkg, as GOG ships its macOS games) without macOS tools:
`python -m pmunity macpkg <root> <installer.pkg>...`

A .pkg is a xar archive: a zlib-compressed XML table of contents, then the files' data. A product
archive (Distribution + one or more component packages) or a single component package both hold,
per component, `PackageInfo` (with the install location) and `Payload`: a cpio archive (odc or
newc), gzip-compressed or in Apple's pbzx framing (xz chunks). The payload's paths are relative to
the install location, so each file lands at <root>/<install location>/<path>: a DLC package that
installs into the game's .app ends up inside it. GOG's installers leave the Payload empty (or out)
and carry the game in the component's Scripts archive under payload/, which a postinstall script
copies to the install location; that folder is unpacked the same way.

Everything is streamed (a game's payload is gigabytes). Symbolic links are skipped and counted
(exFAT cards cannot store them; a game's data folder has none); hard links in the archive are
written as copies.
"""
import gzip
import lzma
import os
import re
import shutil
import struct
import sys
import xml.etree.ElementTree as ET
import zlib


class Region:
    """A read-only file-like view of bytes [start, start+length) of an open file."""

    def __init__(self, f, start, length):
        self.f, self.start, self.length, self.pos = f, start, length, 0

    def read(self, n=-1):
        if n is None or n < 0 or n > self.length - self.pos:
            n = self.length - self.pos
        if n <= 0:
            return b''
        self.f.seek(self.start + self.pos)
        b = self.f.read(n)
        self.pos += len(b)
        return b

    def readable(self):
        return True


class Xar:
    def __init__(self, path):
        self.f = open(path, 'rb')
        head = self.f.read(28)
        if head[:4] != b'xar!':
            raise ValueError(f'{path}: not a macOS installer package (xar)')
        hsize, _ver, toc_c, toc_u = struct.unpack('>HHQQ', head[4:24])
        self.f.seek(hsize)
        self.toc = ET.fromstring(zlib.decompress(self.f.read(toc_c)))
        self.heap = hsize + toc_c

    def files(self):
        """(path, element) of every file in the archive."""
        def walk(el, prefix):
            for fe in el.findall('file'):
                name = fe.findtext('name') or ''
                p = f'{prefix}{name}'
                yield p, fe
                yield from walk(fe, p + '/')
        yield from walk(self.toc.find('toc'), '')

    def open(self, fe):
        d = fe.find('data')
        off, length = int(d.findtext('offset')), int(d.findtext('length'))
        enc = d.find('encoding').get('style') if d.find('encoding') is not None else 'application/octet-stream'
        raw = Region(self.f, self.heap + off, length)
        if enc == 'application/octet-stream':
            return raw
        if enc == 'application/x-gzip':
            return Inflate(raw)
        if enc == 'application/x-bzip2':
            import bz2
            return bz2.BZ2File(raw)
        raise ValueError(f'xar encoding {enc} not supported')

    def read(self, fe):
        s = self.open(fe)
        return s.read()


class _Buffer:
    """Bytes waiting to be read: appended at the end, taken from the front (a list of pieces and an
    offset into the first: taking n bytes copies n bytes, not everything left behind them)."""

    def __init__(self):
        self.parts, self.off, self.size = [], 0, 0

    def add(self, b):
        if b:
            self.parts.append(b)
            self.size += len(b)

    def take(self, n):
        n = min(n, self.size)
        out = []
        while n:
            p = self.parts[0]
            k = min(n, len(p) - self.off)
            out.append(p[self.off:self.off + k] if (self.off, k) != (0, len(p)) else p)
            self.off += k
            n -= k
            self.size -= k
            if self.off == len(p):
                self.parts.pop(0)
                self.off = 0
        return out[0] if len(out) == 1 else b''.join(out)


class Inflate:
    """zlib stream (xar's 'gzip' encoding is zlib) as a file-like object."""

    def __init__(self, raw):
        self.raw, self.z, self.buf, self.eof = raw, zlib.decompressobj(), _Buffer(), False

    def read(self, n=-1):
        while not self.eof and (n < 0 or self.buf.size < n):
            c = self.raw.read(1 << 20)
            if not c:
                self.buf.add(self.z.flush())
                self.eof = True
                break
            self.buf.add(self.z.decompress(c))
        return self.buf.take(self.buf.size if n < 0 else n)


class Pbzx:
    """Apple's pbzx payload framing: 'pbzx', flags, then (flags, length, data) chunks, each an xz
    stream or stored as is."""

    def __init__(self, raw):
        self.raw, self.buf, self.done = raw, _Buffer(), False
        head = raw.read(12)
        if head[:4] != b'pbzx':
            raise ValueError('not a pbzx stream')

    def _chunk(self):
        h = self.raw.read(16)
        if len(h) < 16:
            self.done = True
            return
        _flags, length = struct.unpack('>QQ', h)
        data = self.raw.read(length)
        self.buf.add(lzma.decompress(data) if data[:6] == b'\xfd7zXZ\x00' else data)

    def read(self, n=-1):
        while not self.done and (n < 0 or self.buf.size < n):
            self._chunk()
        return self.buf.take(self.buf.size if n < 0 else n)


class Ahead:
    """A stream read ahead on a thread of its own: the decompression of the next megabytes runs
    while the caller writes the last ones (zlib and xz let go of the GIL), so unpacking takes about
    as long as the slower of the two instead of both. At most `depth` pieces wait in memory."""

    def __init__(self, s, piece=1 << 20, depth=4):
        import queue
        import threading
        self.q, self.buf, self.eof, self.err = queue.Queue(depth), _Buffer(), False, None
        self.stop = threading.Event()
        self.t = threading.Thread(target=self._run, args=(s, piece), daemon=True)
        self.t.start()

    def _run(self, s, piece):
        try:
            while not self.stop.is_set():
                b = s.read(piece)
                self._put(b)
                if not b:
                    return
        except BaseException as ex:            # (handed to the reader)
            self.err = ex
            self._put(b'')

    def _put(self, b):
        import queue
        while not self.stop.is_set():
            try:
                self.q.put(b, timeout=0.5)
                return
            except queue.Full:
                pass

    def read(self, n=-1):
        while not self.eof and (n < 0 or self.buf.size < n):
            b = self.q.get()
            if not b:
                self.eof = True
                if self.err is not None:
                    raise self.err
                break
            self.buf.add(b)
        return self.buf.take(self.buf.size if n < 0 else n)

    def close(self):
        self.stop.set()
        self.t.join()


class Peek:
    def __init__(self, s):
        self.s, self.head = s, b''

    def peek(self, n):
        while len(self.head) < n:
            c = self.s.read(n - len(self.head))
            if not c:
                break
            self.head += c
        return self.head[:n]

    def read(self, n=-1):
        if self.head:
            if n < 0:
                out, self.head = self.head + self.s.read(), b''
                return out
            out, self.head = self.head[:n], self.head[n:]
            if len(out) < n:
                out += self.s.read(n - len(out))
            return out
        return self.s.read(n)


def payload_stream(raw):
    p = Peek(raw)
    magic = p.peek(4)
    if magic[:2] == b'\x1f\x8b':
        return gzip.GzipFile(fileobj=p)
    if magic == b'pbzx':
        return Pbzx(p)
    return p                                   # an uncompressed cpio


def _exact(s, n):
    b = b''
    while len(b) < n:
        c = s.read(n - len(b))
        if not c:
            raise EOFError('cpio archive ends early')
        b += c
    return b


def cpio_members(s):
    """(name, mode, size, read(n) for its data) of each member, in order; the caller reads the data."""
    while True:
        magic = _exact(s, 6)
        if magic == b'070707':                 # odc: octal fields
            h = _exact(s, 70)
            mode = int(h[12:18], 8); namesize = int(h[53:59], 8); size = int(h[59:70], 8)
            name = _exact(s, namesize)[:-1].decode('utf-8', 'replace')
            pad_name = pad_data = 0
        elif magic in (b'070701', b'070702'):  # newc: hex fields, 4-byte alignment
            h = _exact(s, 104)
            mode = int(h[8:16], 16); size = int(h[48:56], 16); namesize = int(h[88:96], 16)
            name = _exact(s, namesize)[:-1].decode('utf-8', 'replace')
            pad_name = (-(110 + namesize)) % 4
            pad_data = (-size) % 4
            _exact(s, pad_name)
        else:
            raise ValueError(f'unknown cpio header {magic!r}')
        if name == 'TRAILER!!!':
            return
        yield name, mode, size
        if pad_data:
            _exact(s, pad_data)


def extract(pkg, root, log=print, keep=None):
    """Extracts every component package of one .pkg under root. keep(path) -> bool filters the
    paths (relative to /). Returns (files, bytes, skipped symlinks).

    A component's files come from its Payload, and also from its Scripts archive when that holds a
    `payload/` folder: GOG's macOS installers ship the game that way (no Payload, and a postinstall
    script that moves Scripts/payload into <install location>/<gog_bundle_name>). keep applies to
    Payload files only."""
    x = Xar(pkg)
    files = dict(x.files())
    comps = sorted({p.rsplit('/', 1)[0] if '/' in p else '' for p in files
                    if p.rsplit('/', 1)[-1] in ('Payload', 'Scripts', 'PackageInfo')})
    totals = [0, 0, 0]                                  # files, bytes, symlinks
    for c in comps:
        pre = c + '/' if c else ''
        loc = '/'
        if pre + 'PackageInfo' in files:
            info = ET.fromstring(x.read(files[pre + 'PackageInfo']))
            loc = info.get('install-location') or '/'
        if pre + 'Payload' in files and files[pre + 'Payload'].find('data') is not None:
            before = totals[0]
            with _ahead(payload_stream(x.open(files[pre + 'Payload']))) as s:
                _unpack(s, root, loc, None, keep, totals)
            log(f'{os.path.basename(pkg)}: {c or "package"} Payload -> {loc}: {totals[0] - before} files')
        if pre + 'Scripts' in files and files[pre + 'Scripts'].find('data') is not None:
            # GOG: payload/ goes to <install location>/<gog_bundle_name> (the postinstall script's
            # `mv payload/*` or, for a DLC, `cp -rf payload/*` into the game's .app); without such a
            # script, payload/ goes to the install location itself. Unpacked into a staging folder
            # first (the script comes after the payload in the archive), then moved into place.
            stage = os.path.join(root, '.pmunity-payload', c or 'package')
            before = totals[0]
            scripts = {}
            with _ahead(payload_stream(x.open(files[pre + 'Scripts']))) as s:
                _unpack(s, stage, '/', 'payload', None, totals, scripts)
            if totals[0] > before:
                m = re.search(r'gog_bundle_name="([^"/]+)"', scripts.get('postinstall', b'').decode('utf-8', 'replace'))
                dest = os.path.join(loc.lstrip('/'), m.group(1)) if m else loc.lstrip('/')
                _merge(stage, os.path.join(root, dest))
                log(f'{os.path.basename(pkg)}: {c or "package"} Scripts/payload -> /{dest}: {totals[0] - before} files')
            shutil.rmtree(stage, ignore_errors=True)
    shutil.rmtree(os.path.join(root, '.pmunity-payload'), ignore_errors=True)
    if totals[0] == 0:
        log(f'{os.path.basename(pkg)}: no files found; the package holds: ' +
            ', '.join(f'{p} ({_size(fe)})' for p, fe in sorted(files.items()))[:2000])
    return tuple(totals)


class _ahead:
    """with _ahead(stream) as s: s reads the stream ahead (Ahead), stopped when the block ends."""

    def __init__(self, s):
        self.s = Ahead(s)

    def __enter__(self):
        return self.s

    def __exit__(self, *exc):
        self.s.close()
        return False


def _size(fe):
    d = fe.find('data')
    return f'{int(d.findtext("size") or 0) >> 10} KB' if d is not None else 'dir'


def _merge(src, dst):
    """Moves the tree src into dst (files replace files of the same name), then removes src."""
    for d, _, names in os.walk(src):
        rel = os.path.relpath(d, src)
        target = os.path.normpath(os.path.join(dst, rel))
        os.makedirs(target, exist_ok=True)
        for n in names:
            os.replace(os.path.join(d, n), os.path.join(target, n))
    shutil.rmtree(src, ignore_errors=True)


def _unpack(s, root, loc, strip, keep, totals, scripts=None):
    """Writes the members of one cpio stream under root/<loc>. strip: only members inside that
    top folder (e.g. 'payload'), with the folder removed from their paths; scripts: a dict that
    gets the small top-level files outside it (postinstall, preinstall) by name."""
    for name, mode, size in cpio_members(s):
        nm = os.path.normpath(name)
        if strip is not None:
            if nm == strip or not nm.startswith(strip + '/'):
                if scripts is not None and '/' not in nm and (mode & 0o170000) == 0o100000 and size < (1 << 20):
                    scripts[nm] = _exact(s, size)
                else:
                    _skip(s, size)
                continue
            nm = nm[len(strip) + 1:]
        rel = os.path.normpath(os.path.join(loc.lstrip('/'), nm))
        rel = '' if rel == '.' else rel
        kind = mode & 0o170000
        if (rel.startswith('..') or os.path.isabs(rel) or os.path.basename(rel).startswith('._')
                or (keep and not keep('/' + rel))):             # ._*: macOS metadata, not the game's
            _skip(s, size)
            continue
        dst = os.path.join(root, rel)
        if kind == 0o040000:
            os.makedirs(dst, exist_ok=True)
        elif kind == 0o120000:
            _skip(s, size)
            totals[2] += 1
        elif kind == 0o100000:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            tmp = dst + '.part'
            with open(tmp, 'wb') as f:
                left = size
                while left:
                    b = s.read(min(left, 1 << 20))
                    if not b:
                        raise EOFError(f'{name}: archive ends early')
                    f.write(b)
                    left -= len(b)
            os.replace(tmp, dst)
            totals[0] += 1
            totals[1] += size
        else:
            _skip(s, size)


def _skip(s, size):
    while size:
        b = s.read(min(size, 1 << 20))
        if not b:
            raise EOFError('payload ends early')
        size -= len(b)


def main(argv):
    if len(argv) < 2:
        sys.exit('usage: python -m pmunity macpkg <root> <installer.pkg>...')
    root = argv[0]
    os.makedirs(root, exist_ok=True)
    for pkg in argv[1:]:
        n, total, links = extract(pkg, root)
        print(f'{os.path.basename(pkg)}: {n} files, {total >> 20} MB' + (f', {links} symbolic links skipped' if links else ''))


if __name__ == '__main__':
    main(sys.argv[1:])
