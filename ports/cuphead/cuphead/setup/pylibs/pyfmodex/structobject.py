"""A dict like object.

Implementation from http://benlast.livejournal.com/12301.html with unnecessary
zope security flag removed.
"""


class Structobject:
    """A 'bag' with keyword initialization, dict-semantics emulation and key
    iteration.
    """

    def __init__(self, **kw):
        """Initialize, and set attributes from all keyword arguments."""
        self.__members = []
        for k in list(kw.keys()):
            setattr(self, k, kw[k])
            self.__remember(k)

    def __remember(self, k):
        """Add k to the list of explicitly set values."""
        if k not in self.__members:
            self.__members.append(k)

    def __getitem__(self, key):
        """Equivalent of dict access by key."""
        try:
            return getattr(self, key)
        except AttributeError as attrerr:
            raise KeyError(key) from attrerr

    def __setitem__(self, key, value):
        setattr(self, key, value)
        self.__remember(key)

    def has_key(self, key):
        """wheter this Structobject contains a value for the given key.

        :rtype: bool
        """
        return hasattr(self, key)

    def keys(self):
        """All keys this Structobject has values for.

        :rtype: list
        """
        return self.__members

    def iterkeys(self):
        """All keys this Structobject has values for.

        :rtype: list
        """
        return self.__members

    def __iter__(self):
        return iter(self.__members)

    def __str__(self):
        """Describe those attributes explicitly set."""
        string = ""
        for member in self.__members:
            value = getattr(self, member)
            if string:
                string += ", "
            string += "%string: %string" % (member, repr(value))
        return string
