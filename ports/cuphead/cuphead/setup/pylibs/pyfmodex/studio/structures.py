"""C structs"""

# pylint: disable=too-few-public-methods,invalid-name
# these are not your average classes

from ctypes import Structure, c_char_p, c_float, c_int, c_uint, sizeof


class ADVANCEDSETTINGS(Structure):
    """Settings for advanced features like configuring memory and cpu usage.

    :ivar int cbsize: Size of this structure in bytes.
    :ivar int commandqueuesize: Command queue size for studio async processing.
    :ivar int handleinitialsize: Initial size to allocate for handles. Memory
        for handles will grow as needed in pages.
    :ivar int studioupdateperiod: Update period of Studio when in async mode,
        in milliseconds. Will be quantized to the nearest multiple of mixer
        duration.
    :ivar int idlesampledatapoolsize: Size in bytes of sample data to retain in
        memory when no longer used, to avoid repeated disk I/O. Use -1 to
        disable.
    :ivar int streamingscheduledelay: Specify the schedule delay for streams,
        in samples. Lower values can reduce latency when scheduling events
        containing streams but may cause scheduling issues if too small.
    :ivar str encryptionkey: Specify the key for loading sounds from encrypted banks.
    """

    _fields_ = [
        ("cbsize", c_int),
        ("commandqueuesize", c_uint),
        ("handleinitialsize", c_uint),
        ("studioupdatedperiod", c_int),
        ("idlesampledatapoolsize", c_int),
        ("streamingscheduledelay", c_uint),
        ("encryptionkey", c_char_p),
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cbsize = sizeof(self)


class BUFFER_INFO(Structure):
    """Information for a single buffer in FMOD Studio.

    :ivar int currentusage: Current buffer usage in bytes.
    :ivar int peakusage: Peak buffer usage in bytes.
    :ivar in capacity: Buffer capacity in bytes.
    :ivar int stallcount: Cumulative number of stalls due to buffer overflow.
    :ivar float stalltime: Cumulative amount of time stalled due to buffer
        overflow, in seconds.
    """

    _fields_ = [
        ("currentusage", c_int),
        ("peakusage", c_int),
        ("capacity", c_int),
        ("stallcount", c_int),
        ("stalltime", c_float),
    ]


class BUFFER_USAGE(Structure):
    """Information for FMOD Studio buffer usage.

    :ivar BUFFER_INFO studiocommandqueue: Information for the Studio Async
        Command buffer.
    :ivar BUFFER_INFO studiohandle: Information for the Studio handle table.
    """

    _fields_ = [("studiocommandqueue", BUFFER_INFO), ("studiohandle", BUFFER_INFO)]


class PARAMETER_DESCRIPTION(Structure):
    """An event parameter.

    :ivar str name: Parameter name.
    :ivar int index: Parameter id.
    :ivar float minimum: Minimum parameter value.
    :ivar float maximum: Maximum parameter value.
    :ivar float defaultvalue: Default parameter value.
    :ivar int type: Parameter type.
    """
    # TODO: id vs index, flags -> because of FMOD API update to 2.0?

    _fields_ = [
        ("name", c_char_p),
        ("index", c_int),
        ("minimum", c_float),
        ("maximum", c_float),
        ("defaultvalue", c_float),
        ("type", c_int),
    ]
