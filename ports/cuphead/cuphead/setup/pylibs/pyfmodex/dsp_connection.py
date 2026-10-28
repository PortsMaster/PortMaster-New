"""An interface that manages Digital Signal Processor (DSP) Connections."""
from ctypes import *

from .enums import DSPCONNECTION_TYPE
from .fmodobject import *
from .globalvars import get_class


class DSPConnection(FmodObject):
    """An interface that manages Digital Signal Processor (DSP) Connections."""

    @property
    def input(self):
        """The connection's input DSP unit.

        If the input was just added, the connection might not be ready because
        the DSP system is still queued to be connected, and may need to wait
        several milliseconds for the next mix to occur. If so the function will
        return :py:attr:`~pyfmodex.enums.RESULT.NOTREADY` and `input` will be
        None.

        :type: DSP
        """
        dsp_ptr = c_void_p()
        self._call_fmod("FMOD_DSPConnection_GetInput", byref(dsp_ptr))
        return get_class("DSP")(dsp_ptr)

    @property
    def mix(self):
        """The connection's volume scale.

        Volume scale applied to the input before being passed to the output. 

        - 0: silent
        - 1: full
        - Negative level: inverts the signal
        - Values larger than 1: amplify the signal

        :type: float
        :default: 1
        :range: -inf, inf
        """
        m_val = c_float()
        self._call_fmod("FMOD_DSPConnection_GetMix", byref(m_val))
        return m_val.value

    @mix.setter
    def mix(self, mix):
        self._call_fmod("FMOD_DSPConnection_SetMix", c_float(mix))

    def get_mix_matrix(self, hop=0):
        """Retrieve a 2 dimensional pan matrix that maps the signal from input
        channels (columns) to output speakers (rows).

        :param int hop: Width (total number of columns) in destination matrix.
            Can be larger than in_channels to represent a smaller valid region
            inside a larger matrix. When 0, the full matrix is retrieved.
        :returns: Two dimensional list of volume levels in row-major order.
           Each row represents an output speaker, each column represents an
           input channel. A matrix element is referenced as out_channel *
           (hop or in_channels) + in_channel.
        :rtype: list of floats
        """
        in_channels = c_int()
        out_channels = c_int()
        self._call_fmod(
            "FMOD_DSPConnection_GetMixMatrix",
            None,
            byref(out_channels),
            byref(in_channels),
            hop,
        )
        matrix = (c_float * (hop or in_channels.value * out_channels.value))()
        self._call_fmod(
            "FMOD_DSPConnection_GetMixMatrix",
            matrix,
            byref(out_channels),
            byref(in_channels),
            hop,
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
        self._call_fmod("FMOD_DSPConnection_SetMixMatrix", raw_matrix, out_channels, in_channels, 0)

    @property
    def output(self):
        """The connection's output DSP unit.

        If the output was just added, the connection might not be ready because
        the DSP system is still queued to be connected, and may need to wait
        several milliseconds for the next mix to occur. If so the function will
        return :py:attr:`~pyfmodex.enums.RESULT.NOTREADY` and `input` will be
        None.

        :type: DSP
        """
        o_ptr = c_void_p()
        self._call_fmod("FMOD_DSPConnection_GetOutput", byref(o_ptr))
        return get_class("DSP")(o_ptr)

    @property
    def type(self):
        """The type of the connection between two DSP units.

        :type: DSPCONNECTION_TYPE
        """
        typ = c_int()
        self._call_fmod("FMOD_DSPConnection_GetType", byref(typ))
        return DSPCONNECTION_TYPE(typ.value)
