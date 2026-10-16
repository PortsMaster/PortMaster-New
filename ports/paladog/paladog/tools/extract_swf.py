#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Paladog SWF Asset Extractor for PortMaster
Extracts atlases, sounds, animations, database files, and embed logos directly from Paladog.swf.
Uses ONLY Python standard library (zlib, struct, os, sys, re, shutil).
Zero third-party dependencies.
"""
import os
import sys
import zlib
import struct
import re
import shutil

def _make_png(w, h, rows):
    def chunk(tag, payload):
        crc = zlib.crc32(tag + payload) & 0xffffffff
        return struct.pack('>I', len(payload)) + tag + payload + struct.pack('>I', crc)
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    raw_scanlines = b''.join(b'\x00' + row for row in rows)
    idat = zlib.compress(raw_scanlines, 6)
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')

def extract_paladog_swf(swf_path, out_assets_dir, patch_dir=None):
    if not os.path.isfile(swf_path):
        print(f"Error: SWF file not found: {swf_path}")
        return False

    print(f"Opening SWF: {swf_path}")
    with open(swf_path, 'rb') as f:
        header = f.read(8)
        if len(header) < 8:
            print("Error: Invalid SWF header.")
            return False
        # If compressed (CWS), decompress after 8 bytes
        if header[:3] == b'CWS':
            body = zlib.decompress(f.read())
        elif header[:3] == b'FWS':
            body = f.read()
        else:
            print(f"Error: Unsupported SWF magic: {header[:3]}")
            return False

    print(f"Decompressed SWF body: {len(body) / (1024*1024):.1f} MB")

    # Pass 1: Parse SymbolClass tags (Tag 76)
    nb = body[0] >> 3
    pos = (5 + nb * 4 + 7) // 8 + 4
    symbols = {}
    tags = []

    while pos < len(body):
        h = struct.unpack('<H', body[pos:pos+2])[0]
        pos += 2
        t = h >> 6
        l = h & 0x3F
        if l == 0x3F:
            l = struct.unpack('<I', body[pos:pos+4])[0]
            pos += 4
        
        if t == 76:  # SymbolClass
            n = struct.unpack('<H', body[pos:pos+2])[0]
            cur = pos + 2
            for _ in range(n):
                tid = struct.unpack('<H', body[cur:cur+2])[0]
                cur += 2
                end = body.find(b'\x00', cur)
                name = body[cur:end].decode('latin1')
                cur = end + 1
                symbols[tid] = name
        elif t in (87, 14, 36):  # DefineBinaryData (87), DefineSound (14), DefineBitsLossless2 (36)
            tags.append((t, pos, l))

        pos += l

    print(f"Parsed {len(symbols)} symbol mappings and {len(tags)} asset tags.")

    atlases_dir = os.path.join(out_assets_dir, 'atlases')
    audio_dir = os.path.join(out_assets_dir, 'audio')
    data_dir = os.path.join(out_assets_dir, 'data')
    anim_dir = os.path.join(out_assets_dir, 'anim')
    embed_dir = os.path.join(out_assets_dir, 'embed')

    os.makedirs(atlases_dir, exist_ok=True)
    os.makedirs(audio_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True)
    os.makedirs(anim_dir, exist_ok=True)
    os.makedirs(embed_dir, exist_ok=True)

    fdat_cnt = 0
    snd_cnt = 0
    db_cnt = 0
    ani_cnt = 0
    logo_cnt = 0

    target_logos = {
        'com.fazecat.web.paladog.Library_Logo00Img': 'logo_0.png',
        'com.fazecat.web.paladog.Library_Logo01Img': 'logo_1.png',
        'com.fazecat.web.paladog.Library_Logo02Img': 'logo_2.png',
    }

    # Pass 2: Extract assets
    for t, p, l in tags:
        tid = struct.unpack('<H', body[p:p+2])[0]
        sym = symbols.get(tid, '')

        if t == 87:  # DefineBinaryData
            # 1. Sprite atlases (fDat)
            m_fdat = re.search(r'fDat(\d+)$', sym)
            if m_fdat:
                num = int(m_fdat.group(1))
                dec = zlib.decompress(body[p+6:p+l])
                n = struct.unpack('<I', dec[:4])[0]
                png_bytes = dec[4+n*32:]
                
                with open(os.path.join(atlases_dir, f'fdat_{num}.png'), 'wb') as out_f:
                    out_f.write(png_bytes)
                with open(os.path.join(atlases_dir, f'fdat_{num}.txt'), 'w', encoding='ascii') as out_f:
                    out_f.write(f'{n}\n')
                    for i in range(n):
                        ax, ay, ow, oh, sx, sy, w, h = struct.unpack('<8i', dec[4+i*32:36+i*32])
                        out_f.write(f'{ax} {ay} {ow} {oh} {sx} {sy} {w} {h}\n')
                fdat_cnt += 1
                continue

            # 2. Database files (DB)
            m_db = re.search(r'DB(\d+)$', sym)
            if m_db:
                num = int(m_db.group(1))
                raw = body[p+6:p+l]
                try:
                    dec = zlib.decompress(raw)
                except Exception:
                    dec = raw
                with open(os.path.join(data_dir, f'db_{num}.bin'), 'wb') as out_f:
                    out_f.write(dec)
                db_cnt += 1
                continue

            # 3. Animations (fAni)
            m_ani = re.search(r'fAni(\d+)$', sym)
            if m_ani:
                num = int(m_ani.group(1))
                raw = body[p+6:p+l]
                try:
                    dec = zlib.decompress(raw)
                except Exception:
                    dec = raw
                with open(os.path.join(anim_dir, f'ani_{num}.bin'), 'wb') as out_f:
                    out_f.write(dec)
                ani_cnt += 1
                continue

        elif t == 14:  # DefineSound
            m_snd = re.search(r'snd(\d+)$', sym)
            if m_snd:
                num = int(m_snd.group(1))
                # Skip 2 bytes SeekSamples header for MP3
                mp3_bytes = body[p+7+2:p+l]
                with open(os.path.join(audio_dir, f'snd_{num}.mp3'), 'wb') as out_f:
                    out_f.write(mp3_bytes)
                snd_cnt += 1
                continue

        elif t == 36:  # DefineBitsLossless2 (Embed Logos)
            if sym in target_logos:
                fname = target_logos[sym]
                w, h = struct.unpack('<HH', body[p+3:p+7])
                decomp = zlib.decompress(body[p+7:p+l])
                rows = []
                for y in range(h):
                    row = bytearray(w * 4)
                    sl = decomp[y*w*4 : (y+1)*w*4]
                    for x in range(w):
                        a = sl[x*4]
                        r = sl[x*4+1]
                        g = sl[x*4+2]
                        b = sl[x*4+3]
                        if 0 < a < 255:
                            r = min(255, int(r * 255 / a))
                            g = min(255, int(g * 255 / a))
                            b = min(255, int(b * 255 / a))
                        row[x*4] = r
                        row[x*4+1] = g
                        row[x*4+2] = b
                        row[x*4+3] = a
                    rows.append(bytes(row))
                png_bytes = _make_png(w, h, rows)
                with open(os.path.join(embed_dir, fname), 'wb') as out_f:
                    out_f.write(png_bytes)
                logo_cnt += 1
                continue

    print(f"Extraction summary: {fdat_cnt} atlases, {snd_cnt} sounds, {db_cnt} DB files, {ani_cnt} animations, {logo_cnt} logos.")

    # Apply custom handheld patches if provided
    if patch_dir and os.path.isdir(patch_dir):
        patched_count = 0
        for f in os.listdir(patch_dir):
            if f.endswith('.png') or f.endswith('.txt'):
                src = os.path.join(patch_dir, f)
                dst = os.path.join(atlases_dir, f)
                shutil.copy2(src, dst)
                patched_count += 1
        if patched_count > 0:
            print(f"Applied {patched_count} handheld patch files from {patch_dir}.")

    return fdat_cnt > 0 and db_cnt > 0 and logo_cnt > 0

def main():
    if len(sys.argv) < 3:
        print("Usage: extract_swf.py <Paladog.swf> <output_assets_dir> [patch_dir]")
        sys.exit(1)

    swf = sys.argv[1]
    out = sys.argv[2]
    patch = sys.argv[3] if len(sys.argv) > 3 else None

    success = extract_paladog_swf(swf, out, patch)
    if not success:
        sys.exit(1)
    print("All assets extracted successfully!")

if __name__ == '__main__':
    main()
