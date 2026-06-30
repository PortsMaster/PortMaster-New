#!/usr/bin/env python3
"""
Disc Creatures - PortMaster Launch Patcher
Patches Game.rgss3a IN-PLACE to stub out Win32API calls in:
  - Script 180: 画像保存 (image save, uses kernel32/gdi32/gdiplus)
  - Script 183: 音量変更スクリプトさん (volume settings, uses kernel32 INI functions)
Modifies only the Scripts size field (4 bytes) and Scripts blob content.
Archive stays the same size as the original.
"""
import struct, zlib, os, sys

GAMEDIR = os.path.dirname(os.path.abspath(__file__))
ARCHIVE = os.path.join(GAMEDIR, "Game.rgss3a")
MARKER  = os.path.join(GAMEDIR, "patchlog.txt")

STUB_180 = b'# Win32API stub for Linux/ARM (PortMaster)\nmodule GDIP\n  module_function\n  def MultiByteToWideChar(str); ""; end\n  def GetDC(hwnd); 0; end\n  def ReleaseDC(hwnd, hdc); end\n  def CopyDC(dest, src, w, h); end\n  def CreateCompatibleDC(hdc); 0; end\n  def CreateCompatibleBitmap(hdc, w, h); 0; end\n  def SelectObject(hdc, obj); false; end\n  def DeleteDC(hdc); end\n  def DeleteObject(obj); end\n  def GdiplusStartup(token); false; end\n  def GdipCreateImageFromBitmap(b); nil; end\n  def GdipCreateImageFromHBITMAP(h); nil; end\n  def GdipSaveImageToFile(i,f,c); end\n  def GdipImageConvertPixelFormat(i,p); end\n  def GdipDisposeImage(i); end\n  def GdiplusShutdown(t); end\n  def UuidFromString(c); ""; end\nend\nclass Bitmap\n  def save(fn, type, back=nil); end\n  def save_png(fn, alpha=false); end\nend\nmodule Graphics\n  def self.save_screen(fn, type); end\nend\n'

STUB_183_INI = b'''  unless defined?(HZM_VXA::Ini)
    module HZM_VXA
      class Ini
        INI_FILENAME = "./Game.ini"
        def self.load(section, key)
          return 100 unless File.exist?(INI_FILENAME)
          in_sec = false
          File.foreach(INI_FILENAME) do |line|
            line = line.strip
            if line =~ /^\\[(.+)\\]$/
              in_sec = ($1.downcase == section.downcase)
            elsif in_sec && line =~ /^([^=]+)=(.*)$/
              return $2.strip.to_i if $1.strip.downcase == key.downcase
            end
          end
          100
        rescue
          100
        end
        def self.save(section, key, value)
          lines = File.exist?(INI_FILENAME) ? File.readlines(INI_FILENAME) : []
          in_sec = false; sec_found = false; key_written = false; result = []
          lines.each do |line|
            stripped = line.strip
            if stripped =~ /^\\[(.+)\\]$/
              if in_sec && !key_written
                result << "#{key}=#{value.to_i}\\n"; key_written = true
              end
              in_sec = ($1.downcase == section.downcase)
              sec_found = true if in_sec
              result << line
            elsif in_sec && stripped =~ /^([^=]+)=/
              if $1.strip.downcase == key.downcase
                result << "#{key}=#{value.to_i}\\n"; key_written = true
              else
                result << line
              end
            else
              result << line
            end
          end
          unless sec_found
            result << "\\n[#{section}]\\n#{key}=#{value.to_i}\\n"; key_written = true
          end
          result << "#{key}=#{value.to_i}\\n" if in_sec && !key_written
          File.open(INI_FILENAME, "w") {|f| f.write(result.join)}
          true
        rescue
          false
        end
      end
    end
  end
'''

# ── RGSS3a helpers ─────────────────────────────────────────────────────────────

def rgss3a_master_key(base):
    return (base * 9 + 3) & 0xFFFFFFFF

def decrypt_field(raw4, key):
    return struct.unpack('<I', raw4)[0] ^ key

def decrypt_bytes_fixed(raw, key):
    out = bytearray(len(raw))
    for i in range(len(raw)):
        out[i] = raw[i] ^ ((key >> (8*(i % 4))) & 0xFF)
    return bytes(out)

def crypt_file(raw, file_key):
    key = file_key
    out = bytearray(len(raw))
    for i in range(0, len(raw), 4):
        chunk = min(4, len(raw) - i)
        for j in range(chunk):
            out[i+j] = raw[i+j] ^ ((key >> (8*j)) & 0xFF)
        key = (key * 7 + 3) & 0xFFFFFFFF
    return bytes(out)

def parse_file_table(data, k1):
    pos = 12
    files = []
    while pos + 16 <= len(data):
        file_offset = decrypt_field(data[pos:pos+4],    k1)
        file_size   = decrypt_field(data[pos+4:pos+8],  k1)
        outer_nl    = decrypt_field(data[pos+8:pos+12], k1)
        inner_nl    = decrypt_field(data[pos+12:pos+16],k1)
        if inner_nl == 0 or inner_nl > 512 or file_offset == 0:
            break
        name = decrypt_bytes_fixed(data[pos+16:pos+16+inner_nl], k1).decode('utf-8','replace').replace('\\','/')
        files.append({'name':name,'offset':file_offset,'size':file_size,
                      'outer_nl':outer_nl,'inner_nl':inner_nl,'table_pos':pos})
        pos += 16 + inner_nl
    return files

# ── Marshal helpers ────────────────────────────────────────────────────────────

class MarshalParser:
    def __init__(self, d): self.d=d; self.p=2; self.sym=[]
    def rb(self): b=self.d[self.p]; self.p+=1; return b
    def ri(self):
        b=self.rb()
        if b==0: return 0
        if b>4: return b-5
        if b>0x80:
            b=b-256
            if b==-1: return -1
            r=-1
            for i in range(-b): r&=~(0xff<<(8*i)); r|=self.rb()<<(8*i)
            return r
        if 1<=b<=4:
            r=0
            for i in range(b): r|=self.rb()<<(8*i)
            return r
        return b
    def rs(self): n=self.ri(); s=self.d[self.p:self.p+n]; self.p+=n; return s
    def pv(self):
        t=self.rb()
        if t==48:  return None
        if t==84:  return True
        if t==70:  return False
        if t==105: return self.ri()
        if t==34:  return self.rs()
        if t==58:  s=self.rs(); self.sym.append(s); return s
        if t==59:  return self.sym[self.ri()]
        if t==91:  n=self.ri(); return [self.pv() for _ in range(n)]
        if t==73:
            val=self.pv(); n=self.ri(); iv={}
            for _ in range(n): k=self.pv(); v=self.pv(); iv[k]=v
            if isinstance(val,bytes) and iv.get(b'E')==True:
                try: return val.decode('utf-8')
                except: pass
            return val
        if t==64: return self.ri()
        raise ValueError(f"Unknown type {t:#x} @ {self.p-1}")

class MarshalWriter:
    def __init__(self): self.b=bytearray(b'\x04\x08'); self.sym={}
    def wb(self,b): self.b.append(b)
    def wi(self,n):
        if n==0: self.b.append(0); return
        if 0<n<123: self.b.append(n+5); return
        if n>0:
            nb=1 if n<=0xFF else 2 if n<=0xFFFF else 3 if n<=0xFFFFFF else 4
            self.b.append(nb)
            for i in range(nb): self.b.append((n>>(8*i))&0xFF)
            return
        if n==-1: self.b.append(0xFF); return
        if n>=-123: self.b.append((n+256-5)&0xFF); return
        nb=1 if n>=-0x100 else 2 if n>=-0x10000 else 3 if n>=-0x1000000 else 4
        self.b.append(256-nb)
        for i in range(nb): self.b.append((n>>(8*i))&0xFF)
    def ws(self,s):
        if isinstance(s,str): s=s.encode('utf-8')
        self.wi(len(s)); self.b.extend(s)
    def wv(self,v):
        if v is None:  self.wb(48); return
        if v is True:  self.wb(84); return
        if v is False: self.wb(70); return
        if isinstance(v,int):   self.wb(105); self.wi(v); return
        if isinstance(v,(bytes,str)):
            self.wb(73); self.wb(34)
            enc=v.encode('utf-8') if isinstance(v,str) else v
            self.ws(enc); self.wi(1)
            E=b'E'
            if E in self.sym: self.wb(59); self.wi(self.sym[E])
            else: self.sym[E]=len(self.sym); self.wb(58); self.ws(E)
            self.wb(84); return
        if isinstance(v,list):
            self.wb(91); self.wi(len(v))
            for x in v: self.wv(x)
            return
        raise ValueError(f"Can't marshal {type(v)}: {v!r}")
    def get(self): return bytes(self.b)

def patch_script_183(code_bytes):
    code = code_bytes.decode('utf-8', 'replace')
    start_marker = '  unless defined?(HZM_VXA::Ini)'
    start = code.find(start_marker)
    if start == -1:
        print("[patcher] WARNING: could not find INI block in script 183")
        return code_bytes
    depth = 0
    consumed = 0
    for line in code[start:].splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith('module ') or stripped.startswith('class ') or \
           stripped.startswith('def ') or stripped.startswith('if ') or \
           stripped == 'unless defined?(HZM_VXA::Ini)':
            depth += 1
        if stripped == 'end':
            depth -= 1
            if depth == 0:
                consumed += len(line)
                break
        consumed += len(line)
    end = start + consumed
    return code[:start].encode('utf-8') + STUB_183_INI + code[end:].encode('utf-8')

# ── Main patch ─────────────────────────────────────────────────────────────────

def patch():
    print("[patcher] Reading Game.rgss3a...")
    with open(ARCHIVE, 'rb') as f:
        data = bytearray(f.read())

    base_key = struct.unpack('<I', data[8:12])[0]
    k1 = rgss3a_master_key(base_key)

    files = parse_file_table(bytes(data), k1)
    scripts_entry = next((f for f in files if f['name'].endswith('Scripts.rvdata2')), None)
    if not scripts_entry:
        print("[patcher] ERROR: Scripts.rvdata2 not found!")
        return False

    off = scripts_entry['offset']
    sz  = scripts_entry['size']
    fk  = scripts_entry['outer_nl']
    tp  = scripts_entry['table_pos']
    print(f"[patcher] Scripts.rvdata2 at offset {off}, size {sz}")

    plain = crypt_file(bytes(data[off:off+sz]), fk)

    mp = MarshalParser(plain)
    mp.rb()
    count = mp.ri()
    scripts = [mp.pv() for _ in range(count)]

    # Patch script 180
    name_180 = scripts[180][1]
    if isinstance(name_180, bytes): name_180 = name_180.decode('utf-8','replace')
    print(f"[patcher] Patching script 180: '{name_180}'")
    old = scripts[180]
    scripts[180] = [old[0], old[1], zlib.compress(STUB_180)]

    # Patch script 183
    name_183 = scripts[183][1]
    if isinstance(name_183, bytes): name_183 = name_183.decode('utf-8','replace')
    print(f"[patcher] Patching script 183: '{name_183}'")
    orig_183 = zlib.decompress(scripts[183][2])
    new_183  = patch_script_183(orig_183)
    old = scripts[183]
    scripts[183] = [old[0], old[1], zlib.compress(new_183)]

    # Verify
    for idx in [180, 183]:
        code = zlib.decompress(scripts[idx][2]).decode('utf-8','replace')
        if 'Win32API.new' in code:
            print(f"[patcher] ERROR: Win32API.new still present in script {idx}!")
            return False

    # Repack Marshal
    mw = MarshalWriter()
    mw.wb(91); mw.wi(len(scripts))
    for s in scripts: mw.wv(s)
    new_plain = mw.get()
    print(f"[patcher] Marshal: {len(plain)} -> {len(new_plain)} bytes")

    # Re-encrypt
    new_enc = crypt_file(new_plain, fk)
    new_sz  = len(new_enc)

    if new_sz > sz:
        print(f"[patcher] ERROR: new size {new_sz} > original {sz}. Cannot patch.")
        return False

    # Modify archive IN-PLACE:
    # 1. Overwrite Scripts blob (leave any trailing bytes from old blob as-is)
    # 2. Update size field in file table
    # This preserves the null terminator and all other structure.
    print(f"[patcher] Patching archive in-place ({new_sz} bytes into {sz} byte slot)...")
    data[off:off+new_sz] = new_enc
    data[tp+4:tp+8] = struct.pack('<I', new_sz ^ k1)

    tmp = ARCHIVE + ".tmp"
    with open(tmp, 'wb') as f:
        f.write(data)
    os.replace(tmp, ARCHIVE)

    with open(MARKER, 'w') as f:
        f.write("Disc Creatures patched successfully.\n")

    print("[patcher] Done!")
    return True

if __name__ == "__main__":
    if os.path.exists(MARKER):
        print("[patcher] Already patched.")
    else:
        if not patch():
            print("[patcher] Patch FAILED!")
            sys.exit(1)
