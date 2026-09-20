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

import tempfile
from mmfparser.data.mfa import (MFA, MFA_CURRENT_VERSION, ValueList, ValueItem,
    ChunkList, Frame, Events, Layer, FrameItem, FrameInstance,
    FRAME_ITEM_LOADERS, EXTENSION_BASE, ExtensionObject, Movements,
    Behaviours, Transition, Animation, AnimationDirection, ItemFolder, Movement,
    EventObject, FRAME_ITEM_TYPE, Paragraph, SYSTEM_ITEM_TYPE)
from mmfparser.data.chunkloaders.fontbank import FontBank
from mmfparser.data.chunkloaders.soundbank import SoundBank
from mmfparser.data.chunkloaders.musicbank import MusicBank
from mmfparser.data.mfaloaders.imagebank import AGMIBank
from mmfparser.data.mfaloaders.playercontrols import Controls, PlayerControl
from mmfparser.bytereader import ByteReader
from mmfparser.data.chunkloaders.objectinfo import (PLAYER, KEYBOARD, CREATE,
    TIMER, GAME, SPEAKER, SYSTEM, QUICKBACKDROP, BACKDROP, ACTIVE, TEXT,
    QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION, objectTypes)
from mmfparser.data.chunkloaders.frame import NONE_PARENT
from mmfparser.data.chunkloaders.objects import HIDDEN
from mmfparser.data.chunkloaders.parameters.loaders import Group, GroupPointer
from mmfparser.data.checksum import make_group_checksum

def convert_alterables(values, kind):
    alterables = ValueList()
    if values is not None:
        for index, item in enumerate(values.items):
            newValue = ValueItem()
            newValue.name = 'Alterable %s %s' % (kind, index + 1)
            newValue.value = item
            alterables.items.append(newValue)
    return alterables

def convert_transition(transition):
    if transition is None:
        return None
    newTransition = Transition()
    newTransition.module = transition.moduleFile
    newTransition.name = 'Transition'
    newTransition.id = transition.module
    newTransition.transitionId = transition.name
    newTransition.flags.setFlags(transition.flags.getFlags())
    newTransition.color = transition.color
    newTransition.parameterData = transition.parameterData
    newTransition.duration = transition.duration
    return newTransition

def dummy_out(*arg, **kw):
    return

class DataWrapper(object):
    def __init__(self, fp):
        self.fp = fp

    def write(self, reader):
        self.fp.seek(0)
        reader.write(self.fp.read())
        self.fp.close()

def save_data_loader(loader):
    writer = ByteReader()
    loader.write(writer)
    loader.parent = None
    data = str(writer)
    fp = tempfile.TemporaryFile()
    fp.write(data)
    return DataWrapper(fp)

def translate(game, print_func = dummy_out):
    onepointfive = game.settings.get('old', False)
    mfa = MFA(ByteReader(open('template.mfa', 'rb')))

    # mfa = MFA()
    mfa.frames = []
    mfa.mfaBuild = 4 #MFA_CURRENT_VERSION
    mfa.product = game.productVersion
    mfa.buildVersion = 251
    mfa.name = game.name or ''
    mfa.description = ''
    mfa.path = game.editorFilename
    mfa.stamp = 6196 * '\x00'

    mfa.fonts = game.fonts or mfa.new(FontBank, compressed = False)
    mfa.sounds = game.sounds or mfa.new(SoundBank, compressed = False)
    mfa.music = game.music or mfa.new(MusicBank, compressed = False)
    for bank in (mfa.fonts, mfa.sounds, mfa.music):
        if bank.items is None:
            continue
        for item in bank.items:
            item.settings = {'compressed' : False}

    # mfa.icons = mfa.new(AGMIBank)
    images = mfa.new(AGMIBank)
    images.items = game.images.items
    for item in images.items:
        item.settings['debug'] = True
    mfa.images = images
    for item in (mfa.images, mfa.icons):
        item.paletteVersion = 768
        item.paletteEntries = 256
        item.palette = mfa.icons.palette
    mfa.author = game.author or ''
    mfa.copyright = game.copyright or ''
    mfa.company = ''
    mfa.version = ''
    if game.files is not None:
        for binaryFile in game.files.items:
            mfa.binaryFiles.append(binaryFile.name)
    header = game.header
    displaySettings = mfa.displaySettings
    graphicSettings = mfa.graphicSettings
    flags = header.flags
    newFlags = header.newFlags
    otherFlags = header.otherFlags
    displaySettings['MDI'] = newFlags['MDI']
    displaySettings['MenuBar'] = flags['MenuBar']
    displaySettings['MenuOnBoot'] = not flags['MenuHidden']
    graphicSettings['MultiSamples'] = flags['MultiSamples']
    mfa.windowSize = (header.windowWidth, header.windowHeight)
    mfa.borderColor = header.borderColor
    mfa.helpFile = ''
    mfa.vitalizePreview = ''
    mfa.initialScore = header.initialScore
    mfa.initialLifes = header.initialLives
    mfa.frameRate = header.frameRate or 50
    mfa.buildType = 0
    mfa.buildPath = game.targetFilename
    mfa.commandLine = ''
    mfa.aboutBox = game.aboutText or ''
    controls = mfa.new(Controls)
    for control in header.controls.items:
        newControl = controls.new(PlayerControl)
        newControl.controlType = 4
        keys = control.keys
        for key in ('up', 'down', 'left', 'right', 'button1', 'button2',
        'button3', 'button4'):
            try:
                key_value = getattr(keys, key).getValue()
            except AttributeError:
                key_value = 0
            getattr(newControl, key).setValue(key_value)
        controls.controls.append(newControl)
    mfa.controls = controls
    mfa.menu = game.menu
    mfa.windowMenuIndex = header.windowsMenuIndex or 0
    mfa.menuImages = {}
    globalValues = mfa.new(ValueList)
    if game.globalValues is not None:
        for index, item in enumerate(game.globalValues.items):
            newValue = ValueItem()
            newValue.name = 'Global Value %s' % (index + 1)
            newValue.value = item
            globalValues.items.append(newValue)
    globalStrings = mfa.new(ValueList)
    if game.globalStrings is not None:
        for index, item in enumerate(game.globalStrings.items):
            newValue = ValueItem()
            newValue.name = 'Global String %s' % (index + 1)
            newValue.value = item
            globalStrings.items.append(newValue)

    mfa.globalValues = globalValues
    mfa.globalStrings = globalStrings

    mfa.globalEvents = ''
    mfa.graphicMode = header.mode
    # mfa.iconImages = []
    mfa.customQualifiers = {}
    mfa.chunks = mfa.new(ChunkList)

    frameItems = {}

    for itemIndex, item in enumerate(game.frameItems.items):
    # for itemIndex, item in enumerate([]):
        newItem = mfa.new(FrameItem)
        newItem.name = item.name or ('Unnamed %s' % itemIndex)
        newItem.objectType = item.objectType
        newItem.handle = item.handle
        newItem.transparent = item.transparent
        newItem.inkEffect = item.inkEffect
        newItem.inkEffectParameter = item.inkEffectValue
        newItem.antiAliasing = item.antialias
        newItem.flags.setFlags(item.flags.getFlags())
        newItem.iconHandle = 10
        newItem.chunks = newItem.new(ChunkList)
        itemLoader = item.properties.loader
        if item.objectType >= EXTENSION_BASE:
            objectClass = ExtensionObject
        else:
            objectClass = FRAME_ITEM_LOADERS[item.objectType]
        newLoader = newItem.loader = newItem.new(objectClass)
        if item.objectType in (QUICKBACKDROP, BACKDROP):
            newLoader.obstacleType = itemLoader.obstacleType
            newLoader.collisionType = itemLoader.collisionMode
            if item.objectType == QUICKBACKDROP:
                newLoader.width = itemLoader.width
                newLoader.height = itemLoader.height
                shape = itemLoader.shape
                newLoader.shape = shape.shape
                newLoader.borderSize = shape.borderSize
                newLoader.borderColor = shape.borderColor
                newLoader.fillType = shape.fillType
                newLoader.color1 = shape.color1 or (0, 0, 0)
                newLoader.color2 = shape.color2 or (0, 0, 0)
                newLoader.flags.setFlags(shape.gradientFlags)
                newLoader.image = shape.image
            else:
                newLoader.handle = itemLoader.image
        else:
            newLoader.objectFlags.setFlags(itemLoader.flags.getFlags())
            try:
                newLoader.newObjectFlags.setFlags(
                    itemLoader.newFlags.getFlags())
            except AttributeError:
                # could happen for MMF1.5
                pass
            newLoader.backgroundColor = itemLoader.backColour
            newLoader.qualifiers = itemLoader.qualifiers
            newLoader.values = convert_alterables(itemLoader.values, 'Value')
            newLoader.strings = convert_alterables(itemLoader.strings, 'String')

            newLoader.movements = movements = newLoader.new(Movements)
            for index, movement in enumerate(itemLoader.movements.items):
                newMovement = movements.new(Movement)
                newMovement.name = 'Movement #%s' % (index + 1)
                if movement.getName() == 'Extension':
                    newMovement.extension = movement.loader.name + '.mvx'
                    newMovement.identifier = movement.loader.id
                else:
                    newMovement.extension = ''
                    newMovement.identifier = movement.type
                    newMovement.player = movement.player
                    newMovement.type = movement.type
                    newMovement.movingAtStart = movement.movingAtStart
                    newMovement.directionAtStart = movement.directionAtStart
                newMovement.loader = movement.loader
                movements.items.append(newMovement)

            newLoader.behaviours = newLoader.new(Behaviours)
            newLoader.fadeIn = convert_transition(itemLoader.fadeIn)
            newLoader.fadeOut = convert_transition(itemLoader.fadeOut)
            if itemLoader.animations is not None:
                animationHeader = itemLoader.animations
                newLoader.items = items = []
                for i in xrange(max(animationHeader.loadedAnimations) + 1):
                    newAnimation = newLoader.new(Animation)
                    items.append(newAnimation)
                    newAnimation.directions = newDirections = []
                    try:
                        animation = animationHeader.loadedAnimations[i]
                    except KeyError:
                        continue
                    for n, direction in animation.loadedDirections.iteritems():
                        newDirection = newAnimation.new(AnimationDirection)
                        newDirections.append(newDirection)
                        newDirection.index = n
                        newDirection.minSpeed = direction.minSpeed
                        newDirection.maxSpeed = direction.maxSpeed
                        newDirection.repeat = direction.repeat
                        newDirection.backTo = direction.backTo
                        newDirection.frames = direction.frames
            if item.objectType >= EXTENSION_BASE:
                extension = item.getExtension(game.extensions)
                newLoader.extensionType = -1
                newLoader.extensionName = ''
                newLoader.filename = extension.name + '.mfx'
                newLoader.magic = extension.magicNumber
                newLoader.subType = extension.subType
                newLoader.extensionVersion = itemLoader.extensionVersion
                newLoader.extensionId = itemLoader.extensionId
                newLoader.extensionPrivate = itemLoader.extensionPrivate
                newLoader.extensionData = itemLoader.extensionData or ''
            elif item.objectType == COUNTER:
                counter = itemLoader.counter
                counters = itemLoader.counters
                newLoader.value = counter.initial
                newLoader.minimum = counter.minimum
                newLoader.maximum = counter.maximum
                if counters is None:
                    newLoader.displayType = HIDDEN
                    shape = None
                    newLoader.countType = 0
                    newLoader.width = 0
                    newLoader.height = 0
                    newLoader.images = []
                    newLoader.font = 0
                else:
                    shape = counters.shape
                    newLoader.displayType = counters.displayType
                    newLoader.countType = counters.inverse
                    newLoader.width = counters.width
                    newLoader.height = counters.height
                    newLoader.images = counters.frames or []
                    newLoader.font = counters.font or 0
                if shape is None:
                    color1 = color2 = (0, 0, 0)
                    newLoader.verticalGradient = 0
                    newLoader.flags = 0
                else:
                    color1 = shape.color1 or (0, 0, 0)
                    color2 = shape.color2 or (0, 0, 0)
                    newLoader.verticalGradient = shape.gradientFlags or 0
                    newLoader.flags = shape.fillType
                newLoader.color1 = color1
                newLoader.color2 = color2
            elif item.objectType in (SCORE, LIVES):
                counters = itemLoader.counters
                newLoader.player = counters.player
                newLoader.images = counters.frames or []
                newLoader.displayType = counters.displayType
                newLoader.flags = counters.flags
                newLoader.font = counters.font
                newLoader.width = counters.width
                newLoader.height = counters.height
            elif item.objectType == RTF:
                rtf = itemLoader.rtf
                newLoader.width = rtf.width
                newLoader.height = rtf.height
                newLoader.value = rtf.value
                newLoader.color = rtf.color
                newLoader.flags = rtf.options.getFlags()
            elif item.objectType == SUBAPPLICATION:
                subApplication = itemLoader.subApplication
                newLoader.width = subApplication.width
                newLoader.height = subApplication.height
                newLoader.filename = subApplication.name
                if subApplication.options['Internal']:
                    startFrame = subApplication.startFrame
                else:
                    startFrame = -1
                newLoader.startFrame = startFrame
                newLoader.options.setFlags(subApplication.options.getFlags())
            elif item.objectType == TEXT:
                text = itemLoader.text
                newLoader.width = text.width
                newLoader.height = text.height
                paragraph = text.items[0]
                newLoader.font = paragraph.font
                newLoader.color = paragraph.color
                newLoader.flags = 0
                newLoader.items = paragraphs = []
                for paragraph in text.items:
                    newParagraph = newLoader.new(Paragraph)
                    paragraphs.append(newParagraph)
                    newParagraph.value = paragraph.value
                    newParagraph.flags = paragraph.flags.getFlags()
            elif item.objectType == QUESTION:
                text = itemLoader.text
                newLoader.width = text.width
                newLoader.height = text.height
                question = text.items[0]
                answer = text.items[1]
                print question.font
                newLoader.questionFont = question.font
                newLoader.questionColor = question.color
                newLoader.questionFlags = 0
                newLoader.question = question.value
                newLoader.answerFont = answer.font
                newLoader.answerColor = answer.color
                newLoader.answerFlags = 0
                newLoader.items = paragraphs = []
                for paragraph in text.items[1:]:
                    newParagraph = newLoader.new(Paragraph)
                    paragraphs.append(newParagraph)
                    newParagraph.value = paragraph.value
                    newParagraph.flags = paragraph.flags.getFlags()
        frameItems[newItem.handle] = newItem

    qualifiers = {}

    indexHandles = dict(
        [(v, index) for (index, v) in enumerate(game.frameHandles)])

    for index, frame in enumerate(game.frames):
        #print 'this application has %s frames. I am currently working on frame %s.' % (len(game.frames), len(frame)) #invalid type lol
        frame.load()
        newFrame = mfa.new(Frame)
        newFrame.handle = indexHandles[index]
        newFrame.name = frame.name or ''
        newFrame.size = (frame.width, frame.height)
        newFrame.background = frame.background
        newFrame.fadeIn = convert_transition(frame.fadeIn)
        newFrame.fadeOut = convert_transition(frame.fadeOut)
        flags = newFrame.flags
        originalFlags = frame.flags
        flags['GrabDesktop'] = originalFlags['GrabDesktop']
        flags['KeepDisplay'] = originalFlags['KeepDisplay']
        flags['BackgroundCollisions'] = originalFlags['TotalCollisionMask']
        flags['ResizeToScreen'] = originalFlags['ResizeAtStart']
        flags['ForceLoadOnCall'] = originalFlags['ForceLoadOnCall']
        flags['NoDisplaySurface'] = False#originalFlags['NoSurface']
        flags['TimerBasedMovements'] = originalFlags['TimedMovements']
        newFrame.maxObjects = frame.maxObjects
        newFrame.password = frame.password or ''
        newFrame.lastViewedX = 320
        newFrame.lastViewedY = 240
        newFrame.palette = newFrame.palette
        newFrame.stampHandle = 12
        newFrame.activeLayer = 0
        newFrame.layers = layers = []
        try:
            for layer in frame.layers.items:
                newLayer = newFrame.new(Layer)
                newLayer.name = layer.name
                flags = newLayer.flags
                originalFlags = layer.flags
                flags['HideAtStart'] = originalFlags['ToHide']
                flags['Visible'] = True
                flags['NoBackground'] = originalFlags['DoNotSaveBackground']
                flags['WrapHorizontally'] = originalFlags['WrapHorizontally']
                flags['WrapVertically'] = originalFlags['WrapVertically']
                newLayer.xCoefficient = layer.xCoefficient
                newLayer.yCoefficient = layer.yCoefficient
                layers.append(newLayer)
        except AttributeError:
            # MMF 1.5
            layer = newFrame.new(Layer)
            layer.name = 'Default Layer'
            layer.xCoefficient = layer.yCoefficient = 1.0
            layers.append(layer)
        newFrameItems = set()
        newFrame.instances = instances = []
        print_func('Translating frame %r (%s)' % (newFrame.name, index))
        if frame.instances is not None:
            for instanceIndex, instance in enumerate(frame.instances.items):
                try:
                    frameItem = frameItems[instance.objectInfo]
                except KeyError:
                    continue
                newFrameItems.add(frameItem)
                newInstance = newFrame.new(FrameInstance)
                newInstance.x = instance.x
                newInstance.y = instance.y
                newInstance.handle = instanceIndex
                if instance.parentType != NONE_PARENT:
                    newInstance.flags = 8
                else:
                    newInstance.flags = 0
                newInstance.parentType = instance.parentType
                newInstance.itemHandle = instance.objectInfo
                parentHandle = instance.parentHandle
                newInstance.parentHandle = parentHandle
                newInstance.layer = instance.layer
                instances.append(newInstance)
        newFrame.items = list(newFrameItems)
        newFrame.folders = folders = []
        for item in newFrame.items:
            newFolder = newFrame.new(ItemFolder)
            newFolder.items = [item.handle]
            folders.append(newFolder)
        events = newFrame.events = frame.new(Events)
        events.version = 1027
        events.frameType = 0
        events.items = frame.events.items
        events.objects = objects = []
        for item in newFrame.items:
            newObject = events.new(EventObject)
            objects.append(newObject)
            newObject.handle = item.handle
            newObject.name = item.name
            newObject.typeName = ''
            newObject.itemType = item.objectType
            newObject.objectType = FRAME_ITEM_TYPE
            newObject.flags = 0
            newObject.itemHandle = item.handle
            newObject.instanceHandle = 0xFFFFFFFF
        for k, item in frame.events.qualifiers.iteritems():
            key = (k, item.type)
            objectInfo = item.objectInfo
            if key in qualifiers:
                newObject = qualifiers[key]
                newHandle = newObject.handle
            else:
                newObject = events.new(EventObject)
                qualifiers[key] = newObject
                newHandle = 0
                while 1:
                    if newHandle not in qualifiers and newHandle not in frameItems:
                        break
                    newHandle += 1
                frameItems[newHandle] = newObject
                newObject.handle = newHandle
                newObject.systemQualifier = item.qualifier
                newObject.name = ''
                newObject.typeName = ''
                newObject.itemType = item.type
                newObject.objectType = SYSTEM_ITEM_TYPE
                newObject.flags = 0
            for eventGroup in frame.events.items:
                for aceList in (eventGroup.actions, eventGroup.conditions):
                    for ace in aceList:
                        if ace.objectInfo == objectInfo:
                            ace.objectInfo = newHandle
                        for parameter in ace.items:
                            parameter = parameter.loader
                            if hasattr(parameter, 'objectInfo'):
                                if parameter.objectInfo == objectInfo:
                                    parameter.objectInfo = newHandle
                            if hasattr(parameter, 'objectInfoParent'):
                                if parameter.objectInfoParent == objectInfo:
                                    parameter.objectInfoParent = newHandle
                            if hasattr(parameter, 'position'):
                                position = parameter.position
                                if position.objectInfoParent == objectInfo:
                                    position.objectInfoParent = newHandle
                            if parameter.isExpression:
                                for expression in parameter.items:
                                    if expression.objectInfo == objectInfo:
                                        expression.objectInfo = newHandle
            objects.append(newObject)
        # group stuff
        groups = {}
        groupId = 0
        def loop_parameters():
            for eventGroup in frame.events.items:
                for aceList in (eventGroup.actions, eventGroup.conditions):
                    for ace in aceList:
                        for parameter in ace.items:
                            yield parameter.getName(), parameter.loader

        for name, parameter in loop_parameters():
            if name == 'GROUP':
                print "loopname GROUP"
                offset = parameter.offset
                print "offset:"
                print offset
                if onepointfive:
                    offset += 2
                else:
                    offset -= 2
                groups[offset] = groupId
                parameter.id = groupId
                parameter.password = make_group_checksum('', parameter.name)
                groupId += 1

        for name, parameter in loop_parameters():
            if name == 'GROUPOINTER':
                parameter.id = groups[parameter.pointer]
                parameter.savedPointer = parameter.pointer = 0

        newFrame.chunks = mfa.new(ChunkList)
        mfa.frames.append(save_data_loader(newFrame))
        frame.close()

    return mfa
