from chowdren.codewriter import CodeWriter

class Local(object):
    def get_string(self, source):
        return None

class DictLocal(Local):
    def __init__(self, values):
        self.values = values

    def get_string(self, source):
        return self.values.get(source, None)

def write_locals(local_dict, writer, header, converter):
    header.putlnc('void set_local(const std::string & name);')
    writer.putmeth('void set_local', 'const std::string & name')

    if not local_dict:
        writer.end_brace()
        return

    writer.putln('if (name.empty()) {')
    writer.indent()
    for value, name in converter.strings.iteritems():
        writer.putlnc('%s.assign(%r, %s);', name, value,
                      len(value), cpp=False)
    writer.putln('return;')
    writer.end_brace()

    for k, local in local_dict.iteritems():
        writer.putlnc('if (name == %r) {', k, cpp=False)
        writer.indent()

        for value, name in converter.strings.iteritems():
            new_string = local.get_string(value)
            if new_string is None:
                new_string = value
            writer.putlnc('%s.assign(%r, %s);', name, new_string,
                          len(new_string), cpp=False)

        writer.putln('return;')
        writer.end_brace()

    writer.end_brace()