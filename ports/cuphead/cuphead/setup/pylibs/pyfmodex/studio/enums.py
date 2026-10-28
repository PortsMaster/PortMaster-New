"""Various Fmod studio enumerations."""

from enum import Enum


class PLAYBACK_STATE(Enum):  # pylint: disable=invalid-name
    """Playback state of various objects.

    PLAYING: Playing
    SUSTAINING: The timeline cursor is paused on a sustain point
    STOPPED: Stopped
    STARTING: Preparing to start
    STOPPING: Preparing to stop
    """

    PLAYING = 0
    SUSTAINING = 1
    STOPPED = 2
    STARTING = 3
    STOPPING = 4

class LOADING_STATE(Enum):
    """Loading state of various objects.
    UNLOADING: Currently unloading.
    UNLOADED: Not loaded.
    LOADING: Loading in progress.
    LOADED: Loaded and ready to play.
    ERROR: Failed to load.
    """
    
    UNLOADING = 0
    UNLOADED = 1
    LOADING = 2
    LOADED = 3
    ERROR = 4