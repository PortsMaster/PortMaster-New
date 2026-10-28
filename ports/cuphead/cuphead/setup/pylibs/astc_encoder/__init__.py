"""astc-encoder-py is a  Python binding of [astc-encoder](https://github.com/ARM-software/astc-encoder).

It can compress images into astc textures and decompress astc textures into images.
To yield the best performance, it checks the host CPU and imports the appropriate encoder implementation.
Currently this is only supported on x86_64, all others use an encoder with no SIMD optimizations.
The exception is aarch64, which uses the neon encoder by default.
"""

__version__ = "0.1.12"

from .enum import (
    ASTCConfigFlags as ASTCConfigFlags,
    ASTCProfile as ASTCProfile,
    ASTCQualityPreset as ASTCQualityPreset,
    ASTCSwizzleComponentSelector as ASTCSwizzleComponentSelector,
    ASTCType as ASTCType,
)

from .encoder import (
    ASTCConfig as ASTCConfig,
    ASTCContext as ASTCContext,
    ASTCImage as ASTCImage,
    ASTCSwizzle as ASTCSwizzle,
    ASTCError as ASTCError,
    compute_error_metrics as compute_error_metrics,
)
