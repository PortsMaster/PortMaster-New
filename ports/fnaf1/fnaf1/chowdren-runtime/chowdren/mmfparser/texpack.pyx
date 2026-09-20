from libcpp.vector cimport vector
from mmfparser.common cimport allocate_memory
from libc.string cimport memset

cdef extern from "./maxrects/MaxRectsBinPack.cpp" namespace "rbp":
    cdef struct RectSize:
        int width
        int height

    cdef struct Rect:
        int x
        int y
        int width
        int height

    ctypedef enum FreeRectChoiceHeuristic:
        RectBestShortSideFit "rbp::MaxRectsBinPack::RectBestShortSideFit"
        RectBestLongSideFit "rbp::MaxRectsBinPack::RectBestLongSideFit"
        RectBestAreaFit "rbp::MaxRectsBinPack::RectBestAreaFit"
        RectBottomLeftRule "rbp::MaxRectsBinPack::RectBottomLeftRule"
        RectContactPointRule "rbp::MaxRectsBinPack::RectContactPointRule"

    cdef cppclass MaxRectsBinPack:
        void Init(int width, int height)
        bint Insert(const vector[RectSize] &rects, vector[Rect] &dst,
                    vector[int] &dstidx, FreeRectChoiceHeuristic method)

cdef extern from "./maxrects/Rect.cpp":
    pass

cdef extern from "./maxrects/frontend.cpp":
    void sort_indexes(vector[int] & idx)

from PIL import Image

cdef class Sprite:
    cdef public:
        int x, y, w, h
        object image

    cdef void init(self, const Rect & rect, object image):
        self.x = rect.x
        self.y = rect.y
        self.w = rect.width
        self.h = rect.height
        self.image = image

cdef class MaxRects:
    cdef public:
        int width, height
        list results

    cdef void set_result(self, int width, int height,
                         vector[int] & idx, const vector[Rect] & dst,
                         list images):
        self.width = width
        self.height = height
        self.results = []
        cdef Sprite s

        cdef int rect_idx
        cdef int i = 0

        for rect_idx in idx:
            s = Sprite.__new__(Sprite)
            s.init(dst[i], images[rect_idx])
            self.results.append(s)
            i += 1

    def get(self):
        im = Image.new('RGBA', (self.width, self.height), (255, 20, 147, 255))

        cdef Sprite sprite
        for sprite in self.results:
            x, y, w, h = (sprite.x, sprite.y,
                          sprite.w, sprite.h)
            tmp = sprite.image.convert('RGBA')
            im.paste(tmp, (x, y, x + w, y + h))

        return im


def pack_images(images, width, height):
    cdef list new_images = []
    cdef vector[RectSize] rects
    cdef Sprite sprite
    cdef RectSize rect

    for image in images:
        w, h = image.size
        if w > width or h > height:
            print 'Truncating image in texture atlas:', w, h
            image = image.crop((0, 0, min(w, width), min(h, height)))
        new_images.append(image)
        rect.width, rect.height = image.size
        rects.push_back(rect)

    cdef MaxRectsBinPack maxrects

    cdef vector[int] idx
    cdef vector[Rect] dst

    cdef MaxRects res = MaxRects()
    cdef int i

    while new_images:
        maxrects.Init(width, height)
        maxrects.Insert(rects, dst, idx, RectBestShortSideFit)
        res.set_result(width, height, idx, dst, new_images)
        sort_indexes(idx)

        for i in idx:
            rects.erase(rects.begin() + i)
            del new_images[i]

        yield res

        print 'remaining sprites:', len(new_images)


cdef void set_bit(char * data, int b):
    data[b / 8] |= 1 << (b % 8)


def get_alpha_bits(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef int bit_size = (size + 32 - 1) / 32
    cdef object ret = allocate_memory(bit_size, &dst)
    memset(dst, 0, bit_size)
    cdef int i = 0
    while i < size:
        if src_c[i + 3] != 0:
            set_bit(dst, i / 4)
        i += 4
    return ret


cdef inline bint pack_bits(unsigned char v, int n, unsigned char * out):
    n = 8 - n
    cdef unsigned char vv = v >> n
    if v != (vv << n):
        return False
    out[0] = vv
    return True


def to_a4(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 8, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if r != 255 or g != 255 or b != 255:
            return None
        if not pack_bits(a, 4, &a):
            return None
        if i % 8 == 0:
            dst[0] |= a << 4
        else:
            dst[0] |= a
            dst += 1
        i += 4
    return ret


def to_a4_ignore_rgb(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 8, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        a = src_c[i+3]
        if not pack_bits(a, 4, &a):
            return None
        if i % 8 == 0:
            dst[0] |= a << 4
        else:
            dst[0] |= a
            dst += 1
        i += 4
    return ret


def to_l4(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 8, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if r != g or r != b or g != b or a != 255:
            return None
        if not pack_bits(r, 4, &r):
            return None
        if i % 8 == 0:
            dst[0] |= r << 4
        else:
            dst[0] |= r
            dst += 1
        i += 4
    return ret


def to_a8(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 4, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if r != 255 or g != 255 or b != 255:
            return None
        dst[0] = a
        dst += 1
        i += 4
    return ret


def to_l8(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 4, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if r != g or r != b or g != b or a != 255:
            return None
        dst[0] = r
        dst += 1
        i += 4
    return ret


def to_rgb565_with_alpha(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 2, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    cdef unsigned short * dst_s = <unsigned short*>dst
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if a != 255:
            return None
        if not pack_bits(r, 5, &r):
            return None
        if not pack_bits(g, 6, &g):
            return None
        if not pack_bits(b, 5, &b):
            return None
        dst_s[0] = (r << 11) | (g << 5) | b
        dst_s += 1
        i += 4
    return ret


def to_rgb565_without_alpha(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 2, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    cdef unsigned short * dst_s = <unsigned short*>dst
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if not pack_bits(r, 5, &r):
            return None
        if not pack_bits(g, 6, &g):
            return None
        if not pack_bits(b, 5, &b):
            return None
        dst_s[0] = (r << 11) | (g << 5) | b
        dst_s += 1
        i += 4
    return ret


def to_rgba4444(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 2, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    cdef unsigned short * dst_s = <unsigned short*>dst
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if a != 255:
            return None
        if not pack_bits(r, 4, &r):
            return None
        if not pack_bits(g, 4, &g):
            return None
        if not pack_bits(b, 4, &b):
            return None
        if not pack_bits(a, 4, &a):
            return None
        dst_s[0] = (r << 12) | (g << 8) | (b << 4) | a
        dst_s += 1
        i += 4
    return ret


def to_rgba5551(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory(size / 2, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    cdef unsigned short * dst_s = <unsigned short*>dst
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if a != 255:
            return None
        if not pack_bits(r, 5, &r):
            return None
        if not pack_bits(g, 5, &g):
            return None
        if not pack_bits(b, 5, &b):
            return None
        if not pack_bits(a, 1, &a):
            return None
        dst_s[0] = (r << 11) | (g << 6) | (b << 1) | a
        dst_s += 1
        i += 4
    return ret


def to_rgb888(image):
    cdef bytes data = image.tobytes()
    cdef char * src_c = data
    cdef char * dst
    cdef int size = len(data)
    cdef object ret = allocate_memory((size / 4) * 3, &dst)
    cdef int i = 0
    cdef unsigned char r, g, b, a
    while i < size:
        r = src_c[i]
        g = src_c[i+1]
        b = src_c[i+2]
        a = src_c[i+3]
        if a != 255:
            return None
        dst[0] = r
        dst[1] = g
        dst[2] = b
        dst += 3
        i += 4
    return ret
