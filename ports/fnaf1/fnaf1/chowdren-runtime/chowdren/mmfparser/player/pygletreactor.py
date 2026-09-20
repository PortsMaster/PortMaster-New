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

"""
This module provides Pyglet/Twisted integration using
the new (Pyglet v1.1) pyglet.app event loop.

To use this reactor, include the following statements
_before_ importing the standard Twisted reactor:

    import pygletreactor
    pygletreactor.install()

Then, just import reactor and call run() to start both
Pyglet and Twisted:

    from twisted.internet import reactor
    reactor.run()

There is no need to call pyglet.app.run().

If you want to subclass pyglet.app.EventLoop (Pyglet 1.1)
or pyglet.app.base.EventLoop (Pyglet 1.1.2), don't! Subclass
pygletreactor.EventLoop instead, which contains logic
to schedule Twisted events to run from Pyglet. Then,
register your new event loop as follows:

    from twisted.internet import reactor
    reactor.registerPygletEventLoop(yourEventLoop)
    reactor.run()

Twisted function calls are scheduled within the Pyglet event
loop. By default, pending calls are dealt with every 0.1 secs.
This frequency can be altered by passing a different 'call_interval'
to reactor.run(), e.g. the following:

	reactor.run(call_interval=1/20.)

will result in Twisted function calls being dealt with every
0.05 secs within the Pyglet event loop. If your code results in
a large number of Twisted calls that need to be processed as
quickly as possible, decreasing the call_interval will help.

Based on the wxPython reactor (wxreactor.py) that ships with Twisted.

Padraig Kitterick <p.kitterick@psych.york.ac.uk>
"""

import Queue

import pyglet

from twisted.internet import _threadedselect

from mmfparser.player import app

class PygletReactor(_threadedselect.ThreadedSelectReactor):
    _stopping = False
    _enabled = False
    _twistedQueue = None
    
    def enable(self):
        if self._enabled:
            return
        self._twistedQueue = Queue.Queue()
        self.interleave(self._runInMainThread,
                        installSignalHandlers=self._installSignalHandlers)
        self.addSystemEventTrigger("after", "shutdown", self._stopPyglet)
        pyglet.clock.schedule_interval_soft(self._make_twisted_calls, 
            self._call_interval)
        self._enabled = True

    def _make_twisted_calls(self, dt):
        try:
            f = self._twistedQueue.get(False)
            f()
        except Queue.Empty:
            pass
    
    def stop(self):
        app.exit()
        if not self._enabled:
            return
        if self._stopping:
            return
        self._stopping = True
        _threadedselect.ThreadedSelectReactor.stop(self)

    def _runInMainThread(self, f):
        self._twistedQueue.put(f)

    def _stopPyglet(self):
        app.exit()

    def run(self, call_interval = 1/10.0, installSignalHandlers = True):
        self._call_interval = call_interval
        self._installSignalHandlers = installSignalHandlers
        app.run()
        
def install():
    reactor = PygletReactor()
    from twisted.internet.main import installReactor
    installReactor(reactor)
    return reactor

__all__ = ['install']
