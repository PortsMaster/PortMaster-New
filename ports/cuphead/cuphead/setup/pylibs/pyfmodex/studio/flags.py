"""Flags."""

from enum import Flag


class STUDIO_INIT_FLAGS(Flag):  # pylint: disable=invalid-name
    """Studio System initialization flags.

    The zero flag is called "NORMAL".

    :cvar int LIVEUPDATE: Enable live update.
    :cvar int ALLOW_MISSING_PLUGINS: Load banks even if they reference plugins
        that have not been loaded.
    :cvar int SYNCHRONOUS_UPDATE: Disable asynchronous processing and perform
        all processing on the calling thread instead. DEFERRED_CALLBACKS: Defer
        timeline callbacks until the main update.
    :cvar int LOAD_FROM_UPDATE: No additional threads are created for bank and
        resource loading.
    """

    NORMAL = 0x0
    LIVEUPDATE = 0x00000001
    ALLOW_MISSING_PLUGINS = 0x00000002
    SYNCHRONOUS_UPDATE = 0x00000004
    DEFERRED_CALLBACKS = 0x00000008
    LOAD_FROM_UPDATE = 0x00000010


class LOAD_BANK_FLAGS(Flag):  # pylint: disable=invalid-name
    """Flags to control bank loading.

    The zero flag is called "NORMAL".

    :cvar int NONBLOCKING: Bank loading occurs asynchronously rather than
        occurring immediately.
    :cvar int DECOMPRESS_SAMPLES: Force samples to decompress into memory when
        they are loaded, rather than staying compressed.
    :cvar int UNENCRYPTED: Ignore the encryption key specified by Advanced
        Settings when loading sounds from this bank (assume the sounds in the
        bank are not encrypted).
    """

    NORMAL = 0x0
    NONBLOCKING = 0x00000001
    DECOMPRESS_SAMPLES = 0x00000002
    UNENCRYPTED = 0x00000004
