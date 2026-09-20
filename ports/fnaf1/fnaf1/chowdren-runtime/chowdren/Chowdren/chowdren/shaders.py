class Shader(object):
    def __init__(self, name, asset_name, has_back=False, has_tex_size=False,
                 tex_param=None):
        self.name = name
        self.asset_name = asset_name
        self.tex_param = tex_param
        self.has_tex_size = has_tex_size
        self.has_back = has_back
        self.uniforms = []

    def add_uniform(self, name, typ):
        self.uniforms.append((name, typ))

shader_subtract = Shader('Subtract', 'subtract')

shader_monochrome = Shader('Monochrome', 'monochrome')

shader_colormixer = Shader('Mixer', 'colormixer')
shader_colormixer.add_uniform('r', 'vec4')
shader_colormixer.add_uniform('g', 'vec4')
shader_colormixer.add_uniform('b', 'vec4')

shader_hue = Shader('Hue', 'hue')
shader_hue.add_uniform('fHue', 'float')

shader_offset = Shader('Offset', 'offset', has_back=True, has_tex_size=True)
shader_offset.add_uniform('width', 'float')
shader_offset.add_uniform('height', 'float')

shader_invert = Shader('Invert', 'invert')

shader_dodgeblur = Shader('DodgeBlur', 'dodgeblur', has_back=True,
                          has_tex_size=True)
shader_dodgeblur.add_uniform('vertical', 'float')
shader_dodgeblur.add_uniform('radius', 'float')

shader_grain = Shader('Grain', 'grain')
shader_grain.add_uniform('fStrength', 'float')
shader_grain.add_uniform('fSeed', 'float')
shader_grain.add_uniform('iInvert', 'int')
shader_grain.add_uniform('iR', 'int')
shader_grain.add_uniform('iG', 'int')
shader_grain.add_uniform('iB', 'int')
shader_grain.add_uniform('iA', 'int')

shader_multiply = Shader('Multiply', 'multiply', has_back=True)

shader_hardlight = Shader('HardLight', 'hardlight', has_back=True)

shader_tint = Shader('Tint', 'tint')
shader_tint.add_uniform('fTintColor', 'vec4')
shader_tint.add_uniform('fTintPower', 'float')
shader_tint.add_uniform('fOriginalPower', 'float')

shader_channelblur = Shader('ChannelBlur', 'channelblur')
shader_channelblur.add_uniform('fCoeff', 'float')
shader_channelblur.add_uniform('iR', 'int')
shader_channelblur.add_uniform('iG', 'int')
shader_channelblur.add_uniform('iB', 'int')
shader_channelblur.add_uniform('iA', 'int')

shader_bgbloom = Shader('BgBloom', 'bgbloom', has_back=True,
                        has_tex_size=True)
shader_bgbloom.add_uniform('coeff', 'float')
shader_bgbloom.add_uniform('radius', 'float')
shader_bgbloom.add_uniform('exponent', 'float')

shader_underwater = Shader('Underwater', 'underwater')
shader_underwater.add_uniform('fBlur', 'float')
shader_underwater.add_uniform('fAmplitudeX', 'float')
shader_underwater.add_uniform('fPeriodsX', 'float')
shader_underwater.add_uniform('fFreqX', 'float')
shader_underwater.add_uniform('fAmplitudeY', 'float')
shader_underwater.add_uniform('fPeriodsY', 'float')
shader_underwater.add_uniform('fFreqY', 'float')

shader_rotatesub = Shader('RotateSub', 'rotatesub')
shader_rotatesub.add_uniform('fA', 'float')
shader_rotatesub.add_uniform('fX', 'float')
shader_rotatesub.add_uniform('fY', 'float')
shader_rotatesub.add_uniform('fSx', 'float')
shader_rotatesub.add_uniform('fSy', 'float')

shader_simplemask = Shader('SimpleMask', 'simplemask')
shader_simplemask.add_uniform('fC', 'vec4')
shader_simplemask.add_uniform('fFade', 'float')

shader_offsetstationary = Shader('OffsetStationary', 'offsetstationary')
shader_offsetstationary.add_uniform('width', 'float')
shader_offsetstationary.add_uniform('height', 'float')
shader_offsetstationary.add_uniform('xoff', 'float')
shader_offsetstationary.add_uniform('yoff', 'float')

shader_patternoverlay = Shader('PatternOverlay', 'patternoverlay',
                               has_tex_size=True, tex_param="pattern")
shader_patternoverlay.add_uniform('x', 'float')
shader_patternoverlay.add_uniform('y', 'float')
shader_patternoverlay.add_uniform('width', 'float')
shader_patternoverlay.add_uniform('height', 'float')
shader_patternoverlay.add_uniform('alpha', 'float')

shader_subpx = Shader('SubPx', 'subpx', has_tex_size=True)
shader_subpx.add_uniform('x', 'float')
shader_subpx.add_uniform('y', 'float')
shader_subpx.add_uniform('limit', 'int')

shader_zoomoffset = Shader('ZoomOffset', 'zoomoffset')
shader_zoomoffset.add_uniform('fX', 'float')
shader_zoomoffset.add_uniform('fY', 'float')
shader_zoomoffset.add_uniform('fWidth', 'float')
shader_zoomoffset.add_uniform('fHeight', 'float')
shader_zoomoffset.add_uniform('fZoomX', 'float')
shader_zoomoffset.add_uniform('fZoomY', 'float')

shader_gradient = Shader('Gradient', 'gradient')
shader_gradient.add_uniform('fArgb', 'vec4')
shader_gradient.add_uniform('fAa', 'float')
shader_gradient.add_uniform('fBrgb', 'vec4')
shader_gradient.add_uniform('fBa', 'float')
shader_gradient.add_uniform('fCoeff', 'float')
shader_gradient.add_uniform('fOffset', 'float')
shader_gradient.add_uniform('fFade', 'float')
shader_gradient.add_uniform('iT', 'int')
shader_gradient.add_uniform('iF', 'int')
shader_gradient.add_uniform('iR', 'int')
shader_gradient.add_uniform('iMask', 'int')

shader_overlayalpha = Shader('OverlayAlpha', 'overlayalpha', has_back=True)
shader_overlayalpha.add_uniform('bgA', 'float')

shader_lens = Shader('Lens', 'lens', has_back=True)
shader_lens.add_uniform('fCoeff', 'float')
shader_lens.add_uniform('fBase', 'float')

shader_coldirblur = Shader('ColDirBlur', 'coldirblur', has_back=True)
shader_coldirblur.add_uniform('rr', 'float')
shader_coldirblur.add_uniform('rg', 'float')
shader_coldirblur.add_uniform('rb', 'float')
shader_coldirblur.add_uniform('gr', 'float')
shader_coldirblur.add_uniform('gg', 'float')
shader_coldirblur.add_uniform('gb', 'float')
shader_coldirblur.add_uniform('br', 'float')
shader_coldirblur.add_uniform('bg', 'float')
shader_coldirblur.add_uniform('bb', 'float')
shader_coldirblur.add_uniform('fAngle', 'float')
shader_coldirblur.add_uniform('fCoeff', 'float')

shader_perspective = Shader('Perspective', 'perspective', has_tex_size=True)
shader_perspective.add_uniform('effect', 'int')
shader_perspective.add_uniform('direction', 'int')
shader_perspective.add_uniform('zoom', 'int')
shader_perspective.add_uniform('offset', 'int')
shader_perspective.add_uniform('sine_waves', 'int')

shader_9g = Shader('NinePatch', '9g', has_tex_size=True)
shader_9g.add_uniform('xScale', 'float')
shader_9g.add_uniform('yScale', 'float')
shader_9g.add_uniform('fArgb', 'vec4')
shader_9g.add_uniform('fAa', 'float')
shader_9g.add_uniform('fBrgb', 'vec4')
shader_9g.add_uniform('fBa', 'float')
shader_9g.add_uniform('fOffset', 'float')

shader_pixeloutline = Shader('PixelOutline', 'pixeloutline', has_tex_size=True)
shader_pixeloutline.add_uniform('color', 'vec4')

shader_brightsatbg = Shader('BrightSatBg', 'brightsatbg', has_back=True)
shader_brightsatbg.add_uniform('Brightness', 'float')
shader_brightsatbg.add_uniform('Saturation', 'float')

shader_bgblur = Shader('BgBlur', 'bgblur', has_back=True, has_tex_size=True)
shader_bgblur.add_uniform('fX', 'float')
shader_bgblur.add_uniform('fY', 'float')
shader_bgblur.add_uniform('fA', 'float')

shader_pixelscale = Shader('PixelScale', 'pixelscale')
shader_pixelscale.add_uniform('x_scale', 'float')
shader_pixelscale.add_uniform('y_scale', 'float')
shader_pixelscale.add_uniform('x_size', 'float')
shader_pixelscale.add_uniform('y_size', 'float')

shader_lineardodge = Shader('LinearDodge', 'lineardodge', has_back=True)

shader_linearburn = Shader('LinearBurn', 'linearburn', has_back=True)

shader_display = Shader('Display', 'display')
shader_display.add_uniform('fPeriods', 'float')
shader_display.add_uniform('fOffset', 'float')
shader_display.add_uniform('fAmplitude', 'float')

shader_blur = Shader('Blur', 'blur', has_tex_size=True)
shader_blur.add_uniform('radius', 'float')

shader_fontoutline = Shader('FontOutline', 'fontoutline', has_tex_size=True)
shader_fontoutline.add_uniform('color', 'vec4')

shader_texture = Shader('Texture', 'texture')
shader_font = Shader('Font', 'font')

SHADERS = [
    shader_subtract,
    shader_monochrome,
    shader_colormixer,
    shader_hue,
    shader_offset,
    shader_invert,
    shader_dodgeblur,
    shader_grain,
    shader_multiply,
    shader_hardlight,
    shader_tint,
    shader_channelblur,
    shader_bgbloom,
    shader_underwater,
    shader_rotatesub,
    shader_simplemask,
    shader_offsetstationary,
    shader_patternoverlay,
    shader_subpx,
    shader_zoomoffset,
    shader_gradient,
    shader_overlayalpha,
    shader_lens,
    shader_coldirblur,
    shader_perspective,
    shader_9g,
    shader_pixeloutline,
    shader_brightsatbg,
    shader_bgblur,
    shader_pixelscale,
    shader_blur,
    shader_texture,
    shader_font,
    shader_linearburn,
    shader_lineardodge,
    shader_display,
    shader_fontoutline
]
