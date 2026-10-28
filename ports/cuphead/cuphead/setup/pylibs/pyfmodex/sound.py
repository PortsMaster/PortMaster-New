"""Container for sample data that can be played on a
:py:class:`~pyfmodex.channel.Channel`.
"""

# pylint: disable=too-many-public-methods
# That's not our fault... :-)

from ctypes import *

from .cone_settings import ConeSettings
from .enums import OPENSTATE, SOUND_FORMAT, SOUND_TYPE, TIMEUNIT
from .flags import MODE
from .fmodobject import FmodObject, _dll
from .globalvars import get_class
from .structobject import Structobject as so
from .structures import TAG, VECTOR
from .utils import check_type, ckresult, prepare_str


class Sound(FmodObject):
    """Container for sample data that can be played on a
    :py:class:`~pyfmodex.channel.Channel`.
    """

    def add_sync_point(self, offset, offset_type, name):
        """Add a sync point at a specific time within the sound.

        :param int offset: Offset value.
        :param TIMEUNIT offset_type: Offset unit type.
        :param str name: Sync point name.
        :returns: Sync point.
        """
        name = prepare_str(name, "ascii")
        s_ptr = c_void_p()
        self._call_fmod(
            "FMOD_Sound_AddSyncPoint", offset, offset_type.value, name, byref(s_ptr)
        )
        return s_ptr.value

    def delete_sync_point(self, point):
        """Delete a sync point within the sound.

        :param point: Sync point.
        """
        self._call_fmod("FMOD_Sound_DeleteSyncPoint", c_void_p(point))

    @property
    def threed_cone_settings(self):
        """The inside and outside angles of the 3D projection cone and the
        outside volume.

        :type: ConeSettings
        """
        return ConeSettings(self._ptr, self.__class__.__name__)

    @property
    def custom_rolloff(self):
        """The current custom rolloff shape for 3D distance attenuation.

        None when custom rolloff is disabled.

        :type: List of [x, y, z] lists where x = distance, y = volume from
            0 to 1 and z should be set to 0.
        """
        num = c_int()
        self._call_fmod("FMOD_Sound_Get3DCustomRolloff", None, byref(num))
        curve_ptr = POINTER(VECTOR)()
        self._call_fmod("FMOD_Sound_Get3DCustomRolloff", byref(curve_ptr), None)
        return [curve_ptr[i].to_list() for i in range(num.value)]

    @custom_rolloff.setter
    def custom_rolloff(self, curve):
        self._native_curve = (VECTOR * len(curve))(
            *[VECTOR.from_list(lst) for lst in curve]
        )
        self._call_fmod(
            "FMOD_Sound_Set3DCustomRolloff", self._native_curve, len(self._native_curve)
        )

    @property
    def _min_max_distance(self):
        """The minimum and maximum audible distance for a 3D sound.

        :type: two-tuple with

            - The sound's minimum volume distance, or the distance that the
              sound has no attenuation due to 3D positioning.
            - The sound's maximum volume distance, or the distance that no
              additional attenuation will occur.
        """
        min_distance = c_float()
        max_distance = c_float()
        self._call_fmod(
            "FMOD_Sound_Get3DMinMaxDistance", byref(min_distance), byref(max_distance)
        )
        return (min_distance.value, max_distance.value)

    @_min_max_distance.setter
    def _min_max_distance(self, dists):
        self._call_fmod(
            "FMOD_Sound_Set3DMinMaxDistance", c_float(dists[0]), c_float(dists[1])
        )

    @property
    def min_distance(self):
        """The sound's minimum volume distance, or the distance that the sound
        has no attenuation due to 3D positioning.

        The distances are meant to simulate the 'size' of a sound. Reducing the
        min distance will mean the sound appears smaller in the world, and in
        some modes makes the volume attenuate faster as the listener moves away
        from the sound.

        Increasing the min distance simulates a larger sound in the world, and
        in some modes makes the volume attenuate slower as the listener moves
        away from the sound.

        :type: float
        """
        return self._min_max_distance[0]

    @min_distance.setter
    def min_distance(self, dist):
        self._min_max_distance = (dist, self._min_max_distance[1])

    @property
    def max_distance(self):
        """The sound's maximum volume distance, or the distance that no
        additional attenuation will occur.

        The distances are meant to simulate the 'size' of a sound.

        max_distance will affect attenuation differently based on rolloff mode
        set in the mode parameter of :py:meth:`~pyfmodex.system.create_sound`,
        :py:meth:`~pyfmodex.system.create_stream` or :py:attr:`mode`.

        For these modes the volume will attenuate to 0 volume (silence), when
        the distance from the sound is equal to or further than the max
        distance:

            - :py:attr:`~pyfmodex.flags.MODE.THREED_LINEARROLLOFF`
            - :py:attr:`~pyfmodex.flags.MODE.THREED_LINEARSQUAREROLLOFF`

        For these modes the volume will stop attenuating at the point of the
        max distance, without affecting the rate of attenuation:

            - :py:attr:`~pyfmodex.flags.MODE.THREED_INVERSEROLLOFF`
            - :py:attr:`~pyfmodex.flags.MODE.THREED_INVERSETAPEREDROLLOFF`

        For this mode the max distance is ignored:

            - :py:attr:`~pyfmodex.flags.MODE.THREED_CUSTOMROLLOFF`
        """
        return self._min_max_distance[1]

    @max_distance.setter
    def max_distance(self, dist):
        self._min_max_distance = (self._min_max_distance[0], dist)

    @property
    def _defaults(self):
        """A sound's default playback attributes.

        :type: list with

            - Default playback frequency (float)
            - Default priority where 0 is the highest priority (int)
        """
        freq = c_float()
        pri = c_int()
        self._call_fmod("FMOD_Sound_GetDefaults", byref(freq), byref(pri))
        return [freq.value, pri.value]

    @_defaults.setter
    def _defaults(self, vals):
        self._call_fmod("FMOD_Sound_SetDefaults", c_float(vals[0]), vals[1])

    @property
    def default_frequency(self):
        """Default playback frequency.

        :type: float
        """
        return self._defaults[0]

    @default_frequency.setter
    def default_frequency(self, freq):
        defaults = self._defaults
        defaults[0] = freq
        self._defaults = defaults

    @property
    def default_priority(self):
        return self._defaults[1]

    @default_priority.setter
    def default_priority(self, pri):
        """Default priority where 0 is the highest priority.

        :type: int
        """
        defaults = self._defaults
        defaults[1] = pri
        self._defaults = defaults

    @property
    def format(self):
        """Format information about the sound.

        :sound_type: Structobject with the following members:

            - type: Type of sound (:py:class:`~pyfmodex.enums.SOUND_TYPE`).
            - format: Format of the sound
              (:py:class:`~pyfmodex.enums.SOUND_FORMAT`).
            - channels: Number of channels (int).
            - bits: Number of bits per sample, corresponding to sound_format
              (int).
        """
        sound_type = c_int()
        sound_format = c_int()
        channels = c_int()
        bits = c_int()
        self._call_fmod(
            "FMOD_Sound_GetFormat",
            byref(sound_type),
            byref(sound_format),
            byref(channels),
            byref(bits),
        )
        return so(
            type=SOUND_TYPE(sound_type.value),
            format=SOUND_FORMAT(sound_format.value),
            channels=channels.value,
            bits=bits.value,
        )

    def get_length(self, ltype):
        """Retrieve the length using the specified time unit.

        ltype must be valid for the file format. For example, an MP3 file does
        not support :py:attr:`~pyfmodex.flags.TIMEUNIT.MODORDER`.

        A length of 0xFFFFFFFF means it is of unlimited length, such as an
        Internet radio stream or MOD/S3M/XM/IT file which may loop forever.

        Note: Using a VBR (Variable Bit Rate) source that does not have
        metadata containing its accurate length (such as un-tagged MP3 or
        MOD/S3M/XM/IT) may return inaccurate length values.

        For these formats, use :py:attr:`~pyfmodex.flags.MODE.ACCURATETIME`
        when creating the sound. This will cause a slight delay and memory
        increase, as FMOD will scan the whole during creation to find the
        correct length. This flag also creates a seek table to enable sample
        accurate seeking.

        :param TIMEUNIT ltype: Time unit type to retrieve length in.
        :rtype: int
        """
        length = c_uint()
        self._call_fmod("FMOD_Sound_GetLength", byref(length), ltype.value)
        return length.value

    @property
    def loop_count(self):
        """The sound's loop count.

            - -1: always loop
            - 0: no loop.

        Unlike the channel loop count property, this is simply the value set.
        It does not decrement as it plays (especially seeing as one sound can
        be played multiple times).

        :type: int
        """
        count = c_int()
        self._call_fmod("FMOD_Sound_GetLoopCount", byref(count))
        return count.value

    @loop_count.setter
    def loop_count(self, count):
        self._call_fmod("FMOD_Sound_SetLoopCount", count)

    def get_loop_points(self, start_unit, end_unit):
        """Retrieve the loop points for a sound.

        The values 'loopstart' and 'loopend' are inclusive, which means these
        positions will be played.

        :param TIMEUNIT start_unit: Time format of loopstart.
        :param TIMEUNIT end_unit: Time format of loopend.
        :rtype: two-tuple with

            - loopstart: Loop start point (int)
            - loopend: Loop end point (int)
        """
        start = c_uint()
        end = c_uint()
        self._call_fmod(
            "FMOD_Sound_GetLoopPoints",
            byref(start),
            start_unit.value,
            byref(end),
            end_unit.value,
        )
        return start.value, end.value

    def set_loop_points(self, loopstart, start_unit, loopend, end_unit):
        """Set the loop points within a sound.

        The values 'loopstart' and 'loopend' are inclusive, which means these
        positions will be played.

        If a loopend is smaller or equal to loopstart an error will be
        returned. The same will happen for any values that are equal or greater
        than the length of the sound.

        Changing loop points on an already buffered stream may not produced
        desired output.

        :param int loopstart: Loop start point.
        :param TIMEUNIT start_unit: Time format of loopstart.
        :param int loopend: Loop end point.
        :param TIMEUNIT end_unit: Time format of loopend.
        """
        self._call_fmod(
            "FMOD_Sound_SetLoopPoints",
            loopstart,
            start_unit.value,
            loopend,
            end_unit.value,
        )

    @property
    def mode(self):
        """The mode of a sound.

        :type: MODE

        The mode is dependent on  the mode set by
        :py:meth:`~pyfmodex.system.create_sound`,
        :py:meth:`~pyfmodex.system.create_stream` or :py:attr:`mode`.

        When setting this, note that it will only take effect when the sound is
        played again with :py:meth:`~pyfmodex.system.System.play_sound`. This
        is the default for when the sound next plays, not a mode that will
        suddenly change all currently playing instances of this sound.

        If :py:attr:`~pyfmodex.flags.MODE.THREED_IGNOREGEOMETRY` is not
        specified, the flag will be cleared if it was specified previously.

        Changing mode on an already buffered stream may not produced desired
        output.
        """
        mode = c_int()
        self._call_fmod("FMOD_Sound_GetMode", byref(mode))
        return MODE(mode.value)

    @mode.setter
    def mode(self, mode):
        self._call_fmod("FMOD_Sound_SetMode", mode.value)

    def get_music_channel_volume(self, channel):
        """Retrieve the volume of a MOD/S3M/XM/IT/MIDI music channel volume.

        :param int channel: MOD/S3M/XM/IT/MIDI music subchannel to retrieve the
            volume for.
        :rtype: float
        """
        volume = c_float()
        self._call_fmod("FMOD_Sound_GetMusicChannelVolume", channel, byref(volume))
        return volume.value

    def set_music_channel_volume(self, channel, vol):
        """Set the volume of a MOD/S3M/XM/IT/MIDI music channel volume.

        :param int channel: MOD/S3M/XM/IT/MIDI music subchannel to set a linear
            volume for.
        :param float vol: Volume of the channel.
        """
        self._call_fmod("FMOD_Sound_SetMusicChannelVolume", channel, c_float(vol))

    @property
    def num_music_channels(self):
        """The number of music channels inside a MOD/S3M/XM/IT/MIDI file.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_Sound_GetMusicNumChannels", byref(num))
        return num.value

    @property
    def name(self):
        """The name of a sound.

        :type: str
        """
        name = create_string_buffer(256)
        self._call_fmod("FMOD_Sound_GetName", byref(name), 256)
        return name.value

    @property
    def num_subsounds(self):
        """The number of subsounds stored within a sound.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_Sound_GetNumSubSounds", byref(num))
        return num.value

    @property
    def num_sync_points(self):
        """The number of sync points stored within a sound.


        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_Sound_GetNumSyncPoints", byref(num))
        return num.value

    @property
    def num_tags(self):
        """The number of metadata tags.

        :type: int
        """
        num = c_int()
        updated = c_int()
        self._call_fmod("FMOD_Sound_GetNumTags", byref(num), byref(updated))
        return so(tags=num.value, updated_tags=updated.value)

    @property
    def open_state(self):
        """The state a sound is in after being opened with the non blocking
        flag, or the current state of the streaming buffer.

        When a sound is opened with
        :py:attr:`~pyfmodex.enums.MODE.NONBLOCKING`, it is opened and prepared
        in the background, or asynchronously. This allows the main application
        to execute without stalling on audio loads. This property describes the
        state of the asynchronous load routine i.e. whether it has succeeded,
        failed or is still in progress.

        If 'starving' is true, then you will most likely hear a
        stuttering/repeating sound as the decode buffer loops on itself and
        replays old data. With the ability to detect stream starvation, muting
        the sound with :py:attr:`~pyfmodex.channel_control.ChannelControl.mute`
        will keep the stream quiet until it is not starving any more.

        Note: Always check 'open_state' to determine the state of the sound. Do
        not assume the sound has finished loading.

        :type: Structobject with the following members:

            state (:py:class:`~pyfmodex.enums.OPENSTATE`)
              Open state of a sound.

            percentbuffered (int)
              Filled percentage of a stream's file buffer.

            starving (bool)
              Starving state. True if a stream has decoded more than the stream
              file buffer has ready.

            diskbusy (bool)
              Disk is currently being accessed for this sound.
        """
        state = c_int()
        percentbuffered = c_uint()
        starving = c_bool()
        diskbusy = c_bool()
        self._call_fmod(
            "FMOD_Sound_GetOpenState",
            byref(state),
            byref(percentbuffered),
            byref(starving),
            byref(diskbusy),
        )
        return so(
            state=OPENSTATE(state.value),
            percent_buffered=percentbuffered.value,
            starving=starving.value,
            disk_busy=diskbusy.value,
        )

    @property
    def sound_group(self):
        """The sound's current sound group.

        By default, a sound is located in the 'master sound group'. This can be
        retrieved with :py:attr:`~pyfmodex.system.System.master_sound_group`.

        :type: SoundGroup
        """
        grp_ptr = c_void_p()
        self._call_fmod("FMOD_Sound_GetSoundGroup", byref(grp_ptr))
        return get_class("SoundGroup")(grp_ptr)

    @sound_group.setter
    def sound_group(self, group):
        check_type(group, get_class("SoundGroup"))
        self._call_fmod("FMOD_Sound_SetSoundGroup", group._ptr)

    def get_subsound(self, index):
        """A Sound object that is contained within the parent sound.

        If the sound is a stream and
        :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` was not used, then this
        call will perform a blocking seek/flush to the specified subsound.

        If :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` was used to open this
        sound and the sound is a stream, FMOD will do a non blocking seek/flush
        and set the state of the subsound to
        :py:attr:`~pyfmodex.enums.OPENSTATE.SEEKING`.

        The sound won't be ready to be used when
        :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` is used, until the state of
        the sound becomes :py:attr:`~pyfmodex.enums.OPENSTATE.READY` or
        :py:attr:`~pyfmodex.enums.OPENSTATE.ERROR`.

        :param int index: Index of the subsound.
        :rtype: Sound
        """
        sh_ptr = c_void_p()
        self._call_fmod("FMOD_Sound_GetSubSound", index, byref(sh_ptr))
        return Sound(sh_ptr)

    @property
    def subsound_parent(self):
        """The parent Sound object that contains this subsound.

        None if this sound is not a subsound.

        :type: Sound
        """
        sh_ptr = c_void_p()
        self._call_fmod("FMOD_Sound_GetSubSoundParent", byref(sh_ptr))
        return Sound(sh_ptr)

    def get_sync_point(self, index):
        """Retrieve a sync point.

        :param int index: Index of the sync point.
        :rtype: Sync point.
        """
        syncpoint = c_void_p()
        self._call_fmod("FMOD_Sound_GetSyncPoint", index, byref(syncpoint))
        return syncpoint.value

    def get_sync_point_info(self, point, offset_type):
        """Retrieve information on an embedded sync point.

        :param point: Sync point.
        :param offset_type: The unit in which the point's offset should be expressed.
        :rtype: Structobject with the following members:

            - name: Name of the syncpoint (str)
            - offset: Offset of the syncpoint, expressed in the given offset_type (int)
        """
        name = create_string_buffer(256)
        offset = c_uint()
        self._call_fmod(
            "FMOD_Sound_GetSyncPointInfo",
            c_void_p(point),
            byref(name),
            256,
            byref(offset),
            offset_type.value,
        )
        return so(
            name=name.value, offset=offset.value
        )

    @property
    def system_object(self):
        """The parent System object.

        :type: System
        """
        sptr = c_void_p()
        self._call_fmod("FMOD_Sound_GetSystemObject", byref(sptr))
        return get_class("System")(sptr)

    def play(self, channel_group=None, paused=False):
        """Instruct the parent System object to play the sound.

        See :py:meth:`~pyfmodex.system.System.play_sound`.

        :param ChannelGroup channel_group: Group to output to instead of the
            master.
        :param bool paused: Whether to start in the paused state.
        :returns: Newly playing channel.
        :rtype: Channel
        """
        return self.system_object.play_sound(self, channel_group, paused)

    def get_tag(self, index, name=None):
        """Retrieve a metadata tag.

        'Tags' are metadata stored within a sound file. These can be things
        like a song's name, composer etc...

        The number of tags available can be found with :py:attr:`num_tags`.

        The way to display or retrieve tags can be done in three different ways:

            - All tags can be continuously retrieved by looping from 0 to the
              numtags value in :py:attr:`num_tags` - 1. Updated tags will
              refresh automatically, and the 'updated' member of the
              :py:class:`~pyfmodex.structures.TAG` structure will be set to
              True if a tag has been updated, due to something like a netstream
              changing the song name for example.

            - Tags can be retrieved by specifying -1 as the index and only
              updating tags that are returned. If all tags are retrieved and
              this method is called it will raise an
              :py:exc:`~pyfmodex.exceptions.FmodError` with code
              :py:attr:`~pyfmodex.enums.RESULT.TAGNOTFOUND`.

            - Specific tags can be retrieved by specifying a name parameter.
              The index can be 0 based or -1 in the same fashion as described
              previously.

        Note with netstreams an important consideration must be made between
        songs, a tag may occur that changes the playback rate of the song. It
        is up to the user to catch this and reset the playback rate with
        :py:attr:`~pyfmodex.channel.Channel.frequency`.

        A sample rate change will be signalled with a tag of type
        :py:attr:`~pyfmodex.enums.TAGTYPE.FMOD`.

        :param int index: Index into the tag list as restricted by name.
        :param str name: Name of a type of tag to retrieve. Specify None to
            retrieve all types of tags.
        """
        name = prepare_str(name, "ascii")
        tag = TAG()
        ckresult(_dll.FMOD_Sound_GetTag(self._ptr, name, index, byref(tag)))
        return tag

    def lock(self, offset, length):
        """Give access to a portion or all the sample data of a sound for
        direct manipulation.

        You must always unlock the data again after you have finished with it,
        using :py:meth:`unlock`.

        With this method you get access to the raw audio data. If the data is
        8, 16, 24 or 32bit PCM data, mono or stereo data, you must take this
        into consideration when processing the data.

        If the sound is created with
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE` the data
        retrieved will be the compressed bitstream.

        It is not possible to lock the following:

            - A parent sound containing subsounds. A parent sound has no audio
              data and :py:exc:`~pyfmodex.exceptions.FmodError` will be
              raised with code :py:attr:`~pyfmodex.enums.RESULT.SUBSOUNDS`
            - A stream / sound created with
              :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`.
              An :py:exc:`~pyfmodex.exceptions.FmodError` will be
              raised with code
              :py:attr:`~pyfmodex.enums.RESULT.BADCOMMAND` in this case.

        The names 'lock'/'unlock' are a legacy reference to older Operating
        System APIs that used to cause a mutex lock on the data, so that it
        could not be written to while the 'lock' was in place. This is no
        longer the case with FMOD and data can be 'locked' multiple times from
        different places/threads at once.

        :param int offset: Offset into the sound's buffer to be retrieved.
        :param int length: Length of the data required to be retrieved. If
            offset + length exceeds the length of the sample buffer, ptr2 and
            len2 will be valid.
        :rtype: two-tuple of two-tuples ((ptr1, len1), (ptr2, len2)) with:

            - ptr1: First part of the locked data
            - len1: Length of ptr1
            - ptr2: Second part of the locked data if the offset + length has
              exceeded the length of the sample buffer
            - len2: Length of ptr2

        """
        ptr1 = c_void_p()
        len1 = c_uint()
        ptr2 = c_void_p()
        len2 = c_uint()
        ckresult(
            _dll.FMOD_Sound_Lock(
                self._ptr,
                offset,
                length,
                byref(ptr1),
                byref(ptr2),
                byref(len1),
                byref(len2),
            )
        )
        return ((ptr1, len1), (ptr2, len2))

    def release(self):
        """Free this sound object.

        This will stop any instances of this sound, and free the sound object
        and its children if it is a multi-sound object.

        If the sound was opened with
        :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` and hasn't finished opening
        yet, it will block. Using :py:attr:`open_state` and checking the open
        state for :py:attr:`~pyfmodex.enums.OPENSTATE.READY` and
        :py:attr:`~pyfmodex.enums.OPENSTATE.ERROR` is a good way to avoid
        stalls.
        """
        self._call_fmod("FMOD_Sound_Release")

    def unlock(self, i1, i2):
        """Finalize a previous sample data lock and submit it back to the
        Sound object.

        The data being 'unlocked' must first have been locked with
        :py:meth:`lock`.

        If an unlock is not performed on PCM data, then sample loops may
        produce audible clicks.

        The names 'lock'/'unlock' are a legacy reference to older Operating
        System APIs that used to cause a mutex lock on the data, so that it
        could not be written to while the 'lock' was in place. This is no
        longer the case with FMOD and data can be 'locked' multiple times from
        different places/threads at once.

        :param tuple i1: two-tuple with

            - First part of the locked data
            - Length of the first part of the locked data
        :param tuple i2: two-tuple with

            - Second part of the locked data
            - Length of the second part of the locked data
        """
        ckresult(_dll.FMOD_Sound_Unlock(self._ptr, i1[0], i2[0], i1[1], i2[1]))

    @property
    def music_speed(self):
        """The relative speed of MOD/S3M/XM/IT/MIDI music.

        :type: float
        """
        speed = c_float()
        self._call_fmod("FMOD_Sound_GetMusicSpeed", byref(speed))
        return speed.value

    @music_speed.setter
    def music_speed(self, speed):
        self._call_fmod("FMOD_Sound_SetMusicSpeed", c_float(speed))

    def read_data(self, length):
        """Read data from an opened sound, using FMOD's internal codecs.

        This can be used for decoding data offline in small pieces (or big
        pieces), rather than playing and capturing it, or loading the whole
        file at once and having to :py:meth:`lock` / :py:meth:`unlock` the
        data.

        If too much data is read, it is possible an
        :py:exc:`~pyfmodex.exceptions.FmodError` will be raised with code
        :py:attr:`~pyfmodex.enums.RESULT.FILE_EOF`, meaning it is out of data.

        As a non streaming sound reads and decodes the whole file then closes
        it upon calling :py:meth:`~pyfmodex.system.System.create_sound`, this
        will then not work because the file handle is closed. Use
        :py:attr:`~pyfmodex.flags.MODE.OPENONLY` to stop FMOD reading/decoding
        the file. If :py:attr:`~pyfmodex.flags.MODE.OPENONLY` is used when
        opening a sound, it will leave the file handle open, and FMOD will not
        read/decode any data internally, so the read cursor will stay at
        position 0. This will allow the user to read the data from the start.

        For streams, the streaming engine will decode a small chunk of data and
        this will advance the read cursor. You need to either use
        :py:attr:`~pyfmodex.flags.MODE.OPENONLY` to stop the stream
        pre-buffering or call :py:meth:`seek_data` to reset the read cursor
        back to the start of the file, otherwise it will appear as if the start
        of the stream is missing. Calling
        :py:meth:`~pyfmodex.channel.Channel.set_position` will have the same
        result. These methods will flush the stream buffer and read in a chunk
        of audio internally. This is why if you want to read from an absolute
        position you should use :py:meth:`seek_data` and not the previously
        mentioned ones.

        If you are calling :py:meth:`read_data` and :py:meth:`seek_data` on a
        stream, information functions such as
        :py:meth:`~pyfmodex.channel.Channel.get_position` may give misleading
        results. Calling :py:meth:`~pyfmodex.channel.Channel.set_position` will
        cause the streaming engine to reset and flush the stream, leading to
        the time values returning to their correct position.

        NOTE! Thread safety. If you call this from another stream callback, or
        any other thread besides the main thread, make sure to mutex the
        callback with :py:meth:`release` in case the sound is still being read
        from while releasing.

        This function is thread safe to call from a stream callback or
        different thread as long as it doesnt conflict with a call to
        :py:meth:`release`.

        :param int length: Amount of data to read.
        :returns: The decoded data and the actual amount of data read.
        :rtype: two-tuple with bytes and int
        """
        buf = create_string_buffer(length)
        actual = c_uint()
        self._call_fmod("FMOD_Sound_ReadData", buf, length, byref(actual))
        return buf.raw, actual.value

    def seek_data(self, offset):
        """Seek a sound for use with data reading, using FMOD's internal
        codecs.

        For use in conjunction with :py:meth:`read_data` and
        :py:attr:`~pyfmodex.flags.MODE.OPENONLY`.

        For streaming sounds, if this method is called, it will advance the
        internal file pointer but not update the streaming engine. This can
        lead to de-synchronization of position information for the stream and
        audible playback.

        A stream can have its stream buffer and position synchronization reset
        by calling :py:meth:`~pyfmodex.channel.Channel.set_position`. This
        causes a reset and flush of the stream buffer.

        :param int offset: Seek offset.
        """
        self._call_fmod("FMOD_Sound_SeekData", offset)
