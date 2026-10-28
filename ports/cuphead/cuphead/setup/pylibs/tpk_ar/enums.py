from enum import IntEnum, IntFlag


class TpkCompressionType(IntEnum):
    NONE = 0
    Lz4 = 1
    Lzma = 2
    Brotli = 3


class TpkDataType(IntEnum):
    TypeTreeInformation = 0
    Collection = 1
    FileSystem = 2
    Json = 3
    ReferenceAssemblies = 4
    EngineAssets = 5


class TpkUnityClassFlags(IntFlag):
    NONE = 0
    IsAbstract = 1
    IsSealed = 2
    IsEditorOnly = 4
    IsReleaseOnly = 8
    IsStripped = 16
    Reserved = 32
    HasEditorRootNode = 64
    HasReleaseRootNode = 128


__all__ = [
    "TpkCompressionType",
    "TpkDataType",
    "TpkUnityClassFlags",
]
