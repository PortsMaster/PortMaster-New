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

cimport cython

import struct
import zlib
from cStringIO import StringIO

from mmfparser.bytereader cimport ByteReader
from mmfparser.data import zlibdata
from mmfparser.data import onepointfive
from mmfparser.loader cimport DataLoader
from mmfparser.data.chunkloaders.appheader import graphicModes
from mmfparser.common cimport allocate_memory

from mmfparser.bitdict import BitDict

cdef extern from "math.h": 
    double ceil(double ceil)

cdef int POINT_MODE = 4 # 16 million colors
cdef int FIFTEENPOINT_MODE = 6  # 32768 colors

cdef class ImageItem
    
cdef inline object indexImage(ImageItem item, frame):
    cdef unsigned int i
    cdef tuple current_value
    cdef unsigned int * image
    cdef unsigned int * new_points_array
    cdef char * new_points
    if not item.indexed:
        return item.image
    else:
        image = <unsigned int *>(<char *>item.image)
        str_points = allocate_memory(len(item.image), &new_points)
        new_points_array = <unsigned int *>new_points
        for i in range(len(item.image) / 4):
            current_value = frame.palette.items[image[i]]
            new_points_array[i] = (current_value[0] | current_value[1] << 8 | 
                current_value[2] << 16) 
        return str_points

cdef inline str joinImage(bytes points, bytes alpha):
    cdef char * c_array_string
    cdef unsigned int value
    new_points = allocate_memory(len(points), &c_array_string)
    cdef unsigned int * c_array = <unsigned int *>c_array_string
    cdef unsigned int * points_c = <unsigned int *>(<char *>points)
    cdef char * alpha_c = alpha
    cdef int i
    for i in range(len(points) / 4):
        c_array[i] = points_c[i] | ((<unsigned char *>alpha_c)[i] << 24)
    return new_points

cdef inline object getImageData(ImageItem item, frame):
    cdef unsigned int point
    cdef unsigned int transparent
    cdef object points = indexImage(item, frame)
    cdef unsigned int * points_c = <unsigned int *>(<char *>points)
    cdef int i
    cdef unsigned int * c_array
    if item.alpha:
        data = joinImage(points, item.alpha)
    else:
        transparent = (item.transparent[0] | item.transparent[1] << 8 | 
            item.transparent[2] << 16)
        data = allocate_memory(len(points), <char**>&c_array)
        for i in range(len(points) / 4):
            if points_c[i] == transparent:
                c_array[i] = points_c[i]
            else:
                c_array[i] = points_c[i] | <unsigned int>(0xFF << 24)
    return data

cdef inline object createDisplay(ImageItem item, frame):
    data = getImageData(item, frame)
    from mmfparser.player.sprite import ImageData
    newImage = ImageData(item.width, item.height, 'RGBA', data,
        -item.width * 4, item.alpha)
    newImage.anchor_x = item.xHotspot
    newImage.anchor_y = item.height - item.yHotspot
    return newImage

cdef class BasePoint

cdef class BasePoint:
    cdef public:
        int size
    cdef unsigned int read(self, char * data, int position):
        pass

cdef class Point(BasePoint):
    def __cinit__(self):
        self.size = 3

    cdef inline unsigned int read(self, char * data, int position):
        cdef unsigned char r, g, b
        b = <unsigned char>data[position]
        g = <unsigned char>data[position+1]
        r = <unsigned char>data[position+2]
        return r | g << 8 | b << 16

    cdef write(self, item, ByteReader reader):
        reader.writeByte(item[2], True)
        reader.writeByte(item[1], True)
        reader.writeByte(item[0], True)

cdef BasePoint point_instance = Point()

cdef class SixteenPoint(BasePoint):
    def __cinit__(self):
        self.size = 2

    cdef inline unsigned int read(self, char * data, int position):
        cdef unsigned short newShort
        newShort = (<unsigned char>data[position] | 
            <unsigned char>data[position + 1] << 8)
        cdef unsigned char r, g, b
        r = (newShort & 63488) >> 11
        g = (newShort & 2016) >> 5
        b = (newShort & 31)
        r = r << 3
        g = g << 2
        b = b << 3
        return r | g << 8 | b << 16

    cdef write(item, ByteReader reader):
        r, g, b = item
        r = r >> 3
        g = g >> 2
        b = b >> 3
        r = r << 11
        g = g << 5
        return r | g | b

cdef BasePoint sixteen_point = SixteenPoint()

cdef class FifteenPoint(BasePoint):
    def __cinit__(self):
        self.size = 2

    cdef inline unsigned int read(self, char * data, int position):
        cdef unsigned char r, g, b
        cdef unsigned short newShort
        newShort = (<unsigned char>data[position] | 
            <unsigned char>data[position + 1] << 8)
        r = (newShort & 31744) >> 10
        g = (newShort & 992) >> 5
        b = (newShort & 31)
        r = r << 3
        g = g << 3
        b = b << 3
        return r | g << 8 | b << 16

    cdef write(item, ByteReader reader):
        r, g, b = item
        r = r >> 3
        g = g >> 3
        b = b >> 3
        r = r << 10
        g = g << 5
        
        return r | g | b

cdef BasePoint fifteen_point = FifteenPoint()

cdef class IndexPoint(BasePoint):
    def __cinit__(self):
        self.size = 1

    cdef inline unsigned int read(self, char * data, int position):
        return <unsigned char>data[position]

    cdef write(self, point, ByteReader reader):
        reader.writeByte(point, True)

cdef IndexPoint index_point = IndexPoint()

cdef inline tuple read_rgb(char * data, int width, int height, BasePoint pointClass):
    cdef char * buf
    points = allocate_memory(width * height * 4, &buf)
    cdef unsigned int * c_array = <unsigned int *>buf
    cdef int x, y
    cdef int n = 0
    cdef int i = 0
    cdef int pad = get_padding(width, pointClass)
    for y in range(height):
        for x in range(width):
            c_array[i] = pointClass.read(data, n)
            n += pointClass.size
            i += 1
        n += pad * pointClass.size
    return points, n

cdef inline int get_padding(int width, BasePoint pointClass, int bytes = 2):
    cdef int pad
    pad = bytes - ((width * pointClass.size) % bytes)
    if pad == bytes:
        pad = 0
    return <int>ceil(pad / <float>pointClass.size)

cdef inline tuple read_rle(char * data, int width, int height, BasePoint pointClass):
    cdef char * buf
    cdef int pad = get_padding(width, pointClass)
    cdef bytes points = allocate_memory(width * height * 4, &buf)
    cdef unsigned int * c_array = <unsigned int *>buf
    cdef int currentPosition = 0
    cdef int i = 0
    cdef int pos = 0
    cdef int n
    cdef unsigned char command
    cdef unsigned int newPoint
    while 1:
        command = <unsigned char>data[currentPosition]
        currentPosition += 1

        if command == 0:
            break

        if command > 128:
            command -= 128
            for n in range(command):
                if pos % (width + pad) < width:
                    c_array[i] = pointClass.read(data, currentPosition)
                    i += 1
                pos += 1
                currentPosition += pointClass.size
        else:
            newPoint = pointClass.read(data, currentPosition)
            for n in range(command):
                if pos % (width + pad) < width:
                    c_array[i] = newPoint
                    i += 1
                pos += 1
            currentPosition += pointClass.size
    return points, currentPosition

cdef inline read_alpha(char * data, int width, int height, int position):
    cdef int pad = get_padding(width, index_point, 4)
    cdef char * buf
    points = allocate_memory(width * height, &buf)
    cdef int i, n, x, y
    n = i = 0
    for y in range(height):
        for x in range(width):
            buf[i] = data[n + position]
            n += 1
            i += 1
        n += pad
    return points

cdef inline generate_alpha(ImageItem item):
    cdef int pad = get_padding(item.width, index_point, 4)
    cdef int i, n, x, y
    cdef char * alpha = item.alpha
    cdef char * buf
    points = allocate_memory(item.width * item.height + pad * item.height, &buf)
    i = n = 0
    for y in range(item.height):
        for x in range(item.width):
            buf[n] = alpha[i]
            i += 1
            n += 1
        n += pad
    return points
    
cdef inline generate_image(ImageItem item):
    cdef int x, y
    cdef int n = 0
    cdef int i = 0
    cdef char * image = item.image
    cdef int pad = get_padding(item.width, point_instance)
    cdef char * buf
    points = allocate_memory((item.width * item.height + pad * item.height
        ) * point_instance.size, &buf)
    for y in range(item.height):
        for x in range(item.width):
            buf[n] = image[i+2]
            buf[n+1] = image[i+1]
            buf[n+2] = image[i]
            i += 4
            n += 3
        n += pad * point_instance.size
    return points

# def generate_alpha(ImageItem item):
    # cdef int pad = get_padding(item.width, index_point, 4)
    # data = ''
    # cdef int i, x, y
    # alpha = item.alpha
    # i = 0
    # for y in range(item.height):
        # for x in range(item.width):
            # data += alpha[i]
            # i += 1
        # data += '\x00' * pad
    # return data
    
# def generate_image(ImageItem item):
    # cdef int x, y
    # cdef int n = 0
    # cdef int i = 0
    # image = item.image
    # data = ''
    # cdef int pad = get_padding(item.width, point_instance)
    # for y in range(item.height):
        # for x in range(item.width):
            # data += image[i+2]
            # data += image[i+1]
            # data += image[i]
            # i += 4
        # data += '\x00' * (pad * point_instance.size)
    # return data

IMAGE_FLAGS = BitDict(
    'RLE',
    'RLEW',
    'RLET',
    'LZX',
    'Alpha',
    'ACE',
    'Mac'
)

cdef class ImageItem(DataLoader):
    cdef public:
        int handle
        int checksum # starts at imgWidth and ends at end of bitmap
        int references
        short width
        short height
        short xHotspot
        short yHotspot
        short actionX
        short actionY
        object flags
        object image
        object alpha
        bint indexed
        char graphicMode
        tuple transparent

        ByteReader reader
        size_t pos

    cpdef initialize(self):
        self.flags = IMAGE_FLAGS.copy()

    cpdef read(self, ByteReader reader):
        self.handle = reader.readInt()
        cdef bint load_now = self.settings.get('loadImages', True)
        self.reader = reader
        self.pos = reader.tell()
        if load_now:
            self.load()
            return

        cdef bint old = self.settings.get('old', False)
        if old:
            raise NotImplementedError('not supported')

        cdef bint debug = self.settings.get('debug', False)
        cdef int size
        if debug:
            reader.skipBytes(8)
            size = reader.readInt(True)
            reader.skipBytes(size + 20)
        else:
            reader.skipBytes(4)
            size = reader.readInt(True)
            reader.skipBytes(size)

    cpdef load(self):
        cdef ByteReader reader = self.reader
        if reader is None:
            return
        reader.seek(self.pos)
        self.reader = None

        cdef bint old = self.settings.get('old', False)
        cdef bint debug = self.settings.get('debug', False)
        cdef ByteReader newReader
        if old:
            newReader = onepointfive.decompress(reader)
        elif debug:
            newReader = reader
        else:
            newReader = zlibdata.decompress(reader)

        start = newReader.tell()
        
        if old:
            self.checksum = newReader.readShort()
        else:
            self.checksum = newReader.readInt()
        self.references = newReader.readInt()
        cdef int size = newReader.readInt(True)
        
        if debug:
            newReader = newReader.readReader(size + 20)
        self.width = newReader.readShort()
        self.height = newReader.readShort()
        self.graphicMode = newReader.readByte()
        self.flags.setFlags(newReader.readByte(True))
        
        if not old:
            newReader.skipBytes(2) # imgNotUsed
        self.xHotspot = newReader.readShort()
        self.yHotspot = newReader.readShort()
        self.actionX = newReader.readShort()
        self.actionY = newReader.readShort()
        if old:
            self.transparent = (0, 0, 0)
        else:
            self.transparent = newReader.readColor()

        cdef int decompressed
        if self.flags['LZX']:
            decompressed = newReader.readInt()
            newReader = ByteReader(zlib.decompress(newReader.read()))

        cdef BasePoint pointClass
        cdef char * data
        cdef int width, height
        width, height = self.width, self.height
        if self.graphicMode == 2:
            pointClass = index_point
            self.indexed = True
        elif self.graphicMode == 3:
            pointClass = index_point
            self.indexed = True
        elif self.graphicMode == 4: # 16 million colors
            pointClass = point_instance
            self.indexed = False
        elif self.graphicMode == 6: # 32768 colors
            pointClass = fifteen_point
            self.indexed = False
        elif self.graphicMode == 7: # 65536 colors
            pointClass = sixteen_point
            self.indexed = False
        else:
            import code
            code.interact(local = locals())
            newReader.openEditor()
            raise NotImplementedError('unknown graphic mode: %s'
                                      % self.graphicMode)

        readerData = newReader.read()
        data = readerData
        cdef int alphaSize, imageSize
        if self.flags['RLE'] or self.flags['RLEW'] or self.flags['RLET']:
            image, bytesRead = read_rle(data, width, height, pointClass)
            alphaSize = size - bytesRead
        else:
            image, imageSize = read_rgb(data, width, height, pointClass)
            alphaSize = size - imageSize
        self.image = image

        if self.flags['Alpha']:
            pad = (alphaSize - width * height) / height
            self.alpha = read_alpha(data, width, height, size - alphaSize)
    
    def write(self, reader):
        cdef bint debug = self.settings.get('debug', False)
        dataReader = ByteReader()

        if False:
            dataReader.write(generate_image(self))
            if self.alpha is not None:
                dataReader.write(generate_alpha(self))

        newReader = ByteReader()
        newReader.writeInt(self.checksum)
        newReader.writeInt(self.references)
        newReader.writeInt(len(dataReader))
        newReader.writeShort(0) # newReader.writeShort(self.width)
        newReader.writeShort(0) # newReader.writeShort(self.height)
        newReader.writeByte(4)#self.graphicMode)
        # simple hack kthxbye
        if self.flags['Alpha']:
            newReader.writeByte(16)
        else:
            newReader.writeByte(0)
        newReader.write(<bytes>('\x00\x00'))
        newReader.writeShort(self.xHotspot)
        newReader.writeShort(self.yHotspot)
        newReader.writeShort(self.actionX)
        newReader.writeShort(self.actionY)
        newReader.writeColor(self.transparent or (0, 0, 0))
        newReader.writeReader(dataReader)

        reader.writeInt(self.handle)
        if debug:
            reader.writeReader(newReader)
        else:
            reader.writeReader(zlibdata.compress(newReader))
    
    def createDisplay(self, frame = None, **kw):
        foo = createDisplay(self, frame)
        self.unload()
        return foo
    
    def getImageData(self, frame = None, **kw):
        foo = getImageData(self, frame)
        self.unload()
        return foo

    def unload(self):
        self.image = None
        self.alpha = None
    
    def getGraphicMode(self):
        return graphicModes[self.graphicMode]

cdef class JavaImage(DataLoader):
    cdef public:
        int handle
        int xHotspot, yHotspot
        int actionX, actionY
        int width, height
        object data
        bint flash

    cpdef read(self, ByteReader reader):
        self.handle = reader.readShort()
        if self.settings.get('withSize', False):
            self.width = reader.readShort()
            self.height = reader.readShort()
        self.xHotspot = reader.readShort()
        self.yHotspot = reader.readShort()
        self.actionX = reader.readShort()
        self.actionY = reader.readShort()
        size = reader.readInt()
        data = reader.read(size)
        try:
            self.data = zlib.decompress(data)
            self.flash = True
        except zlib.error:
            self.data = data
            self.flash = False
    
    def write(self, reader):
        reader.writeShort(self.handle)
        if self.settings.get('withSize', False):
            reader.writeShort(self.width)
            reader.writeShort(self.height)
        reader.writeShort(self.xHotspot)
        reader.writeShort(self.yHotspot)
        reader.writeShort(self.actionX)
        reader.writeShort(self.actionY)
        reader.writeInt(len(self.data))
        reader.write(self.data)
    
    def createDisplay(self, *arg, **kw):
        if self.flash:
            from mmfparser.player.sprite import ImageData
            newImage = ImageData(self.width, self.height, 'ARGB', 
                self.data, self.width * -4, None)
        else:
            from mmfparser.player.common import load_image
            newImage = load_image(StringIO(self.data))
        newImage.anchor_x = self.xHotspot
        newImage.anchor_y = self.height - self.yHotspot
        return newImage

    def getImageData(self, *arg, **kw):
        from mmfparser.image import Image
        img = Image(data = self.data)
        return img.get_data()

cdef class ImageBank(DataLoader):
    cdef public:
        dict itemDict
    
    @property
    def items(self):
        return self.itemDict.values()
    
    cpdef initialize(self):
        self.itemDict = {}

    cpdef read(self, ByteReader reader):
        cdef bint java = self.settings.get('java', False)
        cdef int build = self.settings['build']
        cdef int i
        cdef int numberOfItems
        if not java:
            if self.settings.get('debug', False):
                path = self.readString(reader)
                newReader = ByteReader(open(path, 'rb'))
                newReader.skipBytes(4)
                bank = self.new(AGMIBank, newReader)
                for item in bank.items:
                    self.itemDict[item.handle] = item
                return
            numberOfItems = reader.readInt()
            for i in range(numberOfItems):
                newItem = self.new(ImageItem, reader)
                if build >= 284:
                    newItem.handle -= 1
                self.itemDict[newItem.handle] = newItem
        
        else:
            numberOfItems = reader.readShort()
            itemsInBank = reader.readShort()
            itemsToRead = itemsInBank

            currentPosition = reader.tell()
            try:
                self.itemDict = itemDict = {}
                for _ in xrange(itemsToRead):
                    newItem = self.new(JavaImage, reader, withSize = True)
                    itemDict[newItem.handle] = newItem
            except struct.error:
                reader.seek(currentPosition)
                self.itemDict = itemDict = {}
                for _ in xrange(itemsToRead):
                    newItem = self.new(JavaImage, reader, withSize = False)
                    itemDict[newItem.handle] = newItem
    
    def write(self, reader):
        java = self.settings.get('java', False)
        if not java:
            offsetDict = {}
            self.offsets = offsets = []
            reader.writeInt(len(self.items))
            for item in self.items:
                offsetDict[item.handle] = reader.tell() + 4
                item.write(reader)
            for key in sorted(offsetDict.keys()):
                offsets.append(offsetDict[key])
        else:
            reader.writeShort(len(self.items))
            reader.writeShort(len(self.items))
            for item in self.items:
                item.write(reader)
    
    def fromHandle(self, handle):
        return self.itemDict[handle]

from mmfparser.data.mfaloaders.imagebank import AGMIBank

__all__ = ['ImageBank', 'JavaImage', 'ImageItem']