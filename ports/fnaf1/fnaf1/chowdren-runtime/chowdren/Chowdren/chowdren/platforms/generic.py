from chowdren.platforms.common import Platform
from mmfparser.bytereader import ByteReader

class GenericPlatform(Platform):
    def get_shader(self, name, vert, frag):
        writer = ByteReader()
        writer.writeInt(len(vert))
        writer.write(vert)
        writer.writeInt(len(frag))
        writer.write(frag)
        return str(writer)
