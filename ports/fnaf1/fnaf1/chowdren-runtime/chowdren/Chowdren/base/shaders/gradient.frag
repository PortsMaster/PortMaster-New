#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec4 fArgb;
uniform float fAa;
uniform vec4 fBrgb;
uniform float fBa;
uniform float fCoeff;
uniform float fOffset;
uniform float fFade;
uniform int iT;
uniform bool iF;
uniform bool iR;
uniform bool iMask;

void main()
{
    float Temp;
    float Gx;
    float Gy;
    float Ga;
    vec4 Gcol;

    // Output pixel
    vec4 Out;
    Gx = texture_coordinate.x;
    Gy = texture_coordinate.y;
    if(iF) {
        Gx = 1.0-Gx;
        Gy = 1.0-Gy;
    }
    if(iR) {
        Temp = Gy;
        Gy = Gx;
        Gx = Temp;
    }
    Out = texture2D(texture, texture_coordinate);

    //GRADIENT TYPES
    if(iT==0) {
        Gcol = fArgb+(fBrgb-fArgb)*(Gx+fOffset)*fCoeff;
        Ga = fAa+(fBa-fAa)*(Gx+fOffset)*fCoeff;
    }
    if(iT==1) {
        if(iR)
            Temp = 1.0-Gx;
        else
            Temp = Gx;
        Gcol = fArgb+(fBrgb-fArgb)*(Gy*Temp+fOffset)*fCoeff;
        Ga = fAa+(fBa-fAa)*(Gy*Temp+fOffset)*fCoeff;
    }
    if(iT==2) {
        Gcol = fArgb+(fBrgb-fArgb)*abs(sin(Gx*fCoeff+fOffset));
        Ga = fAa+(fBa-fAa)*abs(sin(Gx*fCoeff+fOffset));
    }
    if(iMask)
        Out.a *= Ga;
    else
        Out.a = Ga;
    Out.rgb += (Gcol.rgb-Out.rgb)*fFade;
    gl_FragColor = Out;
}
