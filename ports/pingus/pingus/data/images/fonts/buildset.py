#!/usr/bin/env python

import sys

str = sys.stdin.read().decode('utf-8')
characters = set(str)
for c in characters: 
    print c.encode('utf-8')

# EOF #
