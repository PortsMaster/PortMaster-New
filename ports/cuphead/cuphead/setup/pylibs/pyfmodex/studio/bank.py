"""FMOD Studio banks contain the metadata and audio sample data required for
runtime mixing and playback.
"""

from ctypes import byref, c_int, c_void_p

from .event_description import EventDescription
from .studio_object import StudioObject


class Bank(StudioObject):
    """FMOD Studio banks contain the metadata and audio sample data required
    for runtime mixing and playback. Audio sample data may be packed into the
    same bank as the events which reference it, or it may be packed into
    separate banks.
    """

    function_prefix = "FMOD_Studio_Bank"

    @property
    def event_count(self):
        """The number of event descriptions in the bank."""
        count = c_int()
        self._call("GetEventCount", byref(count))
        return count.value

    @property
    def events(self):
        """The event descriptions in the bank."""
        count = self.event_count
        array = (c_void_p * count)()
        written = c_int()
        self._call("GetEventList", array, count, byref(written))
        assert count == written.value
        descs = []
        for pointer in array:
            descs.append(EventDescription(pointer))
        return descs
