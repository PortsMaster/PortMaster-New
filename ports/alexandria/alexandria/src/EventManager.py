from weakref import WeakKeyDictionary
class EventManager(object):
    """this object is responsible for coordinating most communication
    between the Model, View, and Controller."""
    def __init__(self ):
	self.listeners = WeakKeyDictionary()

    #----------------------------------------------------------------------
    def RegisterListener( self, listener ):
	self.listeners[ listener ] = 1

    #----------------------------------------------------------------------
    def UnregisterListener( self, listener ):
	if listener in self.listeners.keys():
	    del self.listeners[ listener ]

    #----------------------------------------------------------------------
    def Post( self, event ):
	for listener in self.listeners.keys():
	    #NOTE: If the weakref has died, it will be 
	    #automatically removed, so we don't have 
	    #to worry about it.
	    #print "Notifying of", event 
	    listener.Notify( event )

    def kill_all(self):
        self.listeners = WeakKeyDictionary()
