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

from mmfparser.bytereader cimport ByteReader
from mmfparser.data import zlibdata
from mmfparser.data import onepointfive
from mmfparser.loader cimport DataLoader

IF USE_TRANS:
    cdef extern from "chunk_cm.cpp":
        cdef void prepare_transform(unsigned char * trans, int size)
        cdef void transform(unsigned char * data, int size,
                            unsigned char * trans)

def makeValueChunk(klass, value):
    newLoader = klass()
    newLoader.value = value
    return newLoader

cdef class Chunk(DataLoader):
    cdef public:
        str data
        short id
        short flags
        DataLoader loader

    cpdef read(self, ByteReader reader):
        cdef bint old = self.settings.get('old', False)
        self.id = reader.readShort()
        cdef short flags = reader.readShort()
        self.flags = flags
        cdef int size = reader.readInt()
        cdef ByteReader data = reader.readReader(size)

        cdef bint supported
        IF USE_TRANS:
            supported = (flags & (~3)) == 0
        ELSE:
            supported = (flags & (~1)) == 0
        if not supported:
            raise Exception('unsupported compression flag: %s' % flags)

        if (flags & 1) != 0:
            IF USE_TRANS:
                if (flags & 2) != 0:
                    transform(&data.buffer[data.pos] + 4, data.size() - 4,
                              self.settings['trans'])
            if old:
                data = onepointfive.decompress(data)
            else:
                data = zlibdata.decompress(data)
        elif (flags & 2) != 0:
            IF USE_TRANS:
                transform(&data.buffer[data.pos], data.size(),
                          self.settings['trans'])

        cdef type loaderClass
        try:
            if old:
                loaderClass = oldLoaders[self.id]
            else:
                loaderClass = chunkLoaders[self.id]
            self.loader = self.parent.new(loaderClass, data,
                chunk = self)
        except KeyError:
            print '(unknown chunk %s)' % self.id

    def getName(self):
        return chunkNames[self.id]

    def write(self, ByteReader reader):
        flags = self.flags
        reader.writeShort(self.id)
        reader.writeShort(flags)
        data = self.loader.generate()
        if flags == 1:
            data = zlibdata.compress(data)
        reader.writeInt(len(data))
        reader.writeReader(data)

IF USE_TRANS:
    cdef bytes create_transform_part(bytes data):
        cdef unsigned char * c = data
        cdef unsigned short * v = <unsigned short*>c

        cdef unsigned int l = len(data) / 2
        cdef unsigned int i
        cdef unsigned short vv

        cdef bytes ret = b''

        for i in xrange(l):
            vv = v[i]
            if vv & 0xFF:
                ret += chr(vv & 0xFF)
            vv = vv >> 8
            if vv:
                ret += chr(vv)

        return ret

    cpdef bytes create_transform(bytes editor, bytes name, bytes copyright,
                                 bint is_ascii):
        cdef bytes ret
        if is_ascii:
            ret = (editor + name + copyright)
        else:
            editor = editor.decode('utf-8').encode('utf-16-le')
            name = name.decode('utf-8').encode('utf-16-le')
            copyright = copyright.decode('utf-8').encode('utf-16-le')
            ret = b''
            ret += create_transform_part(editor)
            ret += create_transform_part(name)
            ret += create_transform_part(copyright)

        ret = ret[:128]
        cdef unsigned int l = len(ret)
        ret += '\x00' * max(0, 256 - len(ret))

        cdef bytearray ret_arr = bytearray(ret)
        cdef unsigned char * ret_c = ret_arr
        prepare_transform(ret_arr, l)
        return bytes(ret_arr)

cdef class ChunkList(DataLoader):
    cdef public:
        list items

    cpdef initialize(self):
        self.items = []
    
    cpdef read(self, ByteReader reader):
        setup()
        cdef list items = self.items
        # cdef int checksumStart = -1
        parent = self.parent
        cdef Chunk newChunk, copyright
        cdef bytes copyright_text
        # cdef int chunkPosition

        while 1:
            # chunkPosition = reader.tell()
            newChunk = parent.new(Chunk, reader)
            if newChunk.id == LAST:
                break
            IF USE_TRANS:
                if newChunk.id == 8750 and self.settings['build'] >= 284:
                    # EditorFilename
                    editor = newChunk.loader.value
                    name = self.getId(8740).loader.value
                    copyright = self.getId(8763)
                    if copyright is None:
                        copyright_text = b''
                    else:
                        copyright_text = copyright.loader.value
                    trans = create_transform(editor, name, copyright_text,
                                             not self.settings.get('unicode',
                                                                   False))
                    parent.settings['trans'] = trans

            # elif newChunk.id == APPTARGETFILENAME:
                # checksumStart = chunkPosition
            # elif False and newChunk.id == PROTECTION and checksumStart != -1:
                # currentPosition = reader.tell()
                # reader.seek(checksumStart)
                # data = reader.read(chunkPosition - checksumStart)
                # reader.seek(currentPosition)
                # if not newChunk.loader.compareData(data):
                    # raise Exception('checksum does not match (%s %s)' %
                        # (checksumStart, currentPosition))
            items.append(newChunk)
    
    def append(self, loader, compressed = False):
        newChunk = self.new(Chunk)
        newChunk.id = chunkLoaderIds[loader.__class__]
        if compressed:
            newChunk.flags = 1
        else:
            newChunk.flags = 0
        newChunk.loader = loader
        self.items.append(newChunk)
        return newChunk
    
    cdef Chunk getId(self, unsigned int typ):
        cdef Chunk chunk
        cdef Chunk foundChunk = None
        for chunk in self.items:
            if chunk.id == typ:
                return chunk
        return None

    def popChunk(self, chunkType, bint returnNone = False):
        cdef Chunk chunk
        cdef Chunk foundChunk = None
        for chunk in self.items:
            if type(chunk.loader) is chunkType:
                foundChunk = chunk
                break
        if foundChunk is not None:
            self.items.remove(foundChunk)
            return foundChunk.loader
        if returnNone:
            return None
        raise IndexError('chunktype %r not found' % chunkType.__name__)
    
    def indexChunk(self, chunkType):
        for index, chunk in enumerate(self.items):
            if isinstance(chunk.loader, chunkType):
                return index
        raise IndexError('chunktype %r not found' % chunkType.__name__)
        
    def popName(self, chunkName):
        for chunk in [chunk for chunk in self.items if chunk.getName() == chunkName]:
            self.items.remove(chunk)
            return chunk.loader
        raise IndexError('chunkname %r not found' % chunkName)
                    
    def write(self, ByteReader reader):
        if 'LAST' not in [chunk.getName() for chunk in self.items]:
            raise Exception('Last chunk not found in ChunkList')

        checksumStart = None
        for chunk in self.items:
            if chunk.id == chunkIds['PROTECTION']:
                if checksumStart is None:
                    continue
                currentPosition = reader.tell()
                reader.seek(checksumStart)
                data = reader.read(currentPosition - checksumStart)
                chunk.loader.setData(data)
            elif chunk.id == chunkIds['APPTARGETFILENAME']:
                checksumStart = reader.tell()
            print 'writing', chunk.getName(), 'at', reader.tell()
            chunk.write(reader)

cdef class PreservingLoader(DataLoader):
    cdef public:
        bytes realData
    cpdef read(self, ByteReader reader):
        print '%s has not been implemented' % self.settings['chunk'].getName()
        # reader.openEditor()
        # import code
        # code.interact(local = locals())
        # raise NotImplementedError('%s has not been implemented' % self.parent.getName())
        self.realData = reader.read()
        
    def write(self, ByteReader reader):
        return reader.write(self.realData)

cdef inline createPreservingLoader():
    return PreservingLoader

cdef bint initialized = False

cdef dict chunkLoaders
cdef dict chunkLoaderIds
cdef dict oldLoadersReal

cdef inline void setup():
    if chunkLoaders is not None:
        return
    from mmfparser.data.chunkloaders import all
    from mmfparser.data.chunkloaders.onepointfive import all as oldchunks
    
    global chunkLoaders
    chunkLoaders = {
        # Vitalize chunks (0x11)
        4386 : all.VitalizePreview, # Preview
        # Application chunks (0x22)
        # not-in-use 8738 : createPreservingLoader(), # AppMiniHeader
        8739 : all.AppHeader,
        8740 : all.AppName,
        8741 : all.AppAuthor,
        8742 : all.AppMenu,
        8743 : all.ExtPath,
        # deprecated 8744 : createPreservingLoader(), # Extensions
        8745 : all.FrameItems, # FrameItems
        # deprecated 8746 : createPreservingLoader(), # GlobalEvents
        8747 : all.FrameHandles, # FrameHandles
        8748 : all.ExtData, # ExtData
        # deprecated 8749 : createPreservingLoader(), # Additional_Extension
        8750 : all.EditorFilename, # AppEditorFilename
        8751 : all.TargetFilename, # AppTargetFilename
        8752 : all.AppDoc, # AppDoc
        8753 : all.OtherExtensions, # OtherExts
        8754 : all.GlobalValues,
        8755 : all.GlobalStrings, # GlobalStrings
        8756 : all.ExtensionList, # Extensions2
        8757 : all.AppIcon, # AppIcon_16x16x8
        8758 : createPreservingLoader(), # DemoVersion
        8759 : all.SecNum, # serial number
        8760 : all.BinaryFiles, # BinaryFiles
        8761 : createPreservingLoader(), # AppMenuImages
        8762 : all.AboutText, # AboutText
        8763 : all.Copyright, # Copyright
        8764 : createPreservingLoader(), # GlobalValueNames
        8765 : createPreservingLoader(), # GlobalStringNames
        8766 : all.MovementExtensions, # MvtExts
        8767 : all.FrameItems, # FrameItems_2
        8768 : all.ExeOnly, # EXEOnly
        8770 : all.Protection,
        8771 : all.Shaders, # Shaders
        8773 : all.ExtendedHeader, # ExtendedHeader aka APPHEADER2
        # Frame chunks (0x33)
        13107 : all.Frame, # Frame
        13108 : all.FrameHeader, # FrameHeader
        13109 : all.FrameName, # FrameName
        13110 : all.FramePassword, # FramePassword
        13111 : all.FramePalette, # FramePalette
        13112 : all.ObjectInstances, # FrameItemInstances
        13113 : createPreservingLoader(), # FrameFadeInFrame
        13114 : createPreservingLoader(), # FrameFadeOutFrame
        13115 : all.FadeIn, # FrameFadeIn
        13116 : all.FadeOut, # FrameFadeOut
        13117 : all.Events, # FrameEvents
        13118 : createPreservingLoader(), # FramePlayHeader
        13119 : createPreservingLoader(), # Additional_FrameItem
        13120 : createPreservingLoader(), # Additional_FrameItemInstance
        13121 : all.Layers, # FrameLayers
        13122 : all.VirtualSize, # FrameVirtualRect
        13123 : all.DemoFilePath, # DemoFilePath
        13124 : createPreservingLoader(), # RandomSeed
        13125 : all.LayerEffects, # FrameLayerEffects
        13126 : createPreservingLoader(), # BluRayFrameOptions
        13127 : all.MovementTimerBase, # MvtTimerBase
        13128 : createPreservingLoader(), # MosaicImageTable
        13129 : all.FrameEffects, # FrameEffects
        13130 : createPreservingLoader(), # FrameIphoneOptions
        # Object chunks (0x44)
        17476 : all.ObjectHeader, # ObjInfoHeader
        17477 : all.ObjectName,
        17478 : all.ObjectProperties, # ObjectsCommon
        17479 : createPreservingLoader(), # ObjectUnknown
        17480 : all.ObjectEffects, # ObjectUnknown2
        # Offset chunks (0x55)
        21845 : all.ImageOffsets, # ImagesOffsets
        21846 : all.FontOffsets, # FontsOffsets
        21847 : all.SoundOffsets, # SoundsOffsets
        21848 : all.MusicOffsets, # MusicsOffsets
        # Bank chunks (0x66)
        26214 : all.ImageBank, # Images
        26215 : all.FontBank,
        26216 : all.SoundBank,
        26217 : all.MusicBank, # Musics
        # Last chunk (0x7f7f)
        32639 : all.Last, # Last
    }
    
    global chunkLoaderIds
    chunkLoaderIds = {}
    for id, klass in chunkLoaders.iteritems():
        chunkLoaderIds[klass] = id
    
    global oldLoadersReal
    oldLoadersReal = {
        8739 : oldchunks.AppHeader,
        8740 : all.AppName,
        8741 : all.AppAuthor,
        8742 : all.AppMenu,
        8743 : all.ExtPath,
        8745 : oldchunks.FrameItems, # FrameItems
        8767 : oldchunks.FrameItems, # FrameItems_2
        8747 : all.FrameHandles, # FrameHandles
        8748 : all.ExtData, # ExtData
        8750 : all.EditorFilename, # AppEditorFilename
        8751 : all.TargetFilename, # AppTargetFilename
        8753 : all.OtherExtensions, # OtherExts
        8756 : all.ExtensionList, # Extensions2
        8757 : all.AppIcon, # AppIcon_16x16x8
        17476 : all.ObjectHeader, # ObjInfoHeader
        17477 : all.ObjectName,
        17478 : oldchunks.ObjectProperties,
        #
        13107 : oldchunks.Frame,
        13108 : oldchunks.FrameHeader, # FrameHeader
        13109 : all.FrameName, # FrameName
        13110 : all.FramePassword, # FramePassword
        13111 : all.FramePalette, # FramePalette
        13112 : oldchunks.ObjectInstances, # FrameItemInstances
        13113 : createPreservingLoader(), # FrameFadeInFrame
        13114 : createPreservingLoader(), # FrameFadeOutFrame
        13115 : all.FadeIn, # FrameFadeIn
        13116 : all.FadeOut, # FrameFadeOut
        13117 : oldchunks.Events, # FrameEvents
        13118 : createPreservingLoader(), # FramePlayHeader
        13119 : createPreservingLoader(), # Additional_FrameItem
        13120 : createPreservingLoader(), # Additional_FrameItemInstance
        #
        26214 : all.ImageBank, # Images
        26215 : all.FontBank,
        26216 : all.SoundBank,
        # 26217 : all.MusicBank, # Musics
        32639 : all.Last, # Last
    }

class OldLoaders:
    def __getitem__(self, key):
        try:
            return oldLoadersReal[key]
        except KeyError:
            return createPreservingLoader()

oldLoaders = OldLoaders()

chunkNames = {
    4386 : 'PREVIEW',
    8738 : 'APPMINIHEADER',
    8739 : 'APPHEADER',
    8740 : 'APPNAME',
    8741 : 'APPAUTHOR',
    8742 : 'APPMENU',
    8743 : 'EXTPATH',
    8744 : 'EXTENSIONS',
    8745 : 'FRAMEITEMS',
    8746 : 'GLOBALEVENTS',
    8747 : 'FRAMEHANDLES',
    8748 : 'EXTDATA',
    8749 : 'ADDITIONAL_EXTENSION',
    8750 : 'APPEDITORFILENAME',
    8751 : 'APPTARGETFILENAME',
    8752 : 'APPDOC',
    8753 : 'OTHEREXTS',
    8754 : 'GLOBALVALUES',
    8755 : 'GLOBALSTRINGS',
    8756 : 'EXTENSIONS2',
    8757 : 'APPICON_16x16x8',
    8758 : 'DEMOVERSION',
    8759 : 'SECNUM', # second number, GetTickCount() 
    8760 : 'BINARYFILES',
    8761 : 'APPMENUIMAGES',
    8762 : 'ABOUTTEXT',
    8763 : 'COPYRIGHT',
    8764 : 'GLOBALVALUENAMES',
    8765 : 'GLOBALSTRINGNAMES',
    8766 : 'MVTEXTS',
    8767 : 'FRAMEITEMS_2',
    8768 : 'EXEONLY',
    8770 : 'PROTECTION',
    8771 : 'SHADERS',
    8773 : 'APPHEADER2',
    13107 : 'FRAME',
    13108 : 'FRAMEHEADER',
    13109 : 'FRAMENAME',
    13110 : 'FRAMEPASSWORD',
    13111 : 'FRAMEPALETTE',
    13112 : 'FRAMEITEMINSTANCES',
    13113 : 'FRAMEFADEINFRAME',
    13114 : 'FRAMEFADEOUTFRAME',
    13115 : 'FRAMEFADEIN',
    13116 : 'FRAMEFADEOUT',
    13117 : 'FRAMEEVENTS',
    13118 : 'FRAMEPLAYHEADER',
    13119 : 'ADDITIONAL_FRAMEITEM',
    13120 : 'ADDITIONAL_FRAMEITEMINSTANCE',
    13121 : 'FRAMELAYERS',
    13122 : 'FRAMEVIRTUALRECT',
    13123 : 'DEMOFILEPATH',
    13124 : 'RANDOMSEED',
    13125 : 'FRAMELAYEREFFECTS',
    13126 : 'BLURAYFRAMEOPTIONS',
    13127 : 'MVTTIMERBASE',
    13128 : 'MOSAICIMAGETABLE',
    13129 : 'FRAMEEFFECTS',
    13130 : 'FRAME_IPHONE_OPTIONS',
    17476 : 'OBJINFOHEADER',
    17477 : 'OBJINFONAME',
    17478 : 'OBJECTSCOMMON',
    17479 : 'OBJECTUNKNOWN',
    17480 : 'OBJECTEFFECTS',
    21845 : 'IMAGESOFFSETS',
    21846 : 'FONTSOFFSETS',
    21847 : 'SOUNDSOFFSETS',
    21848 : 'MUSICSOFFSETS',
    26214 : 'IMAGES',
    26215 : 'FONTS',
    26216 : 'SOUNDS',
    26217 : 'MUSICS',
    32639 : 'LAST'
}

chunkIds = {}
for id, name in chunkNames.iteritems():
    chunkIds[name] = id

cdef int LAST = chunkIds['LAST']
cdef int APPTARGETFILENAME = chunkIds['APPTARGETFILENAME']
cdef int PROTECTION = chunkIds['PROTECTION']

__all__ = ['Chunk', 'ChunkList', 'makeValueChunk']