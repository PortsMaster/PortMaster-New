import sys
sys.path.append('..')
import freetype
from freetype.raw import _lib
from freetype.ft_structs import FT_Bitmap
from ctypes import byref
from mmfparser.bytereader import ByteReader
from PIL import Image

FT_GlyphSlot_Embolden = _lib.FT_GlyphSlot_Embolden
FT_Bitmap_Embolden = _lib.FT_Bitmap_Embolden
FT_Bitmap_Convert = _lib.FT_Bitmap_Convert
FT_Bitmap_New = _lib.FT_Bitmap_New
FT_Bitmap_Done = _lib.FT_Bitmap_Done
FT_GlyphSlot_Own_Bitmap = _lib.FT_GlyphSlot_Own_Bitmap
FT_Bitmap_Copy = _lib.FT_Bitmap_Copy

"""
XXX use kerning information?

Format:

struct Glyph
{
    uint32 charcode
    float x1, y1, x2, y2
    float advance_x, advance_y
    float corner_x, corner_y
    uint32 width, height
    uint8 data[width * height];
};

enum FontFlags
{
    BOLD = 1 << 0  
};

struct Font
{
    uint16 size;
    uint16 flags;
    float width;
    float height;
    float ascender;
    float descender;
    uint32 num_glyphs;
    Glyph glyphs[num_glyphs];
};

struct FontBank
{
    uint32 font_count;
    Font fonts[font_count];
};
"""

BOLD_AMOUNT = 64

class Glyph(object):
    def __init__(self, generator, char):
        self.char = char
        self.font = generator.font
        self.glyph = glyph = generator.font.glyph

        bold = 0
        if generator.bold:
            bold = BOLD_AMOUNT

        self.advance = ((glyph.advance.x + bold) / 64.0,
                        glyph.advance.y / 64.0)
        box = self.get_cbox()
        self.x1 = box.xMin / 64.0
        self.y1 = box.yMin / 64.0
        self.x2 = box.xMax / 64.0
        self.y2 = box.yMax / 64.0
        real_glyph = glyph.get_glyph()
        if generator.monochrome:
            mode = freetype.FT_RENDER_MODE_MONO
        else:
            mode = freetype.FT_RENDER_MODE_NORMAL
        bitmap_glyph = real_glyph.to_bitmap(mode, 0, True)
        self.corner = (bitmap_glyph.left, bitmap_glyph.top)
        bitmap = bitmap_glyph.bitmap

        destroy_bitmaps = []
        if generator.monochrome:
            new_bitmap = FT_Bitmap()
            destroy_bitmaps.append(new_bitmap)
            FT_Bitmap_New(byref(new_bitmap))
            FT_Bitmap_Convert(freetype.get_handle(), byref(bitmap._FT_Bitmap),
                              byref(new_bitmap), 1)
            bitmap = freetype.Bitmap(new_bitmap)

        if generator.bold:
            new_bitmap = FT_Bitmap()
            destroy_bitmaps.append(new_bitmap)
            FT_Bitmap_Copy(freetype.get_handle(), byref(bitmap._FT_Bitmap),
                           byref(new_bitmap))
            err = FT_Bitmap_Embolden(freetype.get_handle(),
                                     byref(new_bitmap),
                                     BOLD_AMOUNT, 0)
            bitmap = freetype.Bitmap(new_bitmap)

        self.width = bitmap.width
        self.height = bitmap.rows
        self.buf = ''
        if generator.monochrome:
            for c in bitmap.buffer:
                self.buf += chr(c * 255)
        else:
            for c in bitmap.buffer:
                self.buf += chr(c)


        for bitmap in destroy_bitmaps:
            FT_Bitmap_Done(freetype.get_handle(), byref(bitmap))

    def get_cbox(self):
        outline = self.glyph.outline
        bbox = freetype.FT_BBox()
        freetype.FT_Outline_Get_CBox(byref(outline._FT_Outline), byref(bbox))
        return freetype.BBox(bbox)

    def get_data(self):
        return self.buf

    def get_image(self):
        data = self.get_data()
        image = Image.frombytes('L', (self.width, self.height), data)
        return image

    def write(self, writer):
        writer.writeInt(ord(self.char), True)
        writer.writeFloat(self.x1)
        writer.writeFloat(self.y1)
        writer.writeFloat(self.x2)
        writer.writeFloat(self.y2)
        writer.writeFloat(self.advance[0])
        writer.writeFloat(self.advance[1])
        writer.writeFloat(self.corner[0])
        writer.writeFloat(self.corner[1])
        writer.writeInt(self.width)
        writer.writeInt(self.height)
        writer.write(self.get_data())


RESOLUTION = 96
BOLD = 1 << 0

class Font(object):
    def __init__(self, name, charset, size=None, pixel_size=None, bold=False,
                 monochrome=True):
        self.size = size
        self.monochrome = monochrome
        self.bold = bold
        font = self.font = freetype.Face(name)

        if pixel_size is not None:
            font.set_pixel_sizes(pixel_size, pixel_size)
        else:
            size = int(size * 64)
            font.set_char_size(size, size, RESOLUTION, RESOLUTION)

        self.width = self.get_width()
        self.height = self.get_height()
        metrics = self.font.size
        self.ascender = metrics.ascender / 64.0
        self.descender = metrics.descender / 64.0
        self.glyph_dict = {}
        self.glyphs = []
        self.charmap = {}
        charcode, agindex = font.get_first_char()
        while agindex != 0:
            self.charmap[agindex] = charcode
            charcode, agindex = font.get_next_char(charcode, agindex)
        for c in charset:
            self.load_char(c)
        space_glyph = self.load_char(' ', force=True)

    def get_width(self):
        size = self.font.size
        if self.font.is_scalable:
            bbox = self.font.bbox
            return (bbox.xMax - bbox.xMin) * (float(size.x_ppem) /
                                              self.font.units_per_EM)
        else:
            return size.max_advance / 64.0

    def get_height(self):
        size = self.font.size
        if self.font.is_scalable:
            bbox = self.font.bbox
            return (bbox.yMax - bbox.yMin) * (float(size.y_ppem) /
                                              self.font.units_per_EM)
        else:
            return size.height / 64.0

    def load_char(self, c, force=False):
        flags = freetype.FT_LOAD_FORCE_AUTOHINT
        self.font.load_char(c, flags)
        glyph = Glyph(self, c)
        if (glyph.x1 == 0.0 and glyph.y1 == 0.0 and
            glyph.x2 == 0.0 and glyph.y2 == 0.0 and not force):
            return
        self.glyphs.append(glyph)
        self.glyph_dict[c] = glyph
        return glyph

    def get_sheet(self):
        width = sum(glyph.width for glyph in self.glyphs)
        height = max(glyph.height for glyph in self.glyphs)
        image = Image.new('L', (width, height), 1)
        x = 0
        for glyph in self.glyphs:
            if glyph.width == 0 or glyph.height == 0:
                continue
            image.paste(glyph.get_image(), (x, 0))
            x += glyph.width
        return image

    def get_glyph(self, c):
        return self.glyph_dict[c]

    def write(self, writer):
        writer.writeShort(self.size, True)
        flags = 0
        if self.bold:
            flags |= BOLD
        writer.writeShort(flags, True)
        writer.writeFloat(self.width)
        writer.writeFloat(self.height)
        writer.writeFloat(self.ascender)
        writer.writeFloat(self.descender)
        writer.writeInt(len(self.glyphs))
        for glyph in self.glyphs:
            glyph.write(writer)

def generate_font(filename, charset, out, sizes):
    fonts = []
    for size in sizes:
        fonts.append(Font(filename, size, charset))
    write_fonts(out, fonts)

def write_fonts(out, fonts):
    fp = open(out, 'wb')
    writer = ByteReader(fp)
    writer.writeInt(len(fonts))
    for font in fonts:
        font.write(writer)
    fp.close()