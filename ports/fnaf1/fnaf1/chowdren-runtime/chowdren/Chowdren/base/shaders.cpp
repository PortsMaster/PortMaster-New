class SubtractShader : public BaseShader
{
public:
    SubtractShader()
    : BaseShader(SHADER_SUBTRACT)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class MonochromeShader : public BaseShader
{
public:
    MonochromeShader()
    : BaseShader(SHADER_MONOCHROME)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class MixerShader : public BaseShader
{
public:
    static int r;
    static int g;
    static int b;
    
    MixerShader()
    : BaseShader(SHADER_COLORMIXER)
    {
    }
    
    void initialize_parameters()
    {
        r = get_uniform("r");
        g = get_uniform("g");
        b = get_uniform("b");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_R, r);
        BaseShader::set_vec4(instance, SHADER_PARAM_G, g);
        BaseShader::set_vec4(instance, SHADER_PARAM_B, b);
    }
};
int MixerShader::r;
int MixerShader::g;
int MixerShader::b;

class HueShader : public BaseShader
{
public:
    static int fHue;
    
    HueShader()
    : BaseShader(SHADER_HUE)
    {
    }
    
    void initialize_parameters()
    {
        fHue = get_uniform("fHue");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FHUE, fHue);
    }
};
int HueShader::fHue;

class OffsetShader : public BaseShader
{
public:
    static int width;
    static int height;
    
    OffsetShader()
    : BaseShader(SHADER_OFFSET, SHADER_HAS_BACK | SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        width = get_uniform("width");
        height = get_uniform("height");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_WIDTH, width);
        BaseShader::set_float(instance, SHADER_PARAM_HEIGHT, height);
    }
};
int OffsetShader::width;
int OffsetShader::height;

class InvertShader : public BaseShader
{
public:
    InvertShader()
    : BaseShader(SHADER_INVERT)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class DodgeBlurShader : public BaseShader
{
public:
    static int vertical;
    static int radius;
    
    DodgeBlurShader()
    : BaseShader(SHADER_DODGEBLUR, SHADER_HAS_BACK | SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        vertical = get_uniform("vertical");
        radius = get_uniform("radius");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_VERTICAL, vertical);
        BaseShader::set_float(instance, SHADER_PARAM_RADIUS, radius);
    }
};
int DodgeBlurShader::vertical;
int DodgeBlurShader::radius;

class GrainShader : public BaseShader
{
public:
    static int fStrength;
    static int fSeed;
    static int iInvert;
    static int iR;
    static int iG;
    static int iB;
    static int iA;
    
    GrainShader()
    : BaseShader(SHADER_GRAIN)
    {
    }
    
    void initialize_parameters()
    {
        fStrength = get_uniform("fStrength");
        fSeed = get_uniform("fSeed");
        iInvert = get_uniform("iInvert");
        iR = get_uniform("iR");
        iG = get_uniform("iG");
        iB = get_uniform("iB");
        iA = get_uniform("iA");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FSTRENGTH, fStrength);
        BaseShader::set_float(instance, SHADER_PARAM_FSEED, fSeed);
        BaseShader::set_int(instance, SHADER_PARAM_IINVERT, iInvert);
        BaseShader::set_int(instance, SHADER_PARAM_IR, iR);
        BaseShader::set_int(instance, SHADER_PARAM_IG, iG);
        BaseShader::set_int(instance, SHADER_PARAM_IB, iB);
        BaseShader::set_int(instance, SHADER_PARAM_IA, iA);
    }
};
int GrainShader::fStrength;
int GrainShader::fSeed;
int GrainShader::iInvert;
int GrainShader::iR;
int GrainShader::iG;
int GrainShader::iB;
int GrainShader::iA;

class MultiplyShader : public BaseShader
{
public:
    MultiplyShader()
    : BaseShader(SHADER_MULTIPLY, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class HardLightShader : public BaseShader
{
public:
    HardLightShader()
    : BaseShader(SHADER_HARDLIGHT, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class TintShader : public BaseShader
{
public:
    static int fTintColor;
    static int fTintPower;
    static int fOriginalPower;
    
    TintShader()
    : BaseShader(SHADER_TINT)
    {
    }
    
    void initialize_parameters()
    {
        fTintColor = get_uniform("fTintColor");
        fTintPower = get_uniform("fTintPower");
        fOriginalPower = get_uniform("fOriginalPower");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_FTINTCOLOR, fTintColor);
        BaseShader::set_float(instance, SHADER_PARAM_FTINTPOWER, fTintPower);
        BaseShader::set_float(instance, SHADER_PARAM_FORIGINALPOWER, fOriginalPower);
    }
};
int TintShader::fTintColor;
int TintShader::fTintPower;
int TintShader::fOriginalPower;

class ChannelBlurShader : public BaseShader
{
public:
    static int fCoeff;
    static int iR;
    static int iG;
    static int iB;
    static int iA;
    
    ChannelBlurShader()
    : BaseShader(SHADER_CHANNELBLUR)
    {
    }
    
    void initialize_parameters()
    {
        fCoeff = get_uniform("fCoeff");
        iR = get_uniform("iR");
        iG = get_uniform("iG");
        iB = get_uniform("iB");
        iA = get_uniform("iA");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FCOEFF, fCoeff);
        BaseShader::set_int(instance, SHADER_PARAM_IR, iR);
        BaseShader::set_int(instance, SHADER_PARAM_IG, iG);
        BaseShader::set_int(instance, SHADER_PARAM_IB, iB);
        BaseShader::set_int(instance, SHADER_PARAM_IA, iA);
    }
};
int ChannelBlurShader::fCoeff;
int ChannelBlurShader::iR;
int ChannelBlurShader::iG;
int ChannelBlurShader::iB;
int ChannelBlurShader::iA;

class BgBloomShader : public BaseShader
{
public:
    static int coeff;
    static int radius;
    static int exponent;
    
    BgBloomShader()
    : BaseShader(SHADER_BGBLOOM, SHADER_HAS_BACK | SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        coeff = get_uniform("coeff");
        radius = get_uniform("radius");
        exponent = get_uniform("exponent");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_COEFF, coeff);
        BaseShader::set_float(instance, SHADER_PARAM_RADIUS, radius);
        BaseShader::set_float(instance, SHADER_PARAM_EXPONENT, exponent);
    }
};
int BgBloomShader::coeff;
int BgBloomShader::radius;
int BgBloomShader::exponent;

class UnderwaterShader : public BaseShader
{
public:
    static int fBlur;
    static int fAmplitudeX;
    static int fPeriodsX;
    static int fFreqX;
    static int fAmplitudeY;
    static int fPeriodsY;
    static int fFreqY;
    
    UnderwaterShader()
    : BaseShader(SHADER_UNDERWATER)
    {
    }
    
    void initialize_parameters()
    {
        fBlur = get_uniform("fBlur");
        fAmplitudeX = get_uniform("fAmplitudeX");
        fPeriodsX = get_uniform("fPeriodsX");
        fFreqX = get_uniform("fFreqX");
        fAmplitudeY = get_uniform("fAmplitudeY");
        fPeriodsY = get_uniform("fPeriodsY");
        fFreqY = get_uniform("fFreqY");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FBLUR, fBlur);
        BaseShader::set_float(instance, SHADER_PARAM_FAMPLITUDEX, fAmplitudeX);
        BaseShader::set_float(instance, SHADER_PARAM_FPERIODSX, fPeriodsX);
        BaseShader::set_float(instance, SHADER_PARAM_FFREQX, fFreqX);
        BaseShader::set_float(instance, SHADER_PARAM_FAMPLITUDEY, fAmplitudeY);
        BaseShader::set_float(instance, SHADER_PARAM_FPERIODSY, fPeriodsY);
        BaseShader::set_float(instance, SHADER_PARAM_FFREQY, fFreqY);
    }
};
int UnderwaterShader::fBlur;
int UnderwaterShader::fAmplitudeX;
int UnderwaterShader::fPeriodsX;
int UnderwaterShader::fFreqX;
int UnderwaterShader::fAmplitudeY;
int UnderwaterShader::fPeriodsY;
int UnderwaterShader::fFreqY;

class RotateSubShader : public BaseShader
{
public:
    static int fA;
    static int fX;
    static int fY;
    static int fSx;
    static int fSy;
    
    RotateSubShader()
    : BaseShader(SHADER_ROTATESUB)
    {
    }
    
    void initialize_parameters()
    {
        fA = get_uniform("fA");
        fX = get_uniform("fX");
        fY = get_uniform("fY");
        fSx = get_uniform("fSx");
        fSy = get_uniform("fSy");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FA, fA);
        BaseShader::set_float(instance, SHADER_PARAM_FX, fX);
        BaseShader::set_float(instance, SHADER_PARAM_FY, fY);
        BaseShader::set_float(instance, SHADER_PARAM_FSX, fSx);
        BaseShader::set_float(instance, SHADER_PARAM_FSY, fSy);
    }
};
int RotateSubShader::fA;
int RotateSubShader::fX;
int RotateSubShader::fY;
int RotateSubShader::fSx;
int RotateSubShader::fSy;

class SimpleMaskShader : public BaseShader
{
public:
    static int fC;
    static int fFade;
    
    SimpleMaskShader()
    : BaseShader(SHADER_SIMPLEMASK)
    {
    }
    
    void initialize_parameters()
    {
        fC = get_uniform("fC");
        fFade = get_uniform("fFade");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_FC, fC);
        BaseShader::set_float(instance, SHADER_PARAM_FFADE, fFade);
    }
};
int SimpleMaskShader::fC;
int SimpleMaskShader::fFade;

class OffsetStationaryShader : public BaseShader
{
public:
    static int width;
    static int height;
    static int xoff;
    static int yoff;
    
    OffsetStationaryShader()
    : BaseShader(SHADER_OFFSETSTATIONARY)
    {
    }
    
    void initialize_parameters()
    {
        width = get_uniform("width");
        height = get_uniform("height");
        xoff = get_uniform("xoff");
        yoff = get_uniform("yoff");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_WIDTH, width);
        BaseShader::set_float(instance, SHADER_PARAM_HEIGHT, height);
        BaseShader::set_float(instance, SHADER_PARAM_XOFF, xoff);
        BaseShader::set_float(instance, SHADER_PARAM_YOFF, yoff);
    }
};
int OffsetStationaryShader::width;
int OffsetStationaryShader::height;
int OffsetStationaryShader::xoff;
int OffsetStationaryShader::yoff;

class PatternOverlayShader : public BaseShader
{
public:
    static int x;
    static int y;
    static int width;
    static int height;
    static int alpha;
    
    PatternOverlayShader()
    : BaseShader(SHADER_PATTERNOVERLAY, SHADER_HAS_TEX_SIZE, "pattern")
    {
    }
    
    void initialize_parameters()
    {
        x = get_uniform("x");
        y = get_uniform("y");
        width = get_uniform("width");
        height = get_uniform("height");
        alpha = get_uniform("alpha");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_X, x);
        BaseShader::set_float(instance, SHADER_PARAM_Y, y);
        BaseShader::set_float(instance, SHADER_PARAM_WIDTH, width);
        BaseShader::set_float(instance, SHADER_PARAM_HEIGHT, height);
        BaseShader::set_float(instance, SHADER_PARAM_ALPHA, alpha);
        BaseShader::set_image(instance, SHADER_PARAM_PATTERN);
    }
};
int PatternOverlayShader::x;
int PatternOverlayShader::y;
int PatternOverlayShader::width;
int PatternOverlayShader::height;
int PatternOverlayShader::alpha;

class SubPxShader : public BaseShader
{
public:
    static int x;
    static int y;
    static int limit;
    
    SubPxShader()
    : BaseShader(SHADER_SUBPX, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        x = get_uniform("x");
        y = get_uniform("y");
        limit = get_uniform("limit");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_X, x);
        BaseShader::set_float(instance, SHADER_PARAM_Y, y);
        BaseShader::set_int(instance, SHADER_PARAM_LIMIT, limit);
    }
};
int SubPxShader::x;
int SubPxShader::y;
int SubPxShader::limit;

class ZoomOffsetShader : public BaseShader
{
public:
    static int fX;
    static int fY;
    static int fWidth;
    static int fHeight;
    static int fZoomX;
    static int fZoomY;
    
    ZoomOffsetShader()
    : BaseShader(SHADER_ZOOMOFFSET)
    {
    }
    
    void initialize_parameters()
    {
        fX = get_uniform("fX");
        fY = get_uniform("fY");
        fWidth = get_uniform("fWidth");
        fHeight = get_uniform("fHeight");
        fZoomX = get_uniform("fZoomX");
        fZoomY = get_uniform("fZoomY");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FX, fX);
        BaseShader::set_float(instance, SHADER_PARAM_FY, fY);
        BaseShader::set_float(instance, SHADER_PARAM_FWIDTH, fWidth);
        BaseShader::set_float(instance, SHADER_PARAM_FHEIGHT, fHeight);
        BaseShader::set_float(instance, SHADER_PARAM_FZOOMX, fZoomX);
        BaseShader::set_float(instance, SHADER_PARAM_FZOOMY, fZoomY);
    }
};
int ZoomOffsetShader::fX;
int ZoomOffsetShader::fY;
int ZoomOffsetShader::fWidth;
int ZoomOffsetShader::fHeight;
int ZoomOffsetShader::fZoomX;
int ZoomOffsetShader::fZoomY;

class GradientShader : public BaseShader
{
public:
    static int fArgb;
    static int fAa;
    static int fBrgb;
    static int fBa;
    static int fCoeff;
    static int fOffset;
    static int fFade;
    static int iT;
    static int iF;
    static int iR;
    static int iMask;
    
    GradientShader()
    : BaseShader(SHADER_GRADIENT)
    {
    }
    
    void initialize_parameters()
    {
        fArgb = get_uniform("fArgb");
        fAa = get_uniform("fAa");
        fBrgb = get_uniform("fBrgb");
        fBa = get_uniform("fBa");
        fCoeff = get_uniform("fCoeff");
        fOffset = get_uniform("fOffset");
        fFade = get_uniform("fFade");
        iT = get_uniform("iT");
        iF = get_uniform("iF");
        iR = get_uniform("iR");
        iMask = get_uniform("iMask");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_FARGB, fArgb);
        BaseShader::set_float(instance, SHADER_PARAM_FAA, fAa);
        BaseShader::set_vec4(instance, SHADER_PARAM_FBRGB, fBrgb);
        BaseShader::set_float(instance, SHADER_PARAM_FBA, fBa);
        BaseShader::set_float(instance, SHADER_PARAM_FCOEFF, fCoeff);
        BaseShader::set_float(instance, SHADER_PARAM_FOFFSET, fOffset);
        BaseShader::set_float(instance, SHADER_PARAM_FFADE, fFade);
        BaseShader::set_int(instance, SHADER_PARAM_IT, iT);
        BaseShader::set_int(instance, SHADER_PARAM_IF, iF);
        BaseShader::set_int(instance, SHADER_PARAM_IR, iR);
        BaseShader::set_int(instance, SHADER_PARAM_IMASK, iMask);
    }
};
int GradientShader::fArgb;
int GradientShader::fAa;
int GradientShader::fBrgb;
int GradientShader::fBa;
int GradientShader::fCoeff;
int GradientShader::fOffset;
int GradientShader::fFade;
int GradientShader::iT;
int GradientShader::iF;
int GradientShader::iR;
int GradientShader::iMask;

class OverlayAlphaShader : public BaseShader
{
public:
    static int bgA;
    
    OverlayAlphaShader()
    : BaseShader(SHADER_OVERLAYALPHA, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
        bgA = get_uniform("bgA");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_BGA, bgA);
    }
};
int OverlayAlphaShader::bgA;

class LensShader : public BaseShader
{
public:
    static int fCoeff;
    static int fBase;
    
    LensShader()
    : BaseShader(SHADER_LENS, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
        fCoeff = get_uniform("fCoeff");
        fBase = get_uniform("fBase");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FCOEFF, fCoeff);
        BaseShader::set_float(instance, SHADER_PARAM_FBASE, fBase);
    }
};
int LensShader::fCoeff;
int LensShader::fBase;

class ColDirBlurShader : public BaseShader
{
public:
    static int rr;
    static int rg;
    static int rb;
    static int gr;
    static int gg;
    static int gb;
    static int br;
    static int bg;
    static int bb;
    static int fAngle;
    static int fCoeff;
    
    ColDirBlurShader()
    : BaseShader(SHADER_COLDIRBLUR, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
        rr = get_uniform("rr");
        rg = get_uniform("rg");
        rb = get_uniform("rb");
        gr = get_uniform("gr");
        gg = get_uniform("gg");
        gb = get_uniform("gb");
        br = get_uniform("br");
        bg = get_uniform("bg");
        bb = get_uniform("bb");
        fAngle = get_uniform("fAngle");
        fCoeff = get_uniform("fCoeff");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_RR, rr);
        BaseShader::set_float(instance, SHADER_PARAM_RG, rg);
        BaseShader::set_float(instance, SHADER_PARAM_RB, rb);
        BaseShader::set_float(instance, SHADER_PARAM_GR, gr);
        BaseShader::set_float(instance, SHADER_PARAM_GG, gg);
        BaseShader::set_float(instance, SHADER_PARAM_GB, gb);
        BaseShader::set_float(instance, SHADER_PARAM_BR, br);
        BaseShader::set_float(instance, SHADER_PARAM_BG, bg);
        BaseShader::set_float(instance, SHADER_PARAM_BB, bb);
        BaseShader::set_float(instance, SHADER_PARAM_FANGLE, fAngle);
        BaseShader::set_float(instance, SHADER_PARAM_FCOEFF, fCoeff);
    }
};
int ColDirBlurShader::rr;
int ColDirBlurShader::rg;
int ColDirBlurShader::rb;
int ColDirBlurShader::gr;
int ColDirBlurShader::gg;
int ColDirBlurShader::gb;
int ColDirBlurShader::br;
int ColDirBlurShader::bg;
int ColDirBlurShader::bb;
int ColDirBlurShader::fAngle;
int ColDirBlurShader::fCoeff;

class PerspectiveShader : public BaseShader
{
public:
    static int effect;
    static int direction;
    static int zoom;
    static int offset;
    static int sine_waves;
    
    PerspectiveShader()
    : BaseShader(SHADER_PERSPECTIVE, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        effect = get_uniform("effect");
        direction = get_uniform("direction");
        zoom = get_uniform("zoom");
        offset = get_uniform("offset");
        sine_waves = get_uniform("sine_waves");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_int(instance, SHADER_PARAM_EFFECT, effect);
        BaseShader::set_int(instance, SHADER_PARAM_DIRECTION, direction);
        BaseShader::set_int(instance, SHADER_PARAM_ZOOM, zoom);
        BaseShader::set_int(instance, SHADER_PARAM_OFFSET, offset);
        BaseShader::set_int(instance, SHADER_PARAM_SINE_WAVES, sine_waves);
    }
};
int PerspectiveShader::effect;
int PerspectiveShader::direction;
int PerspectiveShader::zoom;
int PerspectiveShader::offset;
int PerspectiveShader::sine_waves;

class NinePatchShader : public BaseShader
{
public:
    static int xScale;
    static int yScale;
    static int fArgb;
    static int fAa;
    static int fBrgb;
    static int fBa;
    static int fOffset;
    
    NinePatchShader()
    : BaseShader(SHADER_9G, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        xScale = get_uniform("xScale");
        yScale = get_uniform("yScale");
        fArgb = get_uniform("fArgb");
        fAa = get_uniform("fAa");
        fBrgb = get_uniform("fBrgb");
        fBa = get_uniform("fBa");
        fOffset = get_uniform("fOffset");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_XSCALE, xScale);
        BaseShader::set_float(instance, SHADER_PARAM_YSCALE, yScale);
        BaseShader::set_vec4(instance, SHADER_PARAM_FARGB, fArgb);
        BaseShader::set_float(instance, SHADER_PARAM_FAA, fAa);
        BaseShader::set_vec4(instance, SHADER_PARAM_FBRGB, fBrgb);
        BaseShader::set_float(instance, SHADER_PARAM_FBA, fBa);
        BaseShader::set_float(instance, SHADER_PARAM_FOFFSET, fOffset);
    }
};
int NinePatchShader::xScale;
int NinePatchShader::yScale;
int NinePatchShader::fArgb;
int NinePatchShader::fAa;
int NinePatchShader::fBrgb;
int NinePatchShader::fBa;
int NinePatchShader::fOffset;

class PixelOutlineShader : public BaseShader
{
public:
    static int color;
    
    PixelOutlineShader()
    : BaseShader(SHADER_PIXELOUTLINE, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        color = get_uniform("color");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_COLOR, color);
    }
};
int PixelOutlineShader::color;

class BrightSatBgShader : public BaseShader
{
public:
    static int Brightness;
    static int Saturation;
    
    BrightSatBgShader()
    : BaseShader(SHADER_BRIGHTSATBG, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
        Brightness = get_uniform("Brightness");
        Saturation = get_uniform("Saturation");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_BRIGHTNESS, Brightness);
        BaseShader::set_float(instance, SHADER_PARAM_SATURATION, Saturation);
    }
};
int BrightSatBgShader::Brightness;
int BrightSatBgShader::Saturation;

class BgBlurShader : public BaseShader
{
public:
    static int fX;
    static int fY;
    static int fA;
    
    BgBlurShader()
    : BaseShader(SHADER_BGBLUR, SHADER_HAS_BACK | SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        fX = get_uniform("fX");
        fY = get_uniform("fY");
        fA = get_uniform("fA");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FX, fX);
        BaseShader::set_float(instance, SHADER_PARAM_FY, fY);
        BaseShader::set_float(instance, SHADER_PARAM_FA, fA);
    }
};
int BgBlurShader::fX;
int BgBlurShader::fY;
int BgBlurShader::fA;

class PixelScaleShader : public BaseShader
{
public:
    static int x_scale;
    static int y_scale;
    static int x_size;
    static int y_size;
    
    PixelScaleShader()
    : BaseShader(SHADER_PIXELSCALE)
    {
    }
    
    void initialize_parameters()
    {
        x_scale = get_uniform("x_scale");
        y_scale = get_uniform("y_scale");
        x_size = get_uniform("x_size");
        y_size = get_uniform("y_size");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_X_SCALE, x_scale);
        BaseShader::set_float(instance, SHADER_PARAM_Y_SCALE, y_scale);
        BaseShader::set_float(instance, SHADER_PARAM_X_SIZE, x_size);
        BaseShader::set_float(instance, SHADER_PARAM_Y_SIZE, y_size);
    }
};
int PixelScaleShader::x_scale;
int PixelScaleShader::y_scale;
int PixelScaleShader::x_size;
int PixelScaleShader::y_size;

class BlurShader : public BaseShader
{
public:
    static int radius;
    
    BlurShader()
    : BaseShader(SHADER_BLUR, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        radius = get_uniform("radius");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_RADIUS, radius);
    }
};
int BlurShader::radius;

class TextureShader : public BaseShader
{
public:
    TextureShader()
    : BaseShader(SHADER_TEXTURE)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class FontShader : public BaseShader
{
public:
    FontShader()
    : BaseShader(SHADER_FONT)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class LinearBurnShader : public BaseShader
{
public:
    LinearBurnShader()
    : BaseShader(SHADER_LINEARBURN, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class LinearDodgeShader : public BaseShader
{
public:
    LinearDodgeShader()
    : BaseShader(SHADER_LINEARDODGE, SHADER_HAS_BACK)
    {
    }
    
    void initialize_parameters()
    {
    }
    
    static void set_parameters(FrameObject * instance)
    {
    }
};

class DisplayShader : public BaseShader
{
public:
    static int fPeriods;
    static int fOffset;
    static int fAmplitude;
    
    DisplayShader()
    : BaseShader(SHADER_DISPLAY)
    {
    }
    
    void initialize_parameters()
    {
        fPeriods = get_uniform("fPeriods");
        fOffset = get_uniform("fOffset");
        fAmplitude = get_uniform("fAmplitude");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_float(instance, SHADER_PARAM_FPERIODS, fPeriods);
        BaseShader::set_float(instance, SHADER_PARAM_FOFFSET, fOffset);
        BaseShader::set_float(instance, SHADER_PARAM_FAMPLITUDE, fAmplitude);
    }
};
int DisplayShader::fPeriods;
int DisplayShader::fOffset;
int DisplayShader::fAmplitude;

class FontOutlineShader : public BaseShader
{
public:
    static int color;
    
    FontOutlineShader()
    : BaseShader(SHADER_FONTOUTLINE, SHADER_HAS_TEX_SIZE)
    {
    }
    
    void initialize_parameters()
    {
        color = get_uniform("color");
    }
    
    static void set_parameters(FrameObject * instance)
    {
        BaseShader::set_vec4(instance, SHADER_PARAM_COLOR, color);
    }
};
int FontOutlineShader::color;

SubtractShader subtract_shader;
MonochromeShader monochrome_shader;
MixerShader mixer_shader;
HueShader hue_shader;
OffsetShader offset_shader;
InvertShader invert_shader;
DodgeBlurShader dodgeblur_shader;
GrainShader grain_shader;
MultiplyShader multiply_shader;
HardLightShader hardlight_shader;
TintShader tint_shader;
ChannelBlurShader channelblur_shader;
BgBloomShader bgbloom_shader;
UnderwaterShader underwater_shader;
RotateSubShader rotatesub_shader;
SimpleMaskShader simplemask_shader;
OffsetStationaryShader offsetstationary_shader;
PatternOverlayShader patternoverlay_shader;
SubPxShader subpx_shader;
ZoomOffsetShader zoomoffset_shader;
GradientShader gradient_shader;
OverlayAlphaShader overlayalpha_shader;
LensShader lens_shader;
ColDirBlurShader coldirblur_shader;
PerspectiveShader perspective_shader;
NinePatchShader ninepatch_shader;
PixelOutlineShader pixeloutline_shader;
BrightSatBgShader brightsatbg_shader;
BgBlurShader bgblur_shader;
PixelScaleShader pixelscale_shader;
BlurShader blur_shader;
TextureShader texture_shader;
FontShader font_shader;
LinearBurnShader linearburn_shader;
LinearDodgeShader lineardodge_shader;
DisplayShader display_shader;
FontOutlineShader fontoutline_shader;
