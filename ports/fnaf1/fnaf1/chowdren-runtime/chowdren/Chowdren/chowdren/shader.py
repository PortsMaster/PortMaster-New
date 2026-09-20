import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))

from mmfparser.data.chunkloaders.objectinfo import (NONE_EFFECT,
    INVERTED_EFFECT, XOR_EFFECT, AND_EFFECT,
    OR_EFFECT, MONOCHROME_EFFECT, ADD_EFFECT, SUBTRACT_EFFECT)
from chowdren.common import get_base_path, makedirs

INK_EFFECTS = {
    NONE_EFFECT : None,
    ADD_EFFECT : 'Add',
    SUBTRACT_EFFECT : 'Subtract',
    MONOCHROME_EFFECT : 'Monochrome',
    INVERTED_EFFECT : 'Invert',
    XOR_EFFECT : 'XOR',
    AND_EFFECT : 'AND',
    OR_EFFECT : 'OR'
}

NATIVE_SHADERS = {
    None : None,
    'Sub' : 'subtract',
    'Add' : 'additive',
    'ColorMixer.fx' : 'mixer',
    'Looki Offset.fx' : 'offset',
    'CS_Hue.fx' : 'hue',
    'DodgeBlur.fx' : 'dodgeblur',
    'Mono' : 'monochrome',
    'Monochrome' : 'monochrome',
    'Blend' : None,
    'Subtract' : 'subtract',
    'MonoExample.fx' : 'monochrome',
    'HardMix.fx' : None,
    'Overlay.fx' : None,
    'Lens.fx' : 'lens',
    'LinearDodge.fx' : 'lineardodge',
    'SoftLight.fx' : None,
    'PinLight.fx' : None,
    'Invert' : 'invert',
    'GrainPS2.fx' : 'grain',
    'Multiply.fx' : 'multiply',
    'HardLight.fx' : 'hardlight',
    'CS_Tint.fx' : 'tint',
    'ChannelBlur.fx' : 'channelblur',
    'BgBloom.fx' : 'bgbloom',
    'CS_UnderWater.fx' : 'underwater',
    'RotateSub.fx' : 'rotatesub',
    'SimpleMask.fx' : 'simplemask',
    'Offsetstationary.fx' : 'offsetstationary',
    'Pattern Overlay alonso.fx' : 'patternoverlay',
    'SubPx.fx' : 'subpx',
    'ColDirBlur alonso.fx' : 'coldirblur',
    'OverlayAlpha.fx' : 'overlayalpha',
    'Gradient.fx' : 'gradient',
    'CS_ZoomOffset.fx' : 'zoomoffset',
    '9G.fx' : 'ninepatch',
    'PixelOutline_alphacoef support.fx' : 'pixeloutline',
    'BrightnessSaturationBg.fx' : 'brightsatbg',
    'BgBlur.fx' : 'bgblur',
    'Blur.fx' : 'blur',
    'Display.fx' : 'display',
    'PixelOutline.fx' : 'pixeloutline', # change?
    'LinearBurn.fx' : 'linearburn',

    # missing effects
    'CRT.fx' : None,
    'FlipY.fx' : None,
    'ChannelBlurAdd.fx' : 'channelbluradd',
    'DualGlow.fx' : None,
    'DropShadow.fx' : None,

    # new HFA missing effects
    'OffsetStationaryParam.fx' : None,
    'Colorizer with blur.fx' : None,
    'BrightnessSaturation.fx' : None,


    # unsupported in HWA
    'XOR' : None,
    'AND' : None,
    'OR' : None
}

def get_name(name):
    name = NATIVE_SHADERS[name]
    if name is None:
        name = 'NONE'
    return 'Render::%s' % name.upper()

VERTEX_REPLACEMENTS = {
    'gl_MultiTexCoord0': 'in_tex_coord1',
    'gl_MultiTexCoord1': 'in_tex_coord2',
    'gl_Vertex': 'in_pos',
    'gl_Color': 'in_blend_color',
    'gl_FrontColor': 'blend_color',
    'gl_ModelViewProjectionMatrix': '1.0'
}

FRAGMENT_REPLACEMENTS = {
    'gl_Color': 'blend_color'
}

REPLACEMENTS = {
    'vertex': VERTEX_REPLACEMENTS,
    'fragment': FRAGMENT_REPLACEMENTS,
}

SHADER_TYPES = {
    'blend_color': 'varying vec4 blend_color',
    'in_tex_coord1': 'attribute vec2 in_tex_coord1',
    'in_tex_coord2': 'attribute vec2 in_tex_coord2',
    'in_pos': 'attribute vec4 in_pos',
    'in_blend_color': 'attribute vec4 in_blend_color'
}

def translate_shader_data(data, typ, profile):
    # translates GLSL shaders to GLES-compatible ones
    features = set()
    for k, v in REPLACEMENTS[typ].iteritems():
        if not k in data:
            continue
        data = data.replace(k, v)
        features.add(v)

    lines = data.splitlines()
    if lines[0].strip() != '#version 120':
        raise NotImplementedError()
    if profile == 'gles':
        lines.pop(0)
        lines.insert(0, 'precision mediump float;')
    for feature in features:
        new_typ = SHADER_TYPES.get(feature, None)
        if not new_typ:
            continue
        new_line = '%s;' % (new_typ)
        lines.insert(1, new_line)
    return '\n'.join(lines)

def translate_data(data, typ, out_path, profile):
    data = translate_shader_data(data, typ, profile)
    with open(out_path, 'wb') as fp:
        fp.write(data)

def translate_shader_path(path, typ, out_path, profile):
    with open(path, 'rU') as fp:
        data = fp.read()
    translate_data(data, typ, out_path, profile)

def translate_program(vert, frag, out_dir, profile):
    new_vert_path = os.path.join(out_dir, 'out.vert')
    new_frag_path = os.path.join(out_dir, 'out.frag')
    translate_data(vert, 'vertex', new_vert_path, profile)
    translate_data(frag, 'fragment', new_frag_path, profile)
    return new_vert_path, new_frag_path

def translate_name(name, out_dir, profile):
    makedirs(out_dir)
    shader_path = os.path.join(get_base_path(), 'shaders')
    vert_path = os.path.join(shader_path, '%s.vert' % name)
    frag_path = os.path.join(shader_path, '%s.frag' % name)
    new_vert_path = os.path.join(out_dir, '%s.vert' % name)
    new_frag_path = os.path.join(out_dir, '%s.frag' % name)
    translate_shader_path(vert_path, 'vertex', new_vert_path, profile)
    translate_shader_path(frag_path, 'fragment', new_frag_path, profile)
    return new_vert_path, new_frag_path

def get_shader_programs():
    shaders = set()
    for path in os.listdir(os.path.join(get_base_path(), 'shaders')):
        shaders.add(os.path.splitext(os.path.basename(path))[0])
    return shaders

def main():
    out_dir = os.path.join(os.getcwd(), 'glesshaders')
    for name in get_shader_programs():
        translate_name(name, out_dir, 'gles')
        print 'Translated shader', name

if __name__ == '__main__':
    main()
