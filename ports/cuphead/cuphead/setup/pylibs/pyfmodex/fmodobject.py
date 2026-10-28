"""A base FMOD object."""

from .globalvars import DLL as _dll
from .utils import ckresult


class FmodObject(object):
    """A base FMOD object.

    All classes wrapped from the C library can subclass this one.
    """

    def __init__(self, ptr):
        """Constructor.

        :param ptr: The pointer representing this object.
        """
        self._ptr = ptr
        self._cb = None

    def _call_fmod(self, funcname, *args):
        result = getattr(_dll, funcname)(self._ptr, *args)
        ckresult(result)

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self._ptr.value == other._ptr.value
        return False
