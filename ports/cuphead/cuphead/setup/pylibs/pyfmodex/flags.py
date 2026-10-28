"""Flags."""

# pylint: disable=invalid-name
# Just staying close to the original names here.


from enum import Flag


class CHANNELMASK(Flag):
    """Flags that describe the speakers present in a given signal."""

    FRONT_LEFT = 0x00000001  #: Front left channel.
    FRONT_RIGHT = 0x00000002  #: Front right channel.
    FRONT_CENTER = 0x00000004  #: Front center channel.
    LOW_FREQUENCY = 0x00000008  #: Low frequency channel.
    SURROUND_LEFT = 0x00000010  #: Surround left channel.
    SURROUND_RIGHT = 0x00000020  #: Surround right channel.
    BACK_LEFT = 0x00000040  #: Back left channel.
    BACK_RIGHT = 0x00000080  #: Back right channel.

    #: Back center channel, not represented in any
    #: :py:class:`~pyfmodex.enums.SPEAKERMODE`.
    BACK_CENTER = 0x00000100

    MONO = FRONT_LEFT  #: Mono channel mask.
    STEREO = FRONT_LEFT | FRONT_RIGHT  #: Stereo channel mask.

    #: Left / right / center channel mask.
    LRC = FRONT_LEFT | FRONT_RIGHT | FRONT_CENTER

    #: Quadphonic channel mask.
    QUAD = FRONT_LEFT | FRONT_RIGHT | SURROUND_LEFT | SURROUND_RIGHT

    #: 5.0 surround channel mask.
    SURROUND = FRONT_LEFT | FRONT_RIGHT | FRONT_CENTER | SURROUND_LEFT | SURROUND_RIGHT

    #: 5.1 surround channel mask.
    FIVEPOINTONE = (
        FRONT_LEFT
        | FRONT_RIGHT
        | FRONT_CENTER
        | LOW_FREQUENCY
        | SURROUND_LEFT
        | SURROUND_RIGHT
    )

    #: 5.1 surround channel mask, using rears instead of surrounds.
    FIVEPOINTONE_REARS = (
        FRONT_LEFT | FRONT_RIGHT | FRONT_CENTER | LOW_FREQUENCY | BACK_LEFT | BACK_RIGHT
    )

    #: 7.0 surround channel mask.
    SEVENPOINTZERO = (
        FRONT_LEFT
        | FRONT_RIGHT
        | FRONT_CENTER
        | SURROUND_LEFT
        | SURROUND_RIGHT
        | BACK_LEFT
        | BACK_RIGHT
    )

    #: 7.1 surround channel mask.
    SEVENPOINTONE = (
        FRONT_LEFT
        | FRONT_RIGHT
        | FRONT_CENTER
        | LOW_FREQUENCY
        | SURROUND_LEFT
        | SURROUND_RIGHT
        | BACK_LEFT
        | BACK_RIGHT
    )


class DEBUG_FLAGS(Flag):
    """Specify the requested information to be output when using the logging
    version of FMOD.
    """

    LEVEL_NONE = 0x0 #: Disable all messages.
    LEVEL_ERROR = 0x00000001  #: Enable only error messages.
    LEVEL_WARNING = 0x00000002  #: Enable warning and error messages.

    #: Enable informational, warning and error messages (default).
    LEVEL_LOG = 0x00000004

    #: Verbose logging for memory operations, only use this if you are
    #: debugging a memory related issue.
    TYPE_MEMORY = 0x00000100

    #: Verbose logging for file access, only use this if you are debugging a
    #: file related issue.
    TYPE_FILE = 0x00000200

    #: Verbose logging for codec initialization, only use this if you are
    #: debugging a codec related issue.
    TYPE_CODEC = 0x00000400

    #: Verbose logging for internal errors, use this for tracking the origin of
    #: error codes.
    TYPE_TRACE = 0x00000800

    #: Display the time stamp of the log message in milliseconds.
    DISPLAY_TIMESTAMPS = 0x00010000

    #: Display the source code file and line number for where the message
    #: originated.
    DISPLAY_LINENUMBERS = 0x00020000

    #: Display the thread ID of the calling function that generated the
    #: message.
    DISPLAY_THREAD = 0x00040000


class DRIVER_STATE(Flag):
    """Flags that provide additional information about a particular driver."""

    #: Device is currently plugged in.
    CONNECTED = 0x00000001

    #: Device is the users preferred choice.
    DEFAULT = 0x00000002


class INIT_FLAGS(Flag):
    """Configuration flags used when initializing the System object."""

    NORMAL = 0x0 #: Initialize normally.

    #: No stream thread is created internally. Streams are driven from
    #: :py:meth:`~pyfmodex.system.System.update`. Mainly used with non-realtime
    #: outputs.
    STREAM_FROM_UPDATE = 0x00000001

    #: No mixer thread is created internally. Mixing is driven from
    #: :py:meth:`~pyfmodex.system.System.update`. Only applies to polling based
    #: output modes such as :py:attr:`~pyfmodex.enums.OUTPUTTYPE.NOSOUND`,
    #: :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WAVWRITER`.
    MIX_FROM_UPDATE = 0x00000002

    #: 3D calculations will be performed in right-handed coordinates.
    THREED_RIGHTHANDED = 0x00000004

    #: Enables setting of
    #: :py:attr:`~pyfmodex.channel_control.ChannelControl.low_pass_gain`,
    #: :py:attr:`~pyfmodex.channel_control.ChannelControl.direct_occlusion`,
    #: :py:attr:`~pyfmodex.channel_control.ChannelControl.reverb_occlusion`, or
    #: automatic usage by the Geometry API. All voices will add a software
    #: lowpass filter effect into the DSP chain which is idle unless one of the
    #: previous functions/features are used.
    CHANNEL_LOWPASS = 0x00000100

    #: All 3D based voices will add a software lowpass and highpass filter
    #: effect into the DSP chain which will act as a distance-automated
    #: bandpass filter. Use
    #: :py:attr:`~pyfmodex.system.System.advanced_settings` to adjust the
    #: center frequency.
    CHANNEL_DISTANCEFILTER = 0x00000200

    #: Enable TCP/IP based host which allows FMOD Studio or FMOD Profiler to
    #: connect to it, and view memory, CPU and the DSP network graph in
    #: real-time.
    PROFILE_ENABLE = 0x00010000

    #: Any sounds that are 0 volume will go virtual and not be processed except
    #: for having their positions updated virtually. Use
    #: :py:attr:`~pyfmodex.system.System.advanced_settings` to adjust what
    #: volume besides zero to switch to virtual at.
    VOL0_BECOMES_VIRTUAL = 0x00020000

    #: With the geometry engine, only process the closest polygon rather than
    #: accumulating all polygons the sound to listener line intersects.
    GEOMETRY_USECLOSEST = 0x00040000

    #: When using :py:attr:`~pyfmodex.enums.SPEAKERMODE.FIVEPOINTONE` with a
    #: stereo output device, use the Dolby Pro Logic II downmix algorithm
    #: instead of the default stereo downmix algorithm.
    PREFER_DOLBY_DOWNMIX = 0x00080000

    #: Disables thread safety for API calls. Only use this if FMOD is being
    #: called from a single thread, and if Studio API is not being used!
    THREAD_UNSAFE = 0x00100000

    #: Slower, but adds level metering for every single DSP unit in the graph.
    #: Set :py:attr:`~pyfmodex.dsp.DSP.input_metering_enabled` and
    #: :py:attr:`~pyfmodex.dsp.DSP.output_metering_enabled` to turn meters off
    #: individually. Setting this flag implies :py:attr:`PROFILE_ENABLE`.
    PROFILE_METER_ALL = 0x00200000

    #: Enables memory allocation tracking. Currently this is only useful when
    #: using the Studio API. Increases memory footprint and reduces performance.
    MEMORY_TRACKING = 0x00400000


class MEMORY_TYPE(Flag):
    """Bitfields for memory allocation type being passed into FMOD memory
    callbacks.
    """

    NORMAL = 0x0 #: Standard memory.

    #: Stream file buffer, size controllable with
    #: :py:attr:`~pyfmodex.system.System.stream_buffer_size`.
    STREAM_FILE = 0x00000001

    #: Stream decode buffer, size controllable with
    #: :py:attr:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO.decodebuffersize`.
    STREAM_DECODE = 0x00000002

    #: Sample data buffer. Raw audio data, usually PCM/MPEG/ADPCM/XMA data.
    SAMPLEDATA = 0x00000004

    #: Deprecated.
    DSP_BUFFER = 0x00000008

    #: Memory allocated by a third party plugin.
    PLUGIN = 0x00000010

    #: Persistent memory. Memory will be freed when
    #: :py:meth:`~pyfmodex.system.System.release` is called.
    PERSISTENT = 0x00200000

    #: Mask specifying all memory types.
    ALL = 0xFFFFFFFF


class MODE(Flag):
    """Sound description bitfields, bitwise OR them together for loading and
    describing sounds.

    By default a sound will open as a static sound that is decompressed fully
    into memory to PCM (i.e. equivalent of :py:attr:`CREATESAMPLE`). To have a
    sound stream instead, use :py:attr:`CREATESTREAM`, or use the wrapper
    function :py:meth:`~pyfmodex.system.System.create_stream`.

    Some opening modes (i.e. :py:attr:`OPENUSER`, :py:attr:`OPENMEMORY`,
    :py:attr:`OPENMEMORY_POINT`, :py:attr:`OPENRAW`) will need extra
    information. This can be provided using the
    :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO` structure.

    Specifying :py:attr:`OPENMEMORY_POINT` will POINT to your memory rather
    allocating its own sound buffers and duplicating it internally. This means
    you cannot free the memory while FMOD is using it, until after
    :py:meth:`~pyfmodex.sound.Sound.release` is called.

    With :py:attr:`OPENMEMORY_POINT`, for PCM formats, only WAV, FSB, and RAW
    are supported. For compressed formats, only those formats supported by
    :py:attr:`CREATECOMPRESSEDSAMPLE` are supported.

    With :py:attr:`OPENMEMORY_POINT` and :py:attr:`OPENRAW` or PCM, if using
    them together, note that you must pad the data on each side by 16 bytes.
    This is so fmod can modify the ends of the data for looping / interpolation
    / mixing purposes. If a wav file, you will need to insert silence, and then
    reset loop points to stop the playback from playing that silence.
    """

    #: Default for all modes listed below: :py:attr:`LOOP_OFF`,
    #: :py:attr:`TWOD`, :py:attr:`THREED_WORLDRELATIVE`,
    #: :py:attr:`THREED_INVERSEROLLOFF`.
    DEFAULT = 0x0

    #: For non looping sounds. (DEFAULT). Overrides :py:attr:`LOOP_NORMAL` /
    #: :py:attr:`LOOP_BIDI`.
    LOOP_OFF = 0x00000001

    #: For forward looping sounds.
    LOOP_NORMAL = 0x00000002

    #: For bidirectional looping sounds. (only works on software mixed static
    # sounds).
    LOOP_BIDI = 0x00000004

    #: Ignores any 3D processing. (DEFAULT).
    TWOD = 0x00000008

    #: Makes the sound positionable in 3D. Overrides :py:attr:`TWOD`.
    THREED = 0x00000010

    #: Decompress at runtime, streaming from the source provided (i.e. from
    #: disk). Overrides :py:attr:`CREATESAMPLE` and
    #: :py:attr:`CREATECOMPRESSEDSAMPLE`. Note a stream can only be played once
    #: at a time due to a stream only having one stream buffer and file handle.
    #: Open multiple streams to have them play concurrently.
    CREATESTREAM = 0x00000080

    #: Decompress at loadtime, decompressing or decoding whole file into memory
    #: as the target sample format (ie PCM). Fastest for playback and most
    #: flexible.
    CREATESAMPLE = 0x00000100

    #: Load MP2/MP3/FADPCM/IMAADPCM/Vorbis/AT9 or XMA into memory and leave it
    #: compressed. Vorbis/AT9/FADPCM encoding only supported in the .FSB
    #: container format. During playback the FMOD software mixer will decode it
    #: in realtime as a 'compressed sample'. Overrides :py:attr:`CREATESAMPLE`.
    #: If the sound data is not one of the supported formats, it will behave as
    #: if it was created with :py:attr:`CREATESAMPLE` and decode the sound into
    #: PCM.
    CREATECOMPRESSEDSAMPLE = 0x00000200

    #: Opens a user created static sample or stream. Use the
    #: :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO` structure
    #: to specify format, defaultfrequency, numchannels, and optionally a read
    #: callback. If a user created 'sample' is created with no read callback,
    #: the sample will be empty. Use :py:meth:`~pyfmodex.sound.Sound.lock` and
    #: :py:meth:`~pyfmodex.sound.Sound.unlock` to place sound data into the
    #: sound if this is the case.
    OPENUSER = 0x00000400

    #: "name_or_data" will be interpreted as a pointer to memory instead of
    #: filename for creating sounds. Use the
    #: :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO` structure
    #: to specify length. If used with :py:attr:`CREATESAMPLE` or
    #: :py:attr:`CREATECOMPRESSEDSAMPLE`, FMOD duplicates the memory into its
    #: own buffers. Your own buffer can be freed after open, unless you are
    #: using :py:attr:`NONBLOCKING`. Then, wait until the Sound is in the
    #: :py:attr:`OPENSTATE_READY` state. If used with :py:attr:`CREATESTREAM`,
    #: FMOD will stream out of the buffer whose pointer you passed in. In this
    #: case, your own buffer should not be freed until you have finished with
    #: and released the stream.
    OPENMEMORY = 0x00000800

    #: "name_or_data" will be interpreted as a pointer to memory instead of
    #: filename for creating sounds. Use the
    #: :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO` structure
    #: to specify length. This differs to :py:attr:`OPENMEMORY` in that it uses
    #: the memory as is, without duplicating the memory into its own buffers.
    #: Cannot be freed after open, only after Sound::release. Will not work if
    #: the data is compressed and :py:attr:`CREATECOMPRESSEDSAMPLE` is not
    #: used. Cannot be used in conjunction with
    #: :py:attr:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO.encryptionkey`.
    OPENMEMORY_POINT = 0x10000000

    #: Will ignore file format and treat as raw pcm. Use the
    #: :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO` structure
    #: to specify format. Requires at least defaultfrequency, numchannels and
    #: format to be specified before it will open. Must be little endian data.
    OPENRAW = 0x00001000

    #: Just open the file, don't prebuffer or read. Good for fast opens for
    #: info, or when :py:meth:`~pyfmodex.sound.Sound.read_data` is to be used.
    OPENONLY = 0x00002000

    #: For :py:meth:`~pyfmodex.system.System.create_sound` - for accurate
    #: :py:meth:`~pyfmodex.sound.Sound.get_length` /
    #: :py:meth:`~pyfmodex.channel.Channel.set_position` on VBR MP3, and
    #: MOD/S3M/XM/IT/MIDI files. Scans file first, so takes longer to open.
    #: :py:attr:`OPENONLY` does not affect this.
    ACCURATETIME = 0x00004000

    #: For corrupted / bad MP3 files. This will search all the way through the
    #: file until it hits a valid MPEG header. Normally only searches for 4K.
    MPEGSEARCH = 0x00008000

    #: For opening sounds and getting streamed subsounds (seeking)
    #: asynchronously. Use :py:attr:`~pyfmodex.sound.Sound.open_state` to poll
    #: the state of the sound as it opens or retrieves the subsound in the
    #: background.
    NONBLOCKING = 0x00010000

    #: Unique sound, can only be played one at a time
    UNIQUE = 0x00020000

    #: Make the sound's position, velocity and orientation relative to the
    #: listener.
    THREED_HEADRELATIVE = 0x00040000

    #: Make the sound position, velocity and orientation absolute (relative
    #: to the world). (DEFAULT)
    THREED_WORLDRELATIVE = 0x00080000

    #: This sound will follow the inverse rolloff model where mindistance =
    #: full volume, maxdistance = where sound stops attenuating, and rolloff is
    #: fixed according to the global rolloff factor. (DEFAULT)
    THREED_INVERSEROLLOFF = 0x00100000

    #: This sound will follow a linear rolloff model where mindistance = full
    #: volume, maxdistance = silence.
    THREED_LINEARROLLOFF = 0x00200000

    #: This sound will follow a linear-square rolloff model where mindistance =
    #: full volume, maxdistance = silence.
    THREED_LINEARSQUAREROLLOFF = 0x00400000

    #: This sound will follow the inverse rolloff model at distances close to
    #: mindistance and a linear-square rolloff close to maxdistance.
    THREED_INVERSETAPEREDROLLOFF = 0x00800000

    #: This sound will follow a rolloff model defined by
    #: :py:attr:`~pyfmodex.sound.Sound.custom_rolloff`.
    THREED_CUSTOMROLLOFF = 0x04000000

    #: This sonds is not be affected by geometry occlusion. If not specified in
    #: :py:attr:`~pyfmodex.sound.Sound.mode`, or
    #: :py:attr:`~pyfmodex.channel_control.ChannelControl.mode`, the flag is
    #: cleared and it is affected by geometry again.
    THREED_IGNOREGEOMETRY = 0x40000000

    #: Skips id3v2/asf/etc tag checks when opening a sound, to reduce seek/read
    #: overhead when opening files.
    IGNORETAGS = 0x02000000

    #: Removes some features from samples to give a lower memory overhead, like
    #: :py:attr:`~pyfmodex.sound.Sound.name`.
    LOWMEM = 0x08000000

    #: For sounds that start virtual (due to being quiet or low importance),
    #: instead of swapping back to audible, and playing at the correct offset
    #: according to time, this flag makes the sound play from the start.
    VIRTUAL_PLAYFROMSTART = 0x80000000


class SYSTEM_CALLBACK_TYPE(Flag):
    """Types of callbacks called by the System."""

    #: Called from :py:meth:`~pyfmodex.system.System.update` when the
    #: enumerated list of devices has changed.
    DEVICELISTCHANGED = 0x00000001

    #: Deprecated.
    DEVICELOST = 0x00000002

    #: Called directly when a memory allocation fails.
    MEMORYALLOCATIONFAILED = 0x00000004

    #: Called directly when a thread is created.
    THREADCREATED = 0x00000008

    #: Deprecated.
    BADDSPCONNECTION = 0x00000010

    #: Called from the mixer thread before it starts the next block.
    PREMIX = 0x00000020

    #: Called from the mixer thread after it finishes a block.
    POSTMIX = 0x00000040

    #: Called directly when an API function returns an error, including delayed
    #: async functions.
    ERROR = 0x00000080

    #: Called from the mixer thread after clocks have been updated before the
    #: main mix occurs.
    MIDMIX = 0x00000100

    #: Called directly when a thread is destroyed.
    THREADDESTROYED = 0x00000200

    #: Called at start of :py:meth:`~pyfmodex.system.System.update`.
    PREUPDATE = 0x00000400

    #: Called at end of :py:meth:`~pyfmodex.system.System.update`.
    POSTUPDATE = 0x00000800

    #: Called from :py:meth:`~pyfmodex.system.System.update` when the
    #: enumerated list of recording devices has changed.
    RECORDLISTCHANGED = 0x00001000

    #: Called from the feeder thread after audio was consumed from the ring
    #: buffer, but not enough to allow another mix to run.
    BUFFEREDNOMIX = 0x00002000

    #: Called from :py:meth:`~pyfmodex.system.System.update` when an output
    #: device is re-initialized.
    DEVICEREINITIALIZE = 0x00004000

    #: Called from the mixer thread when the device output attempts to read
    #: more samples than are available in the output buffer.
    CALLBACK_OUTPUTUNDERRUN = 0x00008000

    #: Mask representing all callback types.
    ALL = 0xFFFFFFFF
