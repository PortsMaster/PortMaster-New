"""An interface that manages Sound Groups."""
from ctypes import byref, c_float, c_int, c_void_p, create_string_buffer

from .enums import SOUNDGROUP_BEHAVIOR
from .fmodobject import FmodObject
from .globalvars import get_class


class SoundGroup(FmodObject):
    """An interface that manages Sound Groups."""

    @property
    def max_audible(self):
        """The maximum number of playbacks to be audible at once in a sound
        group.

        :type: int
        """
        val = c_int()
        self._call_fmod("FMOD_SoundGroup_GetMaxAudible", byref(val))
        return val.value

    @max_audible.setter
    def max_audible(self, val):
        self._call_fmod("FMOD_SoundGroup_SetMaxAudible", val)

    @property
    def max_audible_behavior(self):
        """The current max audible behavior.

        :type: SOUNDGROUP_BEHAVIOR
        """
        behavior = c_int()
        self._call_fmod("FMOD_SoundGroup_GetMaxAudibleBehavior", byref(behavior))
        return SOUNDGROUP_BEHAVIOR(behavior.value)

    @max_audible_behavior.setter
    def max_audible_behavior(self, behavior):
        self._call_fmod("FMOD_SoundGroup_SetMaxAudibleBehavior", behavior.value)

    @property
    def mute_fade_speed(self):
        """The current mute fade time.

        0 means no fading.

        If a mode besides :py:attr:`~pyfmodex.enums.SOUNDGROUP_BEHAVIOR.MUTE`
        is used, the fade speed is ignored.

        When more sounds are playing in a SoundGroup than are specified with
        :py:attr:`max_audible`, the least important
        :py:class:`~pyfmodex.sound.Sound` (i.e. lowest priority / lowest
        audible volume due to 3D position, volume etc) will fade to silence if
        :py:attr:`~pyfmodex.enums.SOUNDGROUP_BEHAVIOR.MUTE` is used, and any
        previous sounds that were silent because of this rule will fade in if
        they are more important.

        :type: float
        """
        speed = c_float()
        self._call_fmod("FMOD_SoundGroup_GetMuteFadeSpeed", byref(speed))
        return speed.value

    @mute_fade_speed.setter
    def mute_fade_speed(self, speed):
        self._call_fmod("FMOD_SoundGroup_SetMuteFadeSpeed", c_float(speed))

    @property
    def name(self):
        """The name of the sound group.

        :type: str
        """
        buf = create_string_buffer(512)
        self._call_fmod("FMOD_SoundGroup_GetName", buf, 512)
        return buf.value

    @property
    def num_playing(self):
        """The number of currently playing channels for the sound group.

        This returns the number of :py:class:`Channels
        <pyfmodex.channel.Channel>` playing. If the :py:class:`SoundGroup`
        only has one :py:class:`~pyfmodex.sound.Sound`, and that
        :py:class:`~pyfmodex.sound.Sound` is playing twice, the figure returned
        will be two.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_SoundGroup_GetNumPlaying", byref(num))
        return num.value

    @property
    def num_sounds(self):
        """The current number of sounds in this sound group.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_SoundGroup_GetNumSounds", byref(num))
        return num.value

    def get_sound(self, idx):
        """The sound in this group at the given index.

        :param int idx: Index of the sound.
        :returns: Sound object
        :rtype: Sound
        """
        sndptr = c_void_p()
        self._call_fmod("FMOD_SoundGroup_GetSound", idx, byref(sndptr))
        return get_class("Sound")(sndptr)

    @property
    def system_object(self):
        """The parent System object.

        :type: System
        """
        sysptr = c_void_p()
        self._call_fmod("FMOD_SoundGroup_GetSystemObject", byref(sysptr))
        return get_class("System")(sysptr)

    @property
    def volume(self):
        """The volume of the sound group.

        :type: float
        """
        vol = c_float()
        self._call_fmod("FMOD_SoundGroup_GetVolume", byref(vol))
        return vol.value

    @volume.setter
    def volume(self, vol):
        self._call_fmod("FMOD_SoundGroup_SetVolume", c_float(vol))

    def release(self):
        """Release the soundgroup object and return all sounds back to the
        master sound group.

        You cannot release the master :py:class:`SoundGroup`.
        """
        self._call_fmod("FMOD_SoundGroup_Release")

    def stop(self):
        """Stop all sounds within this soundgroup."""
        self._call_fmod("FMOD_SoundGroup_Stop")
