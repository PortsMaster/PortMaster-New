"""FMOD python bindings."""

from .fmodex import (get_disk_busy, get_memory_stats, initialize_debugging,
                     initialize_memory, set_disk_busy)

# Avoid recursive import hell
from . import (channel, channel_group, dsp, dsp_connection, geometry,
               globalvars, reverb, sound, sound_group, system)

# import reverb presets
from .reverb_presets import REVERB_PRESET, set_reverb_preset

# import structures to be used with Resonance Audio plugin
from .roomproperties import MaterialNames, RoomProperties
from .utils import FmodError

__version__ = "0.7.2"

c = {}
c["DSP"] = dsp.DSP
c["DSP_Connection"] = dsp_connection.DSPConnection
c["Geometry"] = geometry.Geometry
c["Channel"] = channel.Channel
c["ChannelGroup"] = channel_group.ChannelGroup
c["Reverb3D"] = reverb.Reverb3D
c["Sound"] = sound.Sound
c["SoundGroup"] = sound_group.SoundGroup
c["System"] = system.System
globalvars.class_list = c

from . import constants

System = c["System"]
