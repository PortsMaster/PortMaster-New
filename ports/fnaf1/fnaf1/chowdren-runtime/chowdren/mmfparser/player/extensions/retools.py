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

import re

translated_table = {}

def convert_pattern(pats, ignore_case, wildcard = False, 
                    keep_delimiters = False):
    try:
        return translated_table[(frozenset(pats), ignore_case, wildcard, 
            keep_delimiters, False)]
    except KeyError:
        pass
    new_pats = []
    if keep_delimiters:
        new_pat = '('
    else:
        new_pat = ''
    for pat in pats:
        res = ''
        for i, c in enumerate(pat):
            if wildcard:
                if c == '*':
                    res += '.*?'
                elif c == '?':
                    res += '.'
                else:
                    res += re.escape(c)
            else:
                res += re.escape(c)
        new_pats.append(res)
    new_pat += '|'.join(new_pats)
    if keep_delimiters:
        new_pat += ')'
    if ignore_case:
        new_pat += '(?mis)'
    else:
        new_pat += '(?ms)'
    translated_table[(frozenset(pats), ignore_case, wildcard, keep_delimiters,
        False)] = new_pat
    return new_pat

def get_pattern(pats, ignore_case = False, wildcard = False, 
                keep_delimiters = False):
    try:
        return translated_table[(frozenset(pats), ignore_case, wildcard, 
            keep_delimiters, True)]
    except KeyError:
        pass
    new_pat = convert_pattern(pats, ignore_case, wildcard, keep_delimiters)
    compiled = re.compile(new_pat)
    translated_table[(frozenset(pats), ignore_case, wildcard, keep_delimiters,
        True)] = compiled
    return compiled