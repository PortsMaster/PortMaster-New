"""Digital Signal Processor."""
from ctypes import *

from .enums import DSP_TYPE, SPEAKERMODE
from .flags import CHANNELMASK
from .fmodobject import FmodObject
from .globalvars import get_class
from .structobject import Structobject as so
from .structures import DSP_METERING_INFO, DSP_PARAMETER_DESC
from .utils import check_type

# pylint: disable=too-many-public-methods
# That's not our fault... :-)


class DSP(FmodObject):
    """A DSP or Digital Signal Processor.

    One node within a graph that transforms input audio signals to an output
    stream.
    """

    def add_input(self, input_dsp, connection_type=None):
        """Add a DSP unit as an input to this object.

        When a DSP has multiple inputs the signals are automatically mixed
        together before sending them to the unit's output(s).

        The returned connection will remain valid until the units are
        disconnected.

        :param DSP input_dsp: DSP unit to be added.
        :param DSPCONNECTION_TYPE connection_type: Type of connection between
            the two units.
        :returns: Connection between the two units.
        :rtype: DSPConnection
        """
        check_type(input_dsp, DSP)
        connptr = c_void_p()
        if connection_type:
            self._call_fmod(
                "FMOD_DSP_AddInput",
                input_dsp._ptr,
                byref(connptr),
                connection_type.value,
            )
        else:
            self._call_fmod("FMOD_DSP_AddInput", input_dsp._ptr, byref(connptr))
        return get_class("DSP_Connection")(connptr)

    def disconnect_all(self, inputs=False, outputs=False):
        """Disconnect all inputs and/or outputs.

        This is a convenience function that is faster than disconnecting all
        inputs and outputs individually.

        :param bool inputs: Whether all inputs should be disconnected.
        :param bool outputs: Whether all outputs should be disconnected.
        """
        self._call_fmod("FMOD_DSP_DisconnectAll", inputs, outputs)

    def disconnect_from(self, target_dsp=None, connection=None):
        """Disconnect the specified input DSP.

        If `target_dsp` had only one output, after this operation that entire
        subgraph will no longer be connected to the DSP network.

        After this operation `connection` is no longer valid.

        :param DSP target_dsp: Input unit to disconnect, if not specified all
            inputs and outputs are disconnected from this unit.
        :param DSPConnection connection: When there is more than one connection
            between two units this can be used to define which of the connections
            should be disconnected.
        """
        dsp_ptr = None
        connection_ptr = None
        if target_dsp:
            check_type(target_dsp, DSP)
            dsp_ptr = target_dsp._ptr
        if connection:
            check_type(connection, get_class("DSP_Connection"))
            connection_ptr = connection._ptr
        self._call_fmod("FMOD_DSP_DisconnectFrom", dsp_ptr, connection_ptr)

    @property
    def active(self):
        """The processing active state.

        When False, processing of this unit and its inputs are stopped.

        When created, a DSP is inactive. If
        :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp` is used it
        will automatically be activated, otherwise it must be set to active
        manually.

        :type: bool
        """
        active_state = c_bool()
        self._call_fmod("FMOD_DSP_GetActive", byref(active_state))
        return active_state.value

    @active.setter
    def active(self, active_state):
        self._call_fmod("FMOD_DSP_SetActive", active_state)

    @property
    def bypass(self):
        """The processing bypass state.

        When True, processing of this unit is skipped but it continues to
        process its inputs.

        :type: bool
        """
        bypass = c_bool()
        self._call_fmod("FMOD_DSP_GetBypass", byref(bypass))
        return bypass.value

    @bypass.setter
    def bypass(self, bypass):
        self._call_fmod("FMOD_DSP_SetBypass", bypass)

    @property
    def channel_format(self):
        """The PCM input format this DSP will receive when processing.

        Setting the number of channels on a unit will force either a down or up
        mix to that channel count before processing the DSP read/process
        callback.

        :type: Structobject with the following members:

            - channel_mask: (:py:class:`~pyfmodex.flags.CHANNELMASK`)
              Deprecated
            - num_channels: (int) Number of channels to be processed.
            - source_speaker_mode: (:py:class:`~pyfmodex.enums.SPEAKERMODE`)
              Speaker mode to describe the channel mapping.
        """
        mask = c_int()
        num_channels = c_int()
        speaker_mode = c_int()
        self._call_fmod(
            "FMOD_DSP_GetChannelFormat",
            byref(mask),
            byref(num_channels),
            byref(speaker_mode),
        )
        return so(
            channel_mask=CHANNELMASK(mask.value),
            num_channels=num_channels.value,
            source_speaker_mode=SPEAKERMODE(speaker_mode.value),
        )

    @channel_format.setter
    def channel_format(self, channel_format):
        self._call_fmod(
            "FMOD_DSP_SetChannelFormat",
            channel_format.channel_mask.value,
            channel_format.num_channels,
            channel_format.source_speaker_mode.value,
        )

    def get_data_parameter_index(self, data_type):
        """Retrieve the index of the first data parameter of a particular data
        type.

        :param DSP_PARAMETER_DATA_TYPE data_type: The type of data to find.
        :returns: The index of the first data parameter of type datatype after
            the function is called. Will be -1 if no matches were found.
        :rtype: int
        :raises FmodError: if no parmeter of matching type is found. This can
            be used to check whether the DSP supports specific functionality
            through data parameters of certain types.
        """
        index = c_int()
        self._call_fmod("FMOD_DSP_GetDataParameterIndex", data_type, byref(index))
        return index.value

    @property
    def idle(self):
        """The idle state.

        A DSP is considered idle when it stops receiving input signal and all
        internal processing of stored input has been exhausted.

        Each DSP type has the potential to have differing idle behaviour based
        on the type of effect. A reverb or echo may take a longer time to go
        idle after it stops receiving a valid signal, compared to an effect
        with a shorter tail length like an EQ filter.

        :type: bool
        """
        res = c_bool()
        self._call_fmod("FMOD_DSP_GetIdle", byref(res))
        return res.value

    @property
    def info(self):
        """Information about this DSP unit.

        :type: Structobject with the following members:

            - name: (str) The name of this unit.
            - version: (int) Version number of this unit, usually formated as
              hex AAAABBBB where the AAAA is the major version number and the
              BBBB is the minor version number.
            - channels: (int) Number of channels this unit processes where 0
              represents "any".
            - config_width: (int) Configuration dialog box width where 0
              represents "no dialog box".
            - config_height: (int) Configuration dialog box height where 0
              represents "no dialog box".
        """
        name = create_string_buffer(33)
        ver = c_uint()
        chans = c_int()
        cfgw = c_int()
        cfgh = c_int()
        self._call_fmod(
            "FMOD_DSP_GetInfo",
            byref(name),
            byref(ver),
            byref(chans),
            byref(cfgw),
            byref(cfgh),
        )
        return so(
            name=name.value.decode(),
            version=ver.value,
            channels=chans.value,
            config_width=cfgw.value,
            config_height=cfgh.value,
        )

    def get_input(self, index):
        """Retrieve the DSP unit at the specified index in the input list.

        This will flush the DSP queue (which blocks against the mixer) to
        ensure the input list is correct; avoid this during time sensitive
        operations.

        The returned connection will remain valid until the units are
        disconnected.

        :param int index: Offset into this DSP's input list.
        :returns: DSP unit at the specified index and connection between this
            unit and `input`.
        :rtype: two-tuple with :py:class:`DSP` and
            :py:class:`~pyfmodex.dsp_connection.DSPConnection`
        """
        i_ptr = c_void_p()
        ic_ptr = c_void_p()
        self._call_fmod("FMOD_DSP_GetInput", index, byref(i_ptr), byref(ic_ptr))
        return (DSP(i_ptr), get_class("DSP_Connection")(ic_ptr))

    @property
    def _metering_enabled(self):
        """The input and output signal metering enabled states.

        Input metering is pre processing, while output metering is post
        processing.

        With enabled metering :py:attr:`metering_info` can return metering
        information and FMOD profiling tools can visualize the levels.

        The :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flag PROFILE_METER_ALL
        with :py:meth:`~pyfmodex.system.System.init` will automatically turn on
        metering for all DSP units inside the mixer graph.

        :type: two-tuple of bools with:
            - Metering enabled state for the input signal
            - Metering enabled state for the output signal
        """
        input_enabled = c_bool()
        output_enabled = c_bool()
        self._call_fmod(
            "FMOD_DSP_GetMeteringEnabled", byref(input_enabled), byref(output_enabled)
        )
        return input_enabled.value, output_enabled.value

    @_metering_enabled.setter
    def _metering_enabled(self, values):
        self._call_fmod("FMOD_DSP_SetMeteringEnabled", values[0], values[1])

    @property
    def input_metering_enabled(self):
        """The input signal metering enabled state.

        Input metering is pre processing.

        With enabled metering :py:attr:`metering_info` can return metering
        information and FMOD profiling tools can visualize the levels.

        The :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flag PROFILE_METER_ALL
        with :py:meth:`~pyfmodex.system.System.init` will automatically turn on
        metering for all DSP units inside the mixer graph.

        :type: bool
        """
        return self._metering_enabled[0]

    @input_metering_enabled.setter
    def input_metering_enabled(self, val):
        self._metering_enabled = (val, self._metering_enabled[1])

    @property
    def output_metering_enabled(self):
        """The output signal metering enabled state.

        Output metering is post processing.

        With enabled metering :py:attr:`metering_info` can return metering
        information and FMOD profiling tools can visualize the levels.

        The :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flag PROFILE_METER_ALL
        with :py:meth:`~pyfmodex.system.System.init` will automatically turn on
        metering for all DSP units inside the mixer graph.

        :type: bool
        """
        return self._metering_enabled[1]

    @output_metering_enabled.setter
    def output_metering_enabled(self, val):
        self._metering_enabled = (self._metering_enabled[0], val)

    @property
    def metering_info(self):
        """The signal metering information.

        Input metering information before the DSP has processed and output
        metering information after the DSP has processed.

        The :py:class:`INIT <pyfmodex.flags.INIT_FLAGS>` flag PROFILE_METER_ALL
        with :py:meth:`~pyfmodex.system.System.init` will automatically enable
        metering for all DSP units.

        :type: two-tuple of :py:class:`~pyfmodex.structures.DSP_METERING_INFO`
        :raises FmodError: when metering hasn't been enabled.
        """
        input_info = DSP_METERING_INFO()
        output_info = DSP_METERING_INFO()
        self._call_fmod(
            "FMOD_DSP_GetMeteringInfo", byref(input_info), byref(output_info)
        )
        return input_info, output_info

    @property
    def num_inputs(self):
        """The number of DSP units in the input list.

        Getting the number of units will flush the DSP queue (which blocks
        against the mixer) to ensure the input list is correct; avoid this
        during time sensitive operations.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_DSP_GetNumInputs", byref(num))
        return num.value

    @property
    def num_outputs(self):
        """The number of DSP units in the output list.

        Getting the number of units will flush the DSP queue (which blocks
        against the mixer) to ensure the output list is correct; avoid this
        during time sensitive operations.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_DSP_GetNumOutputs", byref(num))
        return num.value

    @property
    def num_parameters(self):
        """The number of parameters exposed by this unit.

        Use this to enumerate all parameters of a DSP unit with
        :py:meth:`get_parameter_info`.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_DSP_GetNumParameters", byref(num))
        return num.value

    def get_output(self, index):
        """Retrieve the DSP unit at the specified index in the output list.

        This will flush the DSP queue (which blocks against the mixer) to
        ensure the output list is correct; avoid this during time sensitive
        operations.

        The returned connection will remain valid until the units are
        disconnected.

        :param int index: Offset into this DSP's output list.
        :returns: DSP unit at the specified index and connection between this
            unit and `output`.
        :rtype: two-tuple with :py:class:`DSP` and
            :py:class:`~pyfmodex.dsp_connection.DSPConnection`
        """
        o_ptr = c_void_p()
        oc_ptr = c_void_p()
        self._call_fmod("FMOD_DSP_GetOutput", index, byref(o_ptr), byref(oc_ptr))
        return (DSP(o_ptr), get_class("DSP_Connection")(oc_ptr))

    @property
    def output_channel_format(self):
        """The output format this DSP will produce when processing based on the
        input specified.

        :type: Structobject with the following members:

            - in_mask: (:py:class:`~pyfmodex.flags.CHANNELMASK`) Deprecated.
            - out_mask: (:py:class:`~pyfmodex.flags.CHANNELMASK`) Deprecated.
            - in_channels: (int) Number of channels for the input signal.
            - out_channels: (int) Number of channels for the output signal.
            - in_speaker_mode: (:py:class:`~pyfmodex.enums.SPEAKERMODE`)
              Speaker mode for the input signal.
            - out_speaker_mode: (:py:class:`~pyfmodex.enums.SPEAKERMODE`)
              Speaker mode for the output signal.
        """
        inmask = c_int()
        outmask = c_int()
        inchannels = c_int()
        outchannels = c_int()
        inmode = c_int()
        outmode = c_int()
        self._call_fmod(
            "FMOD_DSP_GetOutputChannelFormat",
            byref(inmask),
            byref(inchannels),
            byref(inmode),
            byref(outmask),
            byref(outchannels),
            byref(outmode),
        )
        return so(
            in_mask=CHANNELMASK(inmask.value),
            out_mask=CHANNELMASK(outmask.value),
            in_channels=inchannels.value,
            out_channels=outchannels.value,
            in_speaker_mode=SPEAKERMODE(inmode.value),
            out_speaker_mode=outmode.value,
        )  # The parameter should be a SPEAKERMODE, but the echo dsp returned
        # basically random value there.

    def get_parameter_bool(self, index):
        """Retrieve a boolean parameter by index.

        :param int index: Parameter index.
        :returns: Parameter boolean value and string representation of the
            value.
        :rtype: two-tuple of bool and str
        """
        value_str = create_string_buffer(256)
        value = c_bool()
        self._call_fmod(
            "FMOD_DSP_GetParameterBool", index, byref(value), value_str, len(value_str)
        )
        return value.value, value_str.value

    def get_parameter_data(self, index):
        """Retrieve a binary data parameter by index.

        :param int index: Parameter index.
        :returns: Parameter binary data, length of data and string
            representation of the data.
        :rtype: three-tuple of data, int and str
        """
        value_str = create_string_buffer(256)
        value = c_void_p()
        value_len = c_uint()
        self._call_fmod(
            "FMOD_DSP_GetParameterData",
            index,
            byref(value),
            byref(value_len),
            value_str,
            len(value_str),
        )
        return value, value_len.value, value_str.value

    def get_parameter_float(self, index):
        """Retrieve a floating point parameter by index.

        :param int index: Parameter index.
        :returns: Parameter floating point data and string representation of
            the data.
        :rtype: two-tuple of float and str
        """
        value_str = create_string_buffer(256)
        value = c_float()
        self._call_fmod(
            "FMOD_DSP_GetParameterFloat", index, byref(value), value_str, len(value_str)
        )
        return value.value, value_str.value

    def get_parameter_info(self, index):
        """Retrieve information about a specified parameter.

        :param int index: Parameter index.
        :returns: Parameter description at the specified index.
        :type: DSP_PARAMETER_DESC
        """
        desc_ptr = POINTER(DSP_PARAMETER_DESC)()
        self._call_fmod("FMOD_DSP_GetParameterInfo", index, byref(desc_ptr))
        return desc_ptr.contents

    def get_parameter_int(self, index):
        """Retrieve an integer parameter by index.

        :param int index: Parameter index.
        :returns: Parameter integer data and string representation of the data.
        :rtype: two-tuple of int and str
        """
        value_str = create_string_buffer(256)
        value = c_int()
        self._call_fmod(
            "FMOD_DSP_GetParameterInt", index, byref(value), value_str, len(value_str)
        )
        return value.value, value_str.value

    def set_parameter_bool(self, index, val):
        """Set a boolean parameter by index.

        :param int index: Parameter index.
        :param bool val: Parameter value.
        """
        self._call_fmod("FMOD_DSP_SetParameterBool", index, val)

    def set_parameter_data(self, index, data):
        """Set a binary data parameter by index.

        :param int index: Parameter index.
        :param PyCArrayType data: Parameter binary data.
        """
        self._call_fmod("FMOD_DSP_SetParameterData", index, byref(data), len(data))

    def set_parameter_float(self, index, val):
        """Set a floating point parameter by index.

        :param int index: Parameter index.
        :param float val: Parameter floating point data.
        """
        self._call_fmod("FMOD_DSP_SetParameterFloat", index, c_float(val))

    def set_parameter_int(self, index, val):
        """Set an integer parameter by index.

        :param int index: Parameter index.
        :param float val: Parameter integer data.
        """
        self._call_fmod("FMOD_DSP_SetParameterInt", index, val)

    @property
    def system_object(self):
        """The parent System object.

        :type: System
        """
        sptr = c_void_p()
        self._call_fmod("FMOD_DSP_GetSystemObject", byref(sptr))
        return get_class("System")(sptr)

    @property
    def type(self):
        """The pre-defined type of this FMOD registered DSP unit.

        This is only valid for built in FMOD effects. Any user plugins will
        simply return :py:attr:`~pyfmodex.enums.DSP_TYPE.UNKNOWN`.

        :type: DSP_TYPE
        """
        typ = c_int()
        self._call_fmod("FMOD_DSP_GetType", byref(typ))
        return DSP_TYPE(typ.value)

    @property
    def _wet_dry_mix(self):
        """The scale of the wet and dry signal members.

        :type: three-tuple of floats with:

            - prewet: Level of the 'Dry' (pre-processed signal) mix that is
              processed by the DSP. 0 = silent, 1 = full. Negative level
              inverts the signal. Values larger than 1 amplify the signal.
            - postwet: Level of the 'Wet' (post-processed signal) mix that is
              output. 0 = silent, 1 = full. Negative level inverts the signal.
              Values larger than 1 amplify the signal.
            - dry: Level of the 'Dry' (pre-processed signal) mix that is
              output. 0 = silent, 1 = full. Negative level inverts the signal.
              Values larger than 1 amplify the signal.
        """
        pre = c_float()
        post = c_float()
        dry = c_float()
        self._call_fmod("FMOD_DSP_GetWetDryMix", byref(pre), byref(post), byref(dry))
        return pre.value, post.value, dry.value

    @_wet_dry_mix.setter
    def _wet_dry_mix(self, values):
        self._call_fmod(
            "FMOD_DSP_SetWetDryMix",
            c_float(values[0]),
            c_float(values[1]),
            c_float(values[2]),
        )

    @property
    def pre_mix(self):
        """Level of the 'Dry' (pre-processed signal) mix that is processed by
        the DSP.

        - 0: silent
        - 1: full
        - Negative level: inverts the signal
        - Values larger than 1: amplify the signal

        :type: float
        """
        return self._wet_dry_mix[0]

    @pre_mix.setter
    def pre_mix(self, val):
        mix = list(self._wet_dry_mix)
        mix[0] = val
        self._wet_dry_mix = mix

    @property
    def post_mix(self):
        """Level of the 'Wet' (post-processed signal) mix that is output.

        - 0: silent
        - 1: full
        - Negative level: inverts the signal
        - Values larger than 1: amplify the signal

        :type: float
        """
        return self._wet_dry_mix[1]

    @post_mix.setter
    def post_mix(self, val):
        mix = list(self._wet_dry_mix)
        mix[1] = val
        self._wet_dry_mix = mix

    @property
    def dry_mix(self):
        """Level of the 'Dry' (pre-processed signal) mix that is output.

        - 0: silent
        - 1: full
        - Negative level: inverts the signal
        - Values larger than 1: amplify the signal

        :type: float
        """
        return self._wet_dry_mix[2]

    @dry_mix.setter
    def dry_mix(self, val):
        mix = list(self._wet_dry_mix)
        mix[2] = val
        self._wet_dry_mix = mix

    def release(self):
        """Frees the DSP object.

        :raises FmodError: when this DSP is not removed from the network with
            :py:meth:`~pyfmodex.channel_control.ChannelControl.remove_dsp`
            after being added with
            :py:meth:`~pyfmodex.channel_control.ChannelControl.add_dsp`.
        """
        self._call_fmod("FMOD_DSP_Release")

    def reset(self):
        """Reset the DSPs internal state ready for new input signal.

        This clears all internal state derived from input signal while
        retaining any set parameter values. The intended use of the function is
        to avoid audible artifacts if moving the DSP from one part of the DSP
        network to another.
        """
        self._call_fmod("FMOD_DSP_Reset")

    def show_config_dialog(self, hwnd, show=True):
        """Display or hide a DSP unit configuration dialog box inside the
        target window.

        Dialog boxes are used by DSP plugins that prefer to use a graphical
        user interface to modify their parameters rather than using the other
        method of enumerating the parameters and using
        :py:meth:`set_parameter_float`/ :py:meth:`set_parameter_int`/
        :py:meth:`set_parameter_bool`/ :py:meth:`set_parameter_data`.

        These are usually VST plugins. FMOD Studio plugins do not have
        configuration dialog boxes. To find out what size window to create to
        store the configuration screen, use :py:attr:`info` where you can get
        the width and height.

        :param hwnd: Target HWND in windows to display configuration dialog.
        :param bool show: Whether to show or hide the dialog box inside target
            hwnd.
        """
        self._call_fmod("FMOD_DSP_ShowConfigDialog", hwnd, show)
