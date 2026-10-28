from abc import ABC, abstractmethod
from dataclasses import dataclass
from struct import Struct
from typing import BinaryIO, Dict, List, NamedTuple, Optional, Tuple

from .unityversion import UnityVersion
from .utils import INT32, get_item_for_version, read_string, read_version


class TpkStringBuffer(Tuple[str]):
    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkStringBuffer":
        count = INT32.unpack(stream.read(INT32.size))[0]
        return cls(read_string(stream) for _ in range(count))


class TpkCommonString(ABC):
    @classmethod
    def parseWithVersion(cls, stream: BinaryIO, version: int) -> "TpkCommonString":
        if version == 1:
            return TpkCommonStringV1.parse(stream)
        elif version == 2:
            return TpkCommonStringV2.parse(stream)
        else:
            raise Exception(f"Invalid TPK version number: {version}")

    @classmethod
    @abstractmethod
    def parse(cls, stream: BinaryIO) -> "TpkCommonString": ...

    @abstractmethod
    def GetStrings(self, buffer: TpkStringBuffer) -> List[str]:
        """
        legacy method of V1
        returns all strings in the buffer, regardless of version
        """
        ...

    @abstractmethod
    def GetCount(self, exactVersion: UnityVersion) -> int:
        """
        legacy method of V1
        returns the number of strings in the buffer for a specific version
        """
        ...

    @abstractmethod
    def BuildMap(self, buffer: TpkStringBuffer, version: Optional[UnityVersion] = None) -> Dict[int, str]:
        """
        method of V2
        returns a dictionary mapping offsets to strings for a specific version
        if version is None, returns the latest version's mapping
        """
        ...


@dataclass(unsafe_hash=True, frozen=True)
class TpkCommonStringV1(TpkCommonString):
    __slots__ = ("VersionInformation", "StringBufferIndices")
    VersionInformation: List[Tuple[UnityVersion, int]]
    StringBufferIndices: Tuple[int, ...]

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkCommonStringV1":
        (versionCount,) = INT32.unpack(stream.read(INT32.size))
        versionInformation = [(read_version(stream), stream.read(1)[0]) for _ in range(versionCount)]
        (indicesCount,) = INT32.unpack(stream.read(INT32.size))
        indicesStruct = Struct(f"<{indicesCount}H")
        stringBufferIndices = indicesStruct.unpack(stream.read(indicesStruct.size))
        return cls(VersionInformation=versionInformation, StringBufferIndices=stringBufferIndices)

    def GetStrings(self, buffer: TpkStringBuffer) -> List[str]:
        return [buffer[i] for i in self.StringBufferIndices]

    def GetCount(self, exactVersion: UnityVersion) -> int:
        return get_item_for_version(exactVersion, self.VersionInformation)

    def BuildMap(self, buffer: TpkStringBuffer, version: Optional[UnityVersion] = None) -> Dict[int, str]:
        strings = self.GetStrings(buffer)
        if version:
            count = self.GetCount(version)
            strings = strings[:count]

        ret: Dict[int, str] = {}
        offset = 0
        for string in strings:
            ret[offset] = string
            offset += len(string) + 1

        return ret


@dataclass(unsafe_hash=True, frozen=True)
class TpkCommonStringV2(TpkCommonString):
    __slots__ = ("VersionInformation",)
    VersionInformation: Dict[UnityVersion, List["TpkCommonStringV2.Entry"]]

    class Entry(NamedTuple):
        offset: int
        stringIndex: int

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkCommonStringV2":
        (versionCount,) = INT32.unpack(stream.read(INT32.size))
        versionInformation = {}
        for version in range(versionCount):
            version = read_version(stream)
            entryCount = INT32.unpack(stream.read(INT32.size))[0]
            entryDataStruct = Struct(f"<{entryCount * 2}H")  # *2 for offset and stringIndex
            entryData = entryDataStruct.unpack(stream.read(entryDataStruct.size))
            entries = [cls.Entry(offset, stringIndex) for offset, stringIndex in zip(entryData[::2], entryData[1::2])]
            versionInformation[version] = entries
        return cls(VersionInformation=versionInformation)

    def GetStrings(self, buffer: TpkStringBuffer) -> List[str]:
        version = list(self.VersionInformation.values())[-1]  # Get the latest version's entries
        return [buffer[entry.stringIndex] for entry in version]

    def GetCount(self, exactVersion: UnityVersion) -> int:
        entries = get_item_for_version(exactVersion, self.VersionInformation.items())
        return len(entries)

    def BuildMap(self, buffer: TpkStringBuffer, version: Optional[UnityVersion] = None) -> Dict[int, str]:
        if version is None:
            # Use the latest version
            version = max(self.VersionInformation.keys())
        entries = get_item_for_version(version, self.VersionInformation.items())
        if entries is None:
            raise ValueError(f"No entries found for version {version}")

        ret: Dict[int, str] = {entry.offset: buffer[entry.stringIndex] for entry in entries}

        return ret


__all__ = ["TpkStringBuffer", "TpkCommonString", "TpkCommonStringV1", "TpkCommonStringV2"]
