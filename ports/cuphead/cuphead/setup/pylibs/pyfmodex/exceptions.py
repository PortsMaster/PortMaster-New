"""Fmod Exceptions."""


class FmodError(Exception):
    """Wrapper FmodError.

    Raised whenever a C library call does not return an OK.
    """

    def __init__(self, result):
        self.message = result.name.replace("_", " ")
        super().__init__(self.message)
        self.result = result

    def __str__(self):
        return self.message
