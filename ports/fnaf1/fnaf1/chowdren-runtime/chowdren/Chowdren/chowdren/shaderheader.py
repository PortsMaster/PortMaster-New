import sys
sys.path.append('..')
from chowdren.shaders import SHADERS
from mmfparser.gperf import get_hash_function
from chowdren.common import get_method_name, get_base_path
from chowdren.codewriter import CodeWriter
import os

def write_shader_param():
    header = CodeWriter(os.path.join(get_base_path(), 'shaderparam.h'))
    code = CodeWriter(os.path.join(get_base_path(), 'shaderparam.cpp'))

    parameters = []
    for shader in SHADERS:
        for param in shader.uniforms:
            parameters.append(param[0])
        if shader.tex_param:
            parameters.append(shader.tex_param)
    parameters = list(set(parameters))

    hash_data = get_hash_function('hash_shader_parameter', parameters,
                                  False)

    code.putln(hash_data.code.replace('inline ', ''))

    header.start_guard('CHOWDREN_SHADERPARAM_H')
    header.putln('unsigned int hash_shader_parameter(const char * str, '
                                                    'unsigned int len);')
    header.putln('')

    for k, v in hash_data.strings.iteritems():
        name = 'SHADER_PARAM_%s' % get_method_name(k).upper()
        header.putdefine(name, v)

    header.close_guard('CHOWDREN_SHADERPARAM_H')

    header.close()
    code.close()

def write_shaders():
    code = CodeWriter(os.path.join(get_base_path(), 'shaders.cpp'))

    for shader in SHADERS:
        shader_name = '%sShader' % shader.name
        code.putlnc('class %s : public BaseShader', shader_name)
        code.start_brace()
        code.put_access('public')

        for uniform in shader.uniforms:
            code.putlnc('static int %s;', uniform[0])

        if shader.uniforms:
            code.putln('')

        asset_name = 'SHADER_%s' % shader.asset_name.upper()
        args = [asset_name]
        options = []
        if shader.has_back:
            options.append('SHADER_HAS_BACK')
        if shader.has_tex_size:
            options.append('SHADER_HAS_TEX_SIZE')
        if not options:
            if shader.tex_param:
                args.append('0')
        else:
            args.append(' | '.join(options))
        if shader.tex_param:
            args.append('"%s"' % shader.tex_param)

        code.putlnc('%s()', shader_name)
        code.putlnc(': BaseShader(%s)', ', '.join(args))
        code.start_brace()
        code.end_brace()

        code.putln('')

        code.putmeth('void initialize_parameters')
        for uniform in shader.uniforms:
            code.putlnc('%s = get_uniform(%r);', uniform[0], uniform[0],
                        cpp=False)
        code.end_brace()
        code.putln('')

        code.putmeth('static void set_parameters', 'FrameObject * instance')

        for uniform in shader.uniforms:
            param = 'SHADER_PARAM_%s' % uniform[0].upper()
            code.putlnc('BaseShader::set_%s(instance, %s, %s);', uniform[1],
                        param, uniform[0])
        if shader.tex_param:
            param = 'SHADER_PARAM_%s' % shader.tex_param.upper()
            code.putlnc('BaseShader::set_image(instance, %s);', param)
        code.end_brace()

        code.end_brace(True)

        for uniform in shader.uniforms:
            code.putlnc('int %s::%s;', shader_name, uniform[0])

        code.putln('')

    # write static init code
    for shader in SHADERS:
        shader_type = '%sShader' % shader.name
        shader_name = '%s_shader' % shader.name.lower()
        code.putlnc('%s %s;', shader_type, shader_name)

    code.close()

def main():
    write_shader_param()
    write_shaders()




if __name__ == '__main__':
    main()