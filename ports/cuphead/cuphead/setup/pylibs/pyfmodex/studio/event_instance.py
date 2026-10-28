"""An instance of an FMOD Studio Event."""

from ctypes import byref, c_bool, c_float, c_int, c_void_p

from ..channel_group import ChannelGroup
from ..utils import prepare_str
from .enums import PLAYBACK_STATE
from .studio_object import StudioObject


class EventInstance(StudioObject):
    """An instance of an FMOD Studio Event."""

    function_prefix = "FMOD_Studio_EventInstance"

    def start(self):
        """Starts playback.

        If the instance was already playing then calling this function will
        restart the event.
        """
        self._call("Start")

    def stop(self):
        """Stops playback."""
        self._call("Stop")

    @property
    def paused(self):
        """Tthe pause state.

        True if the event instance is paused.
        """
        paused = c_bool()
        self._call("GetPaused", byref(paused))
        return paused.value

    @paused.setter
    def paused(self, val):
        """Set the pause state.

        :param bool val: The desired pause state. True = paused, False =
            unpaused.
        """
        self._call("SetPaused", c_bool(val))

    @property
    def playback_state(self):
        """The playback state.

        If the instance is invalid, then the state will be STOPPED.
        """
        state = c_int()
        self._call("GetPlaybackState", byref(state))
        return PLAYBACK_STATE(state.value)

    def get_parameter_by_name(self, name):
        """A parameter value.

        :param str name: Parameter name (case-insensitive)."""
        val = c_float()
        actual = c_float()
        self._call("GetParameterByName", prepare_str(name), byref(val), byref(actual))
        return (val.value, actual.value)

    def set_parameter_by_name(self, name, value, ignoreseekspeed=False):
        """Set a parameter value by name.

        :param str name: Parameter name (case-insensitive).
        :param float value: Value for given name.
        :param bool ignoreseekspeed: Specifies whether to ignore the
            parameter's seek speed and set the value immediately.
        """
        self._call(
            "SetParameterByName", prepare_str(name), c_float(value), ignoreseekspeed
        )

    @property
    def channel_group(self):
        """The core channel group corresponding to the master track.

        Until the event instance has been fully created calling this property
        will raise an :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.STUDIO_NOT_LOADED`.
        """
        ptr = c_void_p()
        self._call("GetChannelGroup", byref(ptr))
        return ChannelGroup(ptr)

    @property
    def reverb_level(self):
        """Not Implemented."""
        raise NotImplementedError

    @reverb_level.setter
    def reverb_level(self, level):
        raise NotImplementedError
