from dataclasses import dataclass
from io import BytesIO
from struct import Struct
from typing import BinaryIO, ClassVar

from .blob import TpkDataBlob
from .enums import TpkCompressionType, TpkDataType
from .utils import decompress_lzma

TPK_VERSIONS = [1, 2]


@dataclass(unsafe_hash=True, frozen=True)
class TpkFile:
    ParserStruct: ClassVar[Struct] = Struct("<IBBBBIII")
    TpkMagicBytes: ClassVar[int] = 0x2A4B5054  # b"TPK*"
    TpkVersionNumber: int
    CompressionType: TpkCompressionType
    DataType: TpkDataType
    CompressedSize: int
    UncompressedSize: int
    CompressedBytes: bytes

    @classmethod
    def parse(cls, stream: BinaryIO) -> "TpkFile":
        (
            magic,
            versionNumber,
            compressionType,
            dataType,
            _,
            _,
            CompressedSize,
            UncompressedSize,
        ) = TpkFile.ParserStruct.unpack(stream.read(TpkFile.ParserStruct.size))
        if magic != TpkFile.TpkMagicBytes:
            raise Exception("Invalid TPK magic bytes")
        if versionNumber not in TPK_VERSIONS:
            raise Exception(f"Invalid TPK version number: {versionNumber}")
        TpkVersionNumber = versionNumber
        CompressionType = TpkCompressionType(compressionType)
        DataType = TpkDataType(dataType)
        CompressedBytes = stream.read(CompressedSize)
        if len(CompressedBytes) != CompressedSize:
            raise Exception("Invalid compressed size")

        return cls(
            TpkVersionNumber=TpkVersionNumber,
            CompressionType=CompressionType,
            DataType=DataType,
            CompressedSize=CompressedSize,
            UncompressedSize=UncompressedSize,
            CompressedBytes=CompressedBytes,
        )

    def GetDataBlob(self) -> TpkDataBlob:
        decompressed: bytes
        if self.CompressionType == TpkCompressionType.NONE:
            decompressed = self.CompressedBytes

        elif self.CompressionType == TpkCompressionType.Lz4:
            import lz4.block

            decompressed = lz4.block.decompress(self.CompressedBytes, self.UncompressedSize)

        elif self.CompressionType == TpkCompressionType.Lzma:
            decompressed = decompress_lzma(self.CompressedBytes)

        elif self.CompressionType == TpkCompressionType.Brotli:
            import brotli

            decompressed = brotli.decompress(self.CompressedBytes)

        else:
            raise Exception("Invalid compression type")

        assert len(decompressed) == self.UncompressedSize, "Decompressed size does not match uncompressed size"
        return TpkDataBlob.parse_with_type(self.DataType, BytesIO(decompressed), self.TpkVersionNumber)


__all__ = ["TpkFile", "TPK_VERSIONS"]
