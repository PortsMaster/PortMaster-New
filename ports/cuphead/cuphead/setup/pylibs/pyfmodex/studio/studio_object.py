"""Parent class for most other classes related to FMOD Stdio."""

from ..utils import ckresult
from .library import get_library


class StudioObject:
    """A base FMOD studio object."""

    function_prefix = ''  # to be overridden in subclasses
    
    def __init__(self, ptr):
        """Constructor.

        :param ptr: The pointer representing this object.
        """
        self._ptr = ptr
        self._lib = get_library()

    def _call(self, specific_function_suffix, *args):
        func_name = "%s_%s" % (self.function_prefix, specific_function_suffix)
        result = getattr(self._lib, func_name)(self._ptr, *args)
        ckresult(result)

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self._ptr.value == other._ptr.value
        return False

    @property
    def is_valid(self):
        """Check that the System reference is valid and has been initialized.
        """
        func_name = "%s_%s" % (self.function_prefix, "IsValid")
        result = getattr(self._lib, func_name)(self._ptr)
        return bool(result)
