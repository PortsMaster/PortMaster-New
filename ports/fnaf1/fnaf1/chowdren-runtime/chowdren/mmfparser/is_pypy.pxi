# Shared Cython compile-time constant. Referenced via `IF`/`DEF` blocks in
# bytereader.pxd/.pyx and loader.pyx. This runtime's original build system
# (not included in this distribution - see setup_x64.py's own notes)
# apparently supplied this some other way; this file replaces that missing
# piece for a native x86_64 build under regular CPython (not PyPy).
DEF IS_PYPY = False
