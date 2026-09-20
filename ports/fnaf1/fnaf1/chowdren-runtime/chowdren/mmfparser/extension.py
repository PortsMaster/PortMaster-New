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

from ctypes import *
from ctypes import wintypes

try:
    from mmfparser import winguiauto
except ImportError:
    pass

KGI_VERSION = 0
KGI_PLUGIN = 2
KGI_PRODUCT = 6
KGI_BUILD = 7

class kpxRunInfos(Structure):
    _fields_ = [
        ('conditions', c_void_p),
        ('actions', c_void_p),
        ('expressions', c_void_p),
        ('numOfConditions', c_short),
        ('numOfActions', c_short),
        ('numOfExpressions', c_short),
        ('editDataSize', c_short),
        ('editFlags', c_int),
        ('windowProcPriority', c_byte),
        ('free', c_char),
        ('editPrefs', c_short),
        ('identifier', c_char * 4),
        ('version', c_short)
    ]

class oldAceInfos(Structure):
    _fields_ = [
        ('code', c_short),
        ('flags', c_short),
        ('param', c_short * 2),
        ('paramTitle', c_short * 2),
    ]

class aceInfos(Structure):
    _fields_ = [
        ('code', c_short),
        ('flags', c_short),
        ('nParams', c_short),
    ]

class eventInformations2(Structure):
    _fields_ = [
        ('menu', c_short),
        ('string', c_short),
        ('infos', aceInfos)
    ]

GETVERSIONFUNC = CFUNCTYPE(c_int)
VERSION_INT = c_int(0)
VERSION_POINTER = POINTER(c_int)(VERSION_INT)
GETVERSIONFUNC2 = CFUNCTYPE(c_int, c_int, c_int, c_int, c_int, c_int)
MN_ACTIONS = 20000
MN_CONDITIONS = 20001
MN_EXPRESSIONS = 20002

class _mvstruct(Structure):
    _fields_ = [
        ('mvHInst', wintypes.HINSTANCE),
        ('mvIdAppli', c_void_p),
        ('mvIdMainWin', c_void_p),
        ('mvIdEditWin', c_void_p),
        ('mvHMainWin', wintypes.HWND),
        ('mvHEditWin', wintypes.HWND),
        ('mvHPal256', wintypes.HPALETTE),
        ('mvAppMode', c_short),
        ('mvScrMode', c_short),
        ('mvEditDXDocToClient', c_int),
        ('mvEditDYDocToClient', c_int),
        ('mvImgFilterMgr', c_void_p),
        ('mvSndFilterMgr', c_void_p),
        ('mvSndMgr', c_void_p),
        ('mvEditApp', c_void_p),
        ('mvEditFrame', c_void_p),
        ('mvRunHdr', c_void_p),
        ('mvPrefs', c_int),
        ('subType', wintypes.LPSTR),
        ('mvFullScreen', wintypes.BOOL),
        ('mvMainAppFileName', wintypes.LPSTR),
        ('mvAppListCount', c_int),
        ('mvAppListSize', c_int),
        ('mvAppList', c_void_p),

        ('mvExtListCount', c_int),
        ('mvExtListSize', c_int),

        ('mvExtList', c_void_p),
        ('mvNbDllTrans', c_int),
        ('mvDllTransList', c_void_p),

        ('mvJoyCaps', c_int * 32),

        ('mvHMsgHook', wintypes.HHOOK),

        ('mvModalLoop', c_int),
        ('mvModalSubAppCount', c_int),

        ('mvFree', c_void_p * 5),

        ('mvHelp', c_void_p),
        ('mvGetDefaultFont', c_void_p),
        ('mvEditSurface', c_void_p),
        ('mvEditImage', c_void_p),
        ('mvEditAnimation', c_void_p),
        ('mvGetExtUserData', c_void_p),
        ('mvSetExtUserData', c_void_p),
        ('mvRegisterDialogBox', c_void_p),
        ('mvUnregisterDialogBox', c_void_p),
        ('mvAddBackdrop', c_void_p),
        ('mvGetFile', c_void_p),
        ('mvReleaseFile', c_void_p),
        ('mvOpenHFile', c_void_p),
        ('mvCloseHFile', c_void_p),
        ('mvLoadNetFile', c_void_p),
        ('mvNetCommand', c_void_p),
        ('mvGetVersion', GETVERSIONFUNC),
        ('mvCallFunction', c_void_p),
        ('mvAdditionalFncs', c_void_p * 16),
    ]

class _mv15struct(Structure):
    _fields_ = [
        ('dummy', c_char * 636), # 636
        ('mvGetVersion', GETVERSIONFUNC)
    ]

class _mv0struct(Structure):
    _fields_ = [
        ('dummy', c_char * 336),
        ('getVersion', GETVERSIONFUNC)
    ]

MMFVERSION_MASK	= 0xFFFF0000
MMFBUILD_MASK = 0x00000FFF		# MMF build
MMFVERFLAG_MASK = 0x0000F000
MMFVERFLAG_HOME = 0x00008000		# TGF
MMFVERFLAG_PRO = 0x00004000		# MMF Pro
MMFVERFLAG_ATX = 0x00002000		# Not used
MMFVERFLAG_PLUGIN = 0x00001000		# Plugin
MMFVERSION_15 = 0x01050000		# MMF 1.5
MMFVERSION_20 = 0x02000000		# MMF 2.0

EXT_VERSION1 = 0x200
EXT_VERSION2 = 0x300
EXT_PLUGIN_VERSION1 = 0x100

def getVersion():
    return MMFVERSION_20 | MMFVERFLAG_PRO | 246

def createMv():
    newMv = _mvstruct()
    newMv.mvGetVersion = GETVERSIONFUNC(getVersion)
    return byref(newMv)

def createMv15():
    newMv = _mv15struct()
    newMv.mvGetVersion = GETVERSIONFUNC(getVersion)
    return byref(newMv)

def createMv0():
    newMv = _mv0struct()
    newMv.mvGetVersion = GETVERSIONFUNC(getVersion)
    return byref(newMv)

_mv = createMv()
_mv15 = createMv15()
_mv0 = createMv15()

class state:
    mv = None

def loadLibrary(path):
    try:
        newLibrary = windll.LoadLibrary(path)
        return newLibrary
    except WindowsError, e:
        print e, path
        return None

MF_BYPOSITION = 0x00000400
MF_SEPARATOR = 0x00000800
MF_POPUP = 0x00000010
MF_STRING = 0x00000000

def copyMenu(dst, src):
    user32 = windll.user32
    nMn = user32.GetMenuItemCount(src)
    strBuf = create_string_buffer(80)
    for n in xrange(nMn):
        id = user32.GetMenuItemID(src, n)
        if id == 0:
            user32.AppendMenuA(dst, MF_SEPARATOR, 0, 0)
        else:
            user32.GetMenuStringA(src, n, strBuf, 80, MF_BYPOSITION)
            if id != -1:
                menu_state = user32.GetMenuState(src, n, MF_BYPOSITION)
                user32.AppendMenuA(dst, menu_state, id, strBuf)
            else:
                newmenu = user32.CreatePopupMenu()
                user32.AppendMenuA(dst, MF_POPUP | MF_STRING, newmenu, strBuf)
                copyMenu(newmenu, user32.GetSubMenu(src, n))

def loadMenu(handle, resource, verbose = True):
    user32 = windll.user32
    menu = user32.LoadMenuA(handle, resource)
    if not menu:
        if verbose:
            print 'could not load menu', handle, resource, menu
        return 0
    submenu = user32.GetSubMenu(menu, 0)
    if not submenu:
        if verbose:
            print 'could not load submenu'
        return 0
    popup = user32.CreatePopupMenu()
    if not popup:
        if verbose:
            print 'could not load popup'
        return 0
    copyMenu(popup, submenu)
    user32.DestroyMenu(menu)
    return popup

def getItems(hmenu, codeFunction):
    nums = {}
    index = 0
    try:
        while 1:
            item = winguiauto.getMenuInfo(hmenu, index)
            if item.submenu:
                subNums = getItems(item.submenu, codeFunction)
                for num, name in subNums.iteritems():
                    name.insert(0, item.name)
                    nums[num] = name
            elif not item.isSeperator and not item.isDisabled:
                itemId = windll.user32.GetMenuItemID(hmenu, index)
                realId = c_short(codeFunction(state.mv, c_short(itemId)))
                nums[realId.value] = [item.name]
            index += 1
    except winguiauto.WinGuiAutoError:
        pass
    return nums

def getActionMenu(extension, menu = None):
    if menu is None:
        try:
            menu = extension.library.GetActionMenu(state.mv, c_void_p(),
                c_void_p())
        except AttributeError:
            return {}
    return getItems(menu, extension.library.GetActionCodeFromMenu)

def getConditionMenu(extension, menu = None):
    if menu is None:
        try:
            menu = extension.library.GetConditionMenu(state.mv, c_void_p(),
                c_void_p())
        except AttributeError:
            return {}
    return getItems(menu, extension.library.GetConditionCodeFromMenu)

def getExpressionMenu(extension, menu = None):
    if menu is None:
        try:
            menu = extension.library.GetExpressionMenu(state.mv, c_void_p(),
                c_void_p())
        except AttributeError:
            return {}
    return getItems(menu, extension.library.GetExpressionCodeFromMenu)

def getDescription(extension):
    objectName = create_string_buffer(256)
    objectAuthor = create_string_buffer(256)
    objectCopyright = create_string_buffer(256)
    objectComment = create_string_buffer(1024)
    objectSite = create_string_buffer(256)

    try:
        extension.library.GetObjInfos(extension.state.mv, c_void_p(),
        byref(objectName), byref(objectAuthor), byref(objectCopyright),
        byref(objectComment), byref(objectSite))
    except AttributeError:
        return ('', '', '', '', '')

    return (objectName.value, objectAuthor.value, objectCopyright.value,
        objectComment.value, objectSite.value)

def getRunInfos(extension):
    newRunInfos = kpxRunInfos()
    runPointer = byref(newRunInfos)
    extension.library.GetRunObjectInfos(c_void_p(), runPointer)
    return newRunInfos

def getActionDescription(self, extension, num):
    data = create_string_buffer(256)
    extension.library.GetActionString(state.mv, c_short(num),
        byref(data), c_short(256))
    return data.value

def getConditionDescription(self, extension, num):
    data = create_string_buffer(256)
    extension.library.GetConditionString(state.mv, c_short(num),
        byref(data), c_short(256))
    return data.value

def getExpressionDescription(self, extension, num):
    data = create_string_buffer(256)
    extension.library.GetExpressionString(state.mv, c_short(num),
        byref(data), c_short(256))
    return data.value

class Parameter(object):
    type = None
    description = None
    def __init__(self, type, description):
        self.type = type
        self.description = description

class ACE(object):
    num = None
    menu = None
    description = None
    flags = None
    info = None
    parameters = None

    infoFunction = None
    titleFunction = None
    descriptionFunction = None
    menuAttribute = None

    def __init__(self, extension, num):
        self.num = num
        self.menu = getattr(extension, self.menuAttribute)[num]
        self.description = self.descriptionFunction(extension, num)
        self.parameters = parameters = []
        parameterTypes = []
        if num == -1:
            return
        offset = getattr(
            extension.library, self.infoFunction)(state.mv, c_short(num))
        if extension.pluginVersion == 0:
            self.info = oldAceInfos.from_address(offset)
            for parameter in self.info.param:
                if parameter != 0:
                    parameterTypes.append(parameter)
        else:
            self.info = aceInfos.from_address(offset)
            currentPosition = offset + 6
            for i in xrange(self.info.nParams):
                parameterTypes.append(c_short.from_address(
                    currentPosition).value)
                currentPosition += 2
        for i in xrange(len(parameterTypes)):
            data = create_string_buffer(256)
            try:
                getattr(extension.library, self.titleFunction)(state.mv, c_short(num),
                    c_short(i), byref(data), c_short(256))
            except AttributeError:
                parameters.append(Parameter(parameterTypes[i], '(not found)'))
                continue
            parameters.append(Parameter(parameterTypes[i], data.value))
        self.created()

    def created(self):
        pass

class Action(ACE):
    infoFunction = 'GetActionInfos'
    titleFunction = 'GetActionTitle'
    descriptionFunction = getActionDescription
    menuAttribute = 'actionMenu'

class Condition(ACE):
    infoFunction = 'GetConditionInfos'
    titleFunction = 'GetConditionTitle'
    descriptionFunction = getConditionDescription
    menuAttribute = 'conditionMenu'

RETURN_TYPES = {
    0 : 'Int',
    1 : 'String',
    2 : 'Float',
    3 : 'String'
}

class Expression(ACE):
    infoFunction = 'GetExpressionInfos'
    titleFunction = 'GetExpressionParam'
    descriptionFunction = getExpressionDescription
    menuAttribute = 'expressionMenu'

    def getReturnType(self):
        if self.num == -1:
            return ''
        return RETURN_TYPES[self.info.flags]

class LoadedExtension(object):
    pluginVersion = None

    actionMenu = None
    actions = None

    conditionMenu = None
    conditions = None

    expressionMenu = None
    expressions = None

    description = None
    runInfos = None

    action_hmenu = condition_hmenu = expression_hmenu = None

    def __init__(self, library, descriptions = True):
        self.library = library

        self.pluginVersion = library.GetInfos(KGI_PLUGIN)
        self.version = library.GetInfos(KGI_VERSION)

        action_hmenu = None
        condition_hmenu = None
        expression_hmenu = None

        if self.version == EXT_VERSION1:
            state.mv = _mv0
            mv_name = 'mv0'
        elif self.version == EXT_VERSION2:
            if self.pluginVersion == EXT_VERSION1:
                state.mv = _mv15
                mv_name = 'mv15'
            else:
                state.mv = _mv
                mv_name = 'mv'

        try:
            library.Initialize(state.mv, 0)
        except AttributeError:
            pass

        if False:
            handle = library._handle
            self.action_hmenu = loadMenu(handle, MN_ACTIONS)
            self.condition_hmenu = loadMenu(handle, MN_CONDITIONS)
            self.expression_hmenu = loadMenu(handle, MN_EXPRESSIONS)

        self.actionMenu = getActionMenu(self, self.action_hmenu)
        if descriptions:
            self.actions = [Action(self, num)
                for num in self.actionMenu.keys()]

        self.conditionMenu = getConditionMenu(self, self.condition_hmenu)
        if descriptions:
            self.conditions = [Condition(self, num)
                for num in self.conditionMenu.keys()]

        self.expressionMenu = getExpressionMenu(self, self.expression_hmenu)
        if descriptions:
            self.expressions = [Expression(self, num)
                for num in self.expressionMenu.keys()]

        self.description = getDescription(self)
        self.runInfos = getRunInfos(self)