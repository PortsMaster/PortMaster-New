from chowdren.platforms.common import Platform
from mmfparser.bytereader import ByteReader
import os
from chowdren.common import call
from chowdren.shader import get_shader_programs, translate_shader_data
from chowdren.common import get_base_path, makedirs, get_root_path
import subprocess
import tempfile
from cStringIO import StringIO
import collections


DXSDK_DIR = os.getenv('DXSDK_DIR')
if DXSDK_DIR is None:
    FXC_DIR = None
else:
    FXC_DIR = os.path.join(DXSDK_DIR, 'Utilities', 'bin', 'x86', 'fxc.exe')

SHADERS_DIR = os.path.join(get_root_path(), 'd3dshaders')

class D3DPlatform(Platform):
    def get_shader(self, name, vert, frag):
        vert_path = os.path.join(SHADERS_DIR, name + '.vsb')
        frag_path = os.path.join(SHADERS_DIR, name + '.psb')

        with open(vert_path, 'rb') as fp:
            vert_data = fp.read()

        with open(frag_path, 'rb') as fp:
            frag_data = fp.read()

        writer = ByteReader()
        writer.writeInt(len(vert_data))
        writer.write(vert_data)
        writer.writeInt(len(frag_data))
        writer.write(frag_data)
        return str(writer)


attribute_map = {
    '_in_tex_coord1': 'TEXCOORD0',
    '_in_tex_coord2': 'TEXCOORD1',
    '_in_blend_color': 'COLOR0',
    '_in_pos': 'POSITION'
}


class state:
    name = None


class HLSLShader(object):
    def __init__(self, data, ext, profile, vs_out=None):
        data = data.replace('cbuffer', 'ConstantBuffer')
        data = data.replace('uniform float4 dx_ViewAdjust',
                            '// uniform float4 dx_ViewAdjust')

        varyings = []
        attributes = []
        in_varyings = False
        in_attributes = False
        for line in data.splitlines():
            if line.startswith('// Varyings'):
                in_varyings = True
                continue
            if line.startswith('// Attributes'):
                in_attributes = True
                continue
            if line.strip() == '':
                in_varyings = in_attributes = False
                continue
            if not in_varyings and not in_attributes:
                continue
            typ, name = line.split()[1:3]
            if in_varyings:
                varyings.append((typ, name))
            if in_attributes:
                attributes.append((typ, name))
        varyings.sort()
        attributes.sort()

        if profile in ('cg', 'hlsl'):
            pos_semantic = 'POSITION'
        else:
            pos_semantic = 'S_POSITION'

        if vs_out is None:
            vs_out = 'struct VS_OUTPUT\n{\n'
            for index, (typ, name) in enumerate(varyings):
                vs_out += '    %s %s : TEXCOORD%s;\n' % (typ, name, index)
            vs_out += '    float4 position : %s;\n' % pos_semantic
            vs_out += '};\n\n'

        self.vs_out = vs_out
        data += vs_out

        if ext == 'vert':
            data += 'struct VS_INPUT\n{\n'
            for (typ, name) in attributes:
                semantic = attribute_map[name]
                data += '    %s %s : %s;\n' % (typ, name, semantic)
            data += '};\n\n'

            data += 'VS_OUTPUT main(VS_INPUT in_data)\n{\n'
            # load attributes
            for (typ, name) in attributes:
                data += '    %s = in_data.%s;\n' % (name, name)
            data += '    gl_main();\n'
            data += '    VS_OUTPUT data;\n'
            # save the varyings
            for (typ, name) in varyings:
                data += '    data.%s = %s;\n' % (name, name)
            data += '    data.position = gl_Position;\n'
            data += '    return data;\n'
            data += '}\n'
        elif ext == 'frag':
            if profile == 'cg':
                suffix = ''
            elif profile == 'hlsl':
                suffix = ' : COLOR0'
            else:
                suffix = ' : S_TARGET_OUTPUT'

            data += 'float4 main(VS_OUTPUT data)%s\n{\n' % suffix
            # load the varyings
            for (typ, name) in varyings:
                data += '    %s = data.%s;\n' % (name, name)
            data += '    gl_main();\n'
            data += '    return gl_Color[0];\n'
            data += '}\n'
        
        self.data = data


def get_shader(source, ext, profile, vs_out=None):
    fp = tempfile.NamedTemporaryFile(suffix='.' + ext, delete=False)
    fp.write(source)
    fp.flush()

    if profile == 'pssl':
        target = 'h11'
    elif profile in ('cg', 'hlsl'):
        target = 'h9'

    exe = os.path.join(os.path.dirname(__file__), 'essl_to_hlsl.exe')
    data = call_get([exe, '-b=%s' % target, '-o', '-u', fp.name])
    fp.close()
    lines = data.splitlines()

    data_map = collections.defaultdict(list)

    current_key = None
    for line in lines:
        if line.startswith('#### BEGIN'):
            current_key = ' '.join(line.strip().split(' ')[4:-1])
        elif line.startswith('#### END'):
            current_key = None
        else:
            data_map[current_key].append(line)

    data_map.pop(None)
    data_map.pop('INFO LOG')
    if 'OBJ CODE' not in data_map:
        print data
        raise NotImplementedError()
    source = '\n'.join(data_map.pop('OBJ CODE'))
    return HLSLShader(source, ext, profile, vs_out)


def call_get(args):
    exp = ' '.join(args)
    print exp
    print ''
    try:
        ret = subprocess.Popen(args, stdout=subprocess.PIPE)
        return ret.communicate()[0]
    except subprocess.CalledProcessError:
        print 'Error, quitting...'
        sys.exit()
        return


def convert(vert_data, frag_data, outdir, profile, name='out'):
    # state.name = name
    vert_data = translate_shader_data(vert_data, 'vertex', 'gles')
    frag_data = translate_shader_data(frag_data, 'fragment', 'gles')

    vert = get_shader(vert_data, 'vert', profile)
    frag = get_shader(frag_data, 'frag', profile, vert.vs_out)

    new_vert_path = os.path.join(outdir, '%s.vs' % name)
    new_frag_path = os.path.join(outdir, '%s.ps' % name)

    with open(new_vert_path, 'wb') as fp:
        fp.write(vert.data)

    with open(new_frag_path, 'wb') as fp:
        fp.write(frag.data)

    if profile == 'hlsl':
        call([FXC_DIR, '/nologo', '/E', 'main', '/O3', '/T', 'vs_2_a',
              new_vert_path, '/Fo', new_vert_path + 'b'])
        call([FXC_DIR, '/nologo', '/E', 'main', '/O3', '/T', 'ps_2_a',
              new_frag_path, '/Fo', new_frag_path + 'b'])

    return new_vert_path, new_frag_path


def convert_shaders():
    base_path = get_base_path()
    shader_path = os.path.join(base_path, 'shaders')

    for shader in get_shader_programs():
        vert_path = os.path.join(shader_path, '%s.vert' % shader)
        frag_path = os.path.join(shader_path, '%s.frag' % shader)

        with open(vert_path, 'rb') as fp:
            vert = fp.read()
        with open(frag_path, 'rb') as fp:
            frag = fp.read()

        convert(vert, frag, SHADERS_DIR, 'hlsl', shader)


if __name__ == '__main__':
    convert_shaders()