# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

include "is_pypy.pxi"

cdef class DataLoader:
    def __init__(self, reader = None, parent = None, **settings):
        self.init(reader, parent, settings)

    cdef bint init(self, ByteReader reader, DataLoader parent,
                   dict settings) except False:
        self.parent = parent
        self.settings = settings
        IF IS_PYPY:
            getattr(self, 'initialize')()
        ELSE:
            self.initialize()
        if reader is not None:
            self.read(reader)
        return True

    def new(self, type loaderClass, reader = None, **kw):
        (<dict>kw).update(self.settings)
        cdef DataLoader newLoader = loaderClass.__new__(loaderClass)
        newLoader.init(reader, self, kw)
        return newLoader

    cpdef readString(self, ByteReader reader, size=None):
        if self.settings.get('unicode', False):
            return reader.readUnicodeString(size).encode('utf-8')
        else:
            return reader.readString(size)

    cpdef initialize(self):
        return

    cpdef read(self, ByteReader reader):
        IF IS_PYPY:
            return getattr(self, 'read')(reader)
        ELSE:
            raise NotImplementedError('%s has not implemented a read method' %
                self.__class__.__name__)

    def generate(self):
        newReader = ByteReader()
        self.write(newReader)
        return newReader

    def write(self, reader):
        raise NotImplementedError('%s has not implemented a write method' %
            self.__class__.__name__)