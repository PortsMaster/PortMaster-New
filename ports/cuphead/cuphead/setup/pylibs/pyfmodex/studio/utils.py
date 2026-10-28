"""Handy util methods."""

import pyfmodex


def fmod_version():
    """FMOD API version number."""
    system = pyfmodex.System()
    version = system.version
    system.close()
    system.release()
    return version
