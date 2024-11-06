#!/bin/bash

if [ $# -eq 0 ]; then 
    for i in *.po; do
        echo -n "Updating $i:"
        msgmerge --update "$i" pingus.pot
    done
else
    for i; do
        echo -n "Updating $i:"
        msgmerge --update "$i" pingus.pot
    done    
fi

# EOF #
