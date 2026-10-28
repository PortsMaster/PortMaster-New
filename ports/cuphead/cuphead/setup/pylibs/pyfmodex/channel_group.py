"""A submix in the mixing hierarchy akin to a bus that can contain both
:py:class:`~pyfmodex.channel.Channel` and
:py:class:`~pyfmodex.channel_group.ChannelGroup` objects.
"""

from ctypes import *

from .channel_control import ChannelControl
from .globalvars import DLL as _dll
from .globalvars import get_class
from .utils import check_type, ckresult


class ChannelGroup(ChannelControl):
    """A submix in the mixing hierarchy akin to a bus that can contain both
    :py:class:`~pyfmodex.channel.Channel` and
    :py:class:`~pyfmodex.channel_group.ChannelGroup` objects.
    """

    def add_group(self, group, propagate_dsp_clock=True):
        """Add a ChannelGroup as an input to this group.

        :param ChannelGroup group: Group to add.
        :param bool propagate_dsp_clock: Recursively propagate this object's
            clock values to `group`.
        :returns: Connection between the head :py:class:`~pyfmodex.dsp.DSP` of
            `group` and the tail :py:class:`~pyfmodex.dsp.DSP` of this object.
        :rtype: DSPConnection
        """
        check_type(group, ChannelGroup)
        conn_ptr = c_void_p()
        self._call_fmod(
            "FMOD_ChannelGroup_AddGroup",
            group._ptr,
            propagate_dsp_clock,
            byref(conn_ptr),
        )
        return get_class("DSP_Connection")(conn_ptr)

    def get_channel(self, idx):
        """Retrieve the Channel at the specified index in the list of Channel
        inputs.

        :param int idx: Offset into the list of Channel inputs.
        :returns: Channel at the specified index.
        :rtype: Channel
        """
        c_ptr = c_void_p()
        self._call_fmod("FMOD_ChannelGroup_GetChannel", idx, byref(c_ptr))
        return get_class("Channel")(c_ptr)

    def get_group(self, idx):
        """Retrieve the ChannelGroup at the specified index in the list of
        group inputs.

        :param int idx: Offset into the list of group inputs.
        :returns: Group at the specified index.
        :rtype: ChannelGroup
        """
        grp_ptr = c_void_p()
        ckresult(_dll.FMOD_ChannelGroup_GetGroup(self._ptr, idx, byref(grp_ptr)))
        return ChannelGroup(grp_ptr)

    @property
    def name(self):
        """The name set when the group was created.

        :type: str
        """
        buf = create_string_buffer(512)
        self._call_fmod("FMOD_ChannelGroup_GetName", buf, 512)
        return buf.value

    @property
    def num_channels(self):
        """The number of Channels that feed into to this group.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_ChannelGroup_GetNumChannels", byref(num))
        return num.value

    @property
    def num_groups(self):
        """The number of ChannelGroups that feed into to this group.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_ChannelGroup_GetNumGroups", byref(num))
        return num.value

    @property
    def parent_group(self):
        """The ChannelGroup this object outputs to.

        :type: ChannelGroup
        """
        grp_ptr = c_void_p()
        self._call_fmod("FMOD_ChannelGroup_GetParentGroup", byref(grp_ptr))
        return ChannelGroup(grp_ptr) if grp_ptr.value else None

    def release(self):
        """Free the memory for the group.

        Any :py:class:`Channels <pyfmodex.channel.Channel>` or
        :py:class:`ChannelGrous <pyfmodex.channel_group.ChannelGroup>` feeding
        into this group are moved to the master
        :py:class:`~pyfmodex.channel_group.ChannelGroup`.
        """
        self._call_fmod("FMOD_ChannelGroup_Release")
