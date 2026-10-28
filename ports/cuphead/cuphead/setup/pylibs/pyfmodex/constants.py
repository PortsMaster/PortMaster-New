"""FMOD constants."""

#: Codec Wave format version number.
#:
#: Use this for binary compatibility of the
#: :py:class:`~pyfmodex.structure_declarations.CODEC_WAVEFORMAT` structure and
#: for future expansion.
#:
#: Should be set into :py:class:`~pyfmodex.structure_declarations.CODEC_STATE`
#: in the :py:func:`~pyfmodex.callback_prototypes.CODEC_OPEN_CALLBACK`.
#:
#: The version here represents the version of the
#: :py:class:`~pyfmodex.structure_declarations.CODEC_WAVEFORMAT` structure,
#: which has evolved over time in FMOD. The
#: :py:class:`~pyfmodex.structure_declarations.CODEC_STATE` contains the
#: waveformat member with the structure in question.
CODEC_WAVEFORMAT_VERSION = 3

#: Length in bytes of the buffer pointed to by the valuestr argument of
#: DSP_GETPARAM_XXXX_CALLBACK functions.
DSP_GETPARAM_VALUESTR_LENGTH = 32

#: Maximum number of channels per frame of audio supported by audio files,
#: buffers, connections and DSPs.
MAX_CHANNEL_WIDTH = 32

#: Maximum number of listeners supported.
MAX_LISTENERS = 8

#: PORT_INDEX is an output type specific index for when there are multiple
#: instances of a port type.
#:
#: This one is used when a port index is not required.
PORT_INDEX_NONE = -1

#: The maximum number of global/physical reverb instances.
#:
#: Each instance of a physical reverb is an instance of a
#: :py:class:`~pyfmodex.enums.DSP_SFXREVERB` dsp in the mix graph. This is
#: unrelated to the number of possible Reverb3D objects, which is unlimited.
REVERB_MAXINSTANCES = 4

#: Maximum number of System objects allowed.
MAX_SYSTEMS = 8
