"""NOPs FTL's glBindRenderbuffer(GL_RENDERBUFFER, 0), which gl4es rejects, failing the
game's scaling FBO. The call is found by its surrounding bytes."""

import re
import sys

# mov (%rsp),%esi; mov $GL_RENDERBUFFER,%edi; call glBindRenderbuffer; add $0x18,%rsp
HEAD = b"\x8b\x34\x24\xbf\x41\x8d\x00\x00"
CALL = b"\xe8...."
TAIL = b"\x48\x83\xc4\x18"
# Multi-byte nop, as long as the call it replaces.
NOP =b"\x0f\x1f\x44\x00\x00"


def main(path):
    """Patches the binary at path in place; leaves it as is unless the call matches once."""
    with open(path, "r+b") as f:
        data = f.read()
        calls = [m.start() + len(HEAD)
                 for m in re.finditer(re.escape(HEAD) + CALL + re.escape(TAIL), data, re.DOTALL)]
        if len(calls) == 1:
            f.seek(calls[0])
            f.write(NOP)
            print(f"fbo_patch: renderbuffer rebind at {calls[0]} replaced by a NOP")
        elif data.count(HEAD + NOP + TAIL) == 1:
            print("fbo_patch: already patched")
        else:
            print(f"fbo_patch: {len(calls)} matches, binary left as is; scaling may not work")


if __name__ == "__main__":
    main(sys.argv[1])
