"""Util functions."""

import sys

from .enums import RESULT
from .exceptions import FmodError


def ckresult(result):
    """Check if the result of our C API call is OK.

    :param RESULT result: C API call return code.
    :raises FmodError: when return code from C API call is not OK.
    """
    result = RESULT(result)
    if result is not RESULT.OK:
        raise FmodError(result)


def check_type(obj, cls, msg="Bad type of passed argument (%s), expected %s"):
    """Verify if a given object is of a given type.

    :param object obj: Object to verify.
    :param class cls: Class to verify against.
    :param str msg: Error message when TypeError is raised.
    :raises TypeError: when object is not an instance of the expected class.
    """
    if not isinstance(obj, cls):
        raise TypeError(msg % (str(type(obj)), str(cls)))


def prepare_str(string, encoding=None):
    """Encode a string to the file system encoding of our host.

    Does nothing if string cannot be encoded.

    :param str string: String to encode.
    :param str encoding: Override encoding to use instead of native file system
        encoding.
    :returns: Encoded string.
    :rtype: str
    """
    if not encoding:
        encoding = sys.getfilesystemencoding()
    if hasattr(string, "encode"):
        return string.encode(encoding)
    return string
