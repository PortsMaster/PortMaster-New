import zlib
import os
import subprocess
from PIL import Image

# Resolve relative to this file's own location instead of a hardcoded
# absolute path - the runtime isn't guaranteed to live at
# /opt/chowdren-runtime on every CFW (confirmed convention per PortMaster
# docs is $controlfolder/runtimes/<name>/, which varies by device/CFW).
# This file lives at <runtime>/chowdren/Chowdren/chowdren/imageworker.py,
# so tools/astcenc-native is four levels up.
_RUNTIME_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))
ASTCENC = os.path.join(_RUNTIME_ROOT, 'tools', 'astcenc-native')
# Detects whether the ASTC encoder is actually present and runnable.
# image.cpp does its own runtime GL_EXTENSIONS check per-image and falls
# back to zlib gracefully if the driver doesn't advertise
# GL_KHR_texture_compression_astc_ldr, so this only needs to gate whether
# conversion attempts ASTC at all - not guess about driver support here.
USE_ASTC = os.path.exists(ASTCENC) and os.access(ASTCENC, os.X_OK)

# Pre-generated guides (see tools/astcenc-bmd-guide) let the encoder skip
# its block-mode/partition search entirely for any image whose pixel
# content exactly matches what the guide was built from - same shape as
# Bastion's --guide-in against a shipped guides/ dir, just matched
# per-image here instead of per-package-archive. Guide quality is
# inherited from whatever preset generated it, not from anything passed
# here, so the quality flag alongside -guide-in below is cosmetic.
GUIDES_DIR = os.path.join(_RUNTIME_ROOT, 'guides')
USE_GUIDES = os.path.isdir(GUIDES_DIR)
if USE_ASTC:
    if USE_GUIDES:
        print 'Using ASTC -Guides'
    else:
        print 'Using ASTC -noguides'

def worker(in_queue):
    while True:
        obj = in_queue.get()
        if obj is None:
            return
        data, index, p, cache_path, size = obj
        print 'Compressing %s (%s)' % (index, p)
        astc_ok = False
        if USE_ASTC:
            tmp_png = cache_path + '.tmp.png'
            tmp_astc = cache_path + '.tmp.astc'
            try:
                pil_img = Image.frombytes('RGBA', size, data)
                pil_img.save(tmp_png, format='PNG')

                guide_path = os.path.join(
                    GUIDES_DIR,
                    os.path.splitext(os.path.basename(cache_path))[0] + '.guide')
                if USE_GUIDES and os.path.isfile(guide_path):
                    # Checksum in the guide is matched against these exact
                    # pixel bytes by astcenc itself - a mismatch (different
                    # .exe/game version than the guide was built from)
                    # just falls back to a normal full search on its own,
                    # same as Bastion's tool does, no extra handling needed
                    # here.
                    cmd = [ASTCENC, '-cl', tmp_png, tmp_astc, '8x8',
                           '-thorough', '-guide-in', guide_path]
                else:
                    cmd = [ASTCENC, '-cl', tmp_png, tmp_astc, '8x8', '-fastest']
                ret = subprocess.call(cmd,
                                      stdout=open(os.devnull, 'wb'),
                                      stderr=open(os.devnull, 'wb'))
                if ret == 0 and os.path.exists(tmp_astc):
                    astc_data = open(tmp_astc, 'rb').read()
                    open(cache_path, 'wb').write('\x01' + astc_data)
                    if USE_GUIDES and os.path.isfile(guide_path):
                        print 'ASTC guided ok %s' % index
                    else:
                        print 'ASTC ok %s' % index
                    astc_ok = True
                else:
                    print 'ASTC encoder returned %s for image %s' % (ret, index)
            except Exception as e:
                print 'ASTC exception %s: %s' % (index, e)
            finally:
                if os.path.exists(tmp_png): os.remove(tmp_png)
                if os.path.exists(tmp_astc): os.remove(tmp_astc)
        if not astc_ok:
            print 'Falling back to zlib for image %s' % index
            data = zlib.compress(data, 6)
            open(cache_path, 'wb').write('\x00' + data)
