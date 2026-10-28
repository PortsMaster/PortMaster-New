"""The enumeration classes for the ASTC encoder."""

from enum import IntEnum, IntFlag


class ASTCProfile(IntEnum):
    """A codec color profile.

    Attributes
    ----------
    LDR_SRGB : int = 0
        The LDR sRGB color profile.
    LDR : int = 1
        The LDR linear color profile.
    HDR_RGB_LDR_A : int = 2
        The HDR RGB with LDR alpha color profile.
    HDR : int = 3
        The HDR RGB color profile.
    """

    LDR_SRGB = 0
    LDR = 1
    HDR_RGB_LDR_A = 2
    HDR = 3


class ASTCQualityPreset(IntEnum):
    """The quality presets.

    These values are just presets, the user can set the quality to any value between 0 and 100.

    Attributes
    ----------
    FASTEST : int = 0
        The fastest, lowest quality, search preset.
    FAST : int = 10
        The fast search preset.
    MEDIUM : int = 60
        The medium quality search preset.
    THOROUGH : int = 98
        The thorough quality search preset.
    VERYTHOROUGH : int = 99
        The very thorough quality search preset.
    EXHAUSTIVE : int = 100
        The exhaustive, highest quality, search preset.
    """

    FASTEST = 0
    FAST = 10
    MEDIUM = 60
    THOROUGH = 98
    VERYTHOROUGH = 99
    EXHAUSTIVE = 100


class ASTCConfigFlags(IntFlag):
    """The configuration flags.

    Attributes
    ----------
    MAP_NORMAL : int = 1 << 0
        Enable normal map compression.

        Input data will be treated a two component normal map,
        storing X and Y, and the codec will optimize for angular error rather than simple linear PSNR.
        In this mode the input swizzle should be e.g.
        - rrrg (the default ordering for ASTC normals on the command line)
        - gggr (the ordering used by BC5n)

    USE_DECODE_UNORM8 : int = 1 << 1
        Enable compression heuristics that assume use of decode_unorm8 decode mode.

        The decode_unorm8 decode mode rounds differently to the decode_fp16 decode mode,
        so enabling this flag during compression will allow the compressor to use
        the correct rounding when selecting encodings.
        This will improve the compressed image quality if your application is using the decode_unorm8 decode mode,
        but will reduce image quality if using decode_fp16.
        Note that LDR_SRGB images will always use decode_unorm8 for the RGB channels,
        irrespective of this setting.

    USE_APLHA_WEIGHT : int = 1 << 2
        Enable alpha weighting.

        The input alpha value is used for transparency, so errors in the RGB components are weighted by
        the transparency level. This allows the codec to more accurately encode the alpha value in areas
        where the color value is less significant.
    USE_PERCEPTUAL : int = 1 << 3
        Enable perceptual error metrics.

        This mode enables perceptual compression mode, which will optimize for perceptual error rather
        than best PSNR. Only some input modes support perceptual error metrics.

    SELF_DECOMPRESS_ONLY : int = 1 << 4
        Create a self-decompression context.

        This mode configures the compressor so that it is only guaranteed to be able to decompress images
        that were actually created using the current context.
        This is the common case for compression use cases, and setting this flag enables additional optimizations,
        but does mean that the context cannot reliably decompress arbitrary ASTC images.

    MAP_RGBM : int = 1 << 6
        Enable RGBM map compression.

        Input data will be treated as HDR data that has been stored in an LDR RGBM-encoded wrapper format.
        Data must be preprocessed by the user to be in LDR RGBM format before calling the compression function,
        this flag is only used to control the use of RGBM-specific heuristics and error metrics.

        **IMPORTANT**:

        The ASTC format is prone to bad failure modes with unconstrained RGBM data;
        very small M values can round to zero due to quantization and result in black or white pixels.
        It is highly recommended that the minimum value of M used in the encoding is kept above a lower threshold (try 16 or 32).
        Applying this threshold reduces the number of very dark colors that can be represented,
        but is still higher precision than 8-bit LDR.

        When this flag is set the value of ``c rgbm_m_scale`` in the context must be set to the RGBM scale factor used during reconstruction.
        This defaults to 5 when in RGBM mode.
        It is recommended that the value of ``c cw_a_weight`` is set to twice the value of the multiplier scale,
        ensuring that the M value is accurately encoded.
        This defaults to 10 when in RGBM mode, matching the default scale factor.
    """

    MAP_NORMAL = 1 << 0
    USE_DECODE_UNORM8 = 1 << 1
    USE_APLHA_WEIGHT = 1 << 2
    USE_PERCEPTUAL = 1 << 3
    DECOMPRESS_ONLY = 1 << 4
    SELF_DECOMPRESS_ONLY = 1 << 5
    MAP_RGBM = 1 << 6


class ASTCType(IntEnum):
    """A texel component data format.

    Attributes
    ----------
    U8 : int = 0
        Unorm 8-bit data per component.
    F16 : int = 1
        16-bit float per component.
    F32 : int = 2
        32-bit float per component.
    """

    U8 = 0
    F16 = 1
    F32 = 2


class ASTCSwizzleComponentSelector(IntEnum):
    """A codec component swizzle selector.

    Attributes
    ----------
    R : int = 0
        Select the red component.
    G : int = 1
        Select the green component.
    B : int = 2
        Select the blue component.
    A : int = 3
        Select the alpha component.
    ZERO : int = 4
        Use a constant zero component.
    ONE : int = 5
        Use a constant one component.
    Z : int = 6
        Use a reconstructed normal vector Z component.
    """

    R = 0
    G = 1
    B = 2
    A = 3
    ZERO = 4
    ONE = 5
    Z = 6


__all__ = (
    "ASTCProfile",
    "ASTCQualityPreset",
    "ASTCConfigFlags",
    "ASTCType",
    "ASTCSwizzleComponentSelector",
)
