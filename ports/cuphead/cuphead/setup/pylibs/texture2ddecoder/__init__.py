"""
A python wrapper for [Perfare](https://github.com/Perfare)'s [Texture2DDecoder](https://github.com/Perfare/AssetStudio/tree/master/Texture2DDecoder).

Some changes were made to the original code to make it cross-platform compatible.
"""

__version__ = "1.0.6"

from ._texture2ddecoder import (
    decode_bc1 as decode_bc1,
    decode_bc3 as decode_bc3,
    decode_bc4 as decode_bc4,
    decode_bc5 as decode_bc5,
    decode_bc6 as decode_bc6,
    decode_bc7 as decode_bc7,
    decode_atc_rgb4 as decode_atc_rgb4,
    decode_atc_rgba8 as decode_atc_rgba8,
    decode_etc1 as decode_etc1,
    decode_etc2 as decode_etc2,
    decode_etc2a1 as decode_etc2a1,
    decode_etc2a8 as decode_etc2a8,
    decode_eacr as decode_eacr,
    decode_eacr_signed as decode_eacr_signed,
    decode_eacrg as decode_eacrg,
    decode_eacrg_signed as decode_eacrg_signed,
    decode_astc as decode_astc,
    decode_pvrtc as decode_pvrtc,
    unpack_crunch as unpack_crunch,
    unpack_unity_crunch as unpack_unity_crunch,
)
