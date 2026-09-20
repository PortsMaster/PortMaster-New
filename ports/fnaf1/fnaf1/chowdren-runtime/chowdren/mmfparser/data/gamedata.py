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

from mmfparser.loader import DataLoader

GAME_HEADER = 'PAME'
UNICODE_GAME_HEADER = 'PAMU'

CNCV1_VERSION = 0x207

products = {
    'MMF1' : 0x0300,
    'MMF1.5' : 0x0301,
    'MMF2' : 0x0302
}

class GameData(DataLoader):
    runtimeVersion = None
    runtimeSubversion = None
    productVersion = None
    productBuild = None
    chunks = None

    name = None
    author = None
    copyright = None
    aboutText = None
    doc = None

    editorFilename = None
    targetFilename = None

    exeOnly = None

    menu = None
    icon = None

    header = None
    extendedHeader = None

    fonts = None
    sounds = None
    music = None
    images = None

    globalValues = None
    globalStrings = None

    extensions = None

    frameItems = None

    frames = None
    frameHandles = None

    serial = None

    shaders = None

    def initialize(self):
        self.frames = []

    def read(self, reader):
        header = reader.read(4)
        if header == UNICODE_GAME_HEADER:
            self.settings['unicode'] = True
        elif header != GAME_HEADER:
            raise Exception('invalid game header')
        first_short = reader.readShort()
        if first_short == CNCV1_VERSION:
            self.settings["cnc"] = True
            self.read_cnc(reader)
            return
        self.runtimeVersion = first_short
        self.runtimeSubversion = reader.readShort()
        self.productVersion = reader.readInt()
        self.productBuild = reader.readInt()

        self.settings['build'] = self.productBuild

        productName = self.getProduct()

        if productName == 'MMF1.5':
            self.settings['old'] = True
        elif productName != 'MMF2':
            raise Exception('invalid product: %s' % productName)

        chunks = self.new(ChunkList, reader)

        if self.settings.get('old', False):
            from mmfparser.data.chunkloaders.onepointfive import all as old
            self.header = chunks.popChunk(old.AppHeader)
            try:
                self.name = chunks.popChunk(AppName).value
            except IndexError:
                pass
            try:
                self.copyright = chunks.popChunk(Copyright).value
            except IndexError:
                pass
            try:
                self.aboutText = chunks.popChunk(AboutText).value
            except IndexError:
                pass
            try:
                self.author = chunks.popChunk(AppAuthor).value
            except IndexError:
                pass
            try:
                self.editorFilename = chunks.popChunk(EditorFilename).value
            except IndexError:
                pass
            try:
                self.targetFilename = chunks.popChunk(TargetFilename).value
            except IndexError:
                pass
            try:
                self.exeOnly = chunks.popChunk(ExeOnly).value
            except IndexError:
                pass
            self.menu = chunks.popChunk(AppMenu, True)
            try:
                self.sounds = chunks.popChunk(SoundBank)
            except IndexError:
                pass
            try:
                self.music = chunks.popChunk(MusicBank)
            except IndexError:
                pass
            try:
                self.fonts = chunks.popChunk(FontBank)
            except IndexError:
                pass
            try:
                self.images = chunks.popChunk(ImageBank)
                print 'Popping imagechunks'
            except IndexError:
                print 'Imagechunk error'
                pass
            try:
                self.icon = chunks.popChunk(AppIcon)
            except IndexError:
                pass
            try:
                self.globalValues = chunks.popChunk(GlobalValues)
            except IndexError:
                pass
            self.extensions = chunks.popChunk(ExtensionList)

            self.frameItems = chunks.popChunk(old.FrameItems)
            self.frameHandles = chunks.popChunk(FrameHandles).handles
            try:
                while 1:
                    self.frames.append(chunks.popChunk(old.Frame))
            except IndexError:
                pass
            self.files = None
            self.chunks = chunks
            return

        self.header = chunks.popChunk(AppHeader)
        self.extendedHeader = chunks.popChunk(ExtendedHeader, True)

        try:
            self.name = chunks.popChunk(AppName).value
        except IndexError:
            pass

        try:
            self.copyright = chunks.popChunk(Copyright).value
        except IndexError:
            pass
        try:
            self.aboutText = chunks.popChunk(AboutText).value
        except IndexError:
            pass
        try:
            self.author = chunks.popChunk(AppAuthor).value
        except IndexError:
            pass

        try:
            self.editorFilename = chunks.popChunk(EditorFilename).value
        except IndexError:
            pass

        try:
            self.targetFilename = chunks.popChunk(TargetFilename).value
        except IndexError:
            pass

        try:
            self.exeOnly = chunks.popChunk(ExeOnly).value
        except IndexError:
            pass

        self.menu = chunks.popChunk(AppMenu, True)

        try:
            self.sounds = chunks.popChunk(SoundBank)
        except IndexError:
            pass

        try:
            self.music = chunks.popChunk(MusicBank)
        except IndexError:
            pass

        try:
            self.fonts = chunks.popChunk(FontBank)
        except IndexError:
            pass

        try:
            self.images = chunks.popChunk(ImageBank)
        except IndexError:
            pass

        try:
            self.icon = chunks.popChunk(AppIcon)
        except IndexError:
            pass

        try:
            self.shaders = chunks.popChunk(Shaders)
        except IndexError:
            pass

        try:
            self.globalStrings = chunks.popChunk(GlobalStrings)
        except IndexError:
            pass
        try:
            self.globalValues = chunks.popChunk(GlobalValues)
        except IndexError:
            pass

        self.extensions = chunks.popChunk(ExtensionList)

        self.frameItems = chunks.popChunk(FrameItems)
        self.frameHandles = chunks.popChunk(FrameHandles).handles

        try:
            while 1:
                self.frames.append(chunks.popChunk(Frame))
        except IndexError:
            pass

        self.serial = chunks.popChunk(SecNum)

        self.files = chunks.popChunk(BinaryFiles, True)

        self.chunks = chunks

    def getProduct(self):
        for key, value in products.iteritems():
            if value == self.runtimeVersion:
                return key
        return False

    def setProduct(self, productName):
        self.runtimeVersion = products[productName]

    def readCnc(self, reader):
        pass

    def write(self, reader):
        reader.write(GAME_HEADER) # PAME
        reader.writeShort(self.runtimeVersion)
        reader.writeShort(self.runtimeSubversion)
        reader.writeInt(self.productVersion)
        reader.writeInt(self.productBuild)
        newChunks = self.new(ChunkList)
        newChunks.append(self.header)
        if self.name is not None:
            newChunks.append(makeValueChunk(AppName, self.name))
        if self.targetFilename is not None:
            newChunks.append(makeValueChunk(TargetFilename, self.targetFilename))
        if self.editorFilename is not None:
            newChunks.append(makeValueChunk(EditorFilename, self.targetFilename))
        if self.icon is not None:
            newChunks.append(self.icon)
        if self.extendedHeader is not None:
            newChunks.append(self.extendedHeader)
        if self.globalValues is not None:
            newChunks.append(self.globalValues)
        if self.globalStrings is not None:
            newChunks.append(self.globalStrings)
        if self.menu is not None:
            newChunks.append(self.menu)
        newChunks.append(ExtData())
        newChunks.append(self.extensions)
        newChunks.append(self.frameItems)
        newChunks.append(self.serial)
        frameHandles = FrameHandles()
        frameHandles.handles = self.frameHandles
        newChunks.append(frameHandles)
        if self.exeOnly is not None:
            newChunks.append(makeValueChunk(ExeOnly, self.exeOnly))
        for frame in self.frames:
            newChunks.append(frame, False)
        newChunks.append(Protection())
        newChunks.append(self.images)
        #newChunks.append(self.imageOffsets)
        newChunks.append(self.new(ImageOffsets, bank = self.images))
        if self.fonts is not None:
            newChunks.append(self.fonts)
            newChunks.append(FontOffsets(bank = self.fonts))
        if self.files is not None:
            newChunks.append(self.files)
        newChunks.append(Last(), False)
        newChunks.write(reader)

from mmfparser.data.chunk import *
from mmfparser.data.chunkloaders.all import *
