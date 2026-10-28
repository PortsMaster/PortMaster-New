import sys
from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import BinaryIO, ClassVar, Dict, List, Tuple

if sys.version_info >= (3, 11):
    from typing import Self
else:
    from typing_extensions import Self

from .enums import TpkDataType
from .string import TpkCommonString, TpkStringBuffer
from .unity import TpkClassInformation, TpkUnityNodeBuffer
from .unityversion import UnityVersion
from .utils import INT32, INT64, read_data, read_string, read_version, read_versions


class TpkDataBlob(metaclass=ABCMeta):
    DataType: ClassVar[TpkDataType]

    @classmethod
    @abstractmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> Self: ...

    @staticmethod
    def parse_with_type(tpk_type: TpkDataType, stream: BinaryIO, version: int = 2) -> "TpkDataBlob":
        if tpk_type == TpkDataType.TypeTreeInformation:
            return TpkTypeTreeBlob.parse(stream, version)
        elif tpk_type == TpkDataType.Collection:
            return TpkCollectionBlob.parse(stream, version)
        elif tpk_type == TpkDataType.FileSystem:
            return TpkFileSystemBlob.parse(stream, version)
        elif tpk_type == TpkDataType.Json:
            return TpkJsonBlob.parse(stream, version)
        elif tpk_type == TpkDataType.EngineAssets:
            return TpkEngineAssetsBlob.parse(stream, version)
        else:
            raise Exception("Unimplemented TpkDataType -> Blob conversion")


@dataclass(unsafe_hash=True, frozen=True)
class TpkTypeTreeBlob(TpkDataBlob):
    __slots__ = (
        "CreationTime",
        "Versions",
        "ClassInformation",
        "CommonString",
        "NodeBuffer",
        "StringBuffer",
    )
    CreationTime: int
    Versions: List[UnityVersion]
    ClassInformation: Dict[int, TpkClassInformation]
    CommonString: TpkCommonString
    NodeBuffer: TpkUnityNodeBuffer
    StringBuffer: TpkStringBuffer
    DataType: ClassVar[TpkDataType] = TpkDataType.TypeTreeInformation

    @classmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> "TpkTypeTreeBlob":
        (CreationTime,) = INT64.unpack(stream.read(INT64.size))
        (versionCount,) = INT32.unpack(stream.read(INT32.size))
        Versions = read_versions(stream, versionCount)
        (classCount,) = INT32.unpack(stream.read(INT32.size))
        ClassInformation = {x.ID: x for x in (TpkClassInformation.parse(stream) for _ in range(classCount))}
        CommonString = TpkCommonString.parseWithVersion(stream, version)
        NodeBuffer = TpkUnityNodeBuffer.parse(stream)
        StringBuffer = TpkStringBuffer.parse(stream)

        return cls(
            CreationTime=CreationTime,
            Versions=Versions,
            ClassInformation=ClassInformation,
            CommonString=CommonString,
            NodeBuffer=NodeBuffer,
            StringBuffer=StringBuffer,
        )


@dataclass(unsafe_hash=True, frozen=True)
class TpkCollectionBlob(TpkDataBlob):
    __slots__ = ("Blobs",)
    Blobs: List[Tuple[str, TpkDataBlob]]
    DataType: ClassVar[TpkDataType] = TpkDataType.Collection

    @classmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> "TpkCollectionBlob":
        (count,) = INT32.unpack(stream.read(INT32.size))
        Blobs = [
            # relativePath, data
            (
                read_string(stream),
                TpkDataBlob.parse_with_type(TpkDataType(stream.read(1)[0]), stream, version),
            )
            for _ in range(count)
        ]
        return cls(Blobs=Blobs)


@dataclass(unsafe_hash=True, frozen=True)
class TpkFileSystemBlob(TpkDataBlob):
    __slots__ = ("Files",)
    # TODO: check if dict might be better
    Files: List[Tuple[str, bytes]]
    DataType: ClassVar[TpkDataType] = TpkDataType.FileSystem

    @classmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> "TpkFileSystemBlob":
        (count,) = INT32.unpack(stream.read(INT32.size))
        Files = [
            # relativePath, data
            (read_string(stream), read_data(stream))
            for _ in range(count)
        ]
        return cls(Files=Files)


@dataclass(unsafe_hash=True, frozen=True)
class TpkJsonBlob(TpkDataBlob):
    __slots__ = ("Text",)
    Text: str
    DataType: ClassVar[TpkDataType] = TpkDataType.Json

    @classmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> "TpkJsonBlob":
        Text = read_string(stream)
        return cls(Text=Text)


@dataclass(unsafe_hash=True, frozen=True)
class TpkEngineAssetsBlob(TpkDataBlob):
    __slots__ = ("CreationTime", "Versions", "Data")
    CreationTime: int
    Versions: List[UnityVersion]
    Data: Dict[UnityVersion, str]  # List[TpkClassInformation]
    DataType: ClassVar[TpkDataType] = TpkDataType.EngineAssets

    @classmethod
    def parse(cls, stream: BinaryIO, version: int = 2) -> "TpkEngineAssetsBlob":
        (CreationTime,) = INT64.unpack(stream.read(INT64.size))
        (versionCount,) = INT32.unpack(stream.read(INT32.size))
        Versions = read_versions(stream, versionCount)
        (dataCount,) = INT32.unpack(stream.read(INT32.size))
        Data = {}
        for _ in range(dataCount):
            version = read_version(stream)
            json = read_string(stream)
            Data[version] = json

        return cls(CreationTime=CreationTime, Versions=Versions, Data=Data)


__all__ = [
    "TpkDataBlob",
    "TpkTypeTreeBlob",
    "TpkCollectionBlob",
    "TpkFileSystemBlob",
    "TpkJsonBlob",
    "TpkEngineAssetsBlob",
]
