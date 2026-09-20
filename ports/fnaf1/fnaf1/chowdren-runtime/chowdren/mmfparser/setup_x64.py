# Native x86_64 build script for mmfparser's Cython extensions.
#
# The runtime as distributed only ships pre-built aarch64 .so files (per
# its own README: "mmfparser (arm64 .so)") - there is no upstream setup.py,
# since it was never intended to be rebuilt on another architecture. This
# script compiles the same .pyx sources natively for x86_64 instead, so the
# exe -> C++ conversion step (chowdren.run) can run directly on a desktop
# Linux dev machine without QEMU.
#
# Usage (from this directory):
#   python2.7 setup_x64.py build_ext --inplace
#
# Requires: cython, and gcc/g++ (already installed via build-essential).

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

# IS_PYPY is referenced via Cython IF/DEF blocks in bytereader.pyx and
# loader.pyx but never defined anywhere in this tree (likely normally
# supplied by a build system not included in this runtime's distribution).
# We're running under CPython 2.7, not PyPy, so this is correctly False.
compile_time_env = {'IS_PYPY': False}

extensions = [
    Extension("bytereader", ["bytereader.pyx"]),
    Extension("common", ["common.pyx"]),
    Extension(
        "gperf", ["gperf.pyx"],
        language="c++",
    ),
    Extension(
        "image", ["image.pyx"],
        # stb_image.c is included directly via `cdef extern from "stb_image.c"`
        # in image.pyx itself, so no separate source entry is needed here -
        # Cython/the C compiler pulls it in via the extern include.
    ),
    Extension("loader", ["loader.pyx"]),
    Extension(
        "texpack", ["texpack.pyx"],
        language="c++",
    ),
    Extension(
        "webp", ["webp.pyx"],
        language="c++",
    ),
    Extension(
        "zopfli", ["zopfli.pyx"],
        language="c++",
    ),
]

setup(
    name="mmfparser-native-ext",
    ext_modules=cythonize(
        extensions,
        compiler_directives={'language_level': 2},  # this codebase is Python 2
        # loader.pxd does `from mmfparser.bytereader cimport ByteReader` -
        # treating mmfparser as an installed package. Since we're building
        # in-place from loose files (not an installed package), point
        # Cython's include path at the parent dir so `mmfparser.<module>`
        # resolves back to this same directory.
        include_path=['..'],
    ),
)
