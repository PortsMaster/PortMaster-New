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

import os
import tempfile

__all__ = ('NamedTemporaryFile', 'gettempdir',)

if os.name == 'nt':
    class TemporaryFile(object):
        """
        Temporary file object constructor that works in Windows and supports
        reopening of the temporary file in windows.
        """
        def __init__(self, mode='w+b', bufsize=-1, suffix='', prefix='',
                dir=None):
            fd, name = tempfile.mkstemp(suffix=suffix, prefix=prefix,
                                          dir=dir)
            self.name = name
            self.file = os.fdopen(fd, mode, bufsize)
            self.close_called = False

        # Because close can be called during shutdown
        # we need to cache os.unlink and access it
        # as self.unlink only
        # unlink = os.unlink

        def close(self):
            if not self.close_called:
                self.close_called = True
                try:
                    self.file.close()
                except (OSError, IOError):
                    pass
                try:
                    os.unlink(self.name)
                except (OSError):
                    pass

        def __del__(self):
            self.close()

        def read(self, *args):          return self.file.read(*args)
        def seek(self, offset):         return self.file.seek(offset)
        def write(self, s):             return self.file.write(s)
        def flush(self):                return self.file.flush()
        def __iter__(self):             return iter(self.file)
        def readlines(self, size=None): return self.file.readlines(size)
        def xreadlines(self):           return self.file.xreadlines()

    NamedTemporaryFile = TemporaryFile
else:
    NamedTemporaryFile = tempfile.NamedTemporaryFile

gettempdir = tempfile.gettempdir
