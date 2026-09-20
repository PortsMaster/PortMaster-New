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

from mmfparser.player.instance cimport Instance
from mmfparser.player.event.common cimport ACBase, ACEBase, ExpressionList

DEF DEBUG = 0

cdef class Action(ACBase):
    cdef void initialize(self, loader):
        self._initialize(loader)
        self._execute = getattr(self, 'execute', None)
        
    cdef void execute(self):
        IF DEBUG:
            try:
                self._execute()
            except:
                print self
                import traceback
                traceback.print_exc()
        ELSE:
            self._execute()
    
    cdef void execute_instance(self, Instance instance):
        IF DEBUG:
            try:
                self._execute(instance)
            except:
                print self
                import traceback
                traceback.print_exc()
        ELSE:
            self._execute(instance)
    
    cdef void handle(self):
        cdef Instance instance
        cdef list all_instances
        cdef int old_index, index
        if self._iterateObjects:
            old_index = self.group.eventPlayer.objectIndex
            all_instances = self.get_instances()
            for index, instance in enumerate(all_instances):
                self.group.eventPlayer.objectIndex = index
                self.select_instances([instance])
                self.execute_instance(instance)
            self.select_instances(all_instances)
            self.group.eventPlayer.objectIndex = old_index
        else:
            self.execute()

cdef class EmptyAction(Action):
    cdef void initialize(self, loader):
        pass

    cdef void execute(self):
        pass
