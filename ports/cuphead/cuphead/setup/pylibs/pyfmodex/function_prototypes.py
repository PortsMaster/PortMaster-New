"""Function prototypes."""


import os
from ctypes import *

from .structure_declarations import *

func = WINFUNCTYPE if os.name == "nt" else CFUNCTYPE
#: Function to allocate memory using the FMOD memory system.
DSP_ALLOC_FUNC = func(c_void_p, c_uint, c_int, c_char_p)

#: Function to reallocate memory using the FMOD memory system.
DSP_REALLOC_FUNC = func(c_void_p, c_void_p, c_uint, c_int, c_char_p)

#: Function to free memory allocated with :py:attr:`DSP_ALLOC_FUNC`.
DSP_FREE_FUNC = func(None, c_void_p, c_int, c_char_p)

#: Function to write to the FMOD logging system.
DSP_LOG_FUNC = func(
    None, c_int, c_char_p, c_int, c_char_p, c_char_p, c_void_p
)  # I hope the varargs semantics are correct

#: Function to query the system sample rate.
DSP_GETSAMPLERATE_FUNC = func(c_int, POINTER(DSP_STATE), POINTER(c_int))

#: Function to query the system block size, DSPs will be requested to process
#: blocks of varying length up to this size.
DSP_GETBLOCKSIZE_FUNC = func(c_int, POINTER(DSP_STATE), POINTER(c_uint))

#: Function to query the system speaker modes. One is the mixer's default
#: speaker mode, the other is the output mode the system is downmixing or
#: upmixing to.
DSP_GETSPEAKERMODE_FUNC = func(
    c_int, POINTER(DSP_STATE), POINTER(c_int), POINTER(c_int)
)

#: Function to get the clock of the current DSP, as well as the subset of the
#: input buffer that contains the signal.
DSP_GETCLOCK_FUNC = func(
    c_int, POINTER(DSP_STATE), POINTER(c_ulonglong), POINTER(c_int), POINTER(c_int)
)

#: Callback for getting the absolute listener attributes set via the API
#: (returned as left-handed coordinates).
DSP_GETLISTENERATTRIBUTES_FUNC = func(
    c_int, POINTER(DSP_STATE), POINTER(c_int), POINTER(THREED_ATTRIBUTES)
)

#: Function to get the user data attached to this DSP. See
#: :py:attr:`~pyfmodex.structures.DSP_DESCRIPTION.userdata`.
DSP_GETUSERDATA_FUNC = func(c_int, POINTER(DSP_STATE), POINTER(c_void_p))

#: Function for performing an FFT on a real signal.
DSP_DFT_FFTREAL_FUNC = func(
    c_int,
    POINTER(DSP_STATE),
    c_int,
    POINTER(c_float),
    POINTER(COMPLEX),
    POINTER(c_float),
    c_int,
)

#: Function for performing an inverse FFT to get a real signal.
DSP_DFT_IFFTREAL_FUNC = func(
    c_int,
    POINTER(DSP_STATE),
    c_int,
    POINTER(COMPLEX),
    POINTER(c_float),
    POINTER(c_float),
    c_int,
)

#: TBD.
DSP_PAN_SUMMONOMATRIX_FUNC = func(
    c_int, POINTER(DSP_STATE), c_int, c_float, c_float, POINTER(c_float)
)

#: TBD.
DSP_PAN_SUMSTEREOMATRIX_FUNC = func(
    c_int, POINTER(DSP_STATE), c_int, c_float, c_float, c_float, c_int, POINTER(c_float)
)

#: TBD.
DSP_PAN_SUMSURROUNDMATRIX_FUNC = func(
    c_int,
    POINTER(DSP_STATE),
    c_int,
    c_int,
    c_float,
    c_float,
    c_float,
    c_float,
    c_float,
    c_int,
    POINTER(c_float),
    c_int,
)

#: TBD.
DSP_PAN_SUMMONOTOSURROUNDMATRIX_FUNC = func(
    c_int,
    POINTER(DSP_STATE),
    c_int,
    c_float,
    c_float,
    c_float,
    c_float,
    c_int,
    POINTER(c_float),
)

#: TBD.
DSP_PAN_SUMSTEREOTOSURROUNDMATRIX_FUNC = func(
    c_int,
    POINTER(DSP_STATE),
    c_int,
    c_float,
    c_float,
    c_float,
    c_float,
    c_float,
    c_int,
    POINTER(c_float),
)

#: TBD.
DSP_PAN_GETROLLOFFGAIN_FUNC = func(
    c_int, POINTER(DSP_STATE), c_int, c_float, c_float, c_float, c_float
)

#: Function to be called when asynchronous reading is finished.
FILE_ASYNCDONE_FUNC = func(c_int, POINTER(ASYNCREADINFO), c_int)

#: Output read from mixer function.
OUTPUT_READFROMMIXER = func(c_int, POINTER(OUTPUT_STATE), c_void_p, c_uint)

#: Output copy port function.
#:
#: Function to copy the output from the mixer for the given auxiliary port.
OUTPUT_COPYPORT = func(c_int, POINTER(OUTPUT_STATE), c_int, c_void_p, c_uint)

#: Output allocate memory function.
OUTPUT_ALLOC = func(c_void_p, c_uint, c_uint, c_char_p, c_int)

#: Output free memory function.
OUTPUT_FREE = func(None, c_void_p, c_char_p, c_int)

#: Output log function.
#:
#: Call this function in an output plugin context to utilize FMOD's debugging
#: system.
OUTPUT_LOG = func(
    None, c_int, c_char_p, c_int, c_char_p, c_char_p, c_void_p
)  # Varargs, again

#: Output request reset function.
#:
#: Request the output to shut down and restart.
#:
#: If this is issued, the output will not reset immediately, but on the next
#: update the output will first shut down with a call to the
#: `OUTPUT_STOP_CALLBACK` then `OUTPUT_CLOSE_CALLBACK`, followed by a restart
#: with `OUTPUT_INIT_CALLBACK` and `OUTPUT_START_CALLBACK`.
OUTPUT_REQUESTRESET = func(None, POINTER(OUTPUT_STATE))
