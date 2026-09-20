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

from mmfparser.player.event.player cimport Group
from mmfparser.player.event.evaluater cimport Evaluater, Value
from mmfparser.player.instance cimport Instance
from mmfparser.player.event.common cimport ACEBase

DEF DEBUG = 0

cdef class Expression(ACEBase):
    cdef void initialize(self, loader):
        self.group = self.parent.parent.parent
        self._initialize(loader)
        self._get = getattr(self, 'get', None)
    
    cpdef next_argument(self):
        self.evaluater.go_forward()
        return self.evaluater.evaluate()
        
    cdef object evaluate(self):
        return self._get()
    
    cdef object evaluate_instance(self, Instance instance):
        IF DEBUG:
            try:
                return self._get(instance)
            except:
                import traceback
                traceback.print_exc()
        ELSE:
            return self._get(instance)
    
    cdef void execute(self, Value value):
        if self._iterateObjects:
            result = self.evaluate_instance(self.get_instance())
        else:
            result = self.evaluate()
        value.set(result)

cdef class DummyExpression(Expression):
    cdef void execute(self, Value value):
        pass