"""The main system object for FMOD Studio."""

from ctypes import byref, c_int, c_void_p

from ..flags import INIT_FLAGS
from ..utils import check_type, ckresult, prepare_str
from .bank import Bank
from .event_description import EventDescription
from .flags import LOAD_BANK_FLAGS, STUDIO_INIT_FLAGS
from .library import get_library
from .structures import ADVANCEDSETTINGS, BUFFER_USAGE
from .studio_object import StudioObject
from .utils import fmod_version
from .. import System

class StudioSystem(StudioObject):
    """The main system object for FMOD Studio.

    Initializing the FMOD Studio System object will also initialize the core
    System object.
    """

    function_prefix = "FMOD_Studio_System"

    def __init__(self, ptr=None, create=True, version=None):
        """FMOD Studio System creation function.

        If create is True, a new instance is created. Otherwise ptr must be a
        valid pointer.
        """
        super().__init__(ptr)
        self._system_callbacks = {}
        if create:
            if not version:
                version = fmod_version()
            self._ptr = c_void_p()
            ckresult(get_library().FMOD_Studio_System_Create(byref(self._ptr), version))
        else:
            self._ptr = ptr

    @property
    def advanced_settings(self):
        """Settings for advanced features like configuring memory and cpu
        usage.
        """
        settings = ADVANCEDSETTINGS()
        self._call("GetAdvancedSettings", byref(settings))
        return settings

    @advanced_settings.setter
    def advanced_settings(self, value):
        check_type(value, ADVANCEDSETTINGS)
        self._call("SetAdvancedSettings", byref(value))

    def get_bank(self, path):
        """A loaded bank.

        :param str path: The bank path or the ID string that identifies the bank.
        """
        path = prepare_str(path)
        ptr = c_void_p()
        self._call("GetBank", path, byref(ptr))
        return Bank(ptr)

    @property
    def bank_count(self):
        """The number of loaded banks."""
        count = c_int()
        self._call("GetBankCount", byref(count))
        return count.value

    @property
    def banks(self):
        """The loaded banks."""
        array = (c_void_p * self.bank_count)()
        self._call("GetBankList", byref(array), len(array), None)
        return [Bank(ptr) for ptr in array]

    @property
    def buffer_usage(self):
        """Buffer usage information."""
        usage = BUFFER_USAGE()
        self._call("GetBufferUsage", byref(usage))
        return usage

    def initialize(
        self,
        max_channels=1000,
        studio_flags=STUDIO_INIT_FLAGS.NORMAL,
        flags=INIT_FLAGS.NORMAL,
        extra=None,
    ):
        """Initialize the Studio System.

        The core system used by the studio system is initialized at the same
        time as the studio system.

        The flags and extra parameters are passed on to initialize the core.

        :param int max_channels: The maximum number of channels to be used in FMOD.
        :param Flags studio_flags: Studio system initialization flags.
        :param Flags flags: Core system initialization flags.
        :param extra: Driver specific data to be passed to the output plugin.
        """
        self._call("Initialize", max_channels, studio_flags.value, flags.value, extra)

    def release(self):
        """Shut down and free the Studio System object.

        This frees the memory used by the Studio System object and everything
        created under it.

        This is not thread-safe. Calling this function concurrently with any
        FMOD Studio API function (inclusing itself) may cause undefined
        behavior. External synchronization must be used if calls to this
        function could overlap other FMOD Studio API calls.

        All other FMOD Studio API functions are thread safe and may be called
        freely from any thread unless otherwise documented.

        All handles or pointers to objects associated with a Studio System
        object become invalid when the Studio System object is released. The
        FMOD Studio API attempts to protect against stale handles and pointers
        being used with a different Studio System object but this protection
        cannot be guaranteed and attempting to use stale handles or pointers
        may cause undefined behavior.
        """
        self._call("Release")

    def flush_commands(self):
        """Block until all pending commands have been executed.

        This blocks the calling thread until all pending commands have been
        executed and all non-blocking bank loads have been completed.

        This is equivalent to calling :func:`update` and then sleeping until
        the asynchronous thread has finished executing all pending commands.
        """
        self._call("FlushCommands")

    def flush_sample_loading(self):
        """Block until all sample loading and unloading has completed."""
        self._call("FlushSampleLoading")

    def load_bank_file(self, filename, flags=LOAD_BANK_FLAGS.NORMAL):
        """Load the metadata of a Studio bank from file.

        :param str filename: Name of the file on disk.
        :param Flags flags: Flags to control bank loading.
        """
        filename = prepare_str(filename)
        bank_ptr = c_void_p()
        self._call("LoadBankFile", filename, flags.value, byref(bank_ptr))
        return Bank(bank_ptr)

    def update(self):
        """Update the FMOD Studio System.

        When Studio is initialized in the default asynchronous processing mode
        this function submits all buffered commands for execution on the Studio
        Update thread for asynchronous processing. This is a fast operation
        since the commands are not processed on the calling thread. If Studio
        is initialized with DEFERRED_CALLBACKS then any deferred callbacks
        fired during any asynchronous updates since the last call to this
        function will be called. If an error occurred during any asynchronous
        updates since the last call to this function then this function will
        return the error result.

        When Studio is initialized with SYNCHRONOUS_UPDATE queued commands will
        be processed immediately when calling this function, the scheduling and
        update logic for the Studio system are executed and all callbacks are
        fired. This may block the calling thread for a substantial amount of
        time.
        """
        self._call("Update")

    def get_event(self, path):
        """An EventDescription.

        :param str path: The path or the ID string that identifies the event or
            snapshot.
        """
        ptr = c_void_p()
        self._call("GetEvent", prepare_str(path), byref(ptr))
        return EventDescription(ptr)

    @property
    def core_system(self):
        """The Core System.

        The Core System object can be retrieved before initializing the Studio
        System object to call additional core configuration functions.
        """
        system_ptr = c_void_p()
        self._call("GetCoreSystem", byref(system_ptr))
        return System(system_ptr)
