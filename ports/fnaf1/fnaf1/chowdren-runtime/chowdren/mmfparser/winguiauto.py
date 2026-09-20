# Module     : winGuiAuto.py
# Synopsis   : Windows GUI automation utilities
# Programmer : Simon Brunning - simon@brunningonline.net
# Date       : 25 June 2003
# Version    : 1.0 pre-alpha 2
# Copyright  : Released to the public domain. Provided as-is, with no warranty.
# Notes      : Requires Python 2.3, win32all and ctypes 
'''Windows GUI automation utilities.

Until I get around to writing some docs and examples, the tests at the foot of
this module should serve to get you started.
'''

import ctypes

MF_BYPOSITION = 0x00000400
MF_CHECKED = 0x00000008
MF_DISABLED = 0x00000002
MF_GRAYED = 0x00000001
MF_SEPARATOR = 0x00000800
MF_POPUP = 0x00000010

def getMenuInfo(hMenu, uIDItem):
    '''Get various info about a menu item.
    
    Arguments:
    hMenu               The menu in which the item is to be found.
    uIDItem             The item's index

    Returns:            Menu item information object. This object is basically
                        a 'bunch'
                        (see http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/52308).
                        It will have useful attributes: name, itemCount,
                        submenu, isChecked, isDisabled, isGreyed, and
                        isSeperator
                    
    Raises:
    WinGuiAutoError     When the requested menu option isn't found.       

    Usage example:      submenuInfo = getMenuInfo(hMenu, submenu)
                        hMenu, hMenuItemCount = submenuInfo.submenu, submenuInfo.itemCount'''
    # An object to hold the menu info
    class MenuInfo(Bunch):
        pass
    menuInfo = MenuInfo()

    # Menu state    
    menuState = ctypes.windll.user32.GetMenuState(hMenu,
                                                  uIDItem,
                                                  MF_BYPOSITION)
    if menuState == -1:
        raise WinGuiAutoError("No such menu item, hMenu=" +
                               str(hMenu) +
                               " uIDItem=" +
                               str(uIDItem))
    menuInfo.isChecked = bool(menuState & MF_CHECKED)
    menuInfo.isDisabled = bool(menuState & MF_DISABLED)
    menuInfo.isGreyed = bool(menuState & MF_GRAYED)
    menuInfo.isSeperator = bool(menuState & MF_SEPARATOR)
    # ... there are more, but these are the ones I'm interested in
    
    # Menu name
    menuName = ctypes.c_buffer("\000" * 256)
    ctypes.windll.user32.GetMenuStringA(ctypes.c_int(hMenu),
                                        ctypes.c_int(uIDItem),
                                        menuName, ctypes.c_int(len(menuName)),
                                        MF_BYPOSITION)
    menuInfo.name = menuName.value

    # Sub menu info
    menuInfo.itemCount = menuState >> 8
    if bool(menuState & MF_POPUP):
        menuInfo.submenu = ctypes.windll.user32.GetSubMenu(hMenu, uIDItem)
    else:
        menuInfo.submenu = None
    
    return menuInfo
                              
class Bunch(object):
    '''See http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/52308'''
    
    def __init__(self, **kwds):
        self.__dict__.update(kwds)
        
    def __str__(self):
        state = ["%s=%r" % (attribute, value)
                 for (attribute, value)
                 in self.__dict__.items()]
        return '\n'.join(state)
    
class WinGuiAutoError(Exception):
    pass