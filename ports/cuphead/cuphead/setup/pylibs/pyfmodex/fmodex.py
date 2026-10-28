"""Load the FMOD C libraries on the host machine.

Raises a RuntimeError when that fails.
"""

# pylint: disable=wrong-import-position
# Doing some initial setup shennanigans here.
#
# pylint: disable=too-many-arguments
# Not our fault... :-)

import os
import platform
import sys
from ctypes import CDLL, c_int, byref

if os.environ.get("PYFMODEX_DLL_PATH") is not None:
    _dll = CDLL(os.environ.get("PYFMODEX_DLL_PATH"))
else:
    arch = platform.architecture()[0]
    if platform.system() == "Windows":
        from ctypes import windll

        try:
            _dll = windll.fmod
        except Exception as exc:
            current_directory = os.path.dirname(os.path.realpath(sys.argv[0]))
            try:
                _dll = CDLL(os.path.join(current_directory, "fmod"))
            except:
                raise RuntimeError("Pyfmodex could not find the fmod library") from exc

    elif platform.system() == "Linux":
        _dll = CDLL("libfmod.so")

    elif platform.system() == "Darwin":
        if arch == "32bit":
            raise RuntimeError("No 32-bit fmod library for Mac Os exists")
        _dll = CDLL("libfmod.dylib")
from . import globalvars

globalvars.DLL = _dll
from .callback_prototypes import DEBUG_CALLBACK
from .structobject import Structobject as so
from .utils import ckresult


def get_disk_busy():
    """Information function to retrieve the state of FMOD disk access.

    Do not use this function to synchronize your own reads with, as due to
    timing, you might call this function and it says False (= it is not busy),
    but the split second after call this function, internally FMOD might set it
    to busy. Use File_SetDiskBusy for proper mutual exclusion as it uses
    semaphores.

    :returns: Busy state of the disk at the current time.
    :rtype: bool
    """
    busy = c_int()
    ckresult(_dll.FMOD_File_GetDiskBusy(byref(busy)))
    return busy.value


def set_disk_busy(busy):
    """Set the busy state for disk access ensuring mutual exclusion of file
    operations.

    If file IO is currently being performed by FMOD this function will block
    until it has completed.

    This function should be called in pairs once to set the state, then again
    to clear it once complete.

    :param bool busy: The busy state where True represent the begining of disk
        access and False represents the end of disk access.
    """
    ckresult(_dll.FMOD_File_SetDiskBusy(busy))


def get_memory_stats(blocking):
    """Get information on the memory usage of FMOD.

    This information is byte accurate and counts all allocs and frees
    internally. This is useful for determining a fixed memory size to make FMOD
    work within for fixed memory machines such as consoles.

    Note that if using :py:meth:`initialize_memory`, the memory usage will be
    slightly higher than without it, as FMOD has to have a small amount of
    memory overhead to manage the available memory.

    :param bool blocking: Flag to indicate whether to favour speed or accuracy.
        Specifying true for this parameter will flush the
        :py:class:`~pyfmodex.dsp.DSP` network to make sure all queued
        allocations happen immediately, which can be costly.
    :returns: Structobject with the following members:

        - currentalloced: Currently allocated memory at time of call.
        - maxalloced: Maximum allocated memory since
          :py:meth:`~pyfmodex.system.System.init` or
          :py:meth:`initialize_memory`.
    :rtype: Structobject
    """
    currenalloced = c_int()
    maxalloced = c_int()
    ckresult(
        _dll.FMOD_Memory_GetStats(byref(currenalloced), byref(maxalloced), blocking)
    )
    return so(current=currenalloced.value, maximum=maxalloced.value)


def initialize_memory(poolmem, poollen, useralloc, userrealloc, userfree, memtypeflags):
    """Specify a method for FMOD to allocate and free memory, either through
    user supplied callbacks or through a user supplied memory memory buffer
    with a fixed size.

    This function must be called before any FMOD
    :py:class:`~pyfmodex.system.System` object is created.

    Valid usage of this function requires either poolmem and poollen or
    useralloc, userrealloc and userfree being set. If 'useralloc' and
    'userfree' are provided without 'userrealloc' the reallocation is
    implemented via an allocation of the new size, copy from old address to
    new, then a free of the old address.

    To find out the required fixed size call :py:meth:`initialize_memory` with
    an overly large pool size (or no pool) and find out the maximum RAM usage
    at any one time with :py:meth:`get_memory_stats`.

    Callback implementations must be thread safe.

    If you specify a fixed size pool that is too small, FMOD will return
    raise an :py:exc:`~pyfmodex.exceptions.FmodError` with code
    :py:attr:`~pyfmodex.enums.RESULT.MEMORY` when the limit of the fixed size
    pool is exceeded. At this point, it's possible that FMOD may become
    unstable. To maintain stability, do not allow FMOD to run out of memory.

    :param c_void_p poolmem: Block of memory of size poollen bytes for FMOD to
        manage, mutually exclusive with useralloc / userrealloc / userfree.
    :param int poollen: Size of poolmem, must be a multiple of 512.
    :param useralloc: Memory allocation callback compatible with ANSI malloc,
        mutually exclusive with poolmem
    :type useralloc: function having a malloc like behavior and signature.
    :param userrealloc: Memory reallocation callback compatible with ANSI
        realloc, mutually exclusive with poolmem.
    :type userrealloc: function having a realloc like behavior and signature
    :param userfree: Memory free callback compatible with ANSI free, mutually
        exclusive with poolmem.
    :type userfree: function having a free like behavior and signature
    :param MEMORY_TYPE memtypeflags: Types of memory callbacks you wish to handle. OR these
        together to handle multiple types.
    """
    ckresult(
        _dll.FMOD_Memory_Initialize(
            poolmem, poollen, useralloc, userrealloc, userfree, memtypeflags
        )
    )


def initialize_debugging(flags, mode, callback, filename):
    """Specify the level and delivery method of log messages when using the
    logging version of FMOD.

    This function will raise an :py:exc:`~pyfmodex.exceptions.FmodError` with
    code :py:attr:`~pyfmodex.enums.RESULT.UNSUPPORTED` when using the
    non-logging (release) versions of FMOD.

    The logging version of FMOD can be recognized by the 'L' suffix in the
    library name, fmodL.dll or libfmodL.so for instance.

    Note that:

     - :py:attr:`~pyfmodex.flags.DEBUG_FLAGS.LEVEL_LOG` produces informational,
       warning and error messages.
     - :py:attr:`~pyfmodex.flags.DEBUG_FLAGS.LEVEL_WARNING` produces warnings
       and error messages.
     - :py:attr:`~pyfmodex.flags.DEBUG_FLAGS.LEVEL_ERROR` produces error
       messages only.

    :param flags: Debug level, type and display control flags. More than one
        mode can be set at once by combining them with the OR operator.
    :type flags: DEBUG_FLAGS
    :param mode: Destination for log messages.
    :type mode: DEBUG_MODE
    :param callback: Callback to use when mode is set to callback, only
        required when using that mode.
    :type callback: DEBUG_CALLBACK like function
    :param str filename: Filename to use when mode is set to file, only
        required when using that mode.
    """
    ckresult(
        _dll.FMOD_Debug_Initialize(flags, mode, DEBUG_CALLBACK(callback), filename)
    )
