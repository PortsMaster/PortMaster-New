"""Util method to get the FMOD LIBRARY from the filesystem into ctypes."""

import os
import platform
import sys

arch = platform.architecture()[0]
if os.name == "nt":
    from ctypes import windll
    library_type = windll
    LIBRARY_NAME = "fmodstudio"
elif os.name == "posix":
    from ctypes import cdll
    library_type = cdll
    LIBRARY_NAME = "libfmodstudio.so"

LIBRARY = None

if os.environ.get("PYFMODEX_STUDIO_DLL_PATH") is not None:
    LIBRARY_NAME = os.environ.get("PYFMODEX_STUDIO_DLL_PATH")

def get_library():
    """Load libary file according to architecture's ctype method."""
    global LIBRARY
    if not LIBRARY:
        try:
            LIBRARY = library_type.LoadLibrary(LIBRARY_NAME)
        except:
            current_directory = os.path.dirname(os.path.realpath(sys.argv[0]))
            try:
                LIBRARY = library_type.LoadLibrary(os.path.join(current_directory, LIBRARY_NAME))
            except:
                raise RuntimeError(
                    "Pyfmodex could not find the " + LIBRARY_NAME + " library")

    return LIBRARY
