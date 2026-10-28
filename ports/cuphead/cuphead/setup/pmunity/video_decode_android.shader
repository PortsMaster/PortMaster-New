// Hidden/VideoDecodeAndroid for portmaster-unity's runtime (our own shader; see video.py).
//
// Unity's Android VideoPlayer draws each video frame from the SurfaceTexture's external texture
// (samplerExternalOES) into the video's RenderTexture with this shader. The runtime's
// SurfaceTexture (runtime/media/um_surface.c) holds the decoded picture as it comes from the
// decoder, YUV 4:2:0 in one 8-bit channel: rows 0 .. H-1 the Y plane, then each chroma row as U
// (W/2 texels) and V (W/2 texels); W x H is the picture padded to even sizes, the texture is
// W x 1.5 H. The texture coordinates Unity passes (its quad's, through getTransformMatrix and
// _MainTex_ST) are frame coordinates: (0,0) the picture's top-left, (1,1) its padded bottom-right.
// Sampling is nearest (Unity sets point filtering on this texture), so each output pixel reads its
// own Y and the U and V of its 2x2 block. (No texture size is read in the shader: drivers differ
// in what textureSize gives for external samplers.)
//
// The YCbCr -> RGB conversion is the one Unity's desktop players apply to the same clips, in the
// same order of operations, so a clip looks as it does there. UM_BT709 (a constant, so the
// compiler drops the other branch) chooses it; video.py sets it from the game's clips:
//   0: VP8 / VP9, decoded by Unity itself on the desktop and converted by its YCbCr_TO_RGB1 pass
//      (BT.601, limited range, coefficients in 1/64 steps): Linux builds' clips;
//   1: H.264 / HEVC, decoded by the system there into NV12 pictures and converted by Unity's NV12
//      pass (BT.709, limited range): macOS and Windows builds' clips.
//
// Two programs, each one Unity program (vertex and fragment in one source, "#ifdef VERTEX" /
// "#ifdef FRAGMENT"), separated by "//// pass <name>" lines: the passes Unity looks up by name.

//// pass RGBAExternal_To_RGBA
#ifdef VERTEX
#version 300 es
precision highp float;
precision highp int;
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 _MainTex_ST;
in  vec4 in_POSITION0;
in  vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    return;
}
#endif
#ifdef FRAGMENT
#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
precision highp int;
const bool UM_BT709 = false;
uniform 	float _AlphaParam;
uniform highp samplerExternalOES _MainTex;
in  vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
// Y, U, V of frame position p
vec3 yuv(vec2 p)
{
    float y = texture(_MainTex, vec2(p.x, p.y * (2.0 / 3.0))).x;
    float c = (2.0 + p.y) / 3.0;
    float u = texture(_MainTex, vec2(p.x * 0.5, c)).x;
    float v = texture(_MainTex, vec2(p.x * 0.5 + 0.5, c)).x;
    return vec3(y, u, v);
}
vec3 rgb(vec3 s)
{
    if (UM_BT709) {
        vec3 t = vec3(s.x + -0.0625, s.yz + vec2(-0.5, -0.5));
        return vec3(dot(vec2(1.16439998, 1.79270005), t.xz), dot(vec3(1.16439998, -0.213300005, -0.532899976), t),
                    dot(vec2(1.16439998, 2.11240005), t.xy));
    }
    vec2 uu = vec2(s.y) * vec2(0.390625, 1.984375);
    float g = s.x * 1.15625 + (-uu.x);
    float b = s.x * 1.15625 + uu.y;
    vec3 o;
    o.z = b + -1.06861997;
    g = (-s.z) * 0.8125 + g;
    float vr = s.z * 1.59375;
    float r = s.x * 1.15625 + vr;
    o.xy = vec2(r, g) + vec2(-0.872539997, 0.531369984);
    return o;
}
void main()
{
    SV_Target0.xyz = rgb(yuv(vs_TEXCOORD0.xy));
    SV_Target0.w = _AlphaParam;
    return;
}
#endif

//// pass RGBASplitExternal_To_RGBA
#ifdef VERTEX
#version 300 es
precision highp float;
precision highp int;
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 _MainTex_ST;
in  vec4 in_POSITION0;
in  vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    return;
}
#endif
#ifdef FRAGMENT
#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
precision highp int;
const bool UM_BT709 = false;
uniform highp samplerExternalOES _MainTex;
in  vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec3 yuv(vec2 p)
{
    float y = texture(_MainTex, vec2(p.x, p.y * (2.0 / 3.0))).x;
    float c = (2.0 + p.y) / 3.0;
    float u = texture(_MainTex, vec2(p.x * 0.5, c)).x;
    float v = texture(_MainTex, vec2(p.x * 0.5 + 0.5, c)).x;
    return vec3(y, u, v);
}
vec3 rgb(vec3 s)
{
    if (UM_BT709) {
        vec3 t = vec3(s.x + -0.0625, s.yz + vec2(-0.5, -0.5));
        return vec3(dot(vec2(1.16439998, 1.79270005), t.xz), dot(vec3(1.16439998, -0.213300005, -0.532899976), t),
                    dot(vec2(1.16439998, 2.11240005), t.xy));
    }
    vec2 uu = vec2(s.y) * vec2(0.390625, 1.984375);
    float g = s.x * 1.15625 + (-uu.x);
    float b = s.x * 1.15625 + uu.y;
    vec3 o;
    o.z = b + -1.06861997;
    g = (-s.z) * 0.8125 + g;
    float vr = s.z * 1.59375;
    float r = s.x * 1.15625 + vr;
    o.xy = vec2(r, g) + vec2(-0.872539997, 0.531369984);
    return o;
}
void main()
{
    // colour in the left half of the picture, alpha as luma in the right half (limited range)
    SV_Target0.xyz = rgb(yuv(vs_TEXCOORD0.xy * vec2(0.5, 1.0)));
    float a = texture(_MainTex, vec2(vs_TEXCOORD0.x * 0.5 + 0.5, vs_TEXCOORD0.y * (2.0 / 3.0))).x;
    SV_Target0.w = (a + -0.0627449974) * 1.15625;
    return;
}
#endif
