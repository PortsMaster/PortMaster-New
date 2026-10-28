"""The Unity version a game's data was built with, read from the data itself, and what the
converter supports.

Every serialized file names the Unity version that wrote it, right after its header (formats 9 -
21: a 20-byte header; formats 22 (Unity 2020.1+) and 23 (Unity 6.5+): 48 bytes, the sizes being
64-bit), and so does the header of a UnityFS bundle (a compressed build's data.unity3d, asset
bundles). The converter knows
the formats of Unity 2017.3 - 2022.3 (docs/compat/README.md): their shader program layouts
(shaders/blob.py) and player-side data rules (android_data.py). Older and newer data is refused
with the version it has, unless the caller insists (`force`).
"""
import os
import re
import struct

# (major, minor) bounds of the versions the converter supports, both included
FIRST, LAST = (5, 6), (6000, 6)


class Unsupported(Exception):
    pass


class Version:
    """A Unity version string, e.g. 2021.3.45f2 -> (2021, 3, 45), 'f', 2."""

    def __init__(self, text):
        m = re.match(r'^(\d+)\.(\d+)\.(\d+)([abfpx]?)(\d*)', text)
        if not m:
            raise ValueError(f'not a Unity version: {text!r}')
        self.text = text
        self.major, self.minor, self.patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
        self.kind, self.build = m.group(4), int(m.group(5) or 0)
        self.exact = True               # False: only the line is known for sure

    @property
    def line(self):
        return self.major, self.minor

    def __ge__(self, other):
        return (self.major, self.minor, self.patch) >= tuple(other) if isinstance(other, tuple) else NotImplemented

    def __lt__(self, other):
        return (self.major, self.minor, self.patch) < tuple(other) if isinstance(other, tuple) else NotImplemented

    def __str__(self):
        return self.text

    def __repr__(self):
        return f'Version({self.text!r})'


def sf_header(head):
    """(format, unity version string, offset of the target platform word, big endian) of a
    SerializedFile's first bytes (format 9 and later)."""
    if len(head) < 40:
        raise ValueError('short file')
    fmt, = struct.unpack_from('>I', head, 8)
    if not 9 <= fmt <= 23:
        raise ValueError(f'unsupported SerializedFile format {fmt}')
    p = 48 if fmt >= 22 else 20
    big = head[16] != 0                         # (formats 22+ keep the old 16 bytes first)
    end = head.index(b'\0', p)
    return fmt, head[p:end].decode('ascii'), end + 1, big


def of_file(path):
    """The Unity version of a serialized file or UnityFS bundle."""
    with open(path, 'rb') as f:
        head = f.read(256)
    if head.startswith(b'UnityFS\0'):
        parts = head[8 + 4:].split(b'\0')
        return Version(parts[1].decode('ascii'))        # (parts[0] is the bundle format's "5.x.x")
    return Version(sf_header(head)[1])


def of_data(data_dir):
    """The Unity version of a game's data folder (<Game>_Data, <Game>.app/Contents/Resources/Data):
    from globalgamemanagers (Unity 5.4+), else mainData, else a compressed build's data.unity3d."""
    for n in ('globalgamemanagers', 'mainData', 'data.unity3d'):
        p = os.path.join(data_dir, n)
        if os.path.isfile(p):
            return of_file(p)
    raise Unsupported(f'{data_dir}: no globalgamemanagers, mainData or data.unity3d (not a Unity data folder?)')


def check(version, force=False):
    """Raises Unsupported for a version outside FIRST..LAST (unless force)."""
    if FIRST <= version.line <= LAST or force:
        return version
    lo, hi = '%d.%d' % FIRST, '%d.%d' % LAST
    raise Unsupported(f'Unity {version}: the converter supports data of Unity {lo} - {hi} '
                      f'(their shader program and data formats are known; see docs/compat/README.md). '
                      f'Use --any-unity-version to try anyway (shader layouts are then guessed and checked by round trip).')
