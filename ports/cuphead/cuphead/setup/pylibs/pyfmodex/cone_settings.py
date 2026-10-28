"""3D cone shape settings."""
from ctypes import byref, c_float

from .fmodobject import _dll
from .utils import ckresult


class ConeSettings:
    """Convenience wrapper class to handle 3D cone shape settings for simulated
    occlusion which is based on direction.
    """

    def __init__(self, sptr, class_name):
        """Constructor.

        Creates ConeSettings for an FMOD object.

        Usually not called directly, but through the
        `cone_settings` or `threed_cone_settings` property of an FMOD object.

        The :py:class:`~pyfmodex.flags.MODE` flag THREED must be set on this
        object otherwise :py:const:`~pyfmodex.enums.RESULT.NEEDS3D` is
        returned.

        When
        :py:meth:`~pyfmodex.channel_control.ChannelControl.cone_orientation` is
        set and a 3D 'cone' is set up, attenuation will automatically occur for
        a sound based on the relative angle of the direction the cone is
        facing, vs the angle between the sound and the listener.

        - If the relative angle is within the :py:attr:`inside_angle`, the
          sound will not have any attenuation applied.
        - If the relative angle is between the :py:attr:`inside_angle` and
          :py:attr:`outside_angle`, linear volume attenuation (between 1 and
          :py:attr:`outside_volume`) is applied between the two angles until it
          reaches the :py:attr:`outside_angle`.
        - If the relative angle is outside of the :py:attr:`outside_angle`
          the volume does not attenuate any further.

        :param sptr: pointer of the object having cone settings.
        :param class_name: class of the object having cone settings (Channel or
            ChannelGroup)
        """
        self._sptr = sptr
        self._in = c_float()
        self._out = c_float()
        self._outvol = c_float()
        self._get_func = "FMOD_%s_Get3DConeSettings" % class_name
        self._set_func = "FMOD_%s_Set3DConeSettings" % class_name
        ckresult(
            getattr(_dll, self._get_func)(
                self._sptr, byref(self._in), byref(self._out), byref(self._outvol)
            )
        )

    @property
    def inside_angle(self):
        """Inside cone angle.

        This is the angle spread within which the sound is unattenuated.
        Between 0 and 360.

        :type: int
        """
        return self._in.value

    @inside_angle.setter
    def inside_angle(self, angle):
        self._in = c_float(angle)
        self._commit()

    @property
    def outside_angle(self):
        """Outside cone angle.

        This is the angle spread outside of which the sound is attenuated to
        its :py:attr:`outside_volume`. Between 0 and 360.

        :type: int
        """
        return self._out.value

    @outside_angle.setter
    def outside_angle(self, angle):
        self._out = c_float(angle)
        self._commit()

    @property
    def outside_volume(self):
        """Cone outside volume.

        Between 0 and 1.

        :type: float
        """
        return self._outvol.value

    @outside_volume.setter
    def outside_volume(self, vol):
        self._outvol = c_float(vol)
        self._commit()

    def _commit(self):
        """Apply a changed code setting."""
        ckresult(
            getattr(_dll, self._set_func)(self._sptr, self._in, self._out, self._outvol)
        )
