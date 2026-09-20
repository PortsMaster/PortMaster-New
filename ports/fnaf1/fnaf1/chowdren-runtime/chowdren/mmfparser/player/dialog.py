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

if sys.platform == 'win32':
    import os
    import ctypes
    from ctypes import (c_int, c_ulong, c_char_p, c_wchar_p, c_ushort, wintypes,
        create_unicode_buffer, cast, wstring_at, addressof, string_at)

    # Windows function prototypes
    BrowseCallbackProc = ctypes.WINFUNCTYPE(ctypes.c_int, wintypes.HWND, 
        ctypes.c_uint, wintypes.LPARAM, wintypes.LPARAM)

    # Windows types
    LPCTSTR = ctypes.c_char_p
    LPTSTR = ctypes.c_char_p
    LPVOID = ctypes.c_voidp
    TCHAR = ctypes.c_char

    # Load required Windows DLLs
    comdlg32 = ctypes.windll.comdlg32
    ole32 = ctypes.windll.ole32
    shell32 = ctypes.windll.shell32

    # Windows Constants
    MAX_PATH = 260
    OFN_HIDEREADONLY = 4
    OFN_ALLOWMULTISELECT = 0x00000200

    #http://msdn.microsoft.com/en-us/library/bb773205(VS.85).aspx
    class BROWSEINFO(ctypes.Structure):
        _fields_ = [("hwndOwner", wintypes.HWND),
            ("pidlRoot", LPVOID),
            ("pszDisplayName", LPTSTR),
            ("lpszTitle", LPCTSTR),
            ("ulFlags", ctypes.c_uint),
            ("lpfn", BrowseCallbackProc),
            ("lParam", wintypes.LPARAM),
            ("iImage", ctypes.c_int)]


    #http://msdn.microsoft.com/en-us/library/ms646839(VS.85).aspx
    class OPENFILENAME(ctypes.Structure):
        _fields_ = (("lStructSize", c_int),
            ("hwndOwner", c_int),
            ("hInstance", c_int),
            ("lpstrFilter", c_wchar_p),
            ("lpstrCustomFilter", c_char_p),
            ("nMaxCustFilter", c_int),
            ("nFilterIndex", c_int),
            ("lpstrFile", c_wchar_p),
            ("nMaxFile", c_int),
            ("lpstrFileTitle", c_wchar_p),
            ("nMaxFileTitle", c_int),
            ("lpstrInitialDir", c_wchar_p),
            ("lpstrTitle", c_wchar_p),
            ("flags", c_int),
            ("nFileOffset", c_ushort),
            ("nFileExtension", c_ushort),
            ("lpstrDefExt", c_char_p),
            ("lCustData", c_int),
            ("lpfnHook", c_char_p),
            ("lpTemplateName", c_char_p),
            ("pvReserved", c_char_p),
            ("dwReserved", c_int),
            ("flagsEx", c_int))

        def __init__(self, win, title, multi = False):
                ctypes.Structure.__init__(self)
                self.lStructSize = ctypes.sizeof(OPENFILENAME)
                self.nMaxFile = 1024
                self.hwndOwner = win
                self.lpstrTitle = title
                self.flags = OFN_HIDEREADONLY
                if multi:
                    self.flags = OFN_HIDEREADONLY | OFN_ALLOWMULTISELECT | 0x00080000

    def BrowseCallback(hwnd, uMsg, lParam, lpData):
        return 0
    
    def open_selector(func, title, filters = [('All Files', ('*.*',))], 
                      root = '', multi = False):
        ofx = OPENFILENAME(0, title, multi)
        lpstrFile = create_unicode_buffer(root, 1024)
        ofx.lpstrFile = cast(lpstrFile, c_wchar_p)
        newFilters = []
        for filter in filters:
            filterTypes = ';'.join(filter[1])
            newFilters.append('%s (%s)' % (filter[0], filterTypes))
            newFilters.append(filterTypes)
        filterText = '\x00'.join(newFilters) + "\x00\x00"
        ofx.lpstrFilter = filterText
        if func(ctypes.byref(ofx)):
            if multi:
                offset = addressof(lpstrFile)
                items = []
                while 1:
                    item = wstring_at(offset)
                    offset += (len(item) + 1) * 2
                    if item == '':
                        break
                    items.append(item)

                if len(items) == 1:
                    return items
                directory = items[0]
                new_items = []
                for item in items[1:]:
                    new_items.append(os.path.join(directory, item))
                return new_items
            else:
                return wstring_at(addressof(lpstrFile))
        return ''
    
    def open_file_selector(title = 'Open', *arg, **kw):
        return open_selector(ctypes.windll.comdlg32.GetOpenFileNameW, title,
            *arg, **kw)
    
    def open_directory_selector(): # not needed yet
        browseInfo = BROWSEINFO()
        browseInfo.pszDisplayName = ctypes.c_char_p('\0' * (MAX_PATH+1))
        browseInfo.lpszTitle = "Select directory"
        browseInfo.lpfn = BrowseCallbackProc(BrowseCallback)
        pidl = shell32.SHBrowseForFolder(ctypes.byref(browseInfo))
        if pidl:
            path = ctypes.c_char_p('\0' * (MAX_PATH+1))
            shell32.SHGetPathFromIDList(pidl, path)
            ole32.CoTaskMemFree(pidl)
            return path.value
        return ''

    def save_file_selector(title = 'Save', *arg, **kw):
        return open_selector(ctypes.windll.comdlg32.GetSaveFileNameW, title,
            *arg, **kw)

elif sys.platform == 'linux2':
    import PyZenity
    
    def open_file_selector(title = 'Open', filters = [('All Files', ('*.*',))], 
                           root = None):
        value = PyZenity.GetFilename(title = title, filename = root)
        if value is None:
            return None
        return value[0]
    
    def save_file_selector(title = 'Save', filters = [('All Files', ('*.*',))], 
                           root = None):
        value = PyZenity.GetSavename(title = title, filename = root)
        if value is None:
            return None
        return value[0]

elif sys.platform == 'darwin':
    import EasyDialogs
    
    def open_file_selector(title = 'Open', filters = None, root = ''):
        filters = filters or [('All Files', ('*.*',))]
        newFilters = []
        for item in filters:
            for filter in item[1]:
                newFilters.append(filter.replace('.', '').replace('*', ''))
        return EasyDialogs.AskFileForOpen(message = title, 
            typeList = newFilters, defaultLocation = root)
            
    def save_file_selector(title = 'Save', filters = None, 
                           root = ''):
        filters = filters or [('All Files', ('*.*',))]
        fileType = filters[0][1][0].replace('.', '').replace('*', '')
        return EasyDialogs.AskFileForSave(message = title, fileType = fileType,
            defaultLocation = root)

__all__ = ['open_file_selector', 'save_file_selector']

if __name__ == '__main__':
    print '%r' % open_file_selector(multi = True)