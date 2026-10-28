"""The description for an FMOD Studio Event."""

from ctypes import byref, c_int, c_void_p, create_string_buffer

from .event_instance import EventInstance
from .studio_object import StudioObject
from .enums import LOADING_STATE

class EventDescription(StudioObject):
    """The description for an FMOD Studio Event.

    Event descriptions belong to banks and can be queried after the relevant
    bank has been loaded. Event descriptions may be retrieved via path or GUID
    lookup, or by enumerating all descriptions in a bank.
    """

    function_prefix = "FMOD_Studio_EventDescription"

    @property
    def path(self):
        """The path."""
        required = c_int()
        self._call("GetPath", None, 0, byref(required))
        path_buffer = create_string_buffer(required.value)
        self._call("GetPath", path_buffer, len(path_buffer), None)
        return path_buffer.value.decode("utf-8")

    def create_instance(self):
        """Create a playable instance."""
        instance_ptr = c_void_p()
        self._call("CreateInstance", byref(instance_ptr))
        return EventInstance(instance_ptr)

    @property
    def parameter_description_count(self):
        """The number of parameters in the event."""
        count = c_int()
        self._call("GetParameterDescriptionCount", byref(count))
        return count.value

    @property
    def user_property_count(self):
        """The number of user properties attached to the event."""
        count = c_int()
        self._call("GetUserPropertyCount", byref(count))
        return count.value

    def load_sample_data(self):
        """Loads non-streaming sample data used by the event."""
        self._call("LoadSampleData")

    @property
    def sample_loading_state(self):
        """Retrieves the sample data loading state."""
        state = c_int()
        self._call("GetSampleLoadingState", byref(state))
        return LOADING_STATE(state.value)