from enum import Enum, IntEnum
from ctypes import *


class MaterialNames(Enum):
    kTransparent = 0
    kAcousticCeilingTiles = 1
    kBrickBare = 2
    kBrickPainted = 3
    kConcreteBlockCoarse = 4
    kConcreteBlockPainted = 5
    kCurtainHeavy = 6
    kFiberGlassInsulation = 7
    kGlassThin = 8
    kGlassThick = 9
    kGrass = 10
    kLinoleumOnConcrete = 11
    kMarble = 12
    kMetal = 13
    kParquetOnConcrete = 14
    kPlasterRough = 15
    kPlasterSmooth = 16
    kPlywoodPanel = 17
    kPolishedConcreteOrTile = 18
    kSheetrock = 19
    kWaterOrIceSurface = 20
    kWoodCeiling = 21
    kWoodPanel = 22
    kUniform = 23
    kNumMaterialNames = 24


class RoomProperties(Structure):
    _fields_ = [
        ("position", c_float * 3),  # {0.0f, 0.0f, 0.0f},
        ("rotation", c_float * 4),  # {0.0f, 0.0f, 0.0f, 1.0f},
        ("dimensions", c_float * 3),  # {0.0f, 0.0f, 0.0f},
        (
            "material_names",
            c_int * 6,
        ),  # {MaterialName::kTransparent, MaterialName::kTransparent,MaterialName::kTransparent, MaterialName::kTransparent,MaterialName::kTransparent, MaterialName::kTransparent},
        ("reflection_scalar", c_float),  # (1.0f),
        ("reverb_gain", c_float),  # (1.0f),
        ("reverb_time", c_float),  # (1.0f),
        ("reverb_brightness", c_float),  # (0.0f)
    ]

    def __init__(self, *args, **kwargs):
        Structure.__init__(self, *args, **kwargs)
        self.position = (c_float * 3)(0.0, 0.0, 0.0)
        self.rotation = (c_float * 4)(0.0, 0.0, 0.0, 1.0)
        self.dimensions = (c_float * 3)(1.0, 1.0, 1.0)
        self.material_names = (c_int * 6)(
            MaterialNames.kTransparent.value,
            MaterialNames.kTransparent.value,
            MaterialNames.kTransparent.value,
            MaterialNames.kTransparent.value,
            MaterialNames.kTransparent.value,
            MaterialNames.kTransparent.value,
        )
        self.reflection_scalar = 1.0
        self.reverb_gain = 1.0
        self.reverb_time = 1.0
        self.reverb_brightness = 0.0

    def set_position(self, x, y, z):
        self.position[0] = x
        self.position[1] = y
        self.position[2] = z

    def set_rotation(self, x, y, z, w):
        self.rotation[0] = x
        self.rotation[1] = y
        self.rotation[2] = z
        self.rotation[3] = w

    def set_dimensions(self, x, y, z):
        self.dimensions[0] = x
        self.dimensions[1] = y
        self.dimensions[2] = z

    def set_materials(self, left, right, botton, up, front, back):
        self.material_names[0] = left.value
        self.material_names[1] = right.value
        self.material_names[2] = botton.value
        self.material_names[3] = up.value
        self.material_names[4] = front.value
        self.material_names[5] = back.value
