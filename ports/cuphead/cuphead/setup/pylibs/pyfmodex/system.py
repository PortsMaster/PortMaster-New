"""Module containing all classes related to the Fmod System class."""

from ctypes import byref, create_string_buffer, sizeof
from ctypes import c_bool, c_float, c_int, c_uint, c_longlong, c_void_p

from .callback_prototypes import ROLLOFF_CALLBACK, SYSTEM_CALLBACK
from .callback_prototypes import FILE_ASYNCCANCEL_CALLBACK, FILE_CLOSE_CALLBACK
from .callback_prototypes import FILE_OPEN_CALLBACK, FILE_READ_CALLBACK
from .callback_prototypes import FILE_SEEK_CALLBACK, FILE_ASYNCREAD_CALLBACK
from .enums import OUTPUTTYPE, PLUGINTYPE, SPEAKERMODE, TIMEUNIT, RESULT
from .exceptions import FmodError
from .flags import INIT_FLAGS, MODE
from .fmodobject import FmodObject
from .globalvars import DLL as _dll
from .globalvars import get_class
from .structobject import Structobject as so
from .structures import ADVANCEDSETTINGS, VECTOR, REVERB_PROPERTIES, GUID
from .structures import DSP_DESCRIPTION
from .utils import ckresult, prepare_str, check_type

class Listener:
    """A 3D sound listener."""

    def __init__(self, sptr, aaidee):
        """Constructor, should be considered non-public. Usually only called
        from :py:attr:`~System.listener`.
        """
        pos_vec = VECTOR()
        vel_vec = VECTOR()
        fwd_vec = VECTOR()
        up_vec = VECTOR()
        self._sysptr = sptr
        self._id = aaidee
        ckresult(
            _dll.FMOD_System_Get3DListenerAttributes(
                self._sysptr,
                aaidee,
                byref(pos_vec),
                byref(vel_vec),
                byref(fwd_vec),
                byref(up_vec),
            )
        )
        self._pos = pos_vec
        self._vel = vel_vec
        self._fwd = fwd_vec
        self._up = up_vec
        self._rolloff_callback = None

    @property
    def position(self):
        """Position in 3D space used for panning and attenuation.

        :type: list of three coordinate floats
        """
        return self._pos.to_list()

    @position.setter
    def position(self, poslist):
        self._pos = VECTOR.from_list(poslist)
        self._commit()

    @property
    def velocity(self):
        """Velocity in 3D space used for doppler.

        :type: list of three coordinate floats
        """
        return self._vel.to_list()

    @velocity.setter
    def velocity(self, vellist):
        self._vel = VECTOR.from_list(vellist)
        self._commit()

    @property
    def forward(self):
        """Forwards orientation.

        :type: list of three coordinate floats
        """
        return self._fwd.to_list()

    @forward.setter
    def forward(self, fwdlist):
        self._fwd = VECTOR.from_list(fwdlist)
        self._commit()

    @property
    def up(self):  # pylint: disable=invalid-name
        """Upwards orientation.

        :type: list of three coordinate floats
        """
        return self._up.to_list()

    @up.setter
    def up(self, uplist):  # pylint: disable=invalid-name
        self._up = VECTOR.from_list(uplist)
        self._commit()

    def set_orientation(self, forward, up):
        """Set the orientation of the listener.

        :param list forward: Forwards orientation.
        :param list up: Upwards orientation.
        """
        self._fwd = VECTOR.from_list(forward)
        self._up = VECTOR.from_list(up)
        self._commit()

    def _commit(self):
        """Apply a changed 3D Listener vector."""
        ckresult(
            _dll.FMOD_System_Set3DListenerAttributes(
                self._sysptr,
                self._id,
                byref(self._pos),
                byref(self._vel),
                byref(self._fwd),
                byref(self._up),
            )
        )


class DSPBufferSizeInfo:
    """Buffer size settings for the FMOD software mixing engine."""

    def __init__(self, sptr, size, count):
        """Constructor, should be considered non-public. Usually only called
        from :py:attr:`~System.dsp_buffer_info`.
        """
        self._sysptr = sptr
        self._size = size
        self._count = count

    @property
    def size(self):
        """Mixer engine block size.

        :type: int
        """
        return self._size

    @size.setter
    def size(self, size):
        ckresult(_dll.FMOD_System_SetDSPBufferSize(self._sysptr, size, self._count))
        self._size = size

    @property
    def count(self):
        """Mixer engine number of buffers used.

        :type: int
        """
        return self._count

    @count.setter
    def count(self, count):
        ckresult(_dll.FMOD_System_SetDSPBufferSize(self._sysptr, self._size, count))
        self._count = count


class ThreedSettings:
    """The global doppler scale, distance factor and rolloff scale for all 3D
    sounds.
    """

    def __init__(self, sptr, dopplerscale, distancefactor, rolloffscale):
        """Constructor, should be considered non-public. Usually only called
        from :py:attr:`~System.threed_settings`.
        """
        self._sysptr = sptr
        self._distancefactor = distancefactor
        self._dopplerscale = dopplerscale
        self._rolloffscale = rolloffscale

    @property
    def distance_factor(self):
        """Distance factor to FMODs units.

        :type: float
        """
        return self._distancefactor

    @distance_factor.setter
    def distance_factor(self, factor):
        ckresult(
            _dll.FMOD_System_Set3DSettings(
                self._sysptr,
                c_float(self._dopplerscale),
                c_float(factor),
                c_float(self._rolloffscale),
            )
        )
        self._distancefactor = factor

    @property
    def doppler_scale(self):
        """Scaling factor for doppler shift.

        :type: int
        """
        return self._dopplerscale

    @doppler_scale.setter
    def doppler_scale(self, scale):
        ckresult(
            _dll.FMOD_System_Set3DSettings(
                self._sysptr,
                c_float(scale),
                c_float(self._distancefactor),
                c_float(self._rolloffscale),
            )
        )
        self._dopplerscale = scale

    @property
    def rolloff_scale(self):
        """Scaling factor for 3D sound rolloff or attenuation.

        :type: int
        """
        return self._rolloffscale

    @rolloff_scale.setter
    def rolloff_scale(self, rscale):
        ckresult(
            _dll.FMOD_System_Set3DSettings(
                self._sysptr,
                c_float(self._distancefactor),
                c_float(self._dopplerscale),
                c_float(rscale),
            )
        )
        self._rolloffscale = rscale


class System(FmodObject):  # pylint: disable=too-many-public-methods
    """Management object from which all resources are created and played."""

    def __init__(self, ptr=None, header_version=0x00020230):
        """A System object must be created first before any other FMOD API
        calls are made (except for
        :py:meth:`~pyfmodex.fmodex.initialize_memory`
        and :py:meth:`~pyfmodex.fmodex.initialize_debugging`).

        You can create one or multiple instances of FMOD System objects. If
        `ptr` is None, a new instance is created. Otherwise it must be a valid
        pointer of an existing System object.
        During creation, the 2.01 and older creation sequece will be tried
        first, when that fails on 2.02 or newer, the new will be used
        with a provided `header_version` or a library default.
        """
        self._system_callbacks = {}
        if ptr is None:
            self._ptr = c_void_p()
            try:
                ckresult(_dll.FMOD_System_Create(byref(self._ptr)))
            except FmodError as exc:
                if exc.result is not RESULT.HEADER_MISMATCH:
                    raise
                ckresult(_dll.FMOD_System_Create(byref(self._ptr), header_version))
        else:
            self._ptr = ptr
        self._user_open = None
        self._user_close = None
        self._user_read = None
        self._user_seek = None

    def attach_channel_group_to_port(
        self, port_type, port_index, group, passthru=False
    ):
        """Connect the output of the specified ChannelGroup to an audio port on
        the output driver.

        Ports are additional outputs supported by some
        :py:class:`~pyfmodex.enums.OUTPUTTYPE` plugins and can include things
        like controller headsets or dedicated background music streams. See
        platform specific header (if it exists) for available port type and
        index, or the platform specific section of the Core API Reference for
        more information.

        :param PORT_TYPE port_type: Port type (output mode specific).
        :param PORT_INDEX port_index: Index to specify which instance of the
            specified `port_type` to use (output mode specific.
        :param ChannelGroup group: Group to attach the port to.
        :param bool passthru: Whether signal should additionally route to the
            existing ChannelGroup output.
        """
        ckresult(
            _dll.FMOD_System_AttachChannelGroupToPort(
                self._ptr, port_type, port_index, group._ptr, passthru
            )
        )

    def attach_file_system(self, user_open, user_close, user_read, user_seek):
        """'Piggyback' on FMOD file reading routines to capture data as it's read.

        This allows users to capture data as FMOD reads it, which may be useful
        for extracting the raw data that FMOD reads for hard to support sources
        (for example Internet streams).

        To detach, pass None as the callback parameters.

        Note: This function is not to replace FMOD's file system. For this
        functionality, see :py:meth:`set_file_system`.

        :param callable user_open: Callback for after a file is opened.
        :param callable user_close: Callback for after a file is closed.
        :param callable user_read: Callback for after a read operation.
        :param callable user_seek: Callback for after a seek operation.
        """
        if user_open:
            user_open = FILE_OPEN_CALLBACK(user_open)
        if user_close:
            user_close = FILE_CLOSE_CALLBACK(user_close)
        if user_read:
            user_read = FILE_READ_CALLBACK(user_read)
        if user_seek:
            user_seek = FILE_SEEK_CALLBACK(user_seek)
        self._call_fmod(
            "FMOD_System_AttachFileSystem", user_open, user_close, user_read, user_seek
        )
        self._user_open = user_open
        self._user_close = user_close
        self._user_read = user_read
        self._user_seek = user_seek

    def create_channel_group(self, name):
        """Create a ChannelGroup object.

        :py:class:`ChannelGroups <pyfmodex.channel_group.ChannelGroup>` can be
        used to assign / group :py:class:`Channels <pyfmodex.channel.Channel>`,
        for things such as volume scaling. :py:class:`ChannelGroups
        <pyfmodex.channel_group.ChannelGroup>` are also used for sub-mixing.
        Any :py:class:`Channels <pyfmodex.channel.Channel>` that are assigned
        to a :py:class:`~pyfmodex.channel_group.ChannelGroup` get submixed into
        that :py:class:`~pyfmodex.channel_group.ChannelGroup`'s 'tail'
        :py:class:`~pyfmodex.dsp.DSP`. See
        :py:attr:`~pyfmodex.enums.CHANNELCONTROL_DSP_INDEX.TAIL`.

        If a :py:class:`~pyfmodex.channel_group.ChannelGroup` has an effect
        added to it, the effect is processed post-mix from the
        :py:class:`Channels <pyfmodex.channel.Channel>` and
        :py:class:`ChannelGroups <pyfmodex.channel_group.ChannelGroup>` below
        it in the mix hierarchy. See the :py:class:`~pyfmodex.dsp.DSP`
        architecture guide for more information.

        All :py:class:`ChannelGroups <pyfmodex.channel_group.ChannelGroup>`
        will initially output directly to the master
        :py:class:`~pyfmodex.channel_group.ChannelGroup` (See
        :py:attr:`master_channel_group`). :py:class:`ChannelGroups
        <pyfmodex.channel_group.ChannelGroup>` can be re-parented with
        :py:meth:`~pyfmodex.channel_group.ChannelGroup.add_group`

        :param str name: Label for identification purposes.
        :returns: Newly created group.
        :rtype: ChannelGroup
        """
        name = prepare_str(name)
        cgp = c_void_p()
        ckresult(_dll.FMOD_System_CreateChannelGroup(self._ptr, name, byref(cgp)))
        return get_class("ChannelGroup")(cgp)

    def create_dsp(self, dspdesc):
        """Create a DSP object given a plugin description structure.

        A DSP object is a module that can be inserted into the mixing graph to
        allow sound filtering or sound generation.

        DSPs must be attached to the DSP graph before they become active,
        either via :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp`
        or :py:meth:`~pyfmodex.dsp.DSP.add_input`.

        :param DSP_DESCRIPTION dspdesc: Structure describing the DSP to create.
        :returns: Newly created unit.
        :rtype: DSP
        """
        dsp_ptr = c_void_p()
        ckresult(_dll.FMOD_System_CreateDSP(self._ptr, byref(dspdesc), byref(dsp_ptr)))
        return get_class("DSP")(dsp_ptr)

    def create_dsp_by_plugin(self, plugin_handle):
        """Create a DSP object given a plugin handle.

        A DSP object is a module that can be inserted into the mixing graph to
        allow sound filtering or sound generation.

        A handle can come from a newly loaded plugin with
        :py:meth:`load_plugin` or an existing plugin with
        :py:meth:`get_plugin_handle`.

        DSPs must be attached to the DSP graph before they become active,
        either via :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp`
        or :py:meth:`~pyfmodex.dsp.DSP.add_input`.

        :param int pugin_handle: Handle to an already loaded DSP plugin.
        :returns: Newly created unit.
        :rtype: DSP
        """
        dsp_ptr = c_void_p()
        ckresult(
            _dll.FMOD_System_CreateDSPByPlugin(self._ptr, plugin_handle, byref(dsp_ptr))
        )
        return get_class("DSP")(dsp_ptr)

    def create_dsp_by_type(self, dsptype):
        """Create a DSP object given a built in type index.

        A DSP object is a module that can be inserted into the mixing graph to
        allow sound filtering or sound generation.

        DSPs must be attached to the DSP graph before they become active,
        either via :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp`
        or :py:meth:`~pyfmodex.dsp.DSP.add_input`.

        Using :py:attr:`~pyfmodex.enums.DSP_TYPE.VSTPLUGIN` or
        :py:attr:`~pyfmodex.enums.DSP_TYPE.WINAMPPLUGIN` will return the first
        loaded plugin of this type. To access other plugins of these types, use
        :py:meth:`create_dsp_by_plugin` instead.

        :param DSP_TYPE dsptype: Type of built in unit.
        :returns: Newly created unit.
        :rtype: DSP
        """
        dsp_ptr = c_void_p()
        ckresult(
            _dll.FMOD_System_CreateDSPByType(self._ptr, dsptype.value, byref(dsp_ptr))
        )
        return get_class("DSP")(dsp_ptr)

    def create_geometry(self, maxpolygons, maxvertices):
        """Geometry creation function. This method will create a base geometry
        object which can then have polygons added to it.

        Polygons can be added to a geometry object using
        :py:meth:`~pyfmodex.geometry.Geometry.add_polygon`. For best
        efficiency, avoid overlapping of polygons and long thin polygons.

        A geometry object stores its polygons in a group to allow optimization
        for line testing, insertion and updating of geometry in real-time.
        Geometry objects also allow for efficient rotation, scaling and
        translation of groups of polygons.

        It is important to set the value of :py:attr:`geometry_max_world_size`
        to an appropriate value.

        :param int maxpolygons: Maximum number of polygons within this object.
        :param int maxvertices: Maximum number of vertices within this object.
        :returns: Newly created geometry object.
        :rtype: Geometry
        """
        geo_ptr = c_void_p()
        ckresult(
            _dll.FMOD_System_CreateGeometry(
                self._ptr, maxpolygons, maxvertices, byref(geo_ptr)
            )
        )
        return get_class("Geometry")(geo_ptr)

    def create_reverb_3d(self):
        """Create a 'virtual reverb' object. This object reacts to 3D location
        and morphs the reverb environment based on how close it is to the
        reverb object's center.

        Multiple reverb objects can be created to achieve a multi-reverb
        environment. One Physical reverb object is used for all 3D reverb
        objects (slot 0 by default).

        The 3D reverb object is a sphere having 3D attributes (position,
        minimum distance, maximum distance) and reverb properties.

        The properties and 3D attributes of all reverb objects collectively
        determine, along with the listener's position, the settings of and
        input gains into a single 3D reverb :py:class:`~pyfmodex.dsp.DSP`.

        When the listener is within the sphere of effect of one or more 3D
        reverbs, the listener's 3D reverb properties are a weighted combination
        of such 3D reverbs.

        When the listener is outside all of the reverbs, no reverb is applied.

        :py:meth:`set_reverb_properties` can be used to create an alternative
        reverb that can be used for 2D and background global reverb.

        To avoid this reverb interfering with the reverb slot used by the 3D
        reverb, 2D reverb should use a different slot id with
        :py:meth:`set_reverb_properties`, otherwise
        :py:attr:`~pyfmodex.structures.ADVANCEDSETTINGS.reverb3Dinstance` can
        also be used to place 3D reverb on a different physical reverb slot.

        Use :py:meth:`~pyfmodex.channel_control.ChannelControl.set_reverb_wet`
        to turn off reverb for 2D sounds (i.e. set wet = 0).

        Creating multiple reverb objects does not impact performance. These are
        'virtual reverbs'. There will still be only one physical reverb
        :py:class:`~pyfmodex.dsp.DSP` running that just morphs between the
        different virtual reverbs.

        Note about physical reverb :py:class:`~pyfmodex.dsp.DSP` unit
        allocation. To remove the :py:class:`~pyfmodex.dsp.DSP` unit and the
        associated CPU cost, first make sure all 3D reverb objects are
        released. Then call :py:meth:`set_reverb_properties` with the 3D
        reverb's slot ID (default is 0) with a property point of 0 or NULL, to
        signal that the physical reverb instance should be deleted.

        If a 3D reverb is still present, and :py:meth:`set_reverb_properties`,
        is called to free the physical reverb, the 3D reverb system will
        immediately recreate it upon the next :py:meth:`update` call.

        Note that the 3D reverb system will not affect Studio events unless it
        is explicitly enabled by setting
        :py:meth:`~pyfmodex.studio.event_instance.EventInstance.reverb_level`
        on each event instance.

        :returns: Newly created virtual reverb object.
        :rtype: Reverb3D
        """
        r_ptr = c_void_p()
        ckresult(_dll.FMOD_System_CreateReverb3D(self._ptr, byref(r_ptr)))
        return get_class("Reverb3D")(r_ptr)

    def create_sound(self, name_or_addr, mode=MODE.THREED, exinfo=None):
        """Load a sound into memory, open it for streaming or set it up for
        callback based sounds.

        :py:attr:`~pyfmodex.flags.MODE.CREATESAMPLE` will try to load and
        decompress the whole sound into memory, use
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM` to open it as a stream
        and have it play back in realtime from disk or another medium.
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE` can also be
        used for certain formats to play the sound directly in its compressed
        format from the mixer.

        To open a file or URL as a stream, so that it decompresses / reads at
        runtime, instead of loading / decompressing into memory all at the time
        of this call, use the :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`
        flag. To open a file or URL as a compressed sound effect that is not
        streamed and is not decompressed into memory at load time, use
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE.` This is
        supported with MPEG (mp2/mp3), ADPCM/FADPCM, XMA, AT9 and FSB Vorbis
        files only. This is useful for those who want realtime compressed
        soundeffects, but not the overhead of disk access. To open a sound as
        2D, so that it is not affected by 3D processing, use the
        :py:attr:`~pyfmodex.flags.MODE.TWOD` flag. 3D sound commands will be
        ignored on these types of sounds. To open a sound as 3D, so that it is
        treated as a 3D sound, use the :py:class:`~pyfmodex.flags.MODE.THREED`
        flag.

        Note that :py:attr:`~pyfmodex.flags.MODE.OPENRAW`,
        :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY`,
        :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT` and
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER` will not work here without
        the exinfo structure present, as more information is needed.

        Use :py:attr:`~pyfmodex.flags.MODE.NONBLOCKING` to have the sound open
        or load in the background. You can use
        :py:attr:`~pyfmodex.sound.Sound.open_state` to determine if it has
        finished loading / opening or not. While it is loading (not ready),
        sound functions are not accessible for that sound. Do not free memory
        provided with :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY` if the sound
        is not in a ready state, as it will most likely lead to a crash.

        To account for slow media that might cause buffer underrun (skipping /
        stuttering / repeating blocks of audio) with sounds created with
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM`, use
        :py:attr:`stream_buffer_size` to increase read ahead.

        Specifying :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT` will POINT
        to your memory rather allocating its own sound buffers and duplicating
        it internally, this means you cannot free the memory while FMOD is
        using it, until after :py:meth:`~pyfmodex.sound.Sound.release` is
        called.

        With :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT`, only PCM
        formats and compressed formats using
        :py:attr:`~pyfmodex.flags.MODE.CREATECOMPRESSEDSAMPLE` are supported.

        :param str name_or_addr: Name of the file or URL to open or a pointer
            to a preloaded sound memory block if
            :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY` /
            :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT` is used.
        :param MODE mode: Behavior modifier for opening the sound.
        :param CREATESOUNDEXINFO exinfo: Extended information for creating the
            sound.
        :returns: Newly created Sound object.
        :rtype: Sound
        """
        name_or_addr = prepare_str(name_or_addr)
        snd_ptr = c_void_p()
        if exinfo is not None:
            exinfo = byref(exinfo)
        ckresult(
            _dll.FMOD_System_CreateSound(
                self._ptr, name_or_addr, mode.value, exinfo, byref(snd_ptr)
            )
        )
        return get_class("Sound")(snd_ptr)

    def create_sound_group(self, name):
        """Create a SoundGroup object.

        A :py:class:`~pyfmodex.sound_group.SoundGroup` is a way to address
        multiple :py:class:`Sounds <pyfmodex.sound.Sound>` at once with group
        level commands, such as:

            - Attributes of :py:class:`Sounds <pyfmodex.sound.Sound>` that are
              playing or about to be played, such as volume. See
              (:py:attr:`~pyfmodex.sound_group.SoundGroup.volume`).
            - Control of playback, such as stopping :py:class:`Sounds
              <pyfmodex.sound.Sound>`. See
              (:py:meth:`~pyfmodex.sound_group.SoundGroup.stop`).
            - Playback behavior such as 'max audible', to limit playback of
              certain types of :py:class:`Sounds <pyfmodex.sound.Sound>`. See
              (:py:attr:`~pyfmodex.sound_group.SoundGroup.max_audible`).

        Once a :py:class:`~pyfmodex.sound_group.SoundGroup` is created,
        :py:attr:`~pyfmodex.sound.Sound.sound_group` is used to put a
        :py:class:`~pyfmodex.sound.Sound` in a
        :py:class:`~pyfmodex.sound_group.SoundGroup`.

        :param str name: Name of SoundGroup.
        :returns: Newly created group.
        :rtype: SoundGroup
        """
        name = prepare_str(name)
        sg_ptr = c_void_p()
        ckresult(_dll.FMOD_System_CreateSoundGroup(self._ptr, name, byref(sg_ptr)))
        return get_class("SoundGroup")(sg_ptr)

    def create_stream(self, name_or_addr, mode=MODE.THREED, exinfo=None):
        """Opens a sound for streaming.

        This is a convenience method for :py:meth:`create_sound` adding the
        :py:attr:`~pyfmodex.flags.MODE.CREATESTREAM` flag to the mode.

        A stream only has one decode buffer and file handle, and therefore can
        only be played once. It cannot play multiple times at once because it
        cannot share a stream buffer if the stream is playing at different
        positions. Open multiple streams to have them play concurrently.

        :param str name_or_addr: Name of the file or URL to open or a pointer
            to a preloaded sound memory block if
            :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY` /
            :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY_POINT` is used.
        :param MODE mode: Behavior modifier for opening the sound.
        :param CREATESOUNDEXINFO exinfo: Extended information while playing the
            sound.
        :returns: Newly created Sound object.
        :rtype: Sound
        """
        mode = mode | MODE.CREATESTREAM
        return self.create_sound(name_or_addr, mode, exinfo)

    def close(self):
        """Close the connection to the output and return to an uninitialized
        state without releasing the object.

        Closing renders objects created with this System invalid. Make sure any
        Sound, ChannelGroup, Geometry and DSP objects are released before
        calling this.

        All pre-initialize configuration settings will remain and the System
        can be reinitialized as needed.
        """
        ckresult(_dll.FMOD_System_Close(self._ptr))

    def detach_channel_group_from_port(self, group):
        """Disconnect the output of the specified ChannelGroup from an audio
        port on the output driver.

        Removing a ChannelGroup from a port will reroute the audio back to the
        main mix.

        :param ChannelGroup group: Group to detach the port from.
        """
        ckresult(_dll.FMOD_System_DetachChannelGroupFromPort(self._ptr, group._ptr))

    @property
    def num_3d_listeners(self):
        """The number of 3D listeners.

        :type: int
        """
        num = c_int()
        ckresult(_dll.FMOD_System_Get3DNumListeners(self._ptr, byref(num)))
        return num.value

    @num_3d_listeners.setter
    def num_3d_listeners(self, num):
        self._call_fmod("FMOD_System_Set3DNumListeners", num)

    @property
    def cpu_usage(self):
        """In percent of CPU time - the amount of CPU usage that FMOD is taking
        for streaming / mixing and updating combined.

        These numbers represent utilization of the core their thread runs on
        and not overall usage. The values are smoothed to provide a more stable
        readout.

        :type: Structobject with the following members:

            - :py:class:`~pyfmodex.dsp.DSP` mixing engine CPU usage (float)
            - Streaming engine CPU usage (float)
            - Geometry engine CPU usage (float)
            - :py:meth:`update` CPU usage (float)
            - Total CPU usage (float)
        """
        dsp = c_float()
        stream = c_float()
        geometry = c_float()
        update = c_float()
        total = c_float()
        ckresult(
            _dll.FMOD_System_GetCPUUsage(
                self._ptr,
                byref(dsp),
                byref(stream),
                byref(geometry),
                byref(update),
                byref(total),
            )
        )
        return so(
            dsp=dsp.value,
            stream=stream.value,
            geometry=geometry.value,
            update=update.value,
            total=total.value,
        )

    def get_channel(self, aaidee):
        """Retrieve a handle to a channel by ID.

        This method is mainly for getting handles to existing (playing)
        channels and setting their attributes. The only way to 'create' an
        instance of a channel for playback is to use :py:meth:`play_sound` or
        :py:meth:`play_dsp`.

        :param int aaidee: Index in the FMOD channel pool. Specify a channel
            number from 0 to the 'maxchannels' value specified in
            :py:meth:`init` minus 1.
        :returns: Requested channel.
        :rtype: Channel
        """
        c_ptr = c_void_p()
        ckresult(_dll.FMOD_System_GetChannel(self._ptr, aaidee, byref(c_ptr)))
        return get_class("Channel")(c_ptr)

    @property
    def channels_playing(self):
        """The number of currently playing channels.

        :type: Structobject with the following members:

            channels (int)
              Number of playing channels (both real and virtual).

            real_channels (int)
              Number of playing non-virtual channels.
        """
        channels = c_int()
        real = c_int()
        ckresult(
            _dll.FMOD_System_GetChannelsPlaying(self._ptr, byref(channels), byref(real))
        )
        return so(channels=channels.value, real_channels=real.value)

    @property
    def threed_settings(self):
        """The global doppler scale, distance factor and rolloff scale for all
        3D sounds.

        :type: ThreedSettings
        """
        dscale = c_float()
        distancefactor = c_float()
        rscale = c_float()
        ckresult(
            _dll.FMOD_System_Get3DSettings(
                self._ptr, byref(dscale), byref(distancefactor), byref(rscale)
            )
        )
        return ThreedSettings(
            self._ptr, distancefactor.value, dscale.value, rscale.value
        )

    @property
    def advanced_settings(self):
        """The advanced settings for the system object.

        :type: :py:class:`~pyfmodex.structures.ADVANCEDSETTINGS`
        """
        settings = ADVANCEDSETTINGS()
        ckresult(_dll.FMOD_System_GetAdvancedSettings(self._ptr, byref(settings)))
        return settings

    @advanced_settings.setter
    def advanced_settings(self, settings):
        ckresult(_dll.FMOD_System_SetAdvancedSettings(self._ptr, byref(settings)))

    @property
    def dsp_buffer_size(self):
        """The buffer size settings for the FMOD software mixing engine.

        To get the bufferlength in milliseconds, divide it by the output rate
        and multiply the result by 1000. For a bufferlength of 1024 and an
        output rate of 48khz (see :py:attr:`software_format`), milliseconds =
        1024 / 48000 * 1000 = 21.33ms. This means the mixer updates every
        21.33ms.

        To get the total buffer size, multiply the bufferlength by the
        numbuffers value. By default this would be 41024 = 4096 samples, or
        421.33ms = 85.33ms. This would generally be the total latency of the
        software mixer, but in reality due to one of the buffers being written
        to constantly, and the cursor position of the buffer that is audible,
        the latency is typically more like the (number of buffers - 1.5)
        multiplied by the buffer length.

        To convert from milliseconds back to 'samples', simply multiply the
        value in milliseconds by the sample rate of the output (i.e. 48000 if
        that is what it is set to), then divide by 1000.
        """
        size = c_uint()
        count = c_int()
        ckresult(
            _dll.FMOD_System_GetDSPBufferSize(self._ptr, byref(size), byref(count))
        )
        return DSPBufferSizeInfo(self._ptr, size.value, count.value)

    def get_dsp_info_by_plugin(self, handle):
        """The description structure for a pre-existing DSP plugin.

        :param handle: Handle to a pre-existing DSP plugin
            :py:meth:`get_plugin_handle`, or a new one loaded by
            :py:meth:`load_plugin`.
        :returns: Description structure for the DSP.
        :rtype: DSP_DESCRIPTION
        """
        desc = DSP_DESCRIPTION()
        self._call_fmod("FMOD_System_GetDSPInfoByPlugin", handle, byref(desc))
        return desc

    def get_default_mix_matrix(
        self, source_speaker_mode, target_speaker_mode, matrix_hop=0
    ):
        """Retrieve the default matrix used to convert from one speaker mode to
        another.

        The gain for source channel 's' to target channel 't' is matrix[t *
        matrix_hop + s].

        If 'sourcespeakermode' or 'targetspeakermode' is
        :py:attr:`~pyfmodex.enums.SPEAKERMODE.RAW` this method will raise an
        :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.INVALID_PARAM`.

        :param SPEAKERMODE source_speaker_mode: The speaker mode being
            converted from.
        :param SPEAKERMODE target_speaker_mode: The speaker mode being
            converted to.
        :param int matrix_hop: The number of source channels in the matrix. If
            this is 0, the number of source channels will be derived from
            `sourcespeakermode`. Maximum of
            :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH`.
        :returns: The output matrix. Its minimum size in number of floats must
            be the number of source channels multiplied by the number of target
            channels. Source and target channels cannot exceed
            :py:const:`~pyfmodex.constants.MAX_CHANNEL_WIDTH`.
        :rtype: list of list of floats
        """
        target_channels = self.get_speaker_mode_channels(target_speaker_mode)
        if matrix_hop:
            source_channels = matrix_hop
        else:
            source_channels = self.get_speaker_mode_channels(source_speaker_mode)
        matrix = (c_float * (source_channels * target_channels))()
        self._call_fmod(
            "FMOD_System_GetDefaultMixMatrix",
            source_speaker_mode.value,
            target_speaker_mode.value,
            matrix,
            matrix_hop,
        )
        return matrix

    @property
    def driver(self):
        """The output driver for the selected output type.

        0 represents the default for the output type.

        When an output type has more than one driver available, this property
        can be used to select between them.

        If this property is set after :py:meth:`init`, the current driver will
        be shutdown and the newly selected driver will be initialized /
        started.

        :type: int
        """
        driver = c_int()
        ckresult(_dll.FMOD_System_GetDriver(self._ptr, byref(driver)))
        return driver.value

    @driver.setter
    def driver(self, driver):
        ckresult(_dll.FMOD_System_SetDriver(self._ptr, driver))

    def get_driver_info(self, aaidee):
        """Retrieve identification information about a sound device specified
        by its index, and specific to the selected output mode.

        :param int aaidee: Index of the sound driver device.
        :rtype: Structobject with the following members:

            name (str)
              Name of the device.

            guid (GUID)
              GUID that uniquely identifies the device.

            system_rate (int)
              Sample rate this device operates at.

            speaker_mode (SPEAKERMODE)
              Speaker setup this device is currently using.

            speaker_mode_channels (int)
              Number of channels in the current speaker setup.

        """
        name = create_string_buffer(256)
        guid = GUID()
        system_rate = c_int()
        speaker_mode = c_int()
        channels = c_int()
        ckresult(
            _dll.FMOD_System_GetDriverInfo(
                self._ptr,
                aaidee,
                name,
                256,
                byref(guid),
                byref(system_rate),
                byref(speaker_mode),
                byref(channels),
            )
        )
        return so(
            name=name.value,
            guid=guid,
            system_rate=system_rate.value,
            speaker_mode=speaker_mode.value,
            speaker_mode_channels=channels.value,
        )

    @property
    def file_usage(self):
        """Information about file reads.

        The values are running totals that never reset.

        :type: Structobject with the following members:

            sample_bytes_read (int)
              Total bytes read from file for loading sample data.

            stream_bytes_read (int)
              Total bytes read from file for streaming sounds.

            other_bytes_read (int)
              Total bytes read for non-audio data such as FMOD Studio banks.
        """
        sample_bytes = c_longlong()
        stream_bytes = c_longlong()
        other_bytes = c_longlong()
        self._call_fmod(
            "FMOD_System_GetFileUsage",
            byref(sample_bytes),
            byref(stream_bytes),
            byref(other_bytes),
        )
        return so(
            sample_bytes_read=sample_bytes.value,
            stream_bytes_read=stream_bytes.value,
            other_bytes_read=other_bytes.value,
        )

    def get_geometry_occlusion(self, listener, source):
        """Calculate geometry occlusion between a listener and a sound
        source.

        If single sided polygons have been created, it is important to get the
        source and listener positions around the right way, as the occlusion
        from point A to point B may not be the same as the occlusion from point
        B to point A.

        :param list listener: The listener position.
        :param list source: The source position.
        :rtype: Structobject with the following members:

            direct
              Direct occlusion value. 0 = not occluded at all / full volume, 1
              = fully occluded / silent.

            reverb
              Reverb occlusion value. 0 = not occluded at all / wet, 1 = fully
              occluded / dry.
        """
        listener = VECTOR.from_list(listener)
        source = VECTOR.from_list(source)
        direct = c_float()
        reverb = c_float()
        ckresult(
            _dll.FMOD_System_GetGeometryOcclusion(
                self._ptr, byref(listener), byref(source), byref(direct), byref(reverb)
            )
        )
        return so(direct=direct.value, reverb=reverb.value)

    @property
    def geometry_max_world_size(self):
        """The maximum world size for the geometry engine from the centerpoint
        to the edge using the same units used in other 3D functions..

        FMOD uses an efficient spatial partitioning system to store polygons
        for ray casting purposes. The maximum size of the world should be set
        to allow processing within a known range. Outside of this range,
        objects and polygons will not be processed as efficiently. Excessive
        world size settings can also cause loss of precision and efficiency.

        Setting :py:attr:`geometry_max_world_size` should be done first before
        creating any geometry. It can be done any time afterwards but may be
        slow in this case.

        :type: float
        """
        wsize = c_float()
        ckresult(_dll.FMOD_System_GetGeometrySettings(self._ptr, byref(wsize)))
        return wsize.value

    @geometry_max_world_size.setter
    def geometry_max_world_size(self, size):
        ckresult(_dll.FMOD_System_SetGeometrySettings(self._ptr, c_float(size)))

    @property
    def master_channel_group(self):
        """The master ChannelGroup that all sounds ultimately route to.

        This is the default Channel Group that channels play on, unless a
        different Channel Group is specified with :py:meth:`play_sound`,
        :py:meth:`play_dsp` or
        :py:attr:`~pyfmodex.channel.Channel.channel_group`.

        A master channel group can be used to do things like set the 'master
        volume' for all playing Channels. See
        :py:attr:`~pyfmodex.channel_control.ChannelControl.volume`.

        :type: ChannelGroup
        """
        grp_ptr = c_void_p()
        ckresult(_dll.FMOD_System_GetMasterChannelGroup(self._ptr, byref(grp_ptr)))
        return get_class("ChannelGroup")(grp_ptr)

    @property
    def master_sound_group(self):
        """The default SoundGroup, where all sounds are placed when they are
        created.

        If a :py:class:`~pyfmodex.sound_group.SoundGroup` is released, the
        :py:class:`Sound <pyfmodex.sound.Sound>` will be put back into this
        :py:class:`~pyfmodex.sound_group.SoundGroup`.

        :type: SoundGroup
        """
        grp_ptr = c_void_p()
        ckresult(_dll.FMOD_System_GetMasterSoundGroup(self._ptr, byref(grp_ptr)))
        return get_class("SoundGroup")(grp_ptr)

    def get_nested_plugin(self, handle, index):
        """Retrieve the handle of a nested plugin.

        This method is used to iterate handles for plugins that have a list of
        definitions.

        Most plugins contain a single definition. If this is the case, only
        index 0 is valid, and the returned handle is the same as the handle
        passed in.

        :param handle: Handle obtained from :py:meth:`load_plugin`.
        :param int index: Index into the list of plugin definitions.
        :returns: Handle used to represent the nested plugin.
        :type: int
        """
        nested = c_uint()
        self._call_fmod("FMOD_System_GetNestedPlugin", handle, index, byref(nested))
        return nested.value

    @property
    def network_proxy(self):
        """The URL of the proxy server used in Internet streaming.

        Specify the proxy in host:port format e.g. www.fmod.com:8888 (defaults
        to port 80 if no port is specified).

        Basic authentication is supported using user:password@host:port format
        e.g. bob:sekrit123@www.fmod.com:8888

        :type: str
        """
        server = create_string_buffer(256)
        ckresult(
            _dll.FMOD_System_GetNetworkProxy(self._ptr, byref(server), sizeof(server))
        )
        return server.value

    @network_proxy.setter
    def network_proxy(self, proxy):
        proxy = prepare_str(proxy)
        ckresult(_dll.FMOD_System_SetNetworkProxy(self._ptr, proxy))

    @property
    def network_timeout(self):
        """The timeout for network streams in milliseconds.

        :type: int
        """
        timeout = c_int()
        ckresult(_dll.FMOD_System_GetNetworkTimeout(self._ptr, byref(timeout)))
        return timeout.value

    @network_timeout.setter
    def network_timeout(self, timeout):
        ckresult(_dll.FMOD_System_SetNetworkTimeout(self._ptr, timeout))

    @property
    def num_drivers(self):
        """The number of output drivers available for the selected output
        type.

        If :py:attr:`output` has not been set, this property will contain the
        number of drivers available for the default output type. A possible use
        for this function is to iterate through available sound devices for the
        current output type, and use :py:meth:`get_driver_info` to get the
        device's name and other attributes.

        :rtype: int
        """
        num = c_int()
        ckresult(_dll.FMOD_System_GetNumDrivers(self._ptr, byref(num)))
        return num.value

    def get_num_nested_plugins(self, handle):
        """Retrieve the number of nested plugins from the selected plugin.

        :param handle: Handle obtained from :py:meth:`load_plugin`.
        :returns: Returned number of plugins.
        :rtype: int

        Most plugins contain a single definition, in which case the count is
        one, however some have a list of definitions. This function returns the
        number of plugins that have been defined.
        """
        num = c_int()
        self._call_fmod("FMOD_System_GetNumNestedPlugins", handle, byref(num))
        return num.value

    def get_num_plugins(self, plugintype):
        """Retrieve the number of loaded plugins.

        :param PLUGINTYPE plugintype: Plugin type.
        :returns: Number of loaded plugins for the selected `plugintype`.
        """
        num = c_int()
        ckresult(
            _dll.FMOD_System_GetNumPlugins(self._ptr, plugintype.value, byref(num))
        )
        return num.value

    @property
    def output(self):
        """The type of output interface used to run the mixer.

        :type: OUTPUTTYPE

        This property is typically set to select between different OS specific
        audio APIs which may have different features.

        It is only necessary to set this property if you want to specifically
        switch away from the default output mode for the operating system. The
        most optimal mode is selected by default for the operating system.

        (Windows Only) This property can be set after :py:meth:`init` to
        perform special handling of driver disconnections, see
        :py:data:`~pyfmodex.callback_prototypes.OUTPUT_DEVICELISTCHANGED_CALLBACK`.

        When using the Studio API, switching to an NRT (non-realtime) output
        type after FMOD is already initialized will not behave correctly unless
        the Studio API was initialized with
        :py:attr:`~pyfmodex.studio.flags.STUDIO_INIT_FLAGS.SYNCHRONOUS_UPDATE`.
        """
        output = c_int()
        ckresult(_dll.FMOD_System_GetOutput(self._ptr, byref(output)))
        return OUTPUTTYPE(output.value)

    @output.setter
    def output(self, out):
        ckresult(_dll.FMOD_System_SetOutput(self._ptr, out.value))

    @property
    def output_by_plugin(self):
        """The plugin handle for the currently selected output type.

        :type: int

        (Windows Only) This property can be set after FMOD is already
        initialized. You can use it to change the output mode at runtime. If
        :py:data:`~pyfmodex.callback_prototypes.OUTPUT_DEVICELISTCHANGED_CALLBACK`
        is specified use the :py:attr:`output` property to change to
        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.NOSOUND` if no more sound card
        drivers exist.
        """
        handle = c_uint()
        ckresult(_dll.FMOD_System_GetOutputByPlugin(self._ptr, byref(handle)))
        return handle.value

    @output_by_plugin.setter
    def output_by_plugin(self, handle):
        ckresult(_dll.FMOD_System_SetOutputByPlugin(self._ptr, handle))

    @property
    def output_handle(self):
        """An output type specific internal native interface.

        Interpret the handle based on the selected output type, if there is
        one:

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WAVWRITER`
          Pointer to stdio FILE is returned.

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WAVWRITER_NRT`
          Pointer to stdio FILE is returned.

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WASAPI`
          Pointer to type IAudioClient is returned.

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.ALSA`
          Pointer to type snd_pcm_t is returned.

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.COREAUDIO`
          Handle of type AudioUnit is returned.

        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.AUDIOOUT`
          Pointer to type int is returned. Handle returned from sceAudioOutOpen.
        """
        handle = c_void_p()
        ckresult(_dll.FMOD_System_GetOutputHandle(self._ptr, byref(handle)))
        return handle.value

    def get_plugin_handle(self, plugintype, index):
        """Retrieve the handle of a plugin based on its plugintype and relative
        index.

        :param PLUGINTYPE plugintype: Plugin type.
        :param int index: Index in the list of plugins for the given
            `plugintype`.
        :returns: Handle used to represent the plugin.
        :rtype: int

        All plugins whether built in or loaded can be enumerated using this and
        :py:meth:`get_num_plugins`.
        """
        handle = c_uint()
        ckresult(
            _dll.FMOD_System_GetPluginHandle(
                self._ptr, plugintype.value, index, byref(handle)
            )
        )
        return handle.value

    def get_plugin_info(self, handle):
        """Retrieve information for the selected plugin.

        :param int handle: Handle to an already loaded plugin.
        :rtype: Structobject with the following members:

            type (PLUGINTYPE)
              Plugin type.

            name (str)
              Name of the plugin.

            version (int)
              Version number of the plugin.
        """
        plugin_type = c_int()
        name = create_string_buffer(256)
        ver = c_uint()
        ckresult(
            _dll.FMOD_System_GetPluginInfo(
                self._ptr, handle, byref(plugin_type), byref(name), 256, byref(ver)
            )
        )
        return so(
            type=PLUGINTYPE(plugin_type.value), name=name.value, version=ver.value
        )

    def get_record_driver_info(self, index):
        """Retrieve identification information about a sound device specified
        by its index, and specific to the output mode.

        :param int index: Index of the recording device.
        :rtype: Structobject with the following members:

            name (str)
              Name of the device.

            guid (GUID)
              GUID that uniquely identifies the device.

            system_rate (int)
              Sample rate the device operates at.

            speaker_mode (SPEAKERMODE)
              Speaker configuration the device is currently using.

            channels (int)
              Number of channels in the current speaker setup.

            state (DRIVER_STATE)
              Flags that provide additional information about the driver.
        """
        name = create_string_buffer(256)
        guid = GUID()
        system_rate = c_int()
        speaker_mode = c_int()
        channels = c_int()
        state = c_int()
        ckresult(
            _dll.FMOD_System_GetRecordDriverInfo(
                self._ptr,
                index,
                byref(name),
                sizeof(name),
                byref(guid),
                byref(system_rate),
                byref(speaker_mode),
                byref(channels),
                byref(state),
            )
        )
        return so(
            name=name.value,
            guid=guid,
            system_rate=system_rate.value,
            speaker_mode=speaker_mode.value,
            speaker_mode_channels=channels.value,
            state=state.value,
        )

    @property
    def record_num_drivers(self):
        """The number of recording devices available for this output mode. Use
        this to enumerate all recording devices possible so that the user can
        select one.

        :type: Structobject with the following members:

            drivers (int)
              Number of recording drivers available for this output mode.

            connected (int)
              Number of recording driver currently plugged in.
        """
        num = c_int()
        connected = c_int()
        ckresult(
            _dll.FMOD_System_GetRecordNumDrivers(
                self._ptr, byref(num), byref(connected)
            )
        )
        return so(drivers=num.value, connected=connected.value)

    def get_record_position(self, index):
        """Retrieve the current recording position of the record buffer in PCM
        samples.

        :param int index: Index of the recording device.
        :returns: Current recording position.
        :rtype: int

        This method will raise an :py:exc:`~pyfmodex.exceptions.FmodError` with
        code :py:attr:`~pyfmodex.enums.RESULT.RECORD_DISCONNECTED` if the
        driver is unplugged.

        The position will be 0 when :py:meth:`record_stop` is called or when a
        non-looping recording reaches the end.

        PS4 specific note: Record devices are virtual so the position will
        continue to update if the device is unplugged (the OS is generating
        silence). This method will still raise an
        :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.RECORD_DISCONNECTED` for your
        information though.
        """
        pos = c_uint()
        ckresult(_dll.FMOD_System_GetRecordPosition(self._ptr, index, byref(pos)))
        return pos.value

    def get_reverb_properties(self, instance=0):
        """Retrieve the current reverb environment for the specified reverb
        instance.

        :param int instance: Index of the particular reverb instance to target.
        :returns: Current reverb environment description.
        :rtype: REVERB_PROPERTIES
        """
        props = REVERB_PROPERTIES()
        props.Instance = instance
        ckresult(
            _dll.FMOD_System_GetReverbProperties(self._ptr, instance, byref(props))
        )
        return props

    def set_reverb_properties(self, instance, props):
        """Set parameters for the global reverb environment.

        :param int instance: Index of the particular reverb instance to target.
        :param REVERB_PROPERTIES props: Reverb environment description. Passing
            0 or None will delete the physical reverb.

        To assist in defining reverb properties there are several presets
        available, see :py:class:`~pyfmodex.reverb_presets.REVERB_PRESET`.

        When using each instance for the first time, FMOD will create a
        physical SFX reverb DSP unit that takes up several hundred kilobytes of
        memory and some CPU.
        """
        self._call_fmod("FMOD_System_SetReverbProperties", instance, byref(props))

    @property
    def software_channels(self):
        """The current maximum number of software mixed channels possible.

        This is the maximum number of mixable voices to be allocated by FMOD.

        This property cannot be set after FMOD is already activated, it must be
        called before :py:meth:`init` or after :py:meth:`close`.

        :type: int
        """
        channels = c_int()
        ckresult(_dll.FMOD_System_GetSoftwareChannels(self._ptr, byref(channels)))
        return channels.value

    @software_channels.setter
    def software_channels(self, num):
        ckresult(_dll.FMOD_System_SetSoftwareChannels(self._ptr, num))

    @property
    def software_format(self):
        """The output format for the software mixer.

        :type: Structobject with the following members:

            sample_rate (int)
              Sample rate of the mixer.

            speaker_mode (:py:attr:`~pyfmodex.enums.SPEAKERMODE`)
            Speaker setup of the mixer. 

            raw_speakers (int)
              Number of speakers when using speaker_mode
              :py:attr:`~pyfmodex.enums.SPEAKERMODE.RAW`.

        If loading Studio banks, this must be called with `speaker_mode`
        corresponding to the project output format if there is a possibility of
        the output audio device not matching the project format. Any
        differences between the project format and `speaker_mode` will cause
        the mix to sound wrong.

        By default `speaker_mode` will assume the setup the OS / output
        prefers.

        Altering the `sample_rate` from the OS / output preferred rate may
        incur extra latency. Altering the `speaker_mode` from the OS / output
        preferred mode may cause an upmix/downmix which can alter the sound.

        On lower power platforms such as mobile `sample_rate` will default to
        24KHz to reduce CPU cost.

        This property must be set before before :py:meth:`init` or after
        :py:meth:`close`.
        """
        rate = c_int()
        mode = c_int()
        speakers = c_int()
        self._call_fmod(
            "FMOD_System_GetSoftwareFormat", byref(rate), byref(mode), byref(speakers)
        )
        return so(
            sample_rate=rate.value,
            speaker_mode=SPEAKERMODE(mode.value),
            raw_speakers=speakers.value
        )

    @software_format.setter
    def software_format(self, soft_format):
        self._call_fmod(
            "FMOD_System_SetSoftwareFormat",
            soft_format.sample_rate,
            soft_format.speaker_mode.value,
            soft_format.raw_speakers,
        )

    def get_speaker_mode_channels(self, mode):
        """Retrieve the channel count for a given speaker mode.

        :param SPEAKERMODE mode: Speaker mode to query.
        :returns: Number of channels.
        :rtype: int
        """
        channels = c_int()
        self._call_fmod(
            "FMOD_System_GetSpeakerModeChannels", mode.value, byref(channels)
        )
        return channels.value

    def get_speaker_position(self, speaker):
        """Retrieve the position of the specified speaker for the current
        speaker mode.

        :param SPEAKER speaker: Speaker.
        :returns: Structobject with the following members:

            x (float)
              2D X position relative to the listener. -1 = left, 0 = middle, +1
              = right.

            y (float)
                2D Y position relative to the listener. -1 = back, 0 = middle,
                +1 = front.

            active (bool)
                Active state of a speaker. True = included in 3D calculations,
                False = ignored.
        """
        pos_x = c_float()
        pos_y = c_float()
        active = c_bool()
        self._call_fmod(
            "FMOD_System_GetSpeakerPosition",
            speaker.value,
            byref(pos_x),
            byref(pos_y),
            byref(active),
        )
        return so(x=pos_x.value, y=pos_y.value, active=active.value)

    def set_speaker_position(self, speaker, pos):
        """Set the position of the specified speaker for the current speaker
        mode.

        This method allows the user to specify the position of their speaker to
        account for non standard setups. It also allows the user to disable
        speakers from 3D consideration in a game.

        :param SPEAKER speaker: Speaker.
        :param pos: Something with `x`, `y` and `active` keys containing values
            as follows:

            x (float)
              2D X position relative to the listener. -1 = left, 0 = middle, +1
              = right.

            y (float)
                2D Y position relative to the listener. -1 = back, 0 = middle,
                +1 = front.

            active (bool)
                Active state of a speaker. True = included in 3D calculations,
                False = ignored.

        This allows you to customize the position of the speakers for the
        current :py:class:`~pyfmodex.enums.SPEAKERMODE` by giving X (left to
        right) and Y (front to back) coordinates.

        When disabling a speaker, 3D spatialization will be redistributed
        around the missing speaker so signal isn't lost.

        Setting :py:attr:`software_format` will override any customization made
        with this function.

        Users of the Studio API should be aware this function does not affect
        the speaker positions used by the Spatializer DSPs, it is purely for
        Core API spatialization via
        :py:attr:`~pyfmodex.channel_control.ChannelControl.position`.
        """
        self._call_fmod(
            "FMOD_System_SetSpeakerPosition",
            speaker.value,
            c_float(pos.x),
            c_float(pos.y),
            pos.active,
        )

    @property
    def stream_buffer_size(self):
        """The default file buffer size for newly opened streams.

        :type: Structobject with the following members:

            size (int)
              Buffer size.

            unit (TIMEUNIT)
              Type of units for `size`.

        Valid units for `unit` are

            - :py:attr:`~pyfmodex.flags.TIMEUNIT.MS`
            - :py:attr:`~pyfmodex.flags.TIMEUNIT.PCM`
            - :py:attr:`~pyfmodex.flags.TIMEUNIT.PCMBYTES`
            - :py:attr:`~pyfmodex.flags.TIMEUNIT.RAWBYTES`

        Larger values will consume more memory, whereas smaller values may
        cause buffer under-run / starvation / stuttering caused by large delays
        in disk access (ie netstream), or CPU usage in slow machines, or by
        trying to play too many streams at once.

        Does not affect streams created with
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER`, as the buffer size is
        specified in :py:meth:`create_sound`.

        Does not affect latency of playback. All streams are pre-buffered
        (unless opened with :py:attr:`~pyfmodex.flags.MODE.OPENONLY`), so
        they will always start immediately.

        Seek and Play operations can sometimes cause a reflush of this buffer.

        If :py:attr:`~pyfmodex.flags.TIMEUNIT.RAWBYTES` is used, the memory
        allocated is two times the size passed in, because fmod allocates a
        double buffer.

        If :py:attr:`~pyfmodex.flags.TIMEUNIT.MS`,
        :py:attr:`~pyfmodex.flags.TIMEUNIT.PCM` or
        :py:attr:`~pyfmodex.flags.TIMEUNIT.PCMBYTES` is used, and the stream is
        infinite (such as a shoutcast netstream), or VBR, then FMOD cannot
        calculate an accurate compression ratio to work with when the file is
        opened. This means it will then base the buffersize on
        :py:attr:`~pyfmodex.flags.TIMEUNIT.PCMBYTES`, or in other words the
        number of PCM bytes, but this will be incorrect for some compressed
        formats. Use :py:attr:`~pyfmodex.flags.TIMEUNIT.RAWBYTES` for these
        type (infinite / undetermined length) of streams for more accurate read
        sizes.

        To determine the actual memory usage of a stream, including sound
        buffer and other overhead, use
        :py:meth:`~pyfmodex.fmodex.get_memory_stats` before and after creating
        a sound.

        Stream may still stutter if the codec uses a large amount of cpu time,
        which impacts the smaller, internal 'decode' buffer. The decode buffer
        size is changeable via
        :py:class:`~pyfmodex.structure_declarations.CREATESOUNDEXINFO`.
        """
        size = c_uint()
        unit = c_int()
        self._call_fmod("FMOD_System_GetStreamBufferSize", byref(size), byref(unit))
        return so(size=size.value, unit=TIMEUNIT(unit.value))

    @stream_buffer_size.setter
    def stream_buffer_size(self, size):
        self._call_fmod("FMOD_System_SetStreamBufferSize", size.size, size.unit.value)

    def init(self, maxchannels=1000, flags=INIT_FLAGS.NORMAL, extra=None):
        """Initialize the system object and prepare FMOD for playback.

        :param int maxchannels: Maximum number of
            :py:class:`~pyfmodex.channel.Channel` objects available for
            playback, also known as virtual channels. Virtual channels will
            play with minimal overhead, with a subset of 'real' voices that are
            mixed, and selected based on priority and audibility.
        :param INIT_FLAGS flags: Initialization flags. More than one mode can
            be set at once by combining them with the OR operator.
        :param extra: Additional output specific initialization data. This will
            be passed to the output plugin. See
            :py:class:`~pyfmodex.enums.OUTPUTTYPE` for descriptions of data
            that can be passed in, based on the selected output mode.

        Most API functions require an initialized System object before they
        will succeed, otherwise they will raise an
        :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.UNINITIALIZED`. Some can only be can
        only be called before initialization. These are:

            - :py:meth:`~pyfmodex.fmodex.initialize_memory`
            - setting :py:attr:`software_format`
            - setting :py:attr:`software_channels`
            - setting :py:attr:`dsp_buffer_size`

        :py:attr:`output` / :py:attr:`output_by_plugin` can be set before or
        after :py:meth:`init` on Android, GameCore, UWP, Windows and Mac. Other
        platforms can only call this before :py:meth:`init`.
        """
        ckresult(_dll.FMOD_System_Init(self._ptr, maxchannels, flags.value, extra))

    def is_recording(self, aaidee):
        """Retrieve the state of the FMOD recording API, ie if it is currently
        recording or not.

        :param int aaidee: Index of the recording device.
        :returns: Recording state. True = system is recording, False = system
            is not recording.
        :rtype: bool

        Recording can be started with :py:meth:`record_start` and stopped with
        :py:meth:`record_stop`.

        will raise an
        :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.RECORD_DISCONNECTED` if the driver is
        unplugged.

        PS4 specific note: Record devices are virtual so
        :py:meth:`is_recording` would continue to report True if the device is
        unplugged (the OS is generating silence). This method will raise an
        :py:exc:`~pyfmodex.exceptions.FmodError` with code
        :py:attr:`~pyfmodex.enums.RESULT.RECORD_DISCONNECTED` for your
        information though.
        """
        rec = c_int()
        ckresult(_dll.FMOD_System_IsRecording(self._ptr, aaidee, byref(rec)))
        return rec.value

    def load_geometry(self, data):
        """Create a geometry object from a block of memory which contains
        pre-saved geometry data.

        This function avoids the need to manually create and add geometry for
        faster start time.

        :param data: Pre-saved geometry data from
            :py:meth:`~pyfmodex.geometry.Geometry.save`.
        :returns: Newly created geometry object.
        :rtype: Geometry
        """
        cdata = create_string_buffer(data)
        print(len(data))
        geo_ptr = c_void_p()
        ckresult(
            _dll.FMOD_System_LoadGeometry(self._ptr, cdata, len(data), byref(geo_ptr))
        )
        return get_class("Geometry")(geo_ptr)

    def load_plugin(self, filename, priority):
        """Load an FMOD (DSP, Output or Codec) plugin from file.

        :param str filename: Path to the plugin file.
        :param int priority: Codec load priority where 0 represents most
            important and higher numbers represent less importance.
            For :py:attr:`~pyfmodex.enums.PLUGINTYPE.CODEC` only.
        :returns: Handle used to represent the plugin.
        :rtype: int

        Once loaded DSP plugins can be used via
        :py:meth:`create_dsp_by_plugin`, output plugins can be use via
        :py:attr:`output_by_plugin` and codec plugins will be used
        automatically.

        When opening a file each codec tests whether it can support the file
        format in priority order.

        The format of the plugin is dependant on the operating system:

            - Windows / UWP / Xbox One: .dll
            - Linux / Android: .so
            - Macintosh: .dylib
            - PS4: .prx
        """
        filename = prepare_str(filename)
        handle = c_uint()
        ckresult(
            _dll.FMOD_System_LoadPlugin(self._ptr, filename, byref(handle), priority)
        )
        return handle.value

    def lock_dsp(self):
        """Mutual exclusion function to lock the FMOD DSP engine (which runs
        asynchronously in another thread), so that it will not execute.

        If the FMOD DSP engine is already executing, this method will block
        until it has completed.

        The method may be used to synchronize DSP network operations carried
        out by the user.

        An example of using this function may be for when the user wants to
        construct a DSP sub-network, without the DSP engine executing in the
        background while the sub-network is still under construction.

        Once the user no longer needs the DSP engine locked, it must be
        unlocked with :py:meth:`unlock_dsp`.

        Note that the DSP engine should not be locked for a significant amount
        of time, otherwise inconsistency in the audio output may result. (audio
        skipping / stuttering).
        """
        ckresult(_dll.FMOD_System_LockDSP(self._ptr))

    def mixer_resume(self):
        """Resume mixer thread and reacquire access to audio hardware.

        Used on mobile platforms when entering the foreground after being
        suspended.

        All internal state will resume, i.e. created sound and channels are
        still valid and playback will continue.

        Android specific: Must be called on the same thread as
        :py:meth:`mixer_suspend`.

        HTML5 specific: Used to start audio from a user interaction event, like
        a mouse click or screen touch event. Without this call audio may not
        start on some browsers.
        """
        self._call_fmod("FMOD_System_MixerResume")

    def mixer_suspend(self):
        """Suspend mixer thread and relinquish usage of audio hardware while
        maintaining internal state.

        Used on mobile platforms when entering a backgrounded state to reduce
        CPU to 0%.

        All internal state will be maintained, i.e. created sound and channels
        will stay available in memory.
        """
        self._call_fmod("FMOD_System_MixerSuspend")

    def play_dsp(self, dsp, channel_group=None, paused=False):
        """Plays a DSP along with any of its inputs on a Channel.

        :param DSP dsp: Unit to play.
        :param ChannelGroup channel_group: Group to output to instead of the
            master.
        :param bool paused: Whether to start in the paused state. Start a
            Channel paused to allow altering attributes without it being
            audible, then follow it up with setting
            :py:attr:`~pyfmodex.channel_control.ChannelControl.paused` to
            False.
        :returns: Newly playing channel.
        :rtype: Channel

        Specifying a `channel_group` is more efficient than setting
        :py:attr:`~pyfmodex.channel.Channel.channel_group` afterwards, and
        could avoid audible glitches if the Channel is not in a paused state.

        Channels are reference counted to handle dead or stolen Channel
        handles.

        Playing more sounds or dsps than physical channels allow is handled
        with virtual channels.
        """
        check_type(dsp, get_class("DSP"))
        if channel_group:
            check_type(channel_group, get_class("ChannelGroup"))
            group_ptr = channel_group._ptr
        else:
            group_ptr = None
        c_ptr = c_void_p()
        self._call_fmod(
            "FMOD_System_PlayDSP", dsp._ptr, group_ptr, paused, byref(c_ptr)
        )
        return get_class("Channel")(c_ptr)

    def play_sound(self, snd, channel_group=None, paused=False):
        """Play a Sound on a Channel.

        :param Sound snd: Sound to play.
        :param ChannelGroup channel_group: Group to output to instead of the
            master.
        :param bool paused: Whether to start in the paused state. Start a
            Channel paused to allow altering attributes without it being
            audible, then follow it up with setting
            :py:attr:`~pyfmodex.channel_control.ChannelControl.paused` to
            False.
        :returns: Newly playing channel.
        :rtype: Channel

        When a sound is played, it will use the sound's default frequency and
        priority. See :py:attr:`~pyfmodex.sound.Sound.frequency`.

        A sound defined as :py:attr:`~pyfmodex.flags.MODE.THREED` will by
        default play at the 3D position of the listener. To set the 3D position
        of the Channel before the sound is audible, start the channel paused by
        setting the `paused` parameter to True, and set
        :py:attr:`~pyfmodex.channel_control.ChannelControl.position`.

        Specifying a `channel_group` is more efficient than setting
        :py:attr:`~pyfmodex.channel.Channel.channel_group` afterwards, and
        could avoid audible glitches if the Channel is not in a paused state.

        Channels are reference counted to handle dead or stolen Channel
        handles.

        Playing more sounds or dsps than physical channels allow is handled
        with virtual channels.
        """
        check_type(snd, get_class("Sound"))
        if channel_group:
            check_type(channel_group, get_class("ChannelGroup"))
            group_ptr = channel_group._ptr
        else:
            group_ptr = None
        c_ptr = c_void_p()
        ckresult(
            _dll.FMOD_System_PlaySound(
                self._ptr, snd._ptr, group_ptr, paused, byref(c_ptr)
            )
        )
        return get_class("Channel")(c_ptr)

    def record_start(self, aaidee, snd, loop=False):
        """Start the recording engine recording to a pre-created Sound object.

        :param int aaidee: Index of the recording device.
        :param Sound snd: User created sound for the user to record to.
        :param bool loop: Flag to tell the recording engine whether to continue
            recording to the provided sound from the start again, after it has
            reached the end. If this is set to True the data will be
            continually be overwritten once every loop.
        :raises FmodError: with code
            :py:attr:`~pyfmodex.enums.RESULT.RECORD_DISCONNECTED` if the driver
            is unplugged.

        Sound must be created as :py:attr:`~pyfmodex.flags.MODE.CREATESAMPLE`.
        Raw PCM data can be accessed with
        :py:meth:`~pyfmodex.sound.Sound.lock`,
        :py:meth:`~pyfmodex.sound.Sound.unlock` and
        :py:meth:`get_record_position`.

        Recording from the same driver a second time will stop the first
        recording.

        For lowest latency set the :py:class:`~pyfmodex.sound.Sound` sample
        rate to the rate returned by :py:meth:`get_record_driver_info`,
        otherwise a resampler will be allocated to handle the difference in
        frequencies, which adds latency.
        """
        check_type(snd, get_class("Sound"))
        ckresult(_dll.FMOD_System_RecordStart(self._ptr, aaidee, snd._ptr, loop))

    def record_stop(self, aaidee):
        """Stop the recording engine from recording to a pre-created Sound
        object.

        :param int aaidee: Index of the recording device.

        Doesn't raise an exception if unplugged or already stopped.
        """
        ckresult(_dll.FMOD_System_RecordStop(self._ptr, aaidee))

    def register_codec(self, description, priority):
        """Register a Codec plugin description structure for later use.

        :param CODEC_DESCRIPTION description: Structure describing the Codec to
            register.
        :param int priority: Codec load priority where 0 represents most
            important and higher numbers represent less importance.
        :returns: Handle used to represent the plugin.
        :rtype: int

        To create an instances of this plugin use :py:meth:`create_sound` or
        :py:meth:`create_stream`.

        When opening a file each Codec tests whether it can support the file
        format in `priority` order.
        """
        handle = c_uint()
        self._call_fmod(
            "FMOD_System_RegisterCodec", byref(description), byref(handle), priority
        )
        return handle.value

    def register_dsp(self, description):
        """Register a DSP plugin description structure for later use.

        :param DSP_DESCRIPTION description: Structure describing the DSP to
            register.
        :returns: Handle used to represent the plugin.
        :rtype: int

        To create an instances of this plugin use
        :py:meth`create_dsp_by_plugin`.
        """
        handle = c_uint()
        self._call_fmod("FMOD_System_RegisterDSP", byref(description), byref(handle))
        return handle.value

    def register_output(self, description):
        """Register an Output plugin description structure for later use.

        :param OUTPUT_DESCRIPTION description: Structure describing the Output
            to register.
        :returns: Handle used to represent the plugin.
        :rtype: int

        To select this plugin for output set :py:attr:`output_by_plugin`.
        """
        handle = c_uint()
        self._call_fmod("FMOD_System_RegisterOutput", byref(description), byref(handle))
        return handle.value

    def release(self):
        """Close and free this object and its resources.

        This will internally call :py:meth:`close`, so calling :py:meth:`close`
        before this function is not necessary.
        """
        ckresult(_dll.FMOD_System_Release(self._ptr))

    def set_3d_rolloff_callback(self, callback):
        """Set a callback to allow custom calculation of distance
        attenuation.

        :param callable callback: Custom callback. Set to 0 or None to return
            control of distance attenuation to FMOD.

        This method overrides
        :py:attr:`~pyfmodex.flags.MODE.THREED_INVERSEROLLOFF`,
        :py:attr:`~pyfmodex.flags.MODE.THREED_LINEARROLLOFF`,
        :py:attr:`~pyfmodex.flags.MODE.THREED_LINEARSQUAREROLLOFF`,
        :py:attr:`~pyfmodex.flags.MODE.THREED_INVERSETAPEREDROLLOFF` and
        :py:attr:`~pyfmodex.flags.MODE.THREED_CUSTOMROLLOFF`.
        """
        callback = ROLLOFF_CALLBACK(callback or 0)
        self._rolloff_callback = callback
        ckresult(_dll.FMOD_System_Set3DRolloffCallback(self._ptr, callback))

    def set_callback(self, callback, callback_mask):
        """Set the callback for System level notifications.

        :param callable callback: Callback to invoke when system notification
            happens.
        :param SYSTEM_CALLBACK_TYPE callback_mask: Bitfield specifying which
            callback types are required, to filter out unwanted callbacks.

        System callbacks can be called by a variety of FMOD threads, so make
        sure any code executed inside the callback is thread safe.
        """
        callback = SYSTEM_CALLBACK(callback or 0)
        self._system_callbacks[callback_mask] = callback
        ckresult(_dll.FMOD_System_SetCallback(self._ptr, callback, callback_mask.value))

    def set_file_system(  # pylint: disable=too-many-arguments
        self,
        user_open,
        user_close,
        user_read,
        user_seek,
        user_async_read,
        user_async_cancel,
        block_align=-1,
    ):
        """Set callbacks to implement all file I/O instead of using the
        platform native method.

        :param callable user_open: Callback for opening a file.
        :param callable user_close: Callback for closing a file.
        :param callable user_read: Callback for reading from a file, instead of
            `user_async_read` and `user_async_cancel`.
        :param callable user_seek: Callback for seeking within a file, instead
            of `user_async_read` and `user_async_cancel`.
        :param callable user_async_read: Callback for reading and seeking
            asynchronously, instead of `user_read` and `user_seek`.
        :param callable user_async_cancel: Callback for cancelling a previous
            `user_async_read` call.
        :param int block_align: File buffering chunk size, specify -1 to keep
            system default or previously set value. 0 = disable buffering.

        Setting these callbacks have no effect on sounds loaded with
        :py:attr:`~pyfmodex.flags.MODE.OPENMEMORY` or
        :py:attr:`~pyfmodex.flags.MODE.OPENUSER`.

        There are three valid configurations for this function:

            #. Set `user_open`, `user_close`, `user_read`, `user_seek` and
               optionally blockalign for blocking file I/O.
            #. Set `user_open`, `user_close`, `user_async_read`,
               `user_async_cancel` and optionally blockalign for asynchronous
               file I/O.
            #. Set block_align by itself with everything else null, to change
               platform native file I/O buffering.

        Setting block_align to 0 will disable file buffering and cause every
        read to invoke the relevant callback (not recommended), current default
        is tuned for memory usage vs performance. Be mindful of the I/O
        capabilities of the platform before increasing this default.

        Asynchronous file access via `user_async_read`/ userasync_canel:

            - it is recommended to consult the 'asyncio' example for reference
              implementation.
            - `user_async_read` allows the user to return immediately before
              the data is ready. FMOD will either wait internally (see note
              below about thread safety), or continuously check in the streamer
              until data arrives. It is the user's responsibility to provide
              data in time in the stream case, or the stream may stutter. Data
              starvation can be detected with
              :py:attr:`~pyfmodex.sound.Sound.open_state`.
            - Important: If `user_async_read` is processed in the main thread,
              then it will hang the application, because FMOD will wait
              internally until data is ready, and the main thread will not be
              able to supply the data. For this reason the user's file access
              should normally be from a separate thread.
            - A `user_async_cancel` must either service or prevent an async
              read issued previously via `user_async_read` before returning.

        Implementation tips to avoid hangs / crashes.

            - All Callbacks must be thread safe.
            - :py:attr:`~pyfmodex.enums.RESULT.FILE_EOF` must be returned if
              the number of bytes read is smaller than requested.
        """
        self._call_fmod(
            "FMOD_System_SetFileSystem",
            FILE_OPEN_CALLBACK(user_open),
            FILE_CLOSE_CALLBACK(user_close),
            FILE_READ_CALLBACK(user_read),
            FILE_SEEK_CALLBACK(user_seek),
            FILE_ASYNCREAD_CALLBACK(user_async_read),
            FILE_ASYNCCANCEL_CALLBACK(user_async_cancel),
            block_align,
        )

    def set_plugin_path(self, path):
        """Specify a base search path for plugins so they can be placed
        somewhere else than the directory of the main executable.

        :param str path: A correctly formatted path to load plugins from.
        """
        ckresult(_dll.FMOD_System_SetPluginPath(self._ptr, path))

    def unload_plugin(self, handle):
        """Unload an FMOD (DSP, Output or Codec) plugin.

        :param int handle: Handle to an already loaded plugin.
        """
        ckresult(_dll.FMOD_System_UnloadPlugin(self._ptr, handle))

    def unlock_dsp(self):
        """Mutual exclusion method to unlock the FMOD DSP engine (which runs
        asynchronously in another thread) and let it continue executing.

        The DSP engine must be locked with :py:meth:`lock_dsp` before this
        method is called.
        """
        ckresult(_dll.FMOD_System_UnlockDSP(self._ptr))

    def update(self):
        """Update the FMOD system.

        Should be called once per 'game' tick, or once per frame in your
        application to perform actions such as:

            - Panning and reverb from 3D attributes changes.
            - Virtualization of Channels based on their audibility.
            - Mixing for non-realtime output types. See comment below.
            - Streaming if using
              :py:attr:`~pyfmodex.flags.INIT_FLAGS.STREAM_FROM_UPDATE`.
            - Mixing if using
              :py:attr:`~pyfmodex.flags.INIT_FLAGS.MIX_FROM_UPDATE`.
            - Firing callbacks that are deferred until Update.
            - DSP cleanup.

        If :py:attr:`~pyfmodex.enums.OUTPUTTYPE.NOSOUND_NRT` or
        :py:attr:`~pyfmodex.enums.OUTPUTTYPE.WAVWRITER` output modes are used,
        this method also drives the software / DSP engine, instead of it
        running asynchronously in a thread as is the default behavior. This can
        be used for faster than realtime updates to the decoding or DSP engine
        which might be useful if the output is the wav writer for example.

        If :py:attr:`~pyfmodex.flags.INIT_FLAGS.STREAM_FROM_UPDATE` is used,
        this function will update the stream engine. Combining this with the
        non realtime output will mean smoother captured output.
        """
        ckresult(_dll.FMOD_System_Update(self._ptr))

    @property
    def version(self):
        """The FMOD version number.

        :type: int

        The version is a 32 bit hexadecimal value formatted as 16:8:8, with the
        upper 16 bits being the product version, the middle 8 bits being the
        major version and the bottom 8 bits being the minor version. For
        example a value of 0x00010203 is equal to 1.02.03.
        """
        ver = c_uint()
        ckresult(_dll.FMOD_System_GetVersion(self._ptr, byref(ver)))
        return ver.value

    def listener(self, aaidee=0):
        """Convenience object for the position, velocity and orientation of the
        specified 3D sound listener.

        :param int aaidee: Listener ID in a multi-listener environment. Specify
            0 if there is only one listener.
        :rtype: Listener
        """
        return Listener(self._ptr, aaidee)
