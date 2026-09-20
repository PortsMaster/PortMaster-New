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

from pyglet.event import EventDispatcher as PygletEventDispatcher
from pyglet.event import EVENT_HANDLED, EVENT_UNHANDLED

# Since pyglet's EventDispatcher fires handlers the opposite way of what
# we actually want, this is a replacement for it

class EventDispatcher(PygletEventDispatcher):
    def dispatch_event(self, event_type, *args):
        assert event_type in self.event_types

        invoked = False

        # Search handler stack for matching event handlers
        for frame in reversed(list(self._event_stack)):
            handler = frame.get(event_type, None)
            if handler:
                try:
                    invoked = True
                    if handler(*args):
                        return EVENT_HANDLED
                except TypeError:
                    self._raise_dispatch_exception(event_type, args, handler)

        # Check instance for an event handler
        if hasattr(self, event_type):
            try:
                invoked = True
                if getattr(self, event_type)(*args):
                    return EVENT_HANDLED
            except TypeError:
                self._raise_dispatch_exception(
                    event_type, args, getattr(self, event_type))

        if invoked:
            return EVENT_UNHANDLED

        return False