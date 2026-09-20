from cStringIO import StringIO
from chowdren.common import to_c

class CodeWriter(object):
    indentation = 0
    fp = None

    def __init__(self, *arg, **kw):
        self.open(*arg, **kw)

    def open(self, filename=None):
        self.fp = StringIO()
        self.filename = filename

    def format_line(self, line):
        return self.get_spaces() + line

    def putln(self, *lines, **kw):
        wrap = kw.get('wrap', False)
        indent = kw.get('indent', True)
        if wrap:
            indent = self.get_spaces(1)
        for line in lines:
            if wrap:
                line = ('\n' + indent).join(textwrap.wrap(line))
            if indent:
                line = self.format_line(line)
            self.fp.write(line + '\n')

    def putlnc(self, line, *arg, **kw):
        line = to_c(line, *arg, **kw)
        self.putln(line, **kw)

    def putraw(self, *arg, **kw):
        indentation = self.indentation
        self.indentation = 0
        self.putln(*arg, **kw)
        self.indentation = indentation

    def putdefine(self, name, value=''):
        if value is None:
            return
        if value == '':
            self.putlnc('#define %s', name)
            return
        if isinstance(value, str):
            value = to_c('%r', value, cpp=False)
        self.putln('#define %s %s' % (name, value))

    def putindent(self, extra = 0):
        self.fp.write(self.get_spaces(extra))

    def put(self, value, indent=False):
        if indent:
            self.putindent()
        self.fp.write(value)

    def putc(self, value, *arg, **kw):
        value = to_c(value, *arg, **kw)
        self.put(value, **kw)

    def get_data(self):
        fp = self.fp
        pos = fp.tell()
        fp.seek(0)
        data = fp.read()
        fp.seek(pos)
        return data

    def putcode(self, writer):
        data = writer.get_data().splitlines()
        for line in data:
            self.putln(line)

    def putclass(self, name, subclass = None):
        text = 'class %s' % name
        if subclass is not None:
            text += ' : public %s' % subclass
        self.putln(text)
        self.start_brace()

    def start_brace(self):
        self.putln('{')
        self.indent()

    def end_brace(self, semicolon = False):
        self.dedent()
        text = '}'
        if semicolon:
            text += ';'
        self.putln(text)

    def putdef(self, name, value, wrap = False):
        new_value = '%r' % (value,)
        self.putln('%s = %s' % (name, new_value), wrap = wrap)

    def putmeth(self, name, *arg, **kw):
        fullarg = list(arg)
        self.putln('%s(%s)' % (name, ', '.join(fullarg)))
        init_list = kw.get('init_list', None)
        if init_list is not None:
            init_list = ', '.join(init_list)
            self.putlnc(': %s', init_list)
        self.start_brace()

    def put_label(self, name):
        self.putln('%s: ;' % name)

    def put_access(self, name):
        self.dedent()
        self.putln('%s:' % name)
        self.indent()

    def start_guard(self, name):
        self.putln('#ifndef %s' % name)
        self.putln('#define %s' % name)
        self.putln('')

    def close_guard(self, name):
        self.putln('')
        self.putln('#endif // %s' % name)

    def putend(self):
        self.putln('pass')
        self.dedent()
        self.putln('')

    def indent(self):
        self.indentation += 1

    def dedent(self):
        self.indentation -= 1
        if self.indentation < 0:
            raise ValueError('indentation cannot be lower than 0')

    def get_spaces(self, extra = 0):
        return (self.indentation + extra) * '    '

    def close(self):
        data = self.get_data()
        self.fp.close()
        self.fp = None
        if self.filename is None:
            return
        try:
            fp = open(self.filename, 'rb')
            original_data = fp.read()
            fp.close()
            if original_data == data:
                return
        except IOError:
            pass
        fp = open(self.filename, 'wb')
        fp.write(data)
        fp.close()

    def get_line_count(self):
        return self.get_data().count('\n')
