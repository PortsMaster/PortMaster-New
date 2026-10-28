"""Geometry related classes."""
from ctypes import *

from .fmodobject import FmodObject
from .globalvars import DLL as _dll
from .structures import VECTOR
from .utils import ckresult


class PolygonAttributes:
    """Convenience wrapper class to handle polygons for simulated occlusion
    which is based on its winding.
    """

    def __init__(self, gptr, index):
        self._gptr = gptr
        self.index = index
        self._directocclusion = c_float()
        self._reverbocclusion = c_float()
        self._doublesided = c_bool()
        self._refresh_state()

    def _refresh_state(self):
        """Retrieve the attributes for the polygon."""
        ckresult(
            _dll.FMOD_Geometry_GetPolygonAttributes(
                self._gptr,
                self.index,
                byref(self._directocclusion),
                byref(self._reverbocclusion),
                byref(self._doublesided),
            )
        )

    @property
    def direct_occlusion(self):
        """Occlusion factor for the direct path where 0 represents no occlusion
        and 1 represents full occlusion.

        :type: float
        """
        self._refresh_state()
        return self._directocclusion.value

    @direct_occlusion.setter
    def direct_occlusion(self, occ):
        ckresult(
            _dll.FMOD_Geometry_SetPolygonAttributes(
                self._gptr,
                self.index,
                c_float(occ),
                self._reverbocclusion,
                self._doublesided,
            )
        )

    @property
    def reverb_occlusion(self):
        """Occlusion factor of the polygon for the reverb path where 0
        represents no occlusion and 1 represents full occlusion.

        :type: float
        """
        self._refresh_state()
        return self._reverbocclusion.value

    @reverb_occlusion.setter
    def reverb_occlusion(self, occ):
        ckresult(
            _dll.FMOD_Geometry_SetPolygonAttributes(
                self._gptr,
                self.index,
                self._directocclusion,
                c_float(occ),
                self._doublesided,
            )
        )

    @property
    def double_sided(self):
        """Double sidedness of the polygon.

        - True: Polygon is double sided
        - False: Polygon is single sided, and the winding of the polygon (which
          determines the polygon's normal) determines which side of the polygon
          will cause occlusion.

        :type: bool
        """
        self._refresh_state()
        return self._doublesided

    @double_sided.setter
    def double_sided(self, dval):
        ckresult(
            _dll.FMOD_Geometry_SetPolygonAttributes(
                self._gptr,
                self.index,
                self._directocclusion,
                self._reverbocclusion,
                dval,
            )
        )

    @property
    def num_vertices(self):
        """The number of vertices in the polygon.

        :type: int
        """
        num = c_int()
        ckresult(
            _dll.FMOD_Geometry_GetPolygonNumVertices(self._gptr, self.index, byref(num))
        )
        return num.value

    def get_vertex(self, index):
        """Retrieve the position of a vertex.

        :param int index: Polygon vertex index.
        :returns: 3D Position of the vertex.
        :rtype: list of x, y, z coordinate floats
        """
        vertex = VECTOR()
        ckresult(
            _dll.FMOD_Geometry_GetPolygonVertex(
                self._gptr, self.index, index, byref(vertex)
            )
        )
        return vertex.to_list()

    def set_vertex(self, index, vertex):
        """Alter the position of a polygon's vertex inside a geometry object.

        :param int index: Polygon vertex index.
        :param vertex: 3D Position of the vertex.
        :type vertex: list of x, y, z coordinate floats
        """
        vvec = VECTOR.from_list(vertex)
        ckresult(
            _dll.FMOD_Geometry_SetPolygonVertex(self._gptr, self.index, index, byref(vvec))
        )


class Geometry(FmodObject):
    """Geometry methods."""

    def add_polygon(self, directocclusion, reverbocclusion, doublesided, *vertices):
        """Add a polygon.

        All vertices must lay in the same plane otherwise behavior may be
        unpredictable. The polygon is assumed to be convex. A non convex
        polygon will produce unpredictable behavior. Polygons with zero area
        will be ignored.

        Polygons cannot be added if already at the maximum number of polygons
        or if the addition of their verticies would result in exceeding the
        maximum number of vertices.

        Vertices of an object are in object space, not world space, and so are
        relative to the position, or center of the object. See
        :py:attr:`position`.

        :param float directocclusion: Occlusion factor of the polygon for the
            direct path where 0 represents no occlusion and 1 represents full
            occlusion.
        :param float reverbocclusion: Occlusion factor of the polygon for the
            reverb path where 0 represents no occlusion and 1 represents full
            occlusion.
        :param bool doublesided: Double sidedness of the polygon.

            - True: Polygon is double sided
            - False: Polygon is single sided, and the winding of the polygon
              (which determines the polygon's normal) determines which side of
              the polygon will cause occlusion.
        :param vertices: At least three vertices located in object space.
        :type vertices: list of list of coordinate floats
        :returns: Polygon index. Use this with other per polygon based
            functions as a handle.
        :rtype: int
        """
        vectors = VECTOR * len(vertices)
        varray = vectors(*vertices)
        idx = c_int()
        self._call_fmod(
            "FMOD_Geometry_AddPolygon",
            c_float(directocclusion),
            c_float(reverbocclusion),
            c_bool(doublesided),
            len(vertices),
            varray,
            byref(idx),
        )
        return idx.value

    @property
    def active(self):
        """Whether an object is processed by the geometry engine.

        :type: bool
        """
        active = c_bool()
        self._call_fmod("FMOD_Geometry_GetActive", byref(active))
        return active.value

    @active.setter
    def active(self, active):
        self._call_fmod("FMOD_Geometry_SetActive", active)

    @property
    def _creation_limits(self):
        """The maximum number of polygons and vertices allocatable for this
        object.

        :type: two-tuple with

            - Maximum possible number of polygons in this object
            - Maximum possible number of vertices in this object
        """
        maxpols, maxverts = (c_int(), c_int())
        self._call_fmod("FMOD_Geometry_GetMaxPolygons", byref(maxpols), byref(maxverts))
        return (maxpols.value, maxverts.value)

    @property
    def max_polygons(self):
        """The maximum number of polygons allocatable for this object.

        :type: int
        """
        return self._creation_limits[0]

    @property
    def max_vertices(self):
        """The maximum number of vertices allocatable for this object.

        :type: int
        """
        return self._creation_limits[1]

    @property
    def num_polygons(self):
        """The number of polygons in this object.

        :type: int
        """
        num = c_int()
        self._call_fmod("FMOD_Geometry_GetNumPolygons", byref(num))
        return num.value

    def get_polygon(self, index):
        """The polygon at the given index.

        :param int index: The polygon index.
        :rtype: PolygonAttributes
        """
        return PolygonAttributes(self._ptr, index)

    @property
    def position(self):
        """The 3D position of the object.

        Position is in world space.

        :type: list of coordinate floats.
        """
        pos = VECTOR()
        self._call_fmod("FMOD_Geometry_GetPosition", byref(pos))
        return pos.to_list()

    @position.setter
    def position(self, pos):
        posv = VECTOR.from_list(pos)
        self._call_fmod("FMOD_Geometry_SetPosition", byref(posv))

    @property
    def _rotation(self):
        """The 3D orientation of the object.

        :type: list of lists of unit length vector coordinates
        """
        fwd_vec = VECTOR()
        up_vec = VECTOR()
        self._call_fmod("FMOD_Geometry_GetRotation", byref(fwd_vec), byref(up_vec))
        return [fwd_vec.to_list(), up_vec.to_list()]

    @_rotation.setter
    def _rotation(self, rot):
        fwd_vec = VECTOR.from_list(rot[0])
        up_vec = VECTOR.from_list(rot[1])
        self._call_fmod("FMOD_Geometry_SetRotation", byref(fwd_vec), byref(up_vec))

    @property
    def forward_rotation(self):
        """Forwards orientation.

        This vector must be of unit length and perpendicular to the up vector.

        :type: list of unit length vector coordinates
        """
        return self._rotation[0]

    @forward_rotation.setter
    def forward_rotation(self, rot):
        rotation = self._rotation
        rotation[0] = rot
        self._rotation = rotation

    @property
    def up_rotation(self):
        """Upwards orientation.

        This vector must be of unit length and perpendicular to the forwards
        vector.

        :type: list of unit length vector coordinates
        """
        return self._rotation[1]

    @up_rotation.setter
    def up_rotation(self, rot):
        rotation = self._rotation
        rotation[1] = rot
        self._rotation = rotation

    @property
    def scale(self):
        """The 3D scale of the object.

        An object can be scaled/warped in all three dimensions separately using
        this function without having to modify polygon data.

        :type: list of three scale dimensions.
        """
        scale = VECTOR()
        self._call_fmod("FMOD_Geometry_GetScale", byref(scale))
        return scale.to_list()

    @scale.setter
    def scale(self, scale):
        scalev = VECTOR.from_list(scale)
        self._call_fmod("FMOD_Geometry_SetScale", byref(scalev))

    def release(self):
        """Free a geometry object and release its memory."""
        self._call_fmod("FMOD_Geometry_Release")

    def save(self):
        """Save the geometry object as a serialized binary block to a user
        memory buffer.

        The data can be saved to a file if required and loaded later with
        :py:meth:`~pyfmodex.system.System.load_geometry`.

        :returns: raw memory data
        """
        size = c_int()
        self._call_fmod("FMOD_Geometry_Save", None, byref(size))
        ptr = create_string_buffer(size.value)
        self._call_fmod("FMOD_Geometry_Save", ptr, byref(size))
        return ptr.raw
