chowdren-runtime — PortMaster runtime for Chowdren-based ports
==============================================================

Bundles everything needed to convert and build Clickteam Fusion games
(Five Nights at Freddy's, Knytt Stories, etc.) on-device:

- Trimmed GCC 8.3 (aarch64) — C++ compiler proper
- Python 2.7 + Cython 0.29 + Pillow — for the conversion step
- mmfparser (arm64 .so) — Clickteam Fusion .exe decoder
- Chowdren codegen — recompiles event graphs to C++
- CMake 3.13 + system make — builds the generated tree

Per-port packages (fnaf-1.zip, fnaf-2.zip etc.) are tiny and depend on
this runtime via PortMaster's runtime mechanism.

Driver entry point: bin/chowdren-build
License: GPL3 (see COPYING.txt). Mathias Kaerlev's original copyright applies.

Layout:
  toolchain/   — gcc, cmake, runtime libs
  python27/    — Python 2.7 + stdlib + site-packages (Cython, PIL, pip)
  chowdren/    — Chowdren codegen + base/ runtime + mmfparser
  bin/         — chowdren-build driver

Total disk: ~200 MB.
