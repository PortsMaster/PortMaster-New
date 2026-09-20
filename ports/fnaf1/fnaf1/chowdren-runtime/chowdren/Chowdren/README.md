========
Chowdren
========

This is Chowdren, the blazingly fast C++ runtime and recompiler for
Clickteam Fusion.

It converts events and objects to native C++, resulting in much faster
applications.

To use it, first build the mmfparser extension modules, then run the following
from this directory:

```python -m chowdren.run <exename> <outdir>```

See `python -m chowdren.run --help` for more options.

You will need CMake to generate the C++ makefile or projectfile, after
which you can use your native compilers to compile the application.