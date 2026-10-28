"""An interface that manages virtual 3D reverb spheres."""

from ctypes import *

from .fmodobject import FmodObject
from .structures import REVERB_PROPERTIES, VECTOR
from .utils import check_type


class Reverb3D(FmodObject):
    """An interface that manages virtual 3D reverb spheres."""

    @property
    def _threed_attrs(self):
        """The 3D attributes of a reverb sphere.

        :type: list with
            - Position in 3D space represnting the center of the reverb as a
              list of three coordinate floats
            - Distance from the centerpoint within which the reverb will have
              full effect
            - Distance from the centerpoint beyond which the reverb will have
              no effect
        """
        pos = VECTOR()
        mindist = c_float()
        maxdist = c_float()
        self._call_fmod(
            "FMOD_Reverb3D_Get3DAttributes", byref(pos), byref(mindist), byref(maxdist)
        )
        return [pos.to_list(), mindist.value, maxdist.value]

    @_threed_attrs.setter
    def _threed_attrs(self, attrs):
        pos = VECTOR.from_list(attrs[0])
        self._call_fmod(
            "FMOD_Reverb3D_Set3DAttributes",
            byref(pos),
            c_float(attrs[1]),
            c_float(attrs[2]),
        )

    @property
    def position(self):
        """Position in 3D space represnting the center of the reverb.

        :type: list of three coordinate floats
        """
        return self._threed_attrs[0]

    @position.setter
    def position(self, pos):
        attrs = self._threed_attrs
        attrs[0] = pos
        self._threed_attrs = attrs

    @property
    def min_distance(self):
        """Distance from the centerpoint within which the reverb will have full
        effect.

        :type: float
        """
        return self._threed_attrs[1]

    @min_distance.setter
    def min_distance(self, mindist):
        attrs = self._threed_attrs
        attrs[1] = mindist
        self._threed_attrs = attrs

    @property
    def max_distance(self):
        """Distance from the centerpoint within which the reverb will have no
        effect.

        :type: float
        """
        return self._threed_attrs[2]

    @max_distance.setter
    def max_distance(self, maxdist):
        attrs = self._threed_attrs
        attrs[2] = maxdist
        self._threed_attrs = attrs

    @property
    def active(self):
        """The active state of the reverb sphere.

        :type: bool
        """
        active = c_bool()
        self._call_fmod("FMOD_Reverb3D_GetActive", byref(active))
        return active.value

    @active.setter
    def active(self, active):
        self._call_fmod("FMOD_Reverb3D_SetActive", active)

    @property
    def properties(self):
        """The environmental properties of a reverb sphere.

        :type: REVERB_PROPERTIES
        """
        props = REVERB_PROPERTIES()
        self._call_fmod("FMOD_Reverb3D_GetProperties", byref(props))
        return props

    @properties.setter
    def properties(self, props):
        check_type(props, REVERB_PROPERTIES)
        self._call_fmod("FMOD_Reverb3D_SetProperties", byref(props))

    def release(self):
        """Release the memory for a reverb object and make it inactive.

        If you release all Reverb3D objects and have not added a new Reverb3D
        object, :py:meth:`~pyfmodex.system.System.set_reverb_properties` should
        be called to reset the reverb properties.
        """
        self._call_fmod("FMOD_Reverb3D_Release")
