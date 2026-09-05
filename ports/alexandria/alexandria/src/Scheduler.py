import pygame.time

class ActorEvent(object):
    def __init__(self, actor):
        self.actor = actor
        super(ActorEvent, self).__init__(self)

class KILL(ActorEvent):
    #KILL(a) means to remove a from running.
    '''killl meee'''
    pass

class REPLACE_THREAD(ActorEvent):
    def __init__(self, actor, replacement):
        super(REPLACE_THREAD, self).__init__(actor)
        self.replacement = replacement

class SUSPEND_FRAMES(ActorEvent):
    #SUSPEND_FRAMES(a, 0) has no effect
    #SUSPEND_FRAMES(a, 1) means defer for one frame (i.e. the same as
    # yielding None)
    def __init__(self, actor, frames):
        super(SUSPEND_FRAMES, self).__init__(actor)
        self.frames = frames

class Scheduler(object):
    def __init__(self):
        super(Scheduler, self).__init__()
        self.actor_threads = {}
        self.ticks = 0
        self.startt = pygame.time.get_ticks()
        self.fps = None

    def register_actor(self, actor, thread):
        '''Register actor as an actor in the scheduler.

        SUSPEND_FRAMES will replace the "thread" with a temporary function that
        will do nothing for a certain number of frames, and then return control
        to the old thread.

        REPLACE_THREAD will replace the thread but not the func used to
        generate the thread. REPLACE_FUNC will replace the thread-generating
        function.'''
        #Replaces the old thread running as self.actor_threads[actor].
        self.actor_threads[actor] = thread
        self.clock = pygame.time.Clock()
        
    def kill_actor(self, actor):
        del self.actor_threads[actor]

    def kill_all(self):
        self.actor_threads.clear()
    
    def poll(self):
        self.ticks += 1
        ### print 'tick',
        self.clock.tick(30)
        self.fps = self.clock.get_fps()
        
        for actor, thread in self.actor_threads.items():
            # keep going until they yield None
            # REPLACE, therefore, happens immediately
            r = True
            reset = None
            while r:
                try:
                    r = thread.next()
                    if isinstance(r, ActorEvent):
                        EVENTFUNCS[r.__class__](self, r)
                except StopIteration, e:
                    print "Killing actor", actor, repr(e), e.__class__, 'nipples'
                    self.kill_actor(actor)
                    r = False
                #except KeyError:
                    #Oh, I guess the actor killed itself or something.
                #    r = False

    def loop(self):
        while self.actor_threads:
            #print self.actor_threads
            self.poll()
            #if i == 853: raise ValueError, "out of time"

    def thread(self, game):
        while True:
            game.fps = self.fps
            yield None

    def printstats(self):
        endt = pygame.time.get_ticks()
        print self.ticks, 'frames'
        print endt - self.startt, 'ticks'
        if self.startt != endt:
            print float(1000*self.ticks)/(endt-self.startt), 'frames per second'
            
    def suspend_actor(self, actor, cycles = None, time = None):
        if cycles != None:
            def deferred(actor, cycles, func):
                ncycles = 0
                while ncycles < cycles:
                    ncycles += 1
                    yield None
                yield REPLACE_THREAD(actor, func)
            t = cycles
        else:
            print "SUSPEND_SEC not supported yet"

        self.actor_threads[actor] = \
                                  deferred(actor, t, self.actor_threads[actor])
            
        
    def kill_event(self, event):
        self.kill_actor(event.actor)

    def replace_thread_event(self, event):
        self.actor_threads[event.actor] = event.replacement

    def suspend_frames_event(self, event):
        self.suspend_actor(event.actor, cycles = event.frames)

EVENTFUNCS = {KILL: Scheduler.kill_event,
              REPLACE_THREAD: Scheduler.replace_thread_event,
              SUSPEND_FRAMES: Scheduler.suspend_frames_event,}
              #SUSPEND_SEC: Scheduler.suspend_sec_event}

if __name__ == '__main__':
    class Sleeper(object):
        def __init__(self, n):
            super(Sleeper, self).__init__()
            self.n = n

        def thread(self):
            for i in range(3):
                for g in self.sleep():
                    yield g

        def sleep(self):
            print 'sleeping for', self.n
            yield SUSPEND_FRAMES(self, self.n)
                
    class Watcher(object):
        def __init__(self, actors):
            self.actors = actors
        def kill_10s(self):
            yield None #Don't kill the sleeper before he comes out.
            for a in self.actors:
                if a.n == 10:
                    print 'killing', a
                    yield SUSPEND_FRAMES(a, 2)

            print 'I\'m done'
    s = Scheduler()
    s1 = Sleeper(1)
    s2 = Sleeper(10)
    s.register_actor(s1, s1.thread())
    s.register_actor(s2, s2.thread())
    w = Watcher([s1, s2])
    s.register_actor(w, w.kill_10s())
    s.loop()
