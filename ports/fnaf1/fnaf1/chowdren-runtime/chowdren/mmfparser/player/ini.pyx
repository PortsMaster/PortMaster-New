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

cdef extern from "minIni.c":
    int ini_gets(char * Section, char *Key, char *DefValue, char *Buffer, 
        int BufferSize, char *Filename)
    int ini_puts(char * Section, char * Key, char * Value, char * Filename)

cdef char[500] buffer

cdef class FastINI:
    cdef:
        bytes name

    def __init__(self, name):
        self.name = name
    
    def get_key(self, bytes section, bytes key):
        cdef int n = ini_gets(<char *>section, <char*>key, "", buffer, 500, 
            <char *>self.name)
        cdef bytes ret = buffer
        return ret
    
    def set_key(self, bytes section, bytes key, bytes value):
        ini_puts(<char *>section, <char *>key, <char*>value, <char *>self.name)
    
    def delete_section(self, bytes section):
        ini_puts(<char *>section, <char *>0, <char *>0, <char *>self.name)
    
    def delete_key(self, bytes section, bytes key):
        ini_puts(<char *>section, <char *>key, <char *>0, <char *>self.name)