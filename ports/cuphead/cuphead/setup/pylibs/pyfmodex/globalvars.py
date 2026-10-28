"""Global variables."""

# Will be filled in __init__.py.
class_list = {}
DLL = None


def get_class(classname):
    """Get the class object from the given string.

    :param str classname: Class name.
    :rtype: class
    """
    return class_list[classname]
