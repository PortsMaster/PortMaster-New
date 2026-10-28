"""A source of audio signal that connects to the
:py:class:`~pyfmodex.channel_group.ChannelGroup` mixing
hierarchy.
"""
from ctypes import *

from .channel_control import ChannelControl
from .fmodobject import _dll
from .globalvars import get_class
from .utils import check_type, ckresult


class Channel(ChannelControl):
    """A source of audio signal that connects to the
    :py:class:`~pyfmodex.channel_group.ChannelGroup` mixing hierarchy.

    Created with :py:meth:`~pyfmodex.system.System.play_sound` or
    :py:meth:`~pyfmodex.system.System.play_dsp`.
    """

    @property
    def channel_group(self):
        """The ChannelGroup this object outputs to.

        A :py:class:`~pyfmodex.channel_group.ChannelGroup` may contain many
        :py:class:`Channels <~pyfmodex.channel.Channel>`.

        :py:class:`Channels <~pyfmodex.channel.Channel>` may only output to a
        single :py:class:`~pyfmodex.channel_group.ChannelGroup`. Setting this
        will remove it from the previous group first.

        :type: ChannelGroup
        """
        grp_ptr = c_void_p()
        ckresult(_dll.FMOD_Channel_GetChannelGroup(self._ptr, byref(grp_ptr)))
        return get_class("ChannelGroup")(grp_ptr)

    @channel_group.setter
    def channel_group(self, group):
        check_type(group, get_class("ChannelGroup"))
        ckresult(_dll.FMOD_Channel_SetChannelGroup(self._ptr, group._ptr))

    @property
    def current_sound(self):
        """The currently playing Sound.

        May be None if no :py:class:`~pyfmodex.sound.Sound` is playing.

        :type: Sound
        """
        snd_ptr = c_void_p()
        ckresult(_dll.FMOD_Channel_GetCurrentSound(self._ptr, byref(snd_ptr)))
        return get_class("Sound")(snd_ptr)

    @property
    def frequency(self):
        """The playback frequency or playback rate.

        :type: float
        """
        freq = c_float()
        ckresult(_dll.FMOD_Channel_GetFrequency(self._ptr, byref(freq)))
        return freq.value

    @frequency.setter
    def frequency(self, freq):
        ckresult(_dll.FMOD_Channel_SetFrequency(self._ptr, c_float(freq)))

    @property
    def index(self):
        """The index of this object in the :py:class:`~pyfmodex.system.System`
        :py:class:`~pyfmodex.channel.Channel` pool.

        :type: int
        """
        idx = c_int()
        self._call_fmod("FMOD_Channel_GetIndex", byref(idx))
        return idx.value

    @property
    def loop_count(self):
        """The number of times to loop before stopping.

        Times to loop before stopping, with:

        - 0: oneshot
        - 1: loop once then stop
        - -1: loop forever

        This is the current loop countdown value that will decrement as it
        plays until reaching 0. It can be reset by setting this property.

        The :py:class:`~pyfmodex.flags.MODE` flags of the
        :py:class:`~pyfmodex.sound.Sound` or
        :py:class:`~pyfmodex.channel.Channel` must include LOOP_NORMAL or
        LOOP_BIDI for this function to work.

        :type: int
        """
        loopcount = c_int()
        ckresult(_dll.FMOD_Channel_GetLoopCount(self._ptr, byref(loopcount)))
        return loopcount.value

    @loop_count.setter
    def loop_count(self, count):
        ckresult(_dll.FMOD_Channel_SetLoopCount(self._ptr, c_int(count)))

    def get_loop_points(self, startunit, endunit):
        """Retrieve the loop start and end points.

        Valid TIMEUNIT types are PCM, MS and PCMBYTES. Any other time units
        return :py:attr:`~pyfmodex.enums.RESULT.FORMAT`.

        If MS or PCMBYTES are used, the value is internally converted from PCM,
        so the retrieved value may not exactly match the set value.

        :param TIMEUNIT startunit: Time units for loop start point.
        :param TIMEUNIT endunit: Time units for loop end point.
        :returns: Loop start point and loop end point.
        :rtype: two-tuple of ints
        """
        start = c_uint()
        end = c_uint()
        ckresult(
            _dll.FMOD_Channel_GetLoopPoints(
                self._ptr, byref(start), startunit.value, byref(end), endunit.value
            )
        )
        return start.value, end.value

    def set_loop_points(self, start, startunit, end, endunit):
        """Set the loop start and end points.

        Loop points may only be set on a :py:class:`~pyfmodex.channel.Channel`
        playing a :py:class:`~pyfmodex.sound.Sound`, not a
        :py:class:`~pyfmodex.channel.Channel` playing a
        :py:class:`~pyfmodex.dsp.DSP`  (see
        :py:meth:`~pyfmodex.system.System.play_dsp`).

        Valid TIMEUNIT types are PCM, MS and PCMBYTES. Any other time units
        return :py:attr:`~pyfmodex.enums.RESULT.FORMAT`. If MS or PCMBYTES are
        used, the value is internally converted to PCM.

        :param int start: Loop start point.
        :param TIMEUNIT startunit: Time units for `start`.
        :param int end: Loop end point.
        :param TIMEUNIT endunit: Time units for `end`.
        """
        ckresult(
            _dll.FMOD_Channel_SetLoopPoints(
                self._ptr, c_uint(start), startunit.value, c_uint(end), endunit.value
            )
        )

    def get_position(self, unit):
        """Retrieve the current playback position.

        Certain TIMEUNIT types are always available: PCM, PCMBYTES and MS. The
        others are format specific such as MODORDER / MODROW / MODPATTERN which
        is specific to files of type MOD / S3M / XM / IT.

        If MS or PCMBYTES are used, the value is internally converted from PCM,
        so the retrieved value may not exactly match the set value.

        :param TIMEUNIT unit: Time units for position.
        :returns: Playback position.
        :rtype: int
        """
        pos = c_uint()
        ckresult(_dll.FMOD_Channel_GetPosition(self._ptr, byref(pos), unit.value))
        return pos.value

    def set_position(self, pos, unit):
        """Set the current playback position.

        Certain TIMEUNIT types are always available: PCM, PCMBYTES and MS. The
        others are format specific such as MODORDER / MODROW / MODPATTERN which
        is specific to files of type MOD / S3M / XM / IT.

        If playing a :py:class:`~pyfmodex.sound.Sound` created with
        :py:meth:`~pyfmodex.system.System.create_stream` or the
        :py:class:`~pyfmodex.flags.MODE` flag CREATESTREAM changing the
        position may cause a slow reflush operation while the file seek and
        decode occurs. You can avoid this by creating the stream with the
        :py:class:`~pyfmodex.flags.MODE` flag NONBLOCKING. This will cause the
        stream to go into :py:attr:`~pyfmodex.enums.OPENSTATE.SETPOSITION`
        state (see :py:attr:`~pyfmodex.sound.Sound.open_state` and Sound
        commands will return :py:attr:`~pyfmodex.enums.RESULT.NOTREADY`.
        :py:meth:`get_position` will also not update until this non-blocking
        set position operation has completed.

        Using a VBR source that does not have an associated seek table or seek
        information (such as MP3 or MOD/S3M/XM/IT) may cause inaccurate seeking
        if you specify MS or PCM. If you want FMOD to create a PCM vs bytes
        seek table so that seeking is accurate, you will have to specify the
        :py:class:`~pyfmodex.flags.MODE` flag ACCURATETIME when loading or
        opening the sound. This means there is a slight delay as FMOD scans the
        whole file when loading the sound to create this table.

        :param int pos: Playback position.
        :param TIMEUNIT unit: Time units for `pos`.
        """
        ckresult(_dll.FMOD_Channel_SetPosition(self._ptr, pos, unit.value))

    @property
    def priority(self):
        """The priority used for virtual Channel ordering, where 0 represents
        most important and 256 represents least important.

        Priority is used as a coarse grain control for the virtual
        :py:class:`~pyfmodex.channel.Channel` system, lower priority
        :py:class:`Channels <~pyfmodex.channel.Channel>` will always be stolen
        before higher. For channels of equal priority, those with the quietest
        :py:attr:`~pyfmodex.channel_control.ChannelControl.audibility` value
        will be stolen first.
        """
        pri = c_int()
        ckresult(_dll.FMOD_Channel_GetPriority(self._ptr, byref(pri)))
        return pri.value

    @priority.setter
    def priority(self, pri):
        ckresult(_dll.FMOD_Channel_SetPriority(self._ptr, pri))

    @property
    def is_virtual(self):
        """Whether the Channel is being emulated by the virtual Channel system.

        - True: silent / emulated
        - False: audible / real

        :type: bool
        """
        virtual_state = c_bool()
        ckresult(_dll.FMOD_Channel_IsVirtual(self._ptr, byref(virtual_state)))
        return virtual_state.value
