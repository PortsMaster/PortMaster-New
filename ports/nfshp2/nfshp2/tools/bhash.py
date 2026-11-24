#!/usr/bin/env python3
r"""bWare bStringHash -- the hash ZDIR.BIN stores instead of filenames.

Recovered by decompiling `bStringHash__FPCc` (0x0023b280) out of
NFSHP2.ELF (see docs/formats/zdir-archive.md):

    int bStringHash(const char *s) {
        int h = -1;
        while (*s) h = h * 33 + (unsigned char)*s++;
        return h;
    }

i.e. a djb2 variant seeded with 0xFFFFFFFF instead of 5381. The
two-argument overload `bStringHash(const char *, int seed)` is the same
loop with a caller-supplied seed, which makes the hash *incremental* --
that is what `crack()` below exploits.

The hash is computed over the exact string the engine passes to
bLoadDirectoryFile(), which for HP2 is an uppercase, backslash-separated,
CD-relative path (e.g. "GLOBAL\DYNTEX.BIN") -- except for a handful of
runtime-formatted paths that keep their source-literal casing (e.g.
"NIS\<name>.bin").
"""
M = 0xFFFFFFFF
P = 33


def bhash(s, seed=M):
    """bStringHash of `s` (str or bytes), optionally continuing from `seed`."""
    if isinstance(s, str):
        s = s.encode("latin-1", "replace")
    h = seed & M
    for c in s:
        h = (h * P + c) & M
    return h


def _pow33(n):
    return pow(P, n, 1 << 32)


def crack(target, prefix="", suffix="", charset=None, min_len=0, max_len=8,
          split=None):
    """Yield every `prefix + middle + suffix` whose bhash is `target`.

    Brute-forces `middle` over `charset` with a meet-in-the-middle split,
    which is what makes lengths past ~4 tractable: the hash is linear in
    GF(2^32) over the character values, so

        bhash(P+M+S) = bhash(P)*33^(|M|+|S|)
                       + sum_j M_j * 33^(|M|-1-j+|S|)
                       + sum_k S_k * 33^(|S|-1-k)   (mod 2^32)

    Splitting M into M1+M2 makes the M term V1*33^(|M2|+|S|) + V2, so we
    can table every V2 and look each V1 up in it.
    """
    if charset is None:
        charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    cs = [c.encode("latin-1") for c in charset]
    target &= M
    sfx = suffix.encode("latin-1")
    slen = len(sfx)
    # constant tail contribution of `suffix`
    tail = 0
    for k, c in enumerate(sfx):
        tail = (tail + c * _pow33(slen - 1 - k)) & M
    hp = bhash(prefix)

    for m in range(min_len, max_len + 1):
        base = (hp * _pow33(m + slen) + tail) & M
        need = (target - base) & M
        if m == 0:
            if need == 0:
                yield prefix + suffix
            continue
        n2 = m // 2 if split is None else min(split, m)
        n1 = m - n2
        # table every second half
        table = {}
        if n2:
            stack = [(b"", 0)]
            for _ in range(n2):
                nxt = []
                for s2, v in stack:
                    for c in cs:
                        nxt.append((s2 + c, (v * P + c[0]) & M))
                stack = nxt
            for s2, v in stack:
                table.setdefault((v * _pow33(slen)) & M, []).append(s2)
        else:
            table[0] = [b""]
        shift = _pow33(n2 + slen)
        stack = [(b"", 0)]
        for _ in range(n1):
            nxt = []
            for s1, v in stack:
                for c in cs:
                    nxt.append((s1 + c, (v * P + c[0]) & M))
            stack = nxt
        for s1, v1 in stack:
            rest = (need - v1 * shift) & M
            for s2 in table.get(rest, ()):
                yield prefix + (s1 + s2).decode("latin-1") + suffix


if __name__ == "__main__":
    import sys
    if len(sys.argv) >= 2 and sys.argv[1] == "-c":
        for s in sys.argv[2:]:
            print("%08x  %s" % (bhash(s), s))
    else:
        print(__doc__)
