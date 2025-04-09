#!/usr/bin/env python

import sys

if len(sys.argv) == 3:
    curset = file(sys.argv[1], "r").read().decode('utf-8')
    newset = file(sys.argv[2], "r").read().decode('utf-8')
    
    curchars = set(curset)
    newchars = set(newset)
    
    for c in newchars.difference(curchars):
        print c.encode('utf-8')
else:
    print "usage:", sys.argv[0],"CURRENTCHARS","NEWCHARS"

# EOF #
