"""
Generates collision functions for Chowdren
"""
import sys
sys.path.append('..')
sys.path.append('../..')
from chowdren.codewriter import CodeWriter

types = (
    ('sprite', 'SpriteCollision'),
    ('tsprite', 'SpriteCollision'),
    ('background', 'BackgroundItem'),
    ('backdrop', 'BackdropCollision'),
    ('box', None)
)

has_sprite = set([
    'sprite',
    'tsprite',
    'background',
    'backdrop'
])

class Case(object):
    loop_x = 'x'
    loop_y = 'y'

    def __init__(self, name, x, y, platform):
        self.name = name
        self.loop_x = '(x + %s)' % x
        self.loop_y = '(y + %s)' % y
        self.platform = platform

    def get_cond(self):
        return None

    def write_init(self, writer):
        pass

    def write_loop(self, writer):
        pass

    def get_alpha(self):
        raise NotImplementedError()

class BoxCase(Case):
    def get_alpha(self):
        return None

class ImageCase(Case):
    def get_cond(self):
        if self.platform == 'wiiu':
            return '%s_img->tex == 0' % self.name
        return '%s_alpha.data == NULL' % self.name

    def write_init(self, writer):
        writer.putlnc('unsigned int * %s_arr = (unsigned int*)%s_img->image;',
                      self.name, self.name)

    def get_alpha(self):
        v = '(%s_arr + %s * %s_width + %s)' % (self.name, self.loop_y,
                                               self.name, self.loop_x)
        v = '((unsigned char*)%s)[3]' % v
        return '(%s != 0)' % v

class AlphaCase(Case):
    def get_cond(self):
        if self.platform == 'wiiu':
            return '%s->tex != 0' % self.name
        return '%s_alpha.data != NULL' % self.name

    def write_loop(self, writer):
        if self.platform != 'wiiu':
            return
        writer.putlnc('unsigned int %sc = '
                      'platform_get_texture_pixel(%s_img->tex, %s, %s);',
                      self.name, self.name, self.loop_x, self.loop_y)

    def get_alpha(self):
        if self.platform == 'wiiu':
            v = '((unsigned char*)&%sc)[3]' % self.name
            return '(%s != 0)' % v
        return '%s_alpha.get(%s * %s_width + %s)' % (self.name, self.loop_y,
                                                     self.name, self.loop_x)

class ImageBoxCase(BoxCase):
    def get_cond(self):
        return '%s->flags & BOX_COLLISION' % self.name

def add_transform(klass):
    class NewClass(klass):
        def __init__(self, *arg, **kw):
            klass.__init__(self, *arg, **kw)
            self.real_loop_x = self.loop_x
            self.real_loop_y = self.loop_y

        def write_init(self, writer):
            klass.write_init(self, writer)
            writer.putlnc('int %s_height = %s_img->height;',
                          self.name, self.name)

        def write_loop(self, writer):
            self.loop_x = '%s_xx' % self.name
            self.loop_y = '%s_yy' % self.name
            writer.putlnc('int %sv = %s;', self.loop_x, self.real_loop_x)
            writer.putlnc('int %sv = %s;', self.loop_y, self.real_loop_y)
            writer.putlnc('int %s = GET_SCALER_RESULT(%sv * %s->co_divx - '
                                                     '%sv * %s->si_divx);',
                          self.loop_x,
                          self.loop_x, self.name, self.loop_y, self.name)

            writer.putlnc('int %s = GET_SCALER_RESULT(%sv * %s->co_divy + '
                                                     '%sv * %s->si_divy);',
                          self.loop_y,
                          self.loop_y, self.name, self.loop_x, self.name)
            writer.putlnc('if ((%s | %s) < 0 || %s >= %s_width || '
                                               '%s >= %s_height)',
                          self.loop_x, self.loop_y,
                          self.loop_x, self.name,
                          self.loop_y, self.name)
            writer.indent()
            writer.putln('continue;')
            writer.dedent()
            klass.write_loop(self, writer)

    return NewClass

ImageTransformCase = add_transform(ImageCase)
AlphaTransformCase = add_transform(AlphaCase)
BoxTransformCase = add_transform(ImageBoxCase)

def write_init(writer, name, col, x, y, platform):
    if name == 'box':
        return (BoxCase(col, x, y, platform),)
    if name == 'tsprite':
        writer.putlnc('%s += %s->x_t;', x, col)
        writer.putlnc('%s += %s->y_t;', y, col)
    elif name == 'background':
        writer.putlnc('%s += %s->src_x;', x, col)
        writer.putlnc('%s += %s->src_y;', y, col)

    if name in has_sprite:
        writer.putlnc('Image * %s_img = %s->image;', col, col)
        if platform != 'wiiu':
            writer.putlnc('BitArray & %s_alpha = %s_img->alpha;', col, col)
        writer.putlnc('int %s_width = %s_img->width;', col, col)
        if name == 'tsprite':
            return (BoxTransformCase(col, x, y, platform),
                    ImageTransformCase(col, x, y, platform),
                    AlphaTransformCase(col, x, y, platform))

        return (ImageCase(col, x, y, platform), AlphaCase(col, x, y, platform))

    return (Case(col, x, y, platform),)

def write_cond(writer, case, index, cases):
    cond = case.get_cond()
    last = index == len(cases) - 1 and index != 0
    has_cond = cond is not None or last
    if last:
        writer.putlnc('else {')
        writer.indent()
    elif has_cond and index == 0:
        writer.putlnc('if (%s) {', cond)
        writer.indent()
    elif has_cond and index > 0:
        writer.putlnc('else if (%s) {', cond)
        writer.indent()
    case.write_init(writer)
    return has_cond

def write_check(writer, case):
    alpha = case.get_alpha()
    if alpha is None:
        return
    writer.putlnc('if (!%s)', alpha)
    writer.indent()
    writer.putln('continue;')
    writer.dedent()

def write_case(writer, case1, case2):
    writer.putln('for (int y = 0; y < h; y++) {')
    writer.indent()

    writer.putln('for (int x = 0; x < w; x++) {')
    writer.indent()

    case1.write_loop(writer)
    write_check(writer, case1)
    case2.write_loop(writer)
    write_check(writer, case2)
    writer.putln('return true;')

    writer.end_brace()
    writer.end_brace()

def write_func(writer, name1, type1, name2, type2, platform):
    args = []
    if type1 is not None:
        args.append('CollisionBase * in_a')
    if type2 is not None:
        args.append('CollisionBase * in_b')
    args.append('int w')
    args.append('int h')
    if type1 is not None:
        args.append('int offx1')
        args.append('int offy1')
    if type2 is not None:
        args.extend(('int offx2', 'int offy2'))

    writer.putmeth('static bool collide_%s_%s' % (name1, name2), *tuple(args))

    if type1 is not None:
        writer.putlnc('%s * a = (%s*)in_a;', type1, type1)
    if type2 is not None:
        writer.putlnc('%s * b = (%s*)in_b;', type2, type2)

    cases_1 = write_init(writer, name1, 'a', 'offx1', 'offy1', platform)
    cases_2 = write_init(writer, name2, 'b', 'offx2', 'offy2', platform)

    for i1, case1 in enumerate(cases_1):
        has_cond1 = write_cond(writer, case1, i1, cases_1)
        for i2, case2 in enumerate(cases_2):
            has_cond2 = write_cond(writer, case2, i2, cases_2)
            write_case(writer, case1, case2)

            if has_cond2:
                writer.end_brace()

        if has_cond1:
            writer.end_brace()

    writer.putln('return false;')

    writer.end_brace()
    writer.putln('')

def write_col_types(writer, platform=None):
    for (name1, type1) in types:
        for (name2, type2) in types:
            write_func(writer, name1, type1, name2, type2, platform)

WARNING_TEXT = ['// Generated by gencol.py, do not modify!', '']

def write_gencol():
    writer = CodeWriter('gencol.cpp')
    for line in WARNING_TEXT:
        writer.putln(line)

    writer.putln('#ifdef CHOWDREN_IS_WIIU')
    write_col_types(writer, 'wiiu')
    writer.putln('#else')
    write_col_types(writer)
    writer.putln('#endif')

    writer.close()

def write_genoverlap():
    writer = CodeWriter('genoverlap.cpp')
    for line in WARNING_TEXT:
        writer.putln(line)

    writer.close()

def main():
    write_gencol()
    write_genoverlap()

if __name__ == '__main__':
    main()