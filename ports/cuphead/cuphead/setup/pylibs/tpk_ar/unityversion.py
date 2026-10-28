from typing import Tuple


class UnityVersion(int):
    """Minimal UnityVersion class to avoid hard dependency on UnityPy"""

    def as_tuple(self) -> Tuple[int, int, int, int, int]:
        major = (self >> 48) & 0xFFFF
        minor = (self >> 32) & 0xFFFF
        build = (self >> 16) & 0xFFFF
        vtype = (self >> 8) & 0xFF
        type_number = self & 0xFF
        return major, minor, build, vtype, type_number

    def __str__(self) -> str:
        return ".".join(map(str, self.as_tuple()))

    def __repr__(self) -> str:
        return f"UnityVersion({self.__str__()})"


try:
    from UnityPy.helpers.UnityVersion import UnityVersion  # pyright: ignore[reportMissingImports]
except ImportError:
    pass

__all__ = ["UnityVersion"]
