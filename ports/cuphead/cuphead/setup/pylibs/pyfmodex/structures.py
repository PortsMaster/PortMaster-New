"""Structures."""
# pylint: disable=too-few-public-methods
# These are mostly data containers, really.

# pylint: disable=attribute-defined-outside-init
# ctype Structures can do this magic!

# pylint: disable=invalid-name
# Just staying close to the original names here.


from ctypes import *

from .callback_prototypes import *
from .enums import OUTPUT_METHOD
from .function_prototypes import *
from .structure_declarations import *

GUID._fields_ = [
    ("data1", c_uint),
    ("data2", c_ushort),
    ("data3", c_ushort),
    (
        "data4",
        c_char * 8,
    ),
]


class ADVANCEDSETTINGS(Structure):
    """Advanced configuration settings.

    Structure to allow configuration of lesser used system level settings.
    These tweaks generally allow the user to set resource limits and customize
    settings to better fit their application.

    All members have a default of 0 except for `cbSize`, so clearing the whole
    structure to zeroes first then setting cbSize is a common use pattern.

    Specifying one of the codec maximums will help determine the maximum CPU
    usage of playing :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`
    Sounds of that type as well as the memory requirements. Memory will be
    allocated for 'up front' (during :py:meth:`~pyfmodex.system.System.init`)
    if these values are specified as non zero. If any are zero, it allocates
    memory for the codec whenever a file of the type in question is loaded. So
    if maxMPEGCodecs is 0 for example, it will allocate memory for the MPEG
    codecs the first time an MP3 is loaded or an MP3 based .FSB file is loaded.

    Setting `DSPBufferPoolSize` will pre-allocate memory for the FMOD DSP
    network. By default eight buffers are created up front. A large network
    might require more if the aim is to avoid real-time allocations from the
    FMOD mixer thread.

    :ivar int cbsize: Size of this structure. Must be set to
        sizeof(`ADVANCEDSETTINGS`) before calling setting or requesting
        :py:attr:`~pyfmodex.system.System.advanced_settings`.
    :ivar int maxMPEGcodecs: Maximum MPEG Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxADPCMcodecs: Maximum IMA-ADPCM Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxXMAcodecs: Maximum XMA Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxVorbisCodecs: Maximum Vorbis Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxAT9Codecs: Maximum AT9 Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxFADPCMCodecs: Maximum FADPCM Sounds created as
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE`.
    :ivar int maxPCMcodecs: Deprecated.
    :ivar int ASIONumChannels: Number of elements in `ASIOSpeakerList` on
        input, number of elements in `ASIOChannelList` on output.
    :ivar str ASIOChannelList: Read only list of strings representing ASIO
        channel names, count is defined by `ASIONumChannels`. Only valid after
        :py:meth:`~pyfmodex.system.System.init`.
    :ivar SPEAKER ASIOSpeakerList: List of speakers that represent each ASIO
        channel used for remapping, count is defined by `ASIONumChannels`. Use
        :py:attr:`~pyfmodex.enums.SPEAKER.NONE` to indicate no output for a
        given speaker.
    :ivar float vol0virtualvol: For use with
        :py:attr:`~pyfmodex.flags.INIT_FLAGS.VOL0_BECOMES_VIRTUAL`,
        :py:class:`Channels <pyfmodex.channel.Channel>` with audibility below
        this will become virtual.
    :ivar int defaultDecodeBufferSize: For use with Streams, the default size
        of the double buffer.
    :ivar int profileport: For use with
        :py:attr:`~pyfmodex.flags.INIT_FLAGS.PROFILE_ENABLE`, specify the port
        to listen on for connections by FMOD Studio or FMOD Profiler.
    :ivar int geometryMaxFadeTime: For use with
        :py:class:`~pyfmodex.geometry.Geometry`, the maximum time it takes for
        a :py:class:`~pyfmodex.channel.Channel` to fade to the new volume level
        when its occlusion changes.
    :ivar float distanceFilterCenterFreq: For use with
        :py:attr:`~pyfmodex.flags.INIT_FLAGS.CHANNEL_DISTANCEFILTER`, the
        default center frequency for the distance filtering effect.
        :ivar int reverb3Dinstance: For use with
        :py:class:`~pyfmodex.reverb.Reverb3D`, selects which global reverb
        instance to use.
    :ivar int DSPBufferPoolSize: Number of intermediate mixing buffers in the
        'DSP buffer pool'. Each buffer in bytes will be `bufferlength` (See
        :py:attr:`~pyfmodex.system.System.dsp_buffer_size`) * sizeof(float) *
        output mode speaker count (See
        :py:class:`~pyfmodex.enums.SPEAKERMODE`). ie 7.1 @ 1024 DSP block size
        = 1024 * 4 * 8 = 32KB.
    :ivar DSP_RESAMPLER resamplerMethod: Resampling method used by
        :py:class:`Channels <pyfmodex.channel.Channel>`.
    :ivar int randomSeed: Seed value to initialize the internal random number
        generator.
    :ivar int maxConvolutionThreads: Maximum number of CPU threads to use for
        :py:class:`~pyfmodex.enums.DSP_CONVOLUTIONREVERB` effect. 1 = effect is
        entirely processed inside the THREAD_TYPE_MIXER thread. 2 and 3
        offloads different parts of the convolution processing into different
        threads (THREAD_TYPE_CONVOLUTION1 and FMOD_THREAD_TYPE_CONVOLUTION2 to
        increase throughput.
    """

    _fields_ = [
        ("cbsize", c_int),
        ("maxMPEGcodecs", c_int),
        ("maxADPCMcodecs", c_int),
        ("maxXMAcodecs", c_int),
        ("maxVorbisCodecs", c_int),
        ("maxAT9Codecs", c_int),
        ("maxFADPCMCodecs", c_int),
        ("maxPCMcodecs", c_int),
        ("ASIONumChannels", c_int),
        ("ASIOChannelList", POINTER(c_char_p)),
        ("ASIOSpeakerList", POINTER(c_int)),
        ("vol0virtualvol", c_float),
        ("defaultDecodeBufferSize", c_uint),
        ("profileport", c_ushort),
        ("geometryMaxFadeTime", c_uint),
        ("distanceFilterCenterFreq", c_float),
        ("reverb3Dinstance", c_int),
        ("DSPBufferPoolSize", c_int),
        ("resamplerMethod", c_int),
        ("randomSeed", c_uint),
        ("maxConvolutionThreads", c_int),
    ]

    def __init__(self, *args, **kwargs):
        Structure.__init__(self, *args, **kwargs)
        self.cbsize = sizeof(self)


ASYNCREADINFO._fields_ = [
    ("handle", c_void_p),
    ("offset", c_uint),
    ("sizebytes", c_uint),
    ("priority", c_int),
    ("userdata", c_void_p),
    ("buffer", c_void_p),
    ("bytesread", c_uint),
    ("done", FILE_ASYNCDONE_FUNC),
]


class CODEC_DESCRIPTION(Structure):
    """Codec description.

    This description structure allows the plugin writer to define all
    functionality required for a user defined codec.

    :ivar str name: Name of the codec.
    :ivar int version: Plugin writer's version number.
    :ivar int defaultasstream: Defaults as stream.
    :ivar TIMEUNIT timeunits: Time units used with setposition codec.
    :ivar CODEC_OPEN_CALLBACK open: Open callback.
    :ivar CODEC_CLOSE_CALLBACK close: Close callback.
    :ivar CODEC_READ_CALLBACK read: Read callback.
    :ivar CODEC_GETLENGTH_CALLBACK getlength: Get length callback.
    :ivar CODEC_SETPOSITION_CALLBACK setposition: Seek callback.
    :ivar CODEC_GETPOSITION_CALLBACK getposition: Get position callback.
    :ivar CODEC_SOUNDCREATE_CALLBACK soundcreate: Sound creation callback.
    :ivar CODEC_GETWAVEFORMAT_CALLBACK getwaveformat: Get wave format callback.
    """

    _fields_ = [
        ("name", c_char_p),
        ("version", c_uint),
        ("defaultasstream", c_int),
        ("timeunits", c_int),
        ("open", CODEC_OPEN_CALLBACK),
        ("close", CODEC_CLOSE_CALLBACK),
        ("read", CODEC_READ_CALLBACK),
        ("getlength", CODEC_GETLENGTH_CALLBACK),
        ("setposition", CODEC_SETPOSITION_CALLBACK),
        ("getposition", CODEC_GETPOSITION_CALLBACK),
        ("soundcreate", CODEC_SOUNDCREATE_CALLBACK),
        ("getwaveformat", CODEC_GETWAVEFORMAT_CALLBACK),
    ]


CODEC_WAVEFORMAT._fields_ = [
    ("name", c_char_p),
    ("format", c_int),
    ("channels", c_int),
    ("frequency", c_int),
    ("lengthbytes", c_uint),
    ("lengthpcm", c_uint),
    ("pcmblocksize", c_uint),
    ("loopstart", c_int),
    ("loopend", c_int),
    ("mode", c_int),
    ("channelmask", c_int),
    ("channelorder", c_int),
    ("peakvolume", c_float),
]

CODEC_STATE._fields_ = [
    ("numsubsounds", c_int),
    ("waveformat", CODEC_WAVEFORMAT),
    ("plugindata", c_void_p),
    ("filehandle", c_void_p),
    ("filesize", c_uint),
    ("fileread", FILE_READ_CALLBACK),
    ("fileseek", FILE_SEEK_CALLBACK),
    ("metadata", CODEC_METADATA_CALLBACK),
    ("waveformatversion", c_int),
]

COMPLEX._fields_ = [("real", c_float), ("imag", c_float)]

CREATESOUNDEXINFO._fields_ = [
    ("cbsize", c_int),
    ("length", c_uint),
    ("fileoffset", c_uint),
    ("numchannels", c_int),
    ("defaultfrequency", c_int),
    ("format", c_int),
    ("decodebuffersize", c_uint),
    ("initialsubsound", c_int),
    ("numsubsounds", c_int),
    ("inclusionlist", POINTER(c_int)),
    ("inclusionlistnum", c_int),
    ("pcmreadcallback", SOUND_PCMREADCALLBACK),
    ("pcmsetposcallback", SOUND_PCMSETPOSCALLBACK),
    ("nonblockcallback", SOUND_NONBLOCKCALLBACK),
    ("dlsname", c_char_p),
    ("encryptionkey", c_char_p),
    ("maxpolyphony", c_int),
    ("userdata", c_void_p),
    ("suggestedsoundtype", c_int),
    ("useropen", FILE_OPEN_CALLBACK),
    ("userclose", FILE_CLOSE_CALLBACK),
    ("userread", FILE_READ_CALLBACK),
    ("userseek", FILE_SEEK_CALLBACK),
    ("userasyncread", FILE_ASYNCREAD_CALLBACK),
    ("userasynccancel", FILE_ASYNCCANCEL_CALLBACK),
    ("fileuserdata", c_void_p),
    ("filebuffersize", c_int),
    ("channelorder", c_int),
    ("initialsoundgroup", c_void_p),
    ("initialseekposition", c_uint),
    ("initialseekpostype", c_int),
    ("ignoresetfilesystem", c_int),
    ("audioqueuepolicy", c_uint),
    ("minmidigranularity", c_uint),
    ("nonblockthreadid", c_int),
    ("fsbguid", POINTER(GUID)),
]


def exinfo_init(self, *args, **kwargs):
    """Constructor for the CREATESOUNDEXINFO structure.

    Determines and stores its own size.
    """
    Structure.__init__(self, *args, **kwargs)
    self.cbsize = sizeof(self)


CREATESOUNDEXINFO.__init__ = exinfo_init


class VECTOR(Structure):
    """Structure describing a point in 3D space.

    FMOD uses a left handed coordinate system by default. To use a right handed
    coordinate system specify
    :py:attr:`~pyfmodex.flags.INIT_FLAGS.THREED_RIGHTHANDED` in
    :py:meth:`~pyfmodex.system.System.init`.

    :ivar float x: X coordinate in 3D space.
    :ivar float y: Y coordinate in 3D space.
    :ivar float z: Z coordinate in 3D space.
    """

    _fields_ = [("x", c_float), ("y", c_float), ("z", c_float)]

    @staticmethod
    def from_list(lst):
        """Instantiate a VECTOR from a list with three coordinate floats."""
        vec = VECTOR()
        vec.x = lst[0]
        vec.y = lst[1]
        vec.z = lst[2]
        return vec

    def to_list(self):
        """The VECTOR as a list of three coordinate floats."""
        return [self.x, self.y, self.z]


THREED_ATTRIBUTES._fields_ = [
    ("position", VECTOR),
    ("velocity", VECTOR),
    ("forward", VECTOR),
    ("up", VECTOR),
]

DSP_BUFFER_ARRAY._fields_ = [
    ("numbuffers", c_int),
    ("buffernumchannels", POINTER(c_int)),
    ("bufferchannelmask", POINTER(c_int)),
    ("buffers", POINTER(POINTER(c_float))),
    ("speakermode", c_int),
]


class DSP_METERING_INFO(Structure):
    """DSP metering info.

    :ivar int numsamples: Number of samples considered for this metering info.
    :ivar list(float) peaklevel: Peak level per channel.
    :ivar list(float) rmslevel: Rms level per channel.
    :ivar float numchannels: Number of channels.
    """

    _fields_ = [
        ("numsamples", c_int),
        ("peaklevel", c_float * 32),
        ("rmslevel", c_float * 32),
        ("numchannels", c_short),
    ]


class DSP_PARAMETER_3DATTRIBUTES(Structure):
    """3D attributes data structure.

    The :py:class:`~pyfmodex.studio.system.StudioSystem` will set this
    parameter automatically if an
    :py:class:`~pyfmodex.studio.event_instance.EventInstance` position changes,
    however if using the core :py:class:`~pyfmodex.system.System` you must set
    this DSP parameter explicitly.

    Attributes must use a coordinate system with the positive Y axis being up
    and the positive X axis being right. FMOD will convert passed in
    coordinates to left-handed for the plugin if the System was initialized
    with the  :py:attr:`~pyfmodex.flags.INIT_FLAGS.THREED_RIGHTHANDED` flag.

    When using a listener attenuation position, the direction of the `relative`
    attributes will be relative to the listener position and the length will be
    the distance to the attenuation position.

    :ivar THREED_ATTRIBUTES relative: Position of the sound relative to the
        listener.
    :ivar THREED_ATTRIBUTES absolute: Position of the sound in world
        coordinates.
    """

    _fields_ = [("relative", THREED_ATTRIBUTES), ("absolute", THREED_ATTRIBUTES)]


class DSP_PARAMETER_3DATTRIBUTES_MULTI(Structure):
    """3D attributes data structure for multiple listeners.

    The :py:class:`~pyfmodex.studio.system.StudioSystem` will set this
    parameter automatically if an
    :py:class:`~pyfmodex.studio.event_instance.EventInstance` position changes,
    however if using the core :py:class:`~pyfmodex.system.System` you must set
    this DSP parameter explicitly.

    Attributes must use a coordinate system with the positive Y axis being up
    and the positive X axis being right. FMOD will convert passed in
    coordinates to left-handed for the plugin if the System was initialized
    with the  :py:attr:`~pyfmodex.flags.INIT_FLAGS.THREED_RIGHTHANDED` flag.

    When using a listener attenuation position, the direction of the `relative`
    attributes will be relative to the listener position and the length will be
    the distance to the attenuation position.

    :ivar int numlisteners: Number of listeners.
    :ivar THREED_ATTRIBUTES relative: Position of the sound relative to the
        listeners.
    :ivar list(float) weight: Weighting of the listeners where 0 means listener
        has no contribution and 1 means full contribution.
    :ivar THREED_ATTRIBUTES absolute: Position of the sound in world
        coordinates.
    """

    _fields_ = [
        ("numlisteners", c_int),
        ("relative", THREED_ATTRIBUTES * 8),
        ("weight", c_float * 8),
        ("absolute", THREED_ATTRIBUTES),
    ]


class DSP_PARAMETER_DESC_BOOL(Structure):
    """Boolean parameter description.

    :ivar bool defaultval: Default parameter value.
    :ivar list(str) valuenames: Names for false and true, respectively. There
        should be two strings.
    """

    _fields_ = [("defaultval", c_bool), ("valuenames", POINTER(c_char_p))]


class DSP_PARAMETER_DESC_DATA(Structure):
    """Data parameter description.

    :ivar int datatype: Type of data.
    """

    _fields_ = [("datatype", c_int)]


class DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR(Structure):
    """Structure to define a piecewise linear mapping.

    :ivar int numpoints: Number of pairs in the piecewise mapping (at least
        two).
    :ivar list(float) pointparamvalues: Values in the parameter's units for
        each point
    :ivar list(float) pointpositions: Positions along the control's scale (e.g.
        dial angle) corresponding to each parameter value. The range of this
        scale is arbitrary and all positions will be relative to the minimum
        and maximum values (e.g. [0,1,3] is equivalent to [1,2,4] and [2,4,8]).
        If this array is zero, pointparamvalues will be distributed with equal
        spacing.
    """

    _fields_ = [
        ("numpoints", c_int),
        ("pointparamvalues", POINTER(c_float)),
        ("pointpositions", POINTER(c_float)),
    ]


class DSP_PARAMETER_FLOAT_MAPPING(Structure):
    """Structure to define a mapping for a DSP unit's float parameter.

    :ivar DSP_PARAMETER_FLOAT_MAPPING_TYPE type: Mapping type.
    :ivar DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR piecewiselinearmapping:
        Piecewise linear mapping type.
    """

    _fields_ = [
        ("type", c_int),
        ("piecewiselinearmapping", DSP_PARAMETER_FLOAT_MAPPING_PIECEWISE_LINEAR),
    ]


class DSP_PARAMETER_DESC_FLOAT(Structure):
    """Float parameter description.

    :ivar float min: Minimum value.
    :ivar float max: Maximum value.
    :ivar float defaultval: Default value.
    :ivar DSP_PARAMETER_FLOAT_MAPPING mapping: How the values are distributed
        across dials and automation curves.
    """

    _fields_ = [
        ("min", c_float),
        ("max", c_float),
        ("defaultval", c_float),
        ("mapping", DSP_PARAMETER_FLOAT_MAPPING),
    ]


class DSP_PARAMETER_DESC_INT(Structure):
    """Integer parameter description.

    :ivar int min: Minimum value.
    :ivar int max: Maximum value.
    :ivar int defaultval: Default value.
    :ivar bool goestoinf: Whether the last value represents infiniy.
    :ivar list(str) valuenames: Names for each value. There should be as many
        strings as there are possible values (`max` - `min` + 1).
    """

    _fields_ = [
        ("min", c_int),
        ("max", c_int),
        ("defaultval", c_int),
        ("goestoinf", c_bool),
        ("valuenames", POINTER(c_char_p)),
    ]


class DSP_PARAMETER_FFT(Structure):
    """FFT parameter data structure.

    Notes on the `spectrum` data member:

        - Values inside the float buffer are typically between 0 and 1.0.
        - Each top level array represents one PCM channel of data.
        - Address data as spectrum[channel][bin]. A bin is 1 fft window entry.
        - Only read/display half of the buffer typically for analysis as the
          2nd half is usually the same data reversed due to the nature of the
          way FFT works.

    :ivar int length: Number of entries in this spectrum window. Divide this by
        the output rate to get the Hz per entry.
    :ivar int numchannels: Number of channels in spectrum.
    :ivar list(float) spectrum: Per channel spectrum arrays.
    """

    _fields_ = [("length", c_int), ("numchannels", c_int), ("spectrum", POINTER(c_float) * 32)]


class DSP_PARAMETER_OVERALLGAIN(Structure):
    """Overall gain parameter data structure.

    This parameter is read by the system to determine the effect's gain for
    voice virtualization.

    :ivar float linear_gain: Overall linear gain of the effect on the direct
        signal path.
    :ivar float linear_gain_additive: Additive gain, for parallel signal paths.
    """

    _fields_ = [("linear_gain", c_float), ("linear_gain_additive", c_float)]


class DSP_PARAMETER_SIDECHAIN(Structure):
    """Side chain parameter data structure.

    :ivar bool sidechainenable: Whether sidechains are enabled.
    """

    _fields_ = [("sidechainenable", c_bool)]


class DSP_STATE_DFT_FUNCTIONS(Structure):
    """Struct containing DFT functions to enable a plugin to perform optimized
    time-frequency domain conversion.

    :ivar DSP_DFT_FFTREAL_FUNC fftreal: Function for performing an FFT on a
        real signal.
    :ivar DSP_DFT_IFFTREAL_FUNC inversefftreal: Function for performing an
        inverse FFT to get a real signal.
    """

    _fields_ = [
        ("fftreal", DSP_DFT_FFTREAL_FUNC),
        ("inversefftreal", DSP_DFT_IFFTREAL_FUNC),
    ]


class DSP_STATE_PAN_FUNCTIONS(Structure):
    """Struct containing panning helper functions for spatialization plugins.

    :ivar DSP_PAN_SUMMONOMATRIX_FUNC summonomatrix: TBD.
    :ivar DSP_PAN_SUMSTEREOMATRIX_FUNC sumstereomatrix: TBD.
    :ivar DSP_PAN_SUMSURROUNDMATRIX_FUNC sumsurroundmatrix: TBD.
    :ivar DSP_PAN_SUMMONOTOSURROUNDMATRIX_FUNC summonotosurroundmatrix: TBD.
    :ivar DSP_PAN_SUMSTEREOTOSURROUNDMATRIX_FUNC sumstereotosurroundmatrix:
        TBD.
    :ivar DSP_PAN_GETROLLOFFGAIN_FUNC getrolloffgain: TBD.
    """

    _fields_ = [
        ("summonomatrix", DSP_PAN_SUMMONOMATRIX_FUNC),
        ("sumstereomatrix", DSP_PAN_SUMSTEREOMATRIX_FUNC),
        ("sumsurroundmatrix", DSP_PAN_SUMSURROUNDMATRIX_FUNC),
        ("summonotosurroundmatrix", DSP_PAN_SUMMONOTOSURROUNDMATRIX_FUNC),
        ("sumstereotosurroundmatrix", DSP_PAN_SUMSTEREOTOSURROUNDMATRIX_FUNC),
        ("getrolloffgain", DSP_PAN_GETROLLOFFGAIN_FUNC),
    ]


class DSP_STATE_FUNCTIONS(Structure):
    """Struct containing functions to give plugin developers the ability to
    query system state, access system level functionality and helpers.

    :ivar DSP_ALLOC_FUNC alloc: Function to allocate memory using the FMOD
        memory system.
    :ivar DSP_REALLOC_FUNC realloc: Function to reallocate memory using the
        FMOD memory system.
    :ivar DSP_FREE_FUNC free: Function to free memory allocated with
        :py:data:`~pyfmodex.function_prototypes.DSP_ALLOC_FUNC`.
    :ivar DSP_GETSAMPLERATE_FUNC getsamplerate: Function to query the system
        sample rate.
    :ivar DSP_GETBLOCKSIZE_FUNC getblocksize: Function to query the system
        block size, DSPs will be requested to process blocks of varying length
        up to this size.
    :ivar DSP_STATE_DFT_FUNCTIONS dft: Struct containing DFT functions to
        enable a plugin to perform optimized time-frequency domain conversion.
    :ivar DSP_STATE_PAN_FUNCTIONS pan: Struct containing panning helper
        functions for spatialization plugins.
    :ivar DSP_GETSPEAKERMODE_FUNC getspeakermode: Function to query the system
        speaker modes. One is the mixer's default speaker mode, the other is
        the output mode the system is downmixing or upmixing to.
    :ivar DSP_GETCLOCK_FUNC getclock: Function to get the clock of the current
        DSP, as well as the subset of the input buffer that contains the
        signal.
    :ivar DSP_GETLISTENERATTRIBUTES_FUNC getlistenerattributes: Callback for
        getting the absolute listener attributes set via the API.
    :ivar DSP_LOG_FUNC log: Function to write to the FMOD logging system.
    :ivar DSP_GETUSERDATA_FUNC getuserdata: Function to get the user data
        attached to this DSP. See
        :py:attr:`~pyfmodex.structures.DSP_DESCRIPTION.userdata`.
    """

    _fields_ = [
        ("alloc", DSP_ALLOC_FUNC),
        ("realloc", DSP_REALLOC_FUNC),
        ("free", DSP_FREE_FUNC),
        ("getsamplerate", DSP_GETSAMPLERATE_FUNC),
        ("getblocksize", DSP_GETBLOCKSIZE_FUNC),
        ("dft", POINTER(DSP_STATE_DFT_FUNCTIONS)),
        ("pan", POINTER(DSP_STATE_PAN_FUNCTIONS)),
        ("getspeakermode", DSP_GETSPEAKERMODE_FUNC),
        ("getclock", DSP_GETCLOCK_FUNC),
        ("getlistenerattributes", DSP_GETLISTENERATTRIBUTES_FUNC),
        ("log", DSP_LOG_FUNC),
        ("getuserdata", DSP_GETUSERDATA_FUNC),
    ]


DSP_STATE._fields_ = [
    ("instance", c_void_p),
    ("plugindata", c_void_p),
    ("channelmask", c_int),
    ("sourcespeakermode", c_int),
    ("sidechaindata", POINTER(c_float)),
    ("sidechainchannels", c_int),
    ("functions", POINTER(DSP_STATE_FUNCTIONS)),
    ("systemobject", c_int),
]


class DSP_PARAMETER_DESC_UNION(Union):
    """
    :ivar DSP_PARAMETER_DESC_FLOAT floatdesc: Floating point format description
        used when type is :py:attr:`~pyfmodex.enums.DSP_PARAMETER_TYPE.FLOAT`.
    :ivar DSP_PARAMETER_DESC_INT intdesc: Integer format description used when
        type is :py:attr:`~pyfmodex.enums.DSP_PARAMETER_TYPE.INT`.
    :ivar DSP_PARAMETER_DESC_BOOL booldesc: Boolean format description used
        when type is :py:attr:`~pyfmodex.enums.DSP_PARAMETER_TYPE.BOOL`.
    :ivar DSP_PARAMETER_DESC_DATA datadesc: Data format description used when
        type is :py:attr:`~pyfmodex.enums.DSP_PARAMETER_TYPE.DATA`.
    """

    _fields_ = [
        ("floatdesc", DSP_PARAMETER_DESC_FLOAT),
        ("intdesc", DSP_PARAMETER_DESC_INT),
        ("booldesc", DSP_PARAMETER_DESC_BOOL),
        ("datadesc", DSP_PARAMETER_DESC_DATA),
    ]


class DSP_PARAMETER_DESC(Structure):
    """Base Structure for DSP parameter descriptions.

    :ivar DSP_PARAMETER_TYPE type: Parameter type.
    :ivar bytes name: Parameter Name.
    :ivar bytes label: Unit type label.
    :ivar str description: Description of the parameter.
    :ivar DSP_PARAMETER_DESC_UNION desc_union: Format description.
    """

    _fields_ = [
        ("type", c_int),
        ("name", c_char * 16),
        ("label", c_char * 16),
        ("description", c_char_p),
        ("desc_union", DSP_PARAMETER_DESC_UNION),
    ]


class DSP_DESCRIPTION(Structure):
    """DSP description.

    This description structure allows the plugin writer to define all
    functionality required for a user defined DSP effect.

    :ivar int pluginsdkversion: The plugin SDK version.
    :ivar str name: DSP name.
    :ivar str version: Plugin writer's version number.
    :ivar int numinputbuffers: Number of input buffers to process. Use 0 for
        DSPs that only generate sound and 1 for effects that process incoming
        sound.
    :ivar int numoutputbuffers: Number of audio output buffers. Only one output
        buffer is currently supported.
    :ivar DSP_CREATE_CALLBACK create: Create callback. This is called when DSP
        unit is created. Set callback invoked by
    :ivar DSP_RELEASE_CALLBACK release: Release callback. This is called just
        before the unit is freed so the user can do any cleanup needed for the
        unit.
    :ivar DSP_RESET_CALLBACK reset: Reset callback. This is called by the user
        to reset any history buffers that may need resetting for a filter, when
        it is to be used or re-used for the first time to its initial clean
        state. Use to avoid clicks or artifacts.
    :ivar DSP_READ_CALLBACK read: Read callback. Processing is done here.
    :ivar DSP_PROCESS_CALLBACK process: Process callback. Can be specified
        instead of the read callback if any channel format changes occur
        between input and output. This also replaces shouldiprocess and should
        return an error if the effect is to be bypassed.
    :ivar DSP_SETPOSITION_CALLBACK setposition: Set position callback. This is
        called if the unit wants to update its position info but not process
        data, or reset a cursor position internally if it is reading data from
        a certain source.
    :ivar int numparameters: Number of parameters used in this filter. The user
        finds this with :py:attr:`~pyfmodex.dsp.DSP.num_parameters`.
    :ivar list(str) paramdesc: Variable number of parameter structures.
    :ivar DSP_SETPARAM_FLOAT_CALLBACK setparameterfloat: Set callback invoked
        by :py:meth:`~pyfmodex.dsp.DSP.set_parameter_float`.
    :ivar DSP_SETPARAM_INT_CALLBACK setparameterint: Set callback invoked by by
        :py:meth:`~pyfmodex.dsp.DSP.set_parameter_int`
    :ivar DSP_SETPARAM_BOOL_CALLBACK setparameterbool: Set callback invoked by
        :py:meth:`~pyfmodex.dsp.DSP.set_parameter_bool`.
    :ivar DSP_SETPARAM_DATA_CALLBACK setparameterdata: Set callback invoked by
        :py:meth:`~pyfmodex.dsp.DSP.set_parameter_data`.
    :ivar DSP_GETPARAM_FLOAT_CALLBACK getparameterfloat: Set callback invoked
        by :py:meth:`~pyfmodex.dsp.DSP.get_parameter_float`.
    :ivar DSP_GETPARAM_INT_CALLBACK getparameterint: Set callback invoked by
        :py:meth:`~pyfmodex.dsp.DSP.get_parameter_int`.
    :ivar DSP_GETPARAM_BOOL_CALLBACK getparameterbool: Set callback invoked by
        :py:meth:`~pyfmodex.dsp.DSP.get_parameter_bool`.
    :ivar DSP_GETPARAM_DATA_CALLBACK getparameterdata: Set callback invoked by
        :py:meth:`~pyfmodex.dsp.DSP.get_parameter_data`.
    :ivar DSP_SHOULDIPROCESS_CALLBACK shouldiprocess: This is called before
        processing. You can detect if inputs are idle and return FMOD_OK to
        process, or any other error code to avoid processing the effect. Use a
        count down timer to allow effect tails to process before idling!
    :ivar userdata: User data.
    :ivar DSP_SYSTEM_REGISTER_CALLBACK sys_register: Register callback. This is
        called when DSP unit is loaded/registered. Useful for 'global'/per
        system object init for plugin.
    :ivar DSP_SYSTEM_DEREGISTER_CALLBACK sys_deregister: Deregister callback.
        This is called when DSP unit is unloaded/deregistered. Useful as
        'global'/per system object shutdown for plugin.
    :ivar DSP_SYSTEM_MIX_CALLBACK sys_mix: System mix stage callback. This is
        called when the mixer starts to execute or is just finishing executing.
        Useful for 'global'/per system object once a mix update calls for a
        plugin.

    There are two different ways to change a parameter in this architecture:

        - One is to use :py:meth:`~pyfmodex.dsp.DSP.set_parameter_float`/
          :py:meth:`~pyfmodex.dsp.DSP.set_parameter_int`/
          :py:meth:`~pyfmodex.dsp.DSP.set_parameter_bool`/
          :py:meth:`~pyfmodex.dsp.DSP.set_parameter_data`. This is platform
          independent and is dynamic, so new unknown plugins can have their
          parameters enumerated and used.
        - The other is to use
          :py:meth:`~pyfmodex.dsp.DSP.show_config_dialog`. This is platform
          specific and requires a GUI, and will display a dialog box to
          configure the plugin.
    """

    _fields_ = [
        ("pluginsdkversion", c_uint),
        ("name", c_char * 32),
        ("version", c_uint),
        ("numinputbuffers", c_int),
        ("numoutputbuffers", c_int),
        ("create", DSP_CREATE_CALLBACK),
        ("release", DSP_RELEASE_CALLBACK),
        ("reset", DSP_RESET_CALLBACK),
        ("read", DSP_READ_CALLBACK),
        ("process", DSP_PROCESS_CALLBACK),
        ("setposition", DSP_SETPOSITION_CALLBACK),
        ("numparameters", c_int),
        ("paramdesc", POINTER(POINTER(DSP_PARAMETER_DESC))),
        ("setparameterfloat", DSP_SETPARAM_FLOAT_CALLBACK),
        ("setparameterint", DSP_SETPARAM_INT_CALLBACK),
        ("setparameterbool", DSP_SETPARAM_BOOL_CALLBACK),
        ("setparameterdata", DSP_SETPARAM_DATA_CALLBACK),
        ("getparameterfloat", DSP_GETPARAM_FLOAT_CALLBACK),
        ("getparameterint", DSP_GETPARAM_INT_CALLBACK),
        ("getparameterbool", DSP_GETPARAM_BOOL_CALLBACK),
        ("getparameterdata", DSP_GETPARAM_DATA_CALLBACK),
        ("shouldiprocess", DSP_SHOULDIPROCESS_CALLBACK),
        ("userdata", c_void_p),
        ("sys_register", DSP_SYSTEM_REGISTER_CALLBACK),
        ("sys_deregister", DSP_SYSTEM_DEREGISTER_CALLBACK),
        ("sys_mix", DSP_SYSTEM_MIX_CALLBACK),
    ]


class ERRORCALLBACK_INFO(Structure):
    """Information describing an error that has occurred.

    :ivar RESULT result: Error code result.
    :ivar ERRORCALLBACK_INSTANCETYPE instancetype: Type of instance the error
        occurred on.
    :ivar instance: Instance pointer.
    :ivar str functionname: Function that the error occurred on.
    :ivar str functionparams: Function parameters that the error ocurred on
    """

    _fields_ = [
        ("result", c_int),
        ("instancetype", c_int),
        ("instance", c_void_p),
        ("functionname", c_char_p),
        ("functionparams", c_char_p),
    ]


class OUTPUT_DESCRIPTION(Structure):
    """Output description.

    This description structure allows the plugin writer to define all
    functionality required for a user defined output device.

    Pass this structure to :py:meth:`~pyfmodex.system.System.register_output`
    to create a new output type, or if defining a dynamically loadable plugin,
    return it in a function called FMODGetOutputDescription. FMOD's plugin
    loader will look for this function in a dynamic library.

    There are several methods for driving the FMOD mixer to service the audio
    hardware:

        - Polled: if the audio hardware must be polled regularly set 'method'
          to :py:attr:`~pyfmodex.enums.OUTPUT_METHOD.POLLING`,
          FMOD will create a mixer thread that calls back via
          :py:data:`~pyfmodex.callback_prototypes.OUTPUT_GETPOSITION_CALLBACK`.
          Once an entire block of samples have played FMOD will call
          :py:data:`~pyfmodex.callback_prototypes.OUTPUT_LOCK_CALLBACK` to
          allow you to provide a destination pointer to write the next mix.

        - Callback: if the audio hardware provides a callback where you must
          provide a buffer of samples then set 'method' to
          :py:attr:`~pyfmodex.enums.OUTPUT_METHOD.MIX_BUFFERED`,
          and directly call
          :py:data:`~pyfmodex.function_prototypes.OUTPUT_READFROMMIXER`.

        - Synchronization: if the audio hardware provides a synchronization
          primitive to wait on then set 'method' to
          :py:attr:`~pyfmodex.enums.OUTPUT_METHOD.MIX_DIRECT`,
          and give a
          :py:data:`~pyfmodex.callback_prototypes.OUTPUT_MIXER_CALLBACK`.
          pointer. FMOD will create a mixer thread and call you repeatedly once
          :py:data:`~pyfmodex.callback_prototypes.OUTPUT_START_CALLBACK` has
          finished, you must wait on your primitive in this callback and upon
          wake call
          :py:data:`~pyfmodex.function_prototypes.OUTPUT_READFROMMIXER`.

        - Non-realtime: if you are writing a file or driving a non-realtime
          output call
          :py:data:`~pyfmodex.function_prototypes.OUTPUT_READFROMMIXER` from
          :py:data:`~pyfmodex.callback_prototypes.OUTPUT_UPDATE_CALLBACK`.

    Callbacks marked with 'user thread' will be called in response to the user
    of the FMOD Core API, in the case of the Studio API, the user is the Studio
    Update thread.

    :ivar int apiversion: The output plugin API version this plugin is built
        for. Set to this to FMOD_OUTPUT_PLUGIN_VERSION.
    :ivar str name: Name of the output plugin, encoded as a UTF-8 string.
    :ivar int version: Version of the output plugin.
    :ivar OUTPUT_METHOD method: Method by which the mixer is executed and
        buffered.
    :ivar OUTPUT_GETNUMDRIVERS_CALLBACK getnumdrivers: User thread callback to
        provide the number of attached sound devices. Called from
        :py:attr:`~pyfmodex.system.System.num_drivers`.
    :ivar OUTPUT_GETDRIVERINFO_CALLBACK getdriverinfo: User thread callback to
        provide information about a particular sound device. Called from
        :py:meth:`~pyfmodex.system.System.get_driver_info`.
    :ivar OUTPUT_INIT_CALLBACK init: User thread callback to allocate resources
        and provide information about hardware capabilities. Called from
        :py:meth:`~pyfmodex.system.System.init`.
    :ivar OUTPUT_START_CALLBACK start: User thread callback just before mixing
        should begin, calls to
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_GETPOSITION_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_LOCK_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_UNLOCK_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_MIXER_CALLBACK` will
        start, you may call
        :py:data:`pyfmodex.function_prototypes.OUTPUT_READFROMMIXER` after this
        point. Called from :py:meth:`~pyfmodex.system.System.init`.
    :ivar OUTPUT_STOP_CALLBACK stop: User thread callback just after mixing has
        finished, calls to
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_GETPOSITION_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_LOCK_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_UNLOCK_CALLBACK` /
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_MIXER_CALLBACK` will
        have stopped, you may not call
        :py:data:`pyfmodex.function_prototypes.OUTPUT_READFROMMIXER` after this
        point. Called from :py:meth:`~pyfmodex.system.System.init`.
    :ivar OUTPUT_CLOSE_CALLBACK close: User thread callback to clean up
        resources allocated during
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_INIT_CALLBACK`. Called
        from :py:meth:`~pyfmodex.system.System.init`. and
        :py:meth:`~pyfmodex.system.System.close`.
    :ivar OUTPUT_UPDATE_CALLBACK update: User thread callback once per frame to
        update internal state. Called from
        :py:meth:`~pyfmodex.system.System.update`.
    :ivar OUTPUT_GETHANDLE_CALLBACK gethandle: User thread callback to provide
        a pointer to the internal device object used to share with other audio
        systems. Called from :py:meth:`~pyfmodex.system.System.output_handle`.
    :ivar OUTPUT_GETPOSITION_CALLBACK getposition: Mixer thread callback  to
        provide the hardware playback position in the output ring buffer.
        Called before a mix.
    :ivar OUTPUT_LOCK_CALLBACK lock: Mixer thread callback  to provide a
        pointer the mixer can write to for the next block of audio data. Called
        before a mix.
    :ivar OUTPUT_UNLOCK_CALLBACK unlock: Mixer thread callback  to signify the
        mixer has finished writing to the pointer from
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_LOCK_CALLBACK`. Called
        after a mix.
    :ivar OUTPUT_MIXER_CALLBACK mixer: Mixer thread callback  called repeatedly
        to give a thread for waiting on an audio hardware synchronization
        primitive. Ensure you have a reasonable timeout (~200ms) on your
        synchronization primitive and allow this callback to return once per
        wakeup to avoid deadlocks.
    :ivar OUTPUT_OBJECT3DGETINFO_CALLBACK object3dgetinfo: Mixer thread
        callback to provide information about the capabilities of 3D object
        hardware. Called during a mix.
    :ivar OUTPUT_OBJECT3DALLOC_CALLBACK object3dalloc: Mixer thread callback to
        reserve a hardware resources for a single 3D object. Called during a
        mix.
    :ivar OUTPUT_OBJECT3DFREE_CALLBACK object3dfree: Mixer thread callback to
        release a hardware resource previously acquired with
        :py:data:`pyfmodex.callback_prototypes.OUTPUT_OBJECT3DALLOC_CALLBACK`.
        Called during a mix.
    :ivar OUTPUT_OBJECT3DUPDATE_CALLBACK object3dupdate: Mixer thread callback
        once for every acquired 3D object every mix to provide 3D information
        and buffered audio. Called during a mix.
    :ivar OUTPUT_OPENPORT_CALLBACK openport: Main thread callback to open an
        auxiliary output port on the device.
    :ivar OUTPUT_CLOSEPORT_CALLBACK closeport: Main thread callback to close an
        auxiliary output port on the device.
    :ivar OUTPUT_DEVICELISTCHANGED_CALLBACK devicelistchanged: Main thread
        callback to notify that a change to the device list may have occurred.
    """

    _fields_ = [
        ("apiversion", c_uint),
        ("name", c_char_p),
        ("version", c_uint),
        ("method", c_uint),
        ("getnumdrivers", OUTPUT_GETNUMDRIVERS_CALLBACK),
        ("getdriverinfo", OUTPUT_GETDRIVERINFO_CALLBACK),
        ("init", OUTPUT_INIT_CALLBACK),
        ("start", OUTPUT_START_CALLBACK),
        ("stop", OUTPUT_STOP_CALLBACK),
        ("close", OUTPUT_CLOSE_CALLBACK),
        ("update", OUTPUT_UPDATE_CALLBACK),
        ("gethandle", OUTPUT_GETHANDLE_CALLBACK),
        ("getposition", OUTPUT_GETPOSITION_CALLBACK),
        ("lock", OUTPUT_LOCK_CALLBACK),
        ("unlock", OUTPUT_UNLOCK_CALLBACK),
        ("mixer", OUTPUT_MIXER_CALLBACK),
        ("object3dgetinfo", OUTPUT_OBJECT3DGETINFO_CALLBACK),
        ("object3dalloc", OUTPUT_OBJECT3DALLOC_CALLBACK),
        ("object3dfree", OUTPUT_OBJECT3DFREE_CALLBACK),
        ("object3dupdate", OUTPUT_OBJECT3DUPDATE_CALLBACK),
        ("openport", OUTPUT_OPENPORT_CALLBACK),
        ("closeport", OUTPUT_CLOSEPORT_CALLBACK),
        ("devicelistchanged", OUTPUT_DEVICELISTCHANGED_CALLBACK),
    ]


OUTPUT_OBJECT3DINFO._fields_ = [
    ("buffer", POINTER(c_float)),
    ("bufferlength", c_uint),
    ("position", VECTOR),
    ("gain", c_float),
    ("spread", c_float),
    ("priority", c_float),
]


OUTPUT_STATE._fields_ = [
    ("plugindata", c_void_p),
    ("readfrommixer", OUTPUT_READFROMMIXER),
    ("alloc", OUTPUT_ALLOC),
    ("free", OUTPUT_FREE),
    ("log", OUTPUT_LOG),
    ("copyport", OUTPUT_COPYPORT),
    ("requestreset", OUTPUT_REQUESTRESET),
]


class PLUGINLIST(Structure):
    """Used to support lists of plugins within the one dynamic library.

    This structure is returned from a plugin as a pointer to a list where the
    last entry has :py:attr:`~pyfmodex.enums.PLUGINTYPE.MAX` and a NULL
    description.

    :ivar PLUGINTYPE type: Plugin type.
    :ivar description: One of the plugin description structures
        (:py:class:`DSP_DESCRIPTION`, :py:class:`OUTPUT_DESCRIPTION`,
        :py:class:`CODEC_DESCRIPTION`)
    """

    _fields_ = [("type", c_int), ("description", c_void_p)]


class REVERB_PROPERTIES(Structure):
    """Structure defining a reverb environment.

    Note the default reverb properties are the same as the
    :py:attr:`~pyfmodex.reverb_presets.REVERB_PRESET.GENERIC` preset.

    :ivar float DecayTime: Reverberation decay time.
    :ivar float EarlyDelay: Initial reflection delay time.
    :ivar float LateDelay: Late reverberation delay time relative to initial
        reflection.
    :ivar float HFReference: Reference high frequency.
    :ivar float HFDecayRatio: High-frequency to mid-frequency decay time ratio.
        Value that controls the echo density in the late reverberation decay.
    :ivar float Density: Value that controls the modal density in the late
        reverberation decay.
    :ivar float LowShelfFrequency: Reference low frequency
    :ivar float LowShelfGain: Relative room effect level at low frequencies.
    :ivar float HighCut: Relative room effect level at high frequencies.
    :ivar float EarlyLateMix: Early reflections level relative to room effect.
    :ivar float WetLevel: Room effect level at mid frequencies.
    """

    _fields_ = [
        ("DecayTime", c_float),
        ("EarlyDelay", c_float),
        ("LateDelay", c_float),
        ("HFReference", c_float),
        ("HFDecayRatio", c_float),
        ("Diffusion", c_float),
        ("Density", c_float),
        ("LowShelfFrequency", c_float),
        ("LowShelfGain", c_float),
        ("HighCut", c_float),
        ("EarlyLateMix", c_float),
        ("WetLevel", c_float),
    ]


class TAG(Structure):
    """Tag data / metadata description.

    :ivar TAGTYPE type: Tag type.
    :ivar TAGDATATYPE datatype: Tag data type.
    :ivar str name: Name.
    :ivar data: Tag data.
    :ivar int datalen: Size of data.
    :ivar bool updated: True if this tag has been updated since last being
        accessed with :py:meth:`~pyfmodex.sound.Sound.get_tag`.
    """

    _fields_ = [
        ("type", c_int),
        ("datatype", c_int),
        ("name", c_char_p),
        ("data", c_void_p),
        ("datalen", c_uint),
        ("updated", c_bool),
    ]
