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

from Crypto.Cipher import Blowfish

import urllib

def padData(data):
    padBytes = 8 - (len(data) % 8)
    return ''.join([data, '\x00' * padBytes])

def reverseBytes(data):
    reversed = []
    for i in range(len(data)/4):
        bytes = data[i*4:i*4+4]
        reversed.append(bytes[::-1])
    return ''.join(reversed)

class MMFBlowfish(object):
    cipher = None
    
    def __init__(self, key, mode = Blowfish.MODE_ECB):
        self.cipher = Blowfish.new(key, mode)
    
    def encrypt(self, data):
        encryptData = reverseBytes(padData(data))
        encrypted = reverseBytes(self.cipher.encrypt(encryptData))
        # filtered = urllib.quote(encrypted)
        return encrypted
        
    def decrypt(self, data):
        decryptData = reverseBytes(urllib.unquote(data))
        return reverseBytes(self.cipher.decrypt(decryptData)).split('\x00')[0]