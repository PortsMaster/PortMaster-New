#!/usr/bin/env python3
"""Makes the pixel shaders FNA3D builds for GLSL ES run at high precision.

MojoShader, built into libFNA3D.so.0, declares every GLSL ES pixel shader mediump, which
handheld GPUs keep in 16-bit floats; the game's VHS and static effects overflow there.
The declaration is replaced in place by a highp one of the same length.

    fna3d-highp.py libFNA3D.so.0
"""
import sys

MEDIUMP = b"precision mediump float;"
# Padded to MEDIUMP's length, so nothing else in the library moves.
HIGHP = b"precision highp   float;"


def patch(data):
    """Swaps the pixel shaders' precision declaration; returns the patched library.

    Raises ValueError unless the library holds the declaration exactly once.
    """
    found = data.count(MEDIUMP)
    if found != 1:
        raise ValueError(f"{found} mediump declarations, expected 1")
    return data.replace(MEDIUMP, HIGHP)


if __name__ == "__main__":
    path = sys.argv[1]
    with open(path, "rb") as f:
        library = f.read()
    with open(path, "wb") as f:
        f.write(patch(library))
