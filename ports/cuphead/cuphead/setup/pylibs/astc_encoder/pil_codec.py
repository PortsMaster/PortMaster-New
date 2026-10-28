"""PIL codec for ASTC images.

Importing this module provides an ASTC codec for PIL for encoding and decoding ASTC images.
"""

import struct
from typing import Any, List, Union

from PIL import Image, ImageFile

from astc_encoder import (
    ASTCConfig,
    ASTCConfigFlags,
    ASTCContext,
    ASTCImage,
    ASTCProfile,
    ASTCSwizzle,
    ASTCType,
)


class ASTCEncoder(ImageFile.PyEncoder):  # noqa: D101
    _pushes_fd: bool = True
    context: ASTCContext

    def init(  # noqa: D102
        self,
        args: List[Any],
    ):
        assert len(args) in (4, 5), "Invalid number of arguments"
        profile: int = args[0]
        quality: float = args[1]
        block_width: int = args[2]
        block_height: int = args[3]
        block_depth: int = args[4] if len(args) > 4 else 1

        assert block_depth == 1, "Cannot handle 3D textures"

        config = ASTCConfig(
            ASTCProfile(profile),
            block_width,
            block_height,
            block_depth,
            quality=quality,
        )
        self.context = ASTCContext(config)

    def encode(self, bufsize: int) -> tuple[int, int, bytes]:  # noqa: D102
        assert self.im is not None, "No image set"  # type: ignore

        mode: str = self.mode
        pack_struct: struct.Struct
        if mode == "RGBA":
            swizzle = ASTCSwizzle.from_str("rgba")
            pack_struct = struct.Struct("4B")
        elif mode == "RGB":
            swizzle = ASTCSwizzle.from_str("rgb1")
            pack_struct = struct.Struct("3Bx")
        else:
            raise ValueError(f"Unsupported mode: {mode}")

        pa = self.im.pixel_access()
        data = b"".join(
            pack_struct.pack(*pa[x, y])  # type: ignore
            for y in range(self.state.ysize)
            for x in range(self.state.xsize)
        )

        astc_img = ASTCImage(
            ASTCType.U8,
            self.state.xsize,
            self.state.ysize,
            data=data,
        )
        comp = self.context.compress(astc_img, swizzle)
        return len(comp), 1, comp


Image.register_encoder("astc", ASTCEncoder)


class ASTCDecoder(ImageFile.PyDecoder):  # noqa: D101
    _pull_fd: bool = True
    context: ASTCContext

    def init(self, args: List[Any]):  # noqa: D102
        assert len(args) in (3, 4), "Invalid number of arguments"
        profile: int = ASTCProfile(args[0])
        block_width: int = args[1]
        block_height: int = args[2]
        block_depth: int = args[3] if len(args) > 3 else 1
        assert block_depth == 1, "Cannot handle 3D textures"

        config = ASTCConfig(
            profile,
            block_width,
            block_height,
            block_depth,
            flags=ASTCConfigFlags.DECOMPRESS_ONLY,
        )
        self.context = ASTCContext(config)

    def decode(
        self, buffer: Union[bytes, Image.SupportsArrayInterface]
    ) -> tuple[int, int]:  # noqa: D102
        assert self.state.xoff == 0 and self.state.yoff == 0, "Cannot handle offsets"

        config = self.context.config
        assert self.state.xsize % config.block_x == 0, (
            "Invalid width, must be multiple of block width"
        )
        assert self.state.ysize % config.block_y == 0, (
            "Invalid height, must be multiple of block height"
        )

        block_count_x = (self.state.xsize + config.block_x - 1) // config.block_x
        block_count_y = (self.state.ysize + config.block_y - 1) // config.block_y
        expected_size = block_count_x * block_count_y * 16

        if len(buffer) != expected_size and self.fd is not None:
            buffer = self.fd.read(expected_size)

        if len(buffer) != expected_size:
            raise ValueError("Not enough data")

        astc_img = ASTCImage(
            ASTCType.U8,
            self.state.xsize,
            self.state.ysize,
        )

        mode: str = self.mode
        if mode == "RGBA":
            swizzle = ASTCSwizzle.from_str("rgba")
        elif mode == "RGB":
            swizzle = ASTCSwizzle.from_str("rgb1")
        else:
            # TODO: LA, L
            raise ValueError(f"Unsupported mode: {mode}")

        self.context.decompress(buffer, astc_img, swizzle)

        self.set_as_raw(astc_img.data, "RGBA")
        return -1, 0


Image.register_decoder("astc", ASTCDecoder)
