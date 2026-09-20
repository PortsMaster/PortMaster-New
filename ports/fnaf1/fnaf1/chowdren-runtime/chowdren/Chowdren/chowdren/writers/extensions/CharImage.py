from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class Alias(object):
    def __init__(self, name, characters):
        self.name = name
        self.characters = characters

class Character(object):
    def __init__(self, image, external, clip, size):
        self.image = image
        self.external = external
        self.rect = clip
        self.size = size

class CharImage(ObjectWriter):
    class_name = 'CharacterImageObject'
    filename = 'charimage'
    use_alterables = True

    def write_init(self, writer):
        data = self.get_data()
        width = data.readInt(True)
        height = data.readInt(True)
        data.skipBytes(60) # logfont?
        data.skipBytes(4) # lastLogFontiPointSize
        data.skipBytes(4) # lastLogFontColor
        data.skipBytes(4) # get page size from object
        pageSize = (data.readInt(), data.readInt())
        text = data.readString(3072)
        lineBreaks = data.readInt() != 0
        wordWrap = data.readInt() != 0
        charmap = data.read(128)
        char_count = data.readShort()
        charmap = charmap[:char_count]
        data.skipBytes(2)
        alias_count = data.readInt()
        data.skipBytes(4)
        aliases = []
        for _ in xrange(alias_count):
            images = []
            external = []
            end = data.tell() + 128 * 2
            for _ in xrange(char_count):
                images.append(data.readShort())
            data.seek(end)
            end = data.tell() + 128
            for _ in xrange(char_count):
                external.append(data.readByte() != 0)
            data.seek(end)
            data.skipBytes(4)
            data.skipBytes(4 * 128)
            end = data.tell() + 128 * (4 + 4 + 4 + 4)
            clip = []
            for _ in xrange(char_count):
                left = data.readInt()
                top = data.readInt()
                right = data.readInt()
                bottom = data.readInt()
                clip.append((left, top, right, bottom))
            data.seek(end)
            data.skipBytes(128 * 4)
            end = data.tell() + 128 * (4 + 4)
            sizes = []
            for _ in xrange(char_count):
                sizes.append((data.readInt(), data.readInt()))
            data.seek(end)
            name = data.readString(128)
            characters = []
            for i in xrange(char_count):
                characters.append(Character(
                    images[i], external[i], clip[i], sizes[i]))
            aliases.append(Alias(name, characters))

        writer.putlnc('width = %s;', width)
        writer.putlnc('height = %s;', height)

        alias_names = []
        for alias_index, alias in enumerate(aliases):
            images = []
            for character_index, character in enumerate(alias.characters):
                # if character.external:
                    # raise NotImplementedError()
                if character.rect[:2] != (0, 0):
                    raise NotImplementedError()
                rect_size = character.rect[2:]
                if rect_size != (0, 0) and rect_size != character.size:
                    raise NotImplementedError()
                if character.image == -1:
                    image = 'NULL'
                else:
                    image = self.converter.get_image(character.image)
                images.append('{%s, %s, %s}' % (image, character.size[0],
                                                character.size[1]))

            new_charmap = {}
            for i, c in enumerate(charmap):
                new_charmap[ord(c)] = images[i]

            new_images = []
            for i in xrange(256):
                if i not in new_charmap:
                    new_images.append('{NULL, 0, 0}')
                    continue
                new_images.append(new_charmap[i])

            alias_names.append('{{%s}}' % ', '.join(new_images))


        writer.putlnc('static CharacterImageAlias '
                      'static_aliases[%s] = {%s};',
                      len(alias_names), ', '.join(alias_names))

        writer.putlnc('aliases = &static_aliases[0];')

        writer.putlnc('set_text(%r);', text)


actions = make_table(ActionMethodWriter, {
    0 : 'set_text',
    12 : '.x_off = %s',
    43 : 'set_clipping_width',
    45 : 'set_char_width',
    47 : 'load'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    1 : '.height',
    2 : '.text', # formatted text
    3 : '.unformatted', # unformatted text
    5 : '.text.size()',
    11 : '.x_off',
    14 : 'get_char', # unformatted
    32 : 'get_char_width'
})

def get_object():
    return CharImage
