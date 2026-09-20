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

import traceback

paths = ['extensions', 'mmfparser.player.extensions']
loaded_extensions = {}
loaded_movements = {}

def get_extension(ext):
    try:
        return loaded_extensions[ext]
    except KeyError:
        pass
    exceptions = []
    for path in paths:
        for name in (ext, ext + 'ext'):
            try:
                module = __import__(path, locals(), globals(), [name])
                extension = getattr(module, name).get_extension()
                loaded_extensions[name] = extension
                return extension
            except (ImportError, AttributeError), e:
                exceptions.append(e)
    print 'Extension %s could not be found:' % ext
    print exceptions

def get_movement(name):
    try:
        return loaded_movements[name]
    except KeyError:
        pass
    exceptions = []
    for path in paths:
        try:
            module = __import__(path, locals(), 
                globals(), [name])
            extension = getattr(module, name).get_movement()
            loaded_movements[name] = extension
            return extension
        except (ImportError, AttributeError), e:
            exceptions.append(traceback.format_exc())
    print 'Movement %s could not be found:' % name
    for exception in e:
        print e