import lzma
from io import BytesIO
from struct import Struct
from typing import BinaryIO, Iterable, List, Literal, Optional, Tuple, TypeVar
from urllib.request import urlopen
from zipfile import ZipFile

from .unityversion import UnityVersion

TPK_URL = "https://nightly.link/AssetRipper/Tpk/workflows/{type}_tpk/{branch}/{compression}_file.zip"

UINT16 = Struct("<H")
INT32 = Struct("<i")
INT64 = Struct("<q")
UINT64 = Struct("<Q")

T = TypeVar("T")


def download_tpk(
    type: Literal["type_tree", "engine_assets"] = "type_tree",
    compression: Literal["brotli", "lz4", "lzma", "uncompressed"] = "lzma",
    branch: str = "master",
    verify: bool = True,
) -> bytes:
    # local import to avoid circular import
    from .file import TpkFile

    url = TPK_URL.format(type=type, branch=branch, compression=compression)
    res = urlopen(url)
    if res.status != 200:
        raise Exception(f"Failed to download TPK file: {res.status} {res.reason}")
    zip_data = res.read()

    with ZipFile(BytesIO(zip_data)) as zip_file:
        tpk_data = zip_file.read(f"{compression}.tpk")

    if verify:
        with BytesIO(tpk_data) as f:
            TpkFile.parse(f).GetDataBlob()
    return tpk_data


def read_string(stream: BinaryIO) -> str:
    # read varint
    shift = 0
    length = 0
    while True:
        (i,) = stream.read(1)
        length |= (i & 0x7F) << shift
        shift += 7
        if not (i & 0x80):
            break
    # read string
    return stream.read(length).decode("utf-8")


def read_data(stream: BinaryIO) -> bytes:
    return stream.read(INT32.unpack(stream.read(INT32.size))[0])


def read_version(stream: BinaryIO) -> UnityVersion:
    return UnityVersion(UINT64.unpack(stream.read(UINT64.size))[0])


def read_versions(stream: BinaryIO, count: int) -> List[UnityVersion]:
    struct = Struct(f"<{count}Q")
    return [UnityVersion(x) for x in struct.unpack(stream.read(struct.size))]


def get_item_for_version(exactVersion: UnityVersion, items: Iterable[Tuple[UnityVersion, T]]) -> T:
    ret: Optional[T] = None
    for version, item in items:
        if exactVersion >= version:
            ret = item
        else:
            break
    if ret is not None:
        return ret
    raise ValueError("Could not find exact version")


def decompress_lzma(data: bytes, read_decompressed_size: bool = False) -> bytes:
    LZMA_STRUCT = Struct("<BI")

    props, dict_size = LZMA_STRUCT.unpack(data[:5])
    lc = props % 9
    remainder = props // 9
    pb = remainder // 5
    lp = remainder % 5
    dec = lzma.LZMADecompressor(
        format=lzma.FORMAT_RAW,
        filters=[
            {
                "id": lzma.FILTER_LZMA1,
                "dict_size": dict_size,
                "lc": lc,
                "lp": lp,
                "pb": pb,
            }
        ],
    )
    data_offset = 13 if read_decompressed_size else 5
    return dec.decompress(data[data_offset:])


__all__ = [
    "UINT16",
    "INT32",
    "INT64",
    "UINT64",
    "download_tpk",
    "read_string",
    "read_data",
    "read_version",
    "read_versions",
    "get_item_for_version",
    "decompress_lzma",
]
