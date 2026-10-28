"""Strcuture declarations."""

# pylint: disable=too-few-public-methods
# Just declaring at this point...

# pylint: disable=invalid-name
# Just staying close to the original names here.


from ctypes import Structure


class CODEC_STATE(Structure):
    """Codec state structure that is passed into each callback.

    `numsubsounds` should be 1+ if the file is a container format, and does not
    contain wav data itself. Examples of these types would be FSB (contains
    multiple sounds), DLS (contain instruments).

    The `waveformat` value should point to an arrays of information based on
    how many subsounds are in the format. If the number of subsounds is 0 then
    it should point to one waveformat, the same as if the number of subsounds
    was one. If subsounds was 100 for example, there should be a pointer to an
    array of 100 waveformat structures.

    When a sound has one or more subsounds, the caller must play the individual
    sounds specified by first obtaining the subsound with
    :py:meth:`~pyfmodex.sound.Sound.get_subsound`.

    :ivar int numsubsounds: Number of 'subsounds' in this sound. Anything other
        than 0 makes it a 'container' format.
    :ivar CODEC_WAVEFORMAT waveformat: Array of format structures containing
        information about each sound.
    :ivar plugindata: Plugin writer created data the codec author wants to
        attach to this object.
    :ivar filehandle: This will return an internal FMOD file handle to use with
        the callbacks provided.
    :ivar int filesize: This will contain the size of the file in bytes.
    :ivar FILE_READ_CALLBACK fileread: This will return a callable FMOD file
        function to use from codec.
    :ivar FILE_SEEK_CALLBACK fileseek: This will return a callable FMOD file
        function to use from codec.
    :ivar CODEC_METADATA_CALLBACK metadata: This will return a callable FMOD
        metadata function to use from codec.
    :ivar int waveformatversion: Must be set to
        :py:const:`~pyfmodex.constants.CODEC_WAVEFORMAT_VERSION` in the
        CODEC_OPEN_CALLBACK.
    """


class CREATESOUNDEXINFO(Structure):
    """Additional options for creating a Sound.

    Loading a file from memory:

        - Create the sound using the :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY`
          flag.
        - Specify `length` for the size of the memory block in bytes.

    Loading a file from within another larger (possibly wad/pak) file, by
    giving the loader an offset and length:

        - Specify `fileoffset` and `length`.

    Create a user created / non-file based sound:

        - Create the sound using the :py:attr:`~pyfmodex.flags.MODE.OPENUSER`
          flag.
        - Specify `defaultfrequency`, `numchannels` and `format`.

    Load an FSB stream seeking to a specific subsound in one file operation:

        - Create the sound using the
          :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM` flag.
        - Specify `initialsubsound`.

    Load a subset of the Sounds in an FSB saving memory:

        - Specify `inclusionlist` and `inclusionlistnum`.
        - Optionally set numsubsounds to match `inclusionlistnum`, saves memory
          and causes :py:meth:`~pyfmodex.sound.Sound.get_subsound` to index
          into `inclusionlist`.

    Capture sound data as it is decoded:

        - Specify `pcmreadcallback` and `pcmseekcallback`.

    Provide a custom DLS for MIDI playback:

        - Specify `dlsname`.

    Setting the `decodebuffersize` is for CPU intensive codecs that may be
    causing stuttering, not file intensive codecs (i.e. those from CD or net
    streams) which are normally altered with
    :py:attr:`~pyfmodex.system.System.stram_buffer_size`. As an example of CPU
    intensive codecs, an MP3 file will take more CPU to decode than a PCM wav
    file.

    If you have a stuttering effect, then it is using more CPU than the decode
    buffer playback rate can keep up with. Increasing the decodebuffersize will
    most likely solve this problem.

    FSB codec: If `inclusionlist` and `numsubsounds` are used together, this
    will trigger a special mode where subsounds are shuffled down to save
    memory (useful for large FSB files where you only want to load one sound).
    There will be no gaps, i.e. no null subsounds. As an example, if there are
    10,000 subsounds and there is an inclusionlist with only one entry, and
    `numsubsounds` = 1, then subsound 0 will be that entry, and there will only
    be the memory allocated for one subsound. Previously there would still be
    10,000 subsound pointers and other associated codec entries allocated along
    with it multiplied by 10,000.

    :ivar int audioqueuepolicy: Hardware / software decoding policy for
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.MIDI`.
    :ivar int cbsize: Size of this structure. Must be set to
        sizeof(`CREATESOUNDEXINFO`) before calling
        :py:meth:`~pyfmodex.system.System.create_sound` or
        :py:meth:`~pyfmodex.system.System.create_stream`.
    :ivar CHANNELORDER channelorder: Custom ordering of speakers for this sound
        data.
    :ivar int decodebuffersize: Size of the decoded buffer for
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`, or the block size used
        with `pcmreadcallback` for :py:attr:`~pyfmodex.flags.MODE.OPENUSER`.
    :ivar int defaultfrequency: Default frequency of sound data for
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER` /
        :py:attr:`~pyfmodex.flags.MODE.OPENRAW`.
    :ivar str dlsname: File path for a FMOD_SOUND_TYPE_DLS sample set to use
        when loading a :py:attr:`~pyfmodex.enums.SOUND_TYPE.MIDI` file.
    :ivar str encryptionkey: Key for encrypted
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.FSB` file, cannot be used in
        conjunction with :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT`.
    :ivar int filebuffersize: Buffer size for reading the file, -1 to disable
        buffering.
    :ivar int fileoffset: File offset to start reading from.
    :ivar FILE_CLOSE_CALLBACK fileuserclose: Callback for closing this file.
    :ivar FILE_OPEN_CALLBACK fileuseropen: Callback for opening this file.
    :ivar FILE_ASYNCREAD_CALLBACK fileuserasyncread: Callback for seeking
        within this file.
    :ivar FILE_ASYNCCANCEL_CALLBACK fileuserasynccancel: Callback for seeking
        within this file.
    :ivar fileuserdata: User data to be passed into the file callbacks.
    :ivar FILE_READ_CALLBACK fileuserread: Callback for reading from this file.
    :ivar FILE_SEEK_CALLBACK fileuserseek: Callback for seeking within this
        file.
    :ivar SOUND_FORMAT format: Format of sound data for
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER` /
        :py:attr:`~pyfmodex.flags.MODE.OPENRAW`.
    :ivar GUID fsbguid: On input, GUID of already loaded
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.FSB` file to reduce disk access,
        on output, GUID of loaded FSB.
    :ivar int ignoresetfilesystem: Ignore
        :py:meth:`~pyfmodex.system.System.set_file_system` and
        CREATESOUNDEXINFO file callbacks.
    :ivar list(int) inclusionlist: List of subsound indices to load from file.
    :ivar int inclusionlistnum: Number of items in `inclusionlist`.
    :ivar SoundGroup initialsoundgroup: SoundGroup to place this Sound in once
        created.
    :ivar int initialseekposition: Initial position to seek to for
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`.
    :ivar TIMEUNIT initialseekpostype: Time units for `initialseekposition`.
    :ivar int initialsubsound: Initial subsound to seek to for
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`.
    :ivar int length: Bytes to read starting at `fileoffset`, or length of
        Sound to create for :py:attr:`~pyfmodex.flags.MODE.OPENUSER`, or length
        of name_or_data for :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY` /
        :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT`
    :ivar int maxpolyphony: Maximum voice count for
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.MIDI` /
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.IT`
    :ivar int minmidigranularity: Mixer granularity for
        :py:attr:`~pyfmodex.enums.SOUND_TYPE.MIDI`. sounds, smaller numbers
        give a more accurate reproduction at the cost of higher CPU usage.
    :ivar SOUND_NONBLOCKCALLBACK nonblockcallback: Callback to notify
        completion for :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING`, occurs
        during creation and seeking / restarting streams.
    :ivar int nonblockthreadid: Thread index to execute
        :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` loads on for parallel Sound
        loading.
    :ivar int numchannels: Number of channels in sound data for
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER` /
        :py:attr:`~pyfmodex.flags.MODE.OPENRAW`.
    :ivar int numsubsounds: Number of subsounds available for
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER`, or maximum subsounds to load
        from file.
    :ivar SOUND_PCMREADCALLBACK pcmreadcallback: Callback to provide audio for
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER`, or capture audio as it is
        decoded.
    :ivar SOUND_PCMSETPOSCALLBACK pcmsetposcallback: Callback to perform
        seeking for :py:attr:`~pyfmodex.flags.MODE.OPENUSER`, or capture seek
        requests.
    :ivar SOUND_TYPE suggestedsoundtype: Attempt to load using the specified
        type first instead of loading in codec priority order.
    :ivar userdata: User data to be attached to the Sound during creation.
    """


class DSP_STATE(Structure):
    """DSP plugin structure that is passed into each callback.

    `systemobject` is an integer that relates to the System object that created
    the DSP or registered the DSP plugin. If only one System object is created
    then it should be 0. A second object would be 1 and so on.

    :py:attr:`~pyfmodex.structures.DSP_STATE_FUNCTIONS.getsamplerate`/
    :py:attr:`~pyfmodex.structures.DSP_STATE_FUNCTIONS.getblocksize`/
    :py:attr:`~pyfmodex.structures.DSP_STATE_FUNCTIONS.getspeakermode`
    could return different results so it could be relevant to plugin developers
    to monitor which object is being used.


    :ivar instance: Internal instance pointer.
    :ivar plugindata: Plugin writer created data the output author wants to
        attach to this object.
    :ivar CHANNELMASK channelmask: Specifies which speakers the DSP effect is
        active on.
    :ivar SPEAKERMODE sourcespeakermode: Specifies which speaker mode the
        signal originated.
    :ivar float sidechaindata: Sidechain mix result.
    :ivar int sidechainchannels: Number of channels in the sidechain buffer.
    :ivar DSP_STATE_FUNCTIONS functions: Struct containing functions to give
        plugin developers the ability to query system state, access system
        level functionality and helpers.
    :ivar systemobject: :py:class:`~pyfmodex.system.System` object index,
        relating to the System object that created this DSP.
    """


class DSP_BUFFER_ARRAY(Structure):
    """Structure for input and output buffers.

    :ivar int numbuffers: Array size of buffers.
    :ivar int buffernumchannels: Array of number of channels for each buffer.
    :ivar CHANNELMASK bufferchannelmask: Array of channel masks for each
        buffer.
    :ivar list(float) buffers: Array of buffers.
    :ivar SPEAKERMODE speakermode: speaker mode for all buffers in the array.
    """


class ASYNCREADINFO(Structure):
    """Information about a single asynchronous file operation.

    When servicing the async read operation, read from `handle` at the given
    `offset` for `sizebytes` into `buffer`. Write the number of bytes read into
    `bytesread` then call `done` with the :py:class:`~pyfmodex.enums.RESULT`
    that matches the success of the operation.

    :ivar handle: File handle that was returned in
        :py:data:`~pyfmodex.callback_prototypes.CODEC_OPEN_CALLBACK`.
    :ivar int offset: Offset within the file where the read operation should
        occur.
    :ivar int sizebytes: Number of bytes to read.
    :ivar int priority: Priority hint for how quickly this operation should be
        serviced where 0 represents low importance and 100 represents extreme
        importance. This could be used to prioritize the read order of a file
        job queue for example. FMOD decides the importance of the read based on
        if it could degrade audio or not.
    :ivar userdata: User value associated with this async operation, passed to
        :py:data:`~pyfmodex.callback_prototypes.FILE_ASYNCCANCEL_CALLBACK`.
    :ivar buffer: Buffer to read data into.
    :ivar int bytesread: Number of bytes read into buffer.
    :ivar FILE_ASYNCDONE_FUNC done: Completion function to signal the async
        read is done.
    """


class OUTPUT_STATE(Structure):
    """Output object state passed into every callback provides access to plugin
    developers data and system functionality.

    :ivar plugindata: Plugin state data.
    :ivar OUTPUT_READFROMMIXER readfrommixer: Function to execute the mixer
        producing a buffer of audio. Used to control when the mix occurs
        manually as an alternative to
        :py:class:`~pyfmodex.structures.OUTPUT_DESCRIPTION` set to
        OUTPUT_METHOD_POLLING.
    :ivar OUTPUT_ALLOC alloc: Function to allocate memory using the FMOD memory
        system.
    :ivar OUTPUT_FREE free: Function to free memory allocated with
        OUTPUT_ALLOC.
    :ivar OUTPUT_LOG log: Function to write to the FMOD logging system.
    :ivar OUTPUT_COPYPORT copyport: Function to copy the output from the mixer
        for the given auxiliary port.
    :ivar OUTPUT_REQUESTRESET requestreset: Function to request the output
        plugin be shutdown then restarted during the next
        :py:meth:`~pyfmodex.system.System.update`.`
    """


class GUID(Structure):
    """Structure describing a globally unique identifier.

    :ivar int data1: Specifies the first 8 hexadecimal digits of the GUID.
    :ivar int data2: Specifies the first group of 4 hexadecimal digits.
    :ivar int data3: Specifies the second group of 4 hexadecimal digits.
    :ivar bytes data4: Array of 8 bytes. The first 2 bytes contain the
        third group of 4 hexadecimal digits. The remaining 6 bytes contain the
        final 12 hexadecimal digits.
    """


class OUTPUT_OBJECT3DINFO(Structure):
    """Output 3D Object Info.

    This callback is used for 'Object mixing' where sound hardware can receive
    individual audio streams and position them in 3D space natively, separate
    from the FMOD mixer. A typical implementation would be something like Dolby
    Atmos or Atmos or Playstation VR.

    This structure is passed to the plugin via
    :py:data:`~pyfmodex.callback_prototypes.OUTPUT_OBJECT3DUPDATE_CALLBACK`, so
    that whatever object based panning solution available can position it in
    the speakers correctly. Object based panning is a 3D panning solution that
    sends a mono only signal to a hardware device, such as Dolby Atmos or other
    similar panning solutions.

    FMOD does not attenuate the buffer, but provides a 'gain' parameter that
    the user must use to scale the buffer by. Rather than pre-attenuating the
    buffer, the plugin developer can access untouched data for other purposes,
    like reverb sending for example. The 'gain' parameter is based on the
    user's 3D custom rolloff model.

    :ivar float buffer: Mono PCM floating point buffer. This buffer needs to be
        scaled by the gain value to get distance attenuation.
    :ivar int bufferlength: Length in PCM samples of buffer.
    :ivar VECTOR position: Vector relative between object and listener.
    :ivar float gain: 0.0 to 1.0 - 1 = 'buffer' is not attenuated, 0 = 'buffer'
        is fully attenuated.
    :ivar float spread: 0 - 360 degrees. 0 = point source, 360 = sound is
        spread around all speakers
    :ivar float priority: 0.0 to 1.0 - 0 = most important, 1 = least important.
        Based on height and distance (height is more important).
    """


class CODEC_WAVEFORMAT(Structure):
    """Codec wave format.

    This structure defines the attributes of a sound, and determines the format
    of the Sound object when it is created with
    :py:meth:`~pyfmodex.system.System.create_sound` or
    :py:meth:`~pyfmodex.system.System.create_stream`.

    The `format`, `channels`, `frequency` and lengthpcm tell FMOD what sort of
    sound buffer to create when you initialize your code.

    If you wrote an MP3 codec that decoded to stereo 16bit integer PCM for a
    44khz sound, you would specify
    :py:attr:`~pyfmodex.enums.SOUND_FORMAT.PCM16`, and channels would be equal
    to 2, and frequency would be 44100.

    Note: When registering a codec, format, channels, frequency and lengthpcm
    must be supplied, otherwise there will be an error.

    This structure is optional if
    :py:data:`~pyfmodex.callback_prototypes.CODEX_GETWAVEFORMAT_CALLBACK` is
    specified.

    An array of these structures may be needed if
    :py:attr:`CODEC_STATE.numsubsounds` is larger than 1.

    :ivar str name: Name of sound. The codec must own the lifetime of the
        string memory until the codec is destroyed.
    :ivar SOUND_FORMAT format: Format for codec output.
    :ivar int channels: Number of channels.
    :ivar int frequency: Default frequency of the codec.
    :ivar int lengthbytes: Length of the source data. Used for
        :py:attr:`~pyfmodex.flags.TIMEUNIT.RAWBYTES`.`
        :ivar int lengthpcm: Length of the file. Used for
        :py:meth:`~pyfmodex.sound.Sound.get_length` and for memory allocation of
        static decompressed sample data.
    :ivar int pcmblocksize: Minimum, optimal number of decompressed PCM samples
        codec can handle.
    :ivar int loopstart: Loop start position.
    :ivar int loopend: Loop end position.
    :ivar MODE mode: Default sound loading mode.
    :ivar CHANNELMASK channelmask: Channel bitmask to describe which speakers
        the channels in the codec map to, in order of channel count.
    :ivar CHANNELORDER channelorder: Channel order type that describes where
        each sound channel should pan for the number of channels specified.
    :ivar float peakvolume: Peak volume of sound.
    """


class THREED_ATTRIBUTES(Structure):
    """Structure describing a position, velocity and orientation.

    :ivar VECTOR position: Position in world space used for panning and
        attenuation.
    :ivar VECTOR velocity: Velocity in world space used for doppler.
    :ivar VECTOR forward: Forwards orientation, must be of unit length (1.0)
        and perpendicular to `up`.
    :ivar VECTOR up: Upwards orientation, must be of unit length (1.0) and
        perpendicular to `forward`.
    """


class COMPLEX(Structure):
    """Complex number structure.

    :ivar float real: Real component
    :ivar float imag: Imaginary component
    """
