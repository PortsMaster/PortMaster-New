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

import sys
import ctypes
from subprocess import Popen, PIPE

if sys.platform == 'win32':
    OpenClipboard = ctypes.windll.user32.OpenClipboard
    EmptyClipboard = ctypes.windll.user32.EmptyClipboard
    GetClipboardData = ctypes.windll.user32.GetClipboardData
    SetClipboardData = ctypes.windll.user32.SetClipboardData
    CloseClipboard = ctypes.windll.user32.CloseClipboard
    GlobalLock = ctypes.windll.kernel32.GlobalLock
    GlobalAlloc = ctypes.windll.kernel32.GlobalAlloc
    GlobalUnlock = ctypes.windll.kernel32.GlobalUnlock
    memcpy = ctypes.cdll.msvcrt.memcpy
    CF_TEXT = 1
    GHND = 66

    def get():
        text = ''
        if OpenClipboard(0):
            hClipMem = GetClipboardData(CF_TEXT)
            GlobalLock.restype = ctypes.c_char_p   
            text = GlobalLock(hClipMem)
            GlobalUnlock(hClipMem)
            CloseClipboard()
        return text

    def set(text):
        buffer = ctypes.c_buffer(text)      
        bufferSize = ctypes.sizeof(buffer)
        hGlobalMem = GlobalAlloc(GHND, bufferSize)
        GlobalLock.restype = ctypes.c_void_p                        
        lpGlobalMem = GlobalLock(hGlobalMem)
        memcpy(lpGlobalMem, ctypes.addressof(buffer), bufferSize) 
        GlobalUnlock(hGlobalMem)
        if OpenClipboard(0):
            EmptyClipboard()
            SetClipboardData(CF_TEXT, hGlobalMem)
            CloseClipboard()

elif sys.platform == 'linux2':
    def get():
        outf = os.popen('xsel -o', 'r')
        content = outf.read()
        outf.close()
        return content

    def set(text):
        outf = os.popen('xsel -i', 'w')
        outf.write(text)
        outf.close()

elif sys.platform == 'darwin':
    from Carbon.Scrap import GetCurrentScrap, ClearCurrentScrap
    import MacOS

    def get():
        try:
            scrap = GetCurrentScrap()
            return scrap.GetScrapFlavorData('TEXT')
        except MacOS.Error, e:
            return ""

    def set(text):
        ClearCurrentScrap()
        scrap = GetCurrentScrap()
        scrap.PutScrapFlavor('TEXT', 0, text)
