from dataclasses import dataclass
from struct import Struct
from typing import Any, BinaryIO, ClassVar, Dict, List, Optional, Tuple

from .enums import TpkUnityClassFlags
from .unityversion import UnityVersion
from .utils import INT32, UINT16, get_item_for_version, read_version


@dataclass(unsafe_hash=True, frozen=True)
class TpkUnityClass:
    __slots__ = ("Name", "Base", "Flags", "EditorRootNode", "ReleaseRootNode")
    ParserStruct: ClassVar[Struct] = Struct("<HHB")
    Name: int
    Base: int
    Flags: TpkUnityClassFlags
    EditorRootNode: Optional[int]
    ReleaseRootNode: Optional[int]

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkUnityClass":
        Name, Base, Flags = TpkUnityClass.ParserStruct.unpack(stream.read(TpkUnityClass.ParserStruct.size))
        editorRootNode = releaseRootNode = None
        if Flags & TpkUnityClassFlags.HasEditorRootNode:
            (editorRootNode,) = UINT16.unpack(stream.read(UINT16.size))
        if Flags & TpkUnityClassFlags.HasReleaseRootNode:
            (releaseRootNode,) = UINT16.unpack(stream.read(UINT16.size))

        return cls(
            Name=Name,
            Base=Base,
            Flags=TpkUnityClassFlags(Flags),
            EditorRootNode=editorRootNode,
            ReleaseRootNode=releaseRootNode,
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "Name": self.Name,
            "Base": self.Base,
            "Flags": TpkUnityClassFlags(self.Flags),
            "EditorRootNode": self.EditorRootNode,
            "ReleaseRootNode": self.ReleaseRootNode,
        }


class TpkClassInformation(List[Tuple[UnityVersion, Optional[TpkUnityClass]]]):
    ID: int

    def __init__(self, entries: List[Tuple[UnityVersion, Optional[TpkUnityClass]]], ID: int):
        super().__init__(entries)
        self.ID = ID

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkClassInformation":
        (ID,) = INT32.unpack(stream.read(INT32.size))
        (count,) = INT32.unpack(stream.read(INT32.size))
        entries = [
            (read_version(stream), TpkUnityClass.parse(stream) if stream.read(1)[0] else None) for _ in range(count)
        ]
        instance = cls(entries, ID)
        return instance

    def getVersionedClass(self, version: UnityVersion) -> Optional[TpkUnityClass]:
        return get_item_for_version(version, self)


@dataclass(unsafe_hash=True, frozen=True)
class TpkUnityNode:
    __slots__ = (
        "TypeName",
        "Name",
        "ByteSize",
        "Version",
        "TypeFlags",
        "MetaFlag",
        "SubNodes",
    )
    ParserStruct: ClassVar[Struct] = Struct("<HHihBIH")
    TypeName: int
    Name: int
    ByteSize: int
    Version: int
    TypeFlags: int
    MetaFlag: int
    SubNodes: Tuple[int]

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkUnityNode":
        (
            TypeName,
            Name,
            ByteSize,
            Version,
            TypeFlags,
            MetaFlag,
            count,
        ) = cls.ParserStruct.unpack(stream.read(cls.ParserStruct.size))

        SubNodeStruct = Struct(f"<{count}H")
        SubNodes = SubNodeStruct.unpack(stream.read(SubNodeStruct.size))

        return cls(
            TypeName=TypeName,
            Name=Name,
            ByteSize=ByteSize,
            Version=Version,
            TypeFlags=TypeFlags,
            MetaFlag=MetaFlag,
            SubNodes=SubNodes,
        )


class TpkUnityNodeBuffer(List[TpkUnityNode]):
    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkUnityNodeBuffer":
        (count,) = INT32.unpack(stream.read(INT32.size))
        return cls(TpkUnityNode.parse(stream) for _ in range(count))


__all__ = ["TpkUnityClass", "TpkClassInformation", "TpkUnityNode", "TpkUnityNodeBuffer"]
