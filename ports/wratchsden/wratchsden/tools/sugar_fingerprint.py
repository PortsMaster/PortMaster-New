#!/usr/bin/env python3
"""Sugar engine patchset picker.

Given a Sugar Mach-O binary, tries each `.conf` patch file in a
directory and reports which one applies. The patch file's own
``; expect <hex>`` clauses are the fingerprint — the patchset itself
is the discriminator. No whole-file SHAs: a one-byte game patch or a
recompile with different layout won't break the match, only a change
that moves a patched instruction will.

A patch file "applies" when every
    at <loc> <insn> ; expect <hex>
clause reads back the expected 32-bit instruction word at its resolved
target address, AND every ``let <label> = <loc>`` binding resolves.

Usage
-----
  sugar_fingerprint.py <binary> [--patches <dir>]
      Scan all ``.conf`` files in <dir> (default: the ``patches/``
      directory next to this script). Print per-file status and the
      selected patchset.

  sugar_fingerprint.py <binary> <patch_file> [-v]
      Check a single patch file. With ``-v``, print every site's
      result; without, print a one-line summary.

Exit status
-----------
  0  exactly one patch file applies (or the explicit file applies)
  1  none apply (unrecognised variant)
  2  multiple apply (patch files are not specific enough)
"""

import argparse
import bisect
import re
import struct
import sys
from pathlib import Path

# ----------------------------------------------------------------------
# Mach-O parsing (arm64 slice only)
# ----------------------------------------------------------------------
MH_MAGIC_64 = 0xFEEDFACF
FAT_MAGIC_BE = 0xCAFEBABE
CPU_TYPE_ARM64 = 0x0100000C
LC_SEGMENT_64 = 0x19
LC_SYMTAB = 0x02


def _arm64_slice(raw):
    if struct.unpack(">I", raw[:4])[0] != FAT_MAGIC_BE:
        return raw
    nfat = struct.unpack(">I", raw[4:8])[0]
    for i in range(nfat):
        e = 8 + i * 20
        cputype, _sub, offset, size, _align = struct.unpack(
            ">IIIII", raw[e:e + 20])
        if cputype == CPU_TYPE_ARM64:
            return raw[offset:offset + size]
    raise RuntimeError("no arm64 slice in fat binary")


def _parse_macho(data):
    if struct.unpack("<I", data[:4])[0] != MH_MAGIC_64:
        raise RuntimeError("not an arm64 Mach-O")
    ncmds = struct.unpack("<I", data[16:20])[0]
    o = 32
    segments, symtab = [], None
    for _ in range(ncmds):
        cmd, sz = struct.unpack("<II", data[o:o + 8])
        if cmd == LC_SEGMENT_64:
            vmaddr, vmsize, fileoff, filesize = struct.unpack(
                "<QQQQ", data[o + 24:o + 56])
            segments.append((vmaddr, vmsize, fileoff, filesize))
        elif cmd == LC_SYMTAB:
            symtab = struct.unpack("<IIII", data[o + 8:o + 24])
        o += sz
    return segments, symtab


def _collect_symbols(data, symtab):
    symoff, nsyms, stroff, strsize = symtab
    strtab = data[stroff:stroff + strsize]
    by_name = {}
    all_addrs = set()
    for i in range(nsyms):
        o = symoff + i * 16
        n_strx, _t, n_sect, _d, n_value = struct.unpack(
            "<IBBHQ", data[o:o + 16])
        if n_sect == 0 or n_value == 0:
            continue
        end = strtab.find(b"\0", n_strx)
        name = strtab[n_strx:end].decode("ascii", "replace")
        by_name.setdefault(name, n_value)
        all_addrs.add(n_value)
    return by_name, sorted(all_addrs)


def _vmaddr_to_fileoff(segments, vmaddr):
    for vm, sz, fo, fsz in segments:
        if vm <= vmaddr < vm + sz:
            delta = vmaddr - vm
            return fo + delta if delta < fsz else None
    return None


def _fileoff_to_vmaddr(segments, fileoff):
    for vm, sz, fo, fsz in segments:
        if fo <= fileoff < fo + fsz:
            return vm + (fileoff - fo)
    return None


# ----------------------------------------------------------------------
# Patch grammar parser
# ----------------------------------------------------------------------
PATTERN_RE = re.compile(r'^[0-9a-fA-F?]{8}$')


def _hex(tok):
    return int(tok, 16)


def _pattern_mask_value(pat):
    mask = value = 0
    for c in pat:
        mask <<= 4
        value <<= 4
        if c == '?':
            continue
        mask |= 0xF
        value |= int(c, 16)
    return mask, value


def _parse_loc(tokens, i):
    """Consume loc tokens starting at ``tokens[i]``. Returns (loc, next_i)
    or raises ValueError."""
    tok = tokens[i]
    if tok.startswith('sym:'):
        body = tok[4:]
        name, off = body, 0
        for k, ch in enumerate(body):
            if ch in '+-':
                name = body[:k]
                off = _hex(body[k + 1:]) * (-1 if ch == '-' else 1)
                break
        loc = {'kind': 'sym', 'sym': name, 'offset': off,
               'find': [], 'within': 0}
        i += 1
        if i < len(tokens) and tokens[i] == 'find':
            i += 1
            while i < len(tokens) and PATTERN_RE.match(tokens[i]):
                loc['find'].append(tokens[i])
                i += 1
            if i < len(tokens) and tokens[i] == 'within':
                i += 1
                loc['within'] = _hex(tokens[i])
                i += 1
            loc['kind'] = 'sym_find'
        return loc, i
    if tok.lower().startswith('0x'):
        return {'kind': 'abs', 'offset': _hex(tok)}, i + 1
    if '+' in tok:
        name, off_tok = tok.split('+', 1)
        return {'kind': 'label', 'sym': name,
                'offset': _hex(off_tok)}, i + 1
    return {'kind': 'label', 'sym': tok, 'offset': 0}, i + 1


def _parse_patchfile(path):
    out = []
    for lineno, raw in enumerate(path.read_text().splitlines(), 1):
        cpos = raw.find('#')
        body = raw if cpos < 0 else raw[:cpos]
        if not body.strip():
            continue
        main, sep, rest = body.partition(';')
        expect = None
        if sep:
            rt = rest.strip().split()
            if len(rt) >= 2 and rt[0] == 'expect':
                try:
                    expect = _hex(rt[1])
                except ValueError:
                    expect = None
        toks = main.split()
        if not toks:
            continue
        try:
            if toks[0] == 'at':
                loc, _ = _parse_loc(toks, 1)
                out.append({'kind': 'at', 'line': lineno,
                            'loc': loc, 'expect': expect})
            elif toks[0] == 'let':
                if len(toks) < 4 or toks[2] != '=':
                    out.append({'kind': 'parse_error', 'line': lineno,
                                'text': body.strip()})
                    continue
                loc, _ = _parse_loc(toks, 3)
                out.append({'kind': 'let', 'line': lineno,
                            'label': toks[1], 'loc': loc})
            else:
                try:
                    addr = _hex(toks[0])
                    if len(toks) >= 2:
                        _hex(toks[1])
                        out.append({'kind': 'legacy', 'line': lineno,
                                    'addr': addr})
                except ValueError:
                    out.append({'kind': 'parse_error', 'line': lineno,
                                'text': body.strip()})
        except (ValueError, IndexError):
            out.append({'kind': 'parse_error', 'line': lineno,
                        'text': body.strip()})
    return out


# ----------------------------------------------------------------------
# Resolver + checker
# ----------------------------------------------------------------------
def _next_addr_after(sorted_addrs, addr):
    i = bisect.bisect_right(sorted_addrs, addr)
    return sorted_addrs[i] if i < len(sorted_addrs) else None


def _find_pattern_unique(data, start_off, end_off, patterns):
    mvs = [_pattern_mask_value(p) for p in patterns]
    need = 4 * len(patterns)
    hits = 0
    hit_off = 0
    off = start_off
    while off + need <= end_off:
        ok = True
        for k, (mask, value) in enumerate(mvs):
            w = struct.unpack("<I", data[off + k * 4:off + k * 4 + 4])[0]
            if (w & mask) != value:
                ok = False
                break
        if ok:
            hits += 1
            if hits == 1:
                hit_off = off
            if hits > 1:
                break
        off += 4
    if hits == 1:
        return ('ok', hit_off)
    if hits == 0:
        return ('not_found', None)
    return ('ambiguous', None)


def _resolve(loc, *, symbols, sorted_addrs, data, segments, labels):
    if loc['kind'] == 'abs':
        return loc['offset'], None
    if loc['kind'] == 'label':
        base = labels.get(loc['sym'])
        if base is None:
            return None, f"unknown label '{loc['sym']}'"
        return base + loc['offset'], None
    if loc['kind'] == 'sym':
        base = symbols.get(loc['sym'])
        if base is None:
            return None, f"symbol not found: {loc['sym']}"
        return base + loc['offset'], None
    # sym_find: pattern search bounded by next adjacent symbol (or
    # within <cap>).
    base = symbols.get(loc['sym'])
    if base is None:
        return None, f"symbol not found: {loc['sym']}"
    seg_end_vm = _next_addr_after(sorted_addrs, base)
    if seg_end_vm is None:
        return None, f"can't determine extent of {loc['sym']}"
    if loc['within'] and base + loc['within'] < seg_end_vm:
        seg_end_vm = base + loc['within']
    start_off = _vmaddr_to_fileoff(segments, base)
    end_off = _vmaddr_to_fileoff(segments, seg_end_vm)
    if start_off is None or end_off is None:
        return None, f"segment mapping failed for {loc['sym']}"
    status, hit_off = _find_pattern_unique(
        data, start_off, end_off, loc['find'])
    if status == 'not_found':
        return None, f"pattern not in {loc['sym']}"
    if status == 'ambiguous':
        return None, f"pattern ambiguous in {loc['sym']}"
    hit_vm = _fileoff_to_vmaddr(segments, hit_off)
    if hit_vm is None:
        return None, "segment back-mapping failed"
    return hit_vm, None


def _read_word(data, segments, vmaddr):
    off = _vmaddr_to_fileoff(segments, vmaddr)
    if off is None:
        return None
    return struct.unpack("<I", data[off:off + 4])[0]


def check(patch_path, binary_path):
    data = _arm64_slice(binary_path.read_bytes())
    segments, symtab = _parse_macho(data)
    if not symtab:
        return {'status': 'binary_stripped', 'applies': False}
    symbols, sorted_addrs = _collect_symbols(data, symtab)
    directives = _parse_patchfile(patch_path)

    labels = {}
    parse_errors = [d for d in directives if d['kind'] == 'parse_error']
    let_errors = []
    site_ok = []
    site_fail = []
    site_unresolved = []
    legacy = 0
    no_expect = 0

    for d in directives:
        if d['kind'] != 'let':
            continue
        addr, err = _resolve(d['loc'], symbols=symbols,
                             sorted_addrs=sorted_addrs, data=data,
                             segments=segments, labels=labels)
        if err:
            let_errors.append((d['line'], d['label'], err))
        else:
            labels[d['label']] = addr

    for d in directives:
        if d['kind'] == 'legacy':
            legacy += 1
            continue
        if d['kind'] != 'at':
            continue
        if d['expect'] is None:
            no_expect += 1
            continue
        addr, err = _resolve(d['loc'], symbols=symbols,
                             sorted_addrs=sorted_addrs, data=data,
                             segments=segments, labels=labels)
        if err:
            site_unresolved.append((d['line'], err))
            continue
        got = _read_word(data, segments, addr)
        if got is None:
            site_unresolved.append((d['line'],
                                    f"address {addr:#x} not mapped"))
            continue
        if got == d['expect']:
            site_ok.append((d['line'], addr, got))
        else:
            site_fail.append((d['line'], addr, got, d['expect']))

    applies = (not parse_errors and not let_errors
               and not site_fail and not site_unresolved
               and len(site_ok) > 0)
    return {
        'status': 'applies' if applies else 'no-match',
        'applies': applies,
        'site_ok': site_ok,
        'site_fail': site_fail,
        'site_unresolved': site_unresolved,
        'let_errors': let_errors,
        'parse_errors': parse_errors,
        'legacy': legacy,
        'no_expect': no_expect,
    }


# ----------------------------------------------------------------------
# CLI
# ----------------------------------------------------------------------
def _one_line_summary(report):
    if report['status'] == 'binary_stripped':
        return "binary stripped (no LC_SYMTAB)"
    ok = len(report['site_ok'])
    fail = len(report['site_fail'])
    unres = len(report['site_unresolved'])
    lets = len(report['let_errors'])
    pe = len(report['parse_errors'])
    total = ok + fail + unres
    if report['applies']:
        return f"APPLIES  {ok}/{total} sites ok"
    if total == 0 and (report['legacy'] or report['no_expect']):
        return (f"unvalidatable  {report['legacy']} legacy / "
                f"{report['no_expect']} no-expect lines")
    parts = [f"{ok}/{total} sites ok"]
    if fail:
        parts.append(f"{fail} bytes differ")
    if unres:
        parts.append(f"{unres} unresolved")
    if lets:
        parts.append(f"{lets} bad let")
    if pe:
        parts.append(f"{pe} parse-error")
    return "no-match  " + ", ".join(parts)


def _verbose_detail(name, report):
    lines = [f"== {name} =="]
    for ln, addr, got in report['site_ok']:
        lines.append(f"  line {ln}: ok at {addr:#x} = {got:#010x}")
    for ln, addr, got, exp in report['site_fail']:
        lines.append(f"  line {ln}: FAIL at {addr:#x} "
                     f"got {got:#010x} expected {exp:#010x}")
    for ln, err in report['site_unresolved']:
        lines.append(f"  line {ln}: UNRESOLVED {err}")
    for ln, lbl, err in report['let_errors']:
        lines.append(f"  line {ln}: bad let '{lbl}' — {err}")
    for d in report['parse_errors']:
        lines.append(f"  line {d['line']}: parse error: {d['text']}")
    if report['legacy']:
        lines.append(f"  ({report['legacy']} legacy lines, not validated)")
    if report['no_expect']:
        lines.append(f"  ({report['no_expect']} at-lines without expect)")
    lines.append(f"  -> {_one_line_summary(report)}")
    return "\n".join(lines)


def main(argv):
    ap = argparse.ArgumentParser(add_help=False, description=__doc__)
    ap.add_argument('binary')
    ap.add_argument('patchfile', nargs='?')
    ap.add_argument('--patches', default=None)
    ap.add_argument('-v', '--verbose', action='store_true')
    ap.add_argument('-h', '--help', action='store_true')
    args = ap.parse_args(argv[1:])
    if args.help:
        print(__doc__)
        return 0

    binary = Path(args.binary)

    if args.patchfile:
        r = check(Path(args.patchfile), binary)
        if args.verbose:
            print(_verbose_detail(args.patchfile, r))
        else:
            print(f"{args.patchfile}: {_one_line_summary(r)}")
        return 0 if r['applies'] else 1

    patches_dir = Path(args.patches) if args.patches else (
        Path(__file__).resolve().parent.parent / 'patches')
    files = sorted(patches_dir.glob('*.conf'))
    if not files:
        print(f"no .conf files in {patches_dir}", file=sys.stderr)
        return 1

    reports = {f: check(f, binary) for f in files}
    applies = [f for f, r in reports.items() if r['applies']]

    print(f"binary: {binary}")
    print(f"patches: {patches_dir}")
    for f in files:
        marker = "*" if reports[f]['applies'] else " "
        print(f"  {marker} {f.name}: {_one_line_summary(reports[f])}")
    if args.verbose:
        print()
        for f in files:
            print(_verbose_detail(f.name, reports[f]))
            print()

    if len(applies) == 1:
        print(f"selected: {applies[0].name}")
        return 0
    if not applies:
        print("selected: NONE — binary is not recognised by any patchset")
        return 1
    print(f"selected: AMBIGUOUS — {[p.name for p in applies]}")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
