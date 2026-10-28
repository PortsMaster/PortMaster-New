"""An interface that represents the shared APIs between
:py:class:`pyfmodex.channel.Channel` and
:py:class:`pyfmodex.channel_group.ChannelGroup`.
"""

# pylint: disable=too-many-public-methods
# That's not our fault... :-)

from ctypes import *

from .callback_prototypes import CHANNELCONTROL_CALLBACK
from .cone_settings import ConeSettings
from .flags import MODE
from .fmodobject import FmodObject
from .globalvars import get_class
from .structobject import Structobject as so
from .structures import VECTOR
from .utils import check_type


class ChannelControl(FmodObject):
    """An interface that represents the shared APIs between
    :py:class:`pyfmodex.channel.Channel` and
    :py:class:`pyfmodex.channel_group.ChannelGroup`.
    """

    def __init__(self, ptr):
        super().__init__(ptr)
        self._custom_rolloff_curve = None # To keep the custom rolloff curve alive

    def _call_specific(self, specific_function_suffix, *args):
        return self._call_fmod(
            "FMOD_%s_%s" % (self.__class__.__name__, specific_function_suffix), *args
        )

    def add_dsp(self, index, dsp):
        """Add a DSP unit to the specified index in the DSP chain.

        :param int index: Offset into the DSP chain. Has to be between 0 and
            the number of DSPs.
        :param DSP dsp: DSP unit to be added.
        """
        check_type(dsp, get_class("DSP"))
        c_ptr = c_void_p()
        if hasattr(index, "value"):
            index = index.value
        self._call_specific("AddDSP", index, dsp._ptr, byref(c_ptr))
        return get_class("DSP_Connection")(c_ptr)

    def add_fade_point(self, dsp_clock, volume):
        """Add a sample accurate fade point at a time relative to the parent
        ChannelGroup DSP clock.

        Fade points are scaled against other volume settings and in-between
        each fade point the volume will be linearly ramped.

        To perform sample accurate fading use :py:attr:`dsp_clock` to
        query the parent clock value. If a parent ChannelGroup changes its
        pitch, the fade points will still be correct as the parent clock rate
        is adjusted by that pitch.

        :param int dsp_clock: DSP clock of the parent
            :py:class:`pyfmodex.channel_group.ChannelGroup` to set the fade
            point volume.
        :param float volume: Volume level at the given dsp_clock. Values above
            1.0 amplify the signal.
        """
        self._call_specific("AddFadePoint", c_ulonglong(dsp_clock), c_float(volume))

    @property
    def _threed_attrs(self):
        """The 3D position and velocity used to apply panning, attenuation and
        doppler.

        :type: list[VECTOR]
        """
        pos = VECTOR()
        vel = VECTOR()
        self._call_specific("Get3DAttributes", byref(pos), byref(vel))
        return [pos.to_list(), vel.to_list()]

    @_threed_attrs.setter
    def _threed_attrs(self, attrs):
        pos = VECTOR.from_list(attrs[0])
        vel = VECTOR.from_list(attrs[1])
        self._call_specific("Set3DAttributes", byref(pos), byref(vel))

    @property
    def position(self):
        """The position in 3D space used to apply panning and attenuation.

        :type: VECTOR
        """
        return self._threed_attrs[0]

    @position.setter
    def position(self, pos):
        self._threed_attrs = (pos, self._threed_attrs[1])

    @property
    def velocity(self):
        """The velocity in 3D space used for doppler.

        :type: VECTOR
        """
        return self._threed_attrs[1]

    @velocity.setter
    def velocity(self, vel):
        self._threed_attrs = (self._threed_attrs[0], vel)

    @property
    def cone_orientation(self):
        """The orientation of a 3D cone shape, used for simulated occlusion.

        Normalized orientation vector, which represents the direction of the
        sound cone.

        :type: list with x, y, and z float values
        """
        ori = VECTOR()
        self._call_specific("Get3DConeOrientation", byref(ori))
        return ori.to_list()

    @cone_orientation.setter
    def cone_orientation(self, ori):
        vec = VECTOR.from_list(ori)
        self._call_specific("Set3DConeOrientation", byref(vec))

    @property
    def cone_settings(self):
        """The angles and attenuation levels of a 3D cone shape, for simulated
        occlusion which is based on direction.

        :rtype: ~pyfmodex.cone_settings.ConeSettings
        """
        return ConeSettings(self._ptr, self.__class__.__name__)

    @property
    def custom_rolloff(self):
        """The current custom rolloff shape for 3D distance attenuation.

        To set a curve, provide a list of objects that can be treated as a list
        of [x, y, z] values with x = distance, y = volume (0 to 1) and z set to
        0.

        :type: list of [x, y, z]-lists where x is distance, y is volume (0 to
            1) and z is undefined.
        """
        num = c_int()
        self._call_specific("Get3DCustomRolloff", None, byref(num))
        curve = (VECTOR * num.value)()
        curve = POINTER(VECTOR)()
        self._call_specific("Get3DCustomRolloff", byref(curve), None)
        return [curve[i].to_list() for i in range(num.value)]

    @custom_rolloff.setter
    def custom_rolloff(self, curve):
        self._custom_rolloff_curve = (VECTOR * len(curve))(*[VECTOR.from_list(lst) for lst in curve])
        self._call_specific("Set3DCustomRolloff", self._custom_rolloff_curve, len(self._custom_rolloff_curve))

    @property
    def threed_distance_filter(self):
        """The override values for the 3D distance filter.

        If distance filtering is enabled, by default the 3D engine will
        automatically attenuate frequencies using a lowpass and a highpass
        filter, based on 3D distance. This function allows the distance filter
        effect to be set manually, or to be set back to 'automatic' mode.

        :type: Structobject with the following members:

            - custom: Boolean indicating wheter to override automatic distance
              filtering and use custom_level instead
            - custom_level: Float between 0 and 1 representing the attenuation
              factor where 1 represents no attenuation and 0 represents
              complete attenuation.
            - center_frequency: Integer between 10 and 22050 showing the center
              frequency of the band-pass filter used to simulate distance
              attenuation, 0 for default, or
              :py:class:`~pyfmodex.structures.ADVANCEDSETTINGS`
        """
        custom = c_bool()
        custom_level = c_float()
        center_frequency = c_float()
        self._call_specific(
            "Get3DDistanceFilter", byref(custom), byref(custom_level), byref(custom)
        )
        return so(
            custom=custom.value,
            custom_level=custom_level.value,
            center_frequency=center_frequency.value,
        )

    @threed_distance_filter.setter
    def threed_distance_filter(self, cfg):
        self._call_specific(
            "Set3DDistanceFilter",
            cfg.custom,
            c_float(cfg.custom_level),
            c_float(cfg.center_frequency),
        )

    @property
    def doppler_level(self):
        """The amount by which doppler is scaled.

        :type: Doppler scale (float) where 0 represents no doppler, 1
            represents natural doppler and 5 represents exaggerated doppler.
        """
        level = c_float()
        self._call_specific("Get3DDopplerLevel", byref(level))
        return level.value

    @doppler_level.setter
    def doppler_level(self, level):
        self._call_specific("Set3DDopplerLevel", c_float(level))

    @property
    def level(self):
        """The blend between 3D panning and 2D panning.

        The :py:class:`~pyfmodex.flags.MODE` flag THREED must be set on this
        object otherwise :py:const:`~pyfmodex.enums.RESULT.NEEDS3D` is
        returned.

        :type: 3D pan level (float) where 0 represents panning/attenuating
            solely with 2D panning functions and 1 represents solely 3D.
        """
        level = c_float()
        self._call_specific("Get3DLevel", byref(level))
        return level.value

    @level.setter
    def level(self, level):
        self._call_specific("Set3DLevel", c_float(level))

    @property
    def _min_max_distance(self):
        """The minimum and maximum distances used to calculate the 3D rolloff
        attenuation.

        :type: two-tuple with

            - mindistance: Distance (float) from the source where attenuation
              begins.
            - maxdistance: Distance (float) from the source where attenuation
              ends.
        """
        mindistance = c_float()
        maxdistance = c_float()
        self._call_specific(
            "Get3DMinMaxDistance", byref(mindistance), byref(maxdistance)
        )
        return (mindistance.value, maxdistance.value)

    @_min_max_distance.setter
    def _min_max_distance(self, dists):
        self._call_specific("Set3DMinMaxDistance", c_float(dists[0]), c_float(dists[1]))

    @property
    def min_distance(self):
        """The minimum distance used to calculate the 3D rolloff attenuation.

        The distance from the source where attenuation begins.

        :type: float
        """
        return self._min_max_distance[0]

    @min_distance.setter
    def min_distance(self, dist):
        self._min_max_distance = (dist, self._min_max_distance[1])

    @property
    def max_distance(self):
        """The maximum distance used to calculate the 3D rolloff attenuation.

        The distance from the source where attenuation ends.

        :type: float
        """
        return self._min_max_distance[1]

    @max_distance.setter
    def max_distance(self, dist):
        self._min_max_distance = (self._min_max_distance[0], dist)

    @property
    def _occlusion(self):
        """The 3D attenuation factors for the direct and reverb paths.

        There is a reverb path/send when `set_reverb_wet` has been used,
        reverb_occlusion controls its attenuation.

        If the System has been initialized with The
        :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flags
        CHANNEL_DISTANCEFILTER or CHANNEL_LOWPASS the direct_occlusion is
        applied as frequency filtering rather than volume attenuation.

        :type: two-tuple with

            - direct_occlusion: Occlusion factor (float) for the direct path
              where 0 represents no occlusion and 1 represents full occlusion.
            - reverb_occlusion: Occlusion factor (float) for the reverb path
              where 0 represents no occlusion and 1 represents full occlusion.
        """
        direct = c_float()
        reverb = c_float()
        self._call_specific("Get3DOcclusion", byref(direct), byref(reverb))
        return (direct.value, reverb.value)

    @_occlusion.setter
    def _occlusion(self, occs):
        self._call_specific("Set3DOcclusion", c_float(occs[0]), c_float(occs[1]))

    @property
    def direct_occlusion(self):
        """Occlusion factor for the direct path where 0 represents no occlusion
        and 1 represents full occlusion.

        If the System has been initialized with The
        :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flags
        CHANNEL_DISTANCEFILTER or CHANNEL_LOWPASS the direct_occlusion is
        applied as frequency filtering rather than volume attenuation.

        :type: float
        """
        return self._occlusion[0]

    @direct_occlusion.setter
    def direct_occlusion(self, occ):
        self._occlusion = (occ, self._occlusion[1])

    @property
    def reverb_occlusion(self):
        """Occlusion factor for the reverb path where 0 represents no occlusion
        and 1 represents full occlusion.

        There is a reverb path/send when
        :py:meth:`~pyfmodex.ChannelControl.set_reverb_wet` has been used,
        reverb_occlusion controls its attenuation.

        :type: float
        """
        return self._occlusion[1]

    @reverb_occlusion.setter
    def reverb_occlusion(self, occ):
        self._occlusion = (self._occlusion[0], occ)

    @property
    def threed_spread(self):
        """The spread of a 3D sound in speaker space.

        Angle over which the sound is spread. Between 0 and 360.

        :type: float
        """
        spread = c_float()
        self._call_specific("Get3DSpread", byref(spread))
        return spread.value

    @threed_spread.setter
    def threed_spread(self, spread):
        """The spread of a 3D sound in speaker space.

        :param float angle: Angle over which the sound is spread. Between 0 and
            360.
        """
        self._call_specific("Set3DSpread", c_float(spread))

    @property
    def audibility(self):
        """An estimation of the output volume.

        Estimated volume is calculated based on 3D spatialization, occlusion,
        API volume levels and DSPs used.

        While this does not represent the actual waveform, Channels playing FSB
        files will take into consideration the overall peak level of the file
        (if available).

        This value is used to determine which Channels should be audible and
        which Channels to virtualize when resources are limited.

        :returns: Estimated audibility.
        :rtype: float
        """
        aud = c_float()
        self._call_specific("GetAudibility", byref(aud))
        return aud.value

    def get_dsp(self, index):
        """The DSP unit at the specified index in the DSP chain.

        :param int index: Offset into the DSP chain, see
            :py:class:`~pyfmodex.enums.CHANNELCONTROL_DSP_INDEX` for special
            named offsets for 'head' and 'tail' and 'fader' units.
        """
        dsp = c_void_p()
        self._call_specific("GetDSP", index, byref(dsp))
        return get_class("DSP")(dsp)

    @property
    def dsp_clock(self):
        """The DSP clock values at this point in time.

        :returns: Structobject with the following members:

            - dsp_clock: DSP clock value for the tail DSP node (int).
            - parent_clock: DSP clock value for the tail DSP node of the parent
              ChannelGroup (int).
        :rtype: Structobject
        """
        clock = c_ulonglong()
        parent = c_ulonglong()
        self._call_specific("GetDSPClock", byref(clock), byref(parent))
        return so(dsp_clock=clock.value, parent_clock=parent.value)

    def get_dsp_index(self, dsp):
        """The index of a DSP inside the Channel or ChannelGroup's DSP chain.

        :param DSP dsp: DSP unit that exists in the DSP chain.
        :returns: Offset into the DSP chain.
        :rtype: int
        """
        index = c_int()
        self._call_specific("GetDSPIndex", dsp._ptr, byref(index))
        return index.value

    def set_dsp_index(self, dsp, index):
        """The index in the DSP chain of the specified DSP.

        :param DSP dsp: DSP unit that exists in the DSP chain.
        :param int index: Offset into the DSP chain, see
            :py:class:`~pyfmodex.enums.CHANNELCONTROL_DSP_INDEX` for special
            named offsets for 'head' and 'tail' and 'fader' units.
        """
        self._call_specific("SetDSPIndex", dsp._ptr, index)

    @property
    def delay(self):
        """A sample accurate start (and/or stop) time relative to the parent
        ChannelGroup DSP clock.

        :returns: Structobject with the following members:

            - dspclock_start: DSP clock (int) of the parent ChannelGroup to
              audibly start playing sound at.
            - dspclock_end: DSP clock (int) of the parent ChannelGroup to
              audibly stop playing sound at.
            - stop_channels:

              - True: When dspclock_end is reached, behaves like
                :py:meth:`stop` has been called.
              - False: When dspclock_end is reached, behaves like
                :py:attr:`paused` is True, a subsequent dspclock_start allows
                it to resume.
        :rtype: Structobject
        """
        dspclock_start = c_ulonglong()
        dspclock_end = c_ulonglong()
        stop_channels = c_bool()
        self._call_specific(
            "GetDelay", byref(dspclock_start), byref(dspclock_end), byref(stop_channels)
        )
        return so(
            dsp_start=dspclock_start.value,
            dsp_end=dspclock_end.value,
            stop_channels=stop_channels.value,
        )

    @delay.setter
    def delay(self, delay):
        """A sample accurate start (and/or stop) time relative to the parent
        ChannelGroup DSP clock.

        :param delay: any object with the following attributes:

            - dsp_start: DSP clock (int) of the parent ChannelGroup to
              audibly start playing sound at.
            - dsp_end: DSP clock (int) of the parent ChannelGroup to
              audibly stop playing sound at.
            - stop_channels:
                - True: When dspclock_end is reached, behaves like
                  :py:meth:`stop` has been called.
                - False: When dspclock_end is reached, behaves like
                  :py:attr:`paused` is True, a subsequent dspclock_start allows
                  it to resume.
        """
        self._call_specific(
            "SetDelay",
            c_ulonglong(delay.dsp_start),
            c_ulonglong(delay.dsp_end),
            delay.stop_channels,
        )

    @property
    def fade_points(self):
        """Information about stored fade points.

        :returns:

            - point_dspclock: List of DSP clock values that represent the fade
              point times.
            - point_volume: List of volume levels that represent the fade point
              values. Volume levels cannot be negative.
        :rtype: two-tuple of lists
        """
        num = c_uint()
        self._call_specific("GetFadePoints", byref(num), None, None)
        clocks = (c_ulonglong * num.value)()
        volumes = (c_float * num.value)()
        self._call_specific("GetFadePoints", byref(num), clocks, volumes)
        return list(clocks), list(volumes)

    @property
    def low_pass_gain(self):
        """The gain of the dry signal when built in lowpass / distance
        filtering is applied.

        Gain level where 0 represents silent (full filtering) and 1 represents
        full volume (no filtering).

        Requires the built in lowpass to be created with
        :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flags CHANNEL_LOWPASS or
        CHANNEL_DISTANCEFILTER.

        :type: float
        """
        gain = c_float()
        self._call_specific("GetLowPassGain", byref(gain))
        return gain.value

    @low_pass_gain.setter
    def low_pass_gain(self, gain):
        self._call_specific("SetLowPassGain", c_float(gain))

    def get_mix_matrix(self, hop=0):
        """Retrieve a 2 dimensional pan matrix that maps the signal from input
        channels (columns) to output speakers (rows).

        Matrix element values can be below 0 to invert a signal and above 1 to
        amplify the signal.

        :returns: Two dimensional list of volume levels in row-major order.
            Each row represents an output speaker, each column represents an
            input channel.
        :rtype: list of floats
        """
        in_channels = c_int()
        out_channels = c_int()
        self._call_fmod(
            "FMOD_Channel_GetMixMatrix",
            None,
            byref(out_channels),
            byref(in_channels),
            hop,
        )
        matrix = (c_float * (hop or in_channels.value * out_channels.value))()
        self._call_specific(
            "GetMixMatrix", matrix, byref(out_channels), byref(in_channels), hop
        )
        return list(matrix)

    def set_mix_matrix(self, matrix, out_channels, in_channels):
        """Set a 2 dimensional pan matrix that maps the signal from input
        channels (columns) to output speakers (rows).

        Matrix element values can be below 0 to invert a signal and above 1 to
        amplify the signal. Note that increasing the signal level too far may
        cause audible distortion.

        :param list matrix: List of volume levels (float) in row-major order.
            Each row represents an output speaker, each column represents an
            input channel.
        :param int out_channels: Number of output channels (rows) in matrix.
            Always assumed 0 if `matrix` is empty.
        :param int in_channels: Number of input channels (columns) in matrix.
            Always assumed 0 if `matrix` is empty.
        """
        if not matrix:
            in_channels = 0
            out_channels = 0
        raw_matrix = (c_float * (in_channels * out_channels))(*matrix)
        self._call_specific("SetMixMatrix", raw_matrix, out_channels, in_channels, 0)

    @property
    def mode(self):
        """The playback mode bits that control how this object behaves.

        When changing the loop mode, sounds created with
        :py:meth:`~pyfmodex.system.System.create_stream` or the
        :py:class:`~pyfmodex.flags.MODE` flag CREATESTREAM may have already
        been pre-buffered and executed their loop logic ahead of time before
        this call was even made. This is dependent on the size of the sound
        versus the size of the stream decode buffer (see
        :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO`). If
        this happens, you may need to reflush the stream buffer by calling
        :py:meth:`~pyfmodex.channel.Channel.set_position`. Note this will
        usually only happen if you have sounds or loop points that are smaller
        than the stream decode buffer size.

        When changing the loop mode of sounds created with
        :py:meth:`~pyfmodex.system.System.create_sound` or the
        :py:class:`~pyfmodex.flags.MODE` flag CREATESAMPLE, if the sound was
        set up with the :py:class:`~pyfmodex.flags.MODE` flag LOOP_OFF, then
        set to LOOP_NORMAL with this function, the sound may click when playing
        the end of the sound. This is because the sound needs to be prepared
        for looping setting its :py:attr:`~pyfmodex.sound.Sound.mode`, by
        modifying the content of the PCM data (i.e. data past the end of the
        actual sample data) to allow the interpolators to read ahead without
        clicking. If you set it this way, it will not do this (because
        different Channels may have different loop modes for the same sound)
        and may click if you try to set it to looping on an unprepared sound.
        If you want to change the loop mode at runtime it may be better to load
        the sound as looping first (or use its
        :py:attr:`~pyfmodex.sound.Sound.mode`), to let it prepare the data as
        if it was looping so that it does not click whenever this proprerty is
        used to turn looping on.

        If :py:class:`~pyfmodex.flags.MODE` flags IGNOREGEOMETRY or
        VIRTUAL_PLAYFROMSTART are not specified, the flag will be cleared if it
        was specified previously.

        :type: Playback mode bitfield. Test against a specific
            :py:class:`~pyfmodex.flags.MODE` with the AND operator or set more
            than one mode at once by combining them with the OR operator.
        """
        mode = c_int()
        self._call_specific("GetMode", byref(mode))
        return MODE(mode.value)

    @mode.setter
    def mode(self, mode):
        self._call_specific("SetMode", mode.value)

    @property
    def mute(self):
        """The mute state.

         - True: silent
         - False: audible

        Mute is an additional control for volume, the effect of which is
        equivalent to setting the volume to zero.

        An individual mute state is kept for each object, muting a parent
        :py:class:`~pyfmodex.channel_group.ChannelGroup` will effectively mute
        this object however when queried the individual mute state is returned.
        The :py:attr:`~pyfmodex.channel_control.ChannelControl.audibility`
        property can be used to calculate overall audibility for a
        :py:class:`~pyfmodex.channel.Channel` or
        :py:class:`~pyfmodex.channel_group.ChannelGroup`.

        :type: bool
        """
        mute = c_bool()
        self._call_specific("GetMute", byref(mute))
        return mute.value

    @mute.setter
    def mute(self, m):
        self._call_specific("SetMute", m)

    @property
    def num_dsps(self):
        """The number of DSP units in the DSP chain.

        :type: int
        """
        num = c_int()
        self._call_specific("GetNumDSPs", byref(num))
        return num.value

    @property
    def paused(self):
        """The paused state.

         - True: playback halted
         - False: playback active

        An individual pause state is kept for each object, a parent
        :py:class:`~pyfmodex.channel_group.ChannelGroup` being paused will
        effectively pause this object. However, when queried, the individual
        pause state is returned.

        :type: bool
        """
        paused = c_bool()
        self._call_specific("GetPaused", byref(paused))
        return paused.value

    @paused.setter
    def paused(self, pausedstate):
        self._call_specific("SetPaused", pausedstate)

    @property
    def pitch(self):
        """The relative pitch / playback rate.

        Pitch value where 0.5 represents half pitch (one octave down), 1
        represents unmodified pitch and 2 represents double pitch (one octave
        up).

        An individual pitch value is kept for each object, a parent
        :py:class:`~pyfmodex.channel_group.ChannelGroup` pitch will effectively
        scale the pitch of this object however when queried the individual
        pitch value is returned.

        :type: float
        """
        val = c_float()
        self._call_specific("GetPitch", byref(val))
        return val.value

    @pitch.setter
    def pitch(self, val):
        self._call_specific("SetPitch", c_float(val))

    def get_reverb_wet(self, instance):
        """Get the wet / send level for a particular reverb instance.

        :param int instance: Reverb instance index.
        :rtype: float
        """
        wet = c_float()
        self._call_specific("GetReverbProperties", instance, byref(wet))
        return wet.value

    def set_reverb_wet(self, instance, wet):
        """Set the wet / send level for a particular reverb instance.

        Channels are automatically connected to all existing reverb instances
        due to the default wet level of 1.
        :py:class:`ChannelGroups <pyfmodex.channel_group.ChannelGroup>` however
        will not send to any reverb by default requiring an explicit call to
        this function.

        :py:class:`~pyfmodex.channel_group.ChannelGroup` reverb is optimal for
        the case where you want to send 1 mixed signal to the reverb, rather
        than a lot of individual :py:class:`~pyfmodex.channel.Channel` reverb
        sends. It is advisable to do this to reduce CPU if you have many
        :py:class:`Channels <pyfmodex.channel.Channel>` inside a
        :py:class:`~pyfmodex.channel_group.ChannelGroup`.

        When setting a wet level for a
        :py:class:`~pyfmodex.channel_group.ChannelGroup`, any
        :py:class:`Channels <pyfmodex.channel.Channel>` under that
        :py:class:`~pyfmodex.channel_group.ChannelGroup` will still have their
        existing sends to the reverb. To avoid this doubling up you should
        explicitly set the Channel wet levels to 0.

        :param int instance: Reverb instance index.
        :param float wet: Send level for the signal to the reverb. 0 = none, 1
            = full. Negative level inverts the signal.
        """
        self._call_specific("SetReverbProperties", instance, c_float(wet))

    @property
    def system_object(self):
        """The System that created this object.

        :type: System
        """
        sptr = c_void_p()
        self._call_specific("GetSystemObject", byref(sptr))
        return get_class("System")(sptr)

    @property
    def volume(self):
        """The volume level.

         - 0: silent
         - 1: full
         - Negative level: inverts the signal
         - Value larger than 1: amplifies the signal

        Setting volume at a level higher than 1 can lead to
        distortion/clipping.

        :type: float
        """
        vol = c_float()
        self._call_specific("GetVolume", byref(vol))
        return vol.value

    @volume.setter
    def volume(self, vol):
        self._call_specific("SetVolume", c_float(vol))

    @property
    def volume_ramp(self):
        """Ramp state: whether volume changes are ramped or instantaneous.

         - True: volume change is ramped
         - False: volume change is instantaeous

        Volume changes when not paused will be ramped to the target value to
        avoid a pop sound, this function allows that setting to be overridden
        and volume changes to be applied immediately.

        :type: bool
        """
        ramp = c_bool()
        self._call_specific("GetVolumeRamp", byref(ramp))
        return ramp.value

    @volume_ramp.setter
    def volume_ramp(self, ramp):
        self._call_specific("SetVolumeRamp", ramp)

    @property
    def is_playing(self):
        """The playing state.

        A :py:class:`~pyfmodex.channel.Channel` is considered
        playing after :py:meth:`~pyfmodex.system.System.play_sound` or
        :py:meth:`~pyfmodex.system.System.play_dsp`, even if it is paused.

        A :py:class:`~pyfmodex.channel_group.ChannelGroup` is considered
        playing if it has any playing :py:class:`Channels
        <pyfmodex.channel.Channel>`.

        :type: bool
        """
        play_state = c_bool()
        self._call_specific("IsPlaying", byref(play_state))
        self._call_specific("IsPlaying", byref(play_state))
        return play_state.value

    def remove_dsp(self, dsp):
        """Remove the specified DSP unit from the DSP chain.

        :param DSP dsp: DSP unit to be removed.
        """
        self._call_specific("RemoveDSP", dsp._ptr)

    def remove_fade_points(self, dsp_clock_start, dsp_clock_end):
        """Remove all fade points between the two specified clock values
        (inclusive).

        :param int dsp_clock_start: :py:class:`~pyfmodex.dsp.DSP` clock of the
            parent :py:class:`~pyfmodex.channel_group.ChannelGroup` at which to
            begin removing fade points.
        :param int dsp_clock_end: :py:class:`~pyfmodex.dsp.DSP` clock of the
            parent :py:class:`~pyfmodex.channel_group.ChannelGroup` at which to
            stop removing fade points.
        """
        self._call_specific(
            "RemoveFadePoints", c_ulonglong(dsp_clock_start), c_ulonglong(dsp_clock_end)
        )

    def set_callback(self, callback):
        """Set the callback for ChannelControl level notifications.

        :param CHANNELCONTROL_CALLBACK callback: Callback to invoke.
        """
        cbi = CHANNELCONTROL_CALLBACK(callback)
        self._cb = callback
        self._call_specific("SetCallback", cbi)

    def set_fade_point_ramp(self, dsp_clock, volume):
        """Add a volume ramp at the specified time in the future using fade
        points.

        This is a convenience method that creates a scheduled 64 sample fade
        point ramp from the current volume level to volume arriving at
        dsp_clock time.

        Can be use in conjunction with :py:attr:`delay`.

        All fade points after dsp_clock will be removed.

        :param int dsp_clock: Time at which the ramp will end, as measured by
            the :py:class:`~pyfmodex.dsp.DSP` clock of the parent
            :py:class:`~pyfmodex.channel_group.ChannelGroup`.
        :param float volume: Volume level at the given dsp_clock.

            - 0: silent
            - 1: full
        """
        self._call_specific("SetFadePointRamp", c_ulonglong(dsp_clock), c_float(volume))

    def set_mix_levels_input(self, *levels):
        """Set the incoming volume level for each channel of a multi-channel
        signal.

        This is a convenience method to avoid passing a matrix, it will
        overwrite values set via :py:meth:`set_pan`,
        :py:meth:`set_mix_levels_output` and :py:meth:`set_mix_matrix`.

        :param list levels: volume levels for each incoming channel.

            - 0: silent
            - 1: full
            - Negative level: inverts the signal
            - Value larger than 1: amplifies the signal
        """
        level_array = (c_float * len(levels))(*levels)
        self._call_specific("SetMixLevelsInput", level_array, len(level_array))

    def set_mix_levels_output(
        self,
        frontleft,
        frontright,
        center,
        lfe,
        surroundleft,
        surroundright,
        backleft,
        backright,
    ):
        """Set the outgoing volume levels for each speaker.

        Specify the level for a given output speaker. If the channel count of
        the input and output do not match, channels will be up/down mixed as
        appropriate to approximate the given speaker values. For example stereo
        input with 5.1 output will use the center parameter to distribute
        signal to the center speaker from front left and front right channels.

        This is a convenience method to avoid passing a matrix, it will
        overwrite values set via :py:meth:`set_pan`,
        :py:meth:`set_mix_levels_input` and :py:meth:`set_mix_matrix`.

        The output channel count will always match the System speaker mode set
        via :py:attr:`~pyfmodex.system.System.software_format`.

        If the System is initialized with
        :py:class:`~pyfmodex.enums.SPEAKERMODE` RAW calling this function will
        produce silence.

        :param float frontleft: Volume level.
        :param float frontright: Volume level.
        :param float center: Volume level.
        :param float lfe: Volume level.
        :param float surroundleft: Volume level.
        :param float surroundright: Volume level.
        :param float backleft: Volume level.
        :param float backright: Volume level.

        Volume levels:

            - 0: silent
            - 1: full
            - Negative level: inverts the signal
            - Value larger than 1: amplifies the signal
        """
        self._call_specific(
            "SetMixLevelsOutput",
            c_float(frontleft),
            c_float(frontright),
            c_float(center),
            c_float(lfe),
            c_float(surroundleft),
            c_float(surroundright),
            c_float(backleft),
            c_float(backright),
        )

    def set_pan(self, pan):
        """Set the left/right pan level.

        This is a convenience method to avoid passing a matrix, it will
        overwrite values set via :py:meth:`set_mix_levels_input`,
        :py:meth:`set_mix_levels_output` and :py:meth:`set_mix_matrix`.

        Mono inputs are panned from left to right using constant power panning
        (non linear fade). Stereo and greater inputs will isolate the front
        left and right input channels and fade them up and down based on the
        pan value (silencing other channels). The output channel count will
        always match the System speaker mode set via
        :py:attr:`pyfmodex.system.System.software_format`.

        If the System is initialized with
        :py:class:`~pyfmodex.enums.SPEAKERMODE` RAW calling this function will
        produce silence.

        :param float pan: Pan level where -1 represents full left, 0 represents
            center and 1 represents full right.
        """
        self._call_specific("SetPan", c_float(pan))

    def stop(self):
        """Stop the Channel (or all Channels in nested ChannelGroups) from
        playing.

        This will free up internal resources for reuse by the virtual
        :py:class:`~pyfmodex.channel.Channel` system.
        """
        self._call_specific("Stop")
