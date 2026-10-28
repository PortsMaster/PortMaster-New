import os
from ctypes import *

from .structure_declarations import *

func = WINFUNCTYPE if os.name == "nt" else CFUNCTYPE
ROLLOFF_CALLBACK = func(c_float, c_void_p, c_float)
CHANNELCONTROL_CALLBACK = func(c_int, c_void_p, c_int, c_int, c_void_p, c_void_p)
CODEC_CLOSE_CALLBACK = func(c_int, POINTER(CODEC_STATE))
CODEC_GETLENGTH_CALLBACK = func(c_int, POINTER(CODEC_STATE), POINTER(c_int), c_int)
CODEC_GETPOSITION_CALLBACK = func(c_int, POINTER(CODEC_STATE), POINTER(c_uint), c_int)
CODEC_GETWAVEFORMAT_CALLBACK = func(
    c_int, POINTER(CODEC_STATE), c_int, POINTER(CODEC_WAVEFORMAT)
)
CODEC_METADATA_CALLBACK = func(
    c_int, POINTER(CODEC_STATE), c_int, c_char_p, c_void_p, c_uint, c_int, c_int
)
CODEC_OPEN_CALLBACK = func(
    c_int, POINTER(CODEC_STATE), c_int, POINTER(CREATESOUNDEXINFO)
)
CODEC_READ_CALLBACK = func(
    c_int, POINTER(CODEC_STATE), c_void_p, c_uint, POINTER(c_uint)
)
CODEC_SETPOSITION_CALLBACK = func(c_int, POINTER(CODEC_STATE), c_int, c_uint, c_int)
CODEC_SOUNDCREATE_CALLBACK = func(c_int, POINTER(CODEC_STATE), c_int, c_void_p)
DEBUG_CALLBACK = func(c_int, c_int, c_char_p, c_int, c_char_p, c_char_p)
DSP_CREATE_CALLBACK = func(c_int, POINTER(DSP_STATE))
DSP_DIALOG_CALLBACK = func(c_int, POINTER(DSP_STATE), c_void_p, c_int)
DSP_GETPARAM_BOOL_CALLBACK = func(
    c_int, POINTER(DSP_STATE), c_int, POINTER(c_bool), c_char_p
)
DSP_GETPARAM_DATA_CALLBACK = func(
    c_int, POINTER(DSP_STATE), c_int, POINTER(c_void_p), POINTER(c_uint), c_char_p
)
DSP_GETPARAM_FLOAT_CALLBACK = func(
    c_int, POINTER(DSP_STATE), c_int, POINTER(c_float), c_char_p
)
DSP_GETPARAM_INT_CALLBACK = func(
    c_int, POINTER(DSP_STATE), c_int, POINTER(c_int), c_char_p
)
DSP_PROCESS_CALLBACK = func(
    c_int,
    POINTER(DSP_STATE),
    c_uint,
    POINTER(DSP_BUFFER_ARRAY),
    POINTER(DSP_BUFFER_ARRAY),
    c_bool,
    c_int,
)
DSP_READ_CALLBACK = func(
    c_int,
    POINTER(DSP_STATE),
    POINTER(c_float),
    POINTER(c_float),
    c_uint,
    c_int,
    POINTER(c_int),
)
DSP_RELEASE_CALLBACK = func(c_int, POINTER(DSP_STATE))
DSP_RESET_CALLBACK = func(c_int, POINTER(DSP_STATE))
DSP_SETPARAM_BOOL_CALLBACK = func(c_int, POINTER(DSP_STATE), c_int, c_bool)
DSP_SETPARAM_DATA_CALLBACK = func(c_int, POINTER(DSP_STATE), c_int, c_void_p, c_uint)
DSP_SETPARAM_FLOAT_CALLBACK = func(c_int, POINTER(DSP_STATE), c_int, c_float)
DSP_SETPARAM_INT_CALLBACK = func(c_int, POINTER(DSP_STATE), c_int, c_int)
DSP_SETPOSITION_CALLBACK = func(c_int, POINTER(DSP_STATE), c_uint)
DSP_SHOULDIPROCESS_CALLBACK = func(
    c_int, POINTER(DSP_STATE), c_bool, c_uint, c_int, c_int, c_int
)
DSP_SYSTEM_DEREGISTER_CALLBACK = func(c_int, POINTER(DSP_STATE))
DSP_SYSTEM_MIX_CALLBACK = func(c_int, POINTER(DSP_STATE), c_int)
DSP_SYSTEM_REGISTER_CALLBACK = func(c_int, POINTER(DSP_STATE))
FILE_ASYNCCANCEL_CALLBACK = func(c_int, POINTER(ASYNCREADINFO), c_void_p)
FILE_ASYNCREAD_CALLBACK = func(c_int, POINTER(ASYNCREADINFO), c_void_p)
FILE_CLOSE_CALLBACK = func(c_int, c_void_p, c_void_p)
FILE_OPEN_CALLBACK = func(
    c_int, c_char_p, POINTER(c_uint), c_uint, POINTER(c_void_p), c_void_p
)
FILE_READ_CALLBACK = func(c_int, c_void_p, c_void_p, c_uint, POINTER(c_uint), c_void_p)
FILE_SEEK_CALLBACK = func(c_int, c_void_p, c_uint, c_void_p)
MEMORY_ALLOC_CALLBACK = func(c_void_p, c_uint, c_int, c_char_p)
MEMORY_FREE_CALLBACK = func(None, c_void_p, c_int, c_char_p)
MEMORY_REALLOC_CALLBACK = func(c_void_p, c_void_p, c_uint, c_int, c_char_p)
OUTPUT_CLOSE_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
OUTPUT_GETDRIVERINFO_CALLBACK = func(
    c_int,
    POINTER(OUTPUT_STATE),
    c_int,
    c_char_p,
    c_int,
    POINTER(GUID),
    POINTER(c_int),
    POINTER(c_int),
    POINTER(c_int),
)
OUTPUT_GETHANDLE_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), POINTER(c_void_p))
OUTPUT_GETNUMDRIVERS_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), POINTER(c_int))
OUTPUT_GETPOSITION_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), POINTER(c_uint))
OUTPUT_INIT_CALLBACK = func(
    c_int,
    POINTER(OUTPUT_STATE),
    c_int,
    c_int,
    POINTER(c_int),
    POINTER(c_int),
    POINTER(c_int),
    POINTER(c_int),
    c_int,
    c_int,
    c_void_p,
)
OUTPUT_LOCK_CALLBACK = func(
    c_int,
    POINTER(OUTPUT_STATE),
    c_uint,
    c_uint,
    POINTER(c_void_p),
    POINTER(c_void_p),
    POINTER(c_uint),
    POINTER(c_uint),
)
OUTPUT_MIXER_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
OUTPUT_OBJECT3DALLOC_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), POINTER(c_void_p))
OUTPUT_OBJECT3DFREE_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), c_void_p)
OUTPUT_OBJECT3DGETINFO_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), POINTER(c_int))
OUTPUT_OBJECT3DUPDATE_CALLBACK = func(
    c_int, POINTER(OUTPUT_STATE), c_void_p, POINTER(OUTPUT_OBJECT3DINFO)
)
OUTPUT_OPENPORT_CALLBACK = func(
    c_int,
    POINTER(OUTPUT_STATE),
    c_int,
    c_int,
    POINTER(c_int),
    POINTER(c_int),
    POINTER(c_int),
    POINTER(c_int),
)
OUTPUT_CLOSEPORT_CALLBACK = func(c_int, POINTER(OUTPUT_STATE), c_int)
OUTPUT_READFROMMIXER = func(c_int, POINTER(OUTPUT_STATE), c_void_p, c_uint)
OUTPUT_START_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
OUTPUT_STOP_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
OUTPUT_UNLOCK_CALLBACK = func(
    c_int, POINTER(OUTPUT_STATE), c_void_p, c_void_p, c_uint, c_uint
)
OUTPUT_UPDATE_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
OUTPUT_DEVICELISTCHANGED_CALLBACK = func(c_int, POINTER(OUTPUT_STATE))
SOUND_NONBLOCKCALLBACK = func(c_int, c_void_p, c_int)
SOUND_PCMREADCALLBACK = func(c_int, c_void_p, c_void_p, c_uint)
SOUND_PCMSETPOSCALLBACK = func(c_int, c_void_p, c_int, c_uint, c_int)
SYSTEM_CALLBACK = func(c_int, c_void_p, c_int, c_void_p, c_void_p, c_void_p)
