# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

# -*- coding: cp1252 -*-

cdef extern from "stddef.h":
    ctypedef char wchar_t

cdef extern from "include_gl.h":
    pass

cdef extern from *:
    unsigned int GL_VERSION_1_1   
    unsigned int GL_ARB_imaging   
    ctypedef   unsigned int    GLenum   
    ctypedef   unsigned char   GLboolean   
    ctypedef   unsigned int    GLbitfield   
    ctypedef   void            GLvoid   
    ctypedef   char     GLbyte            
    ctypedef   short           GLshort           
    ctypedef   int             GLint             
    ctypedef   unsigned char   GLubyte           
    ctypedef   unsigned short  GLushort          
    ctypedef   unsigned int    GLuint            
    ctypedef   int             GLsizei           
    ctypedef   float           GLfloat           
    ctypedef   float           GLclampf          
    ctypedef   double          GLdouble          
    ctypedef   double          GLclampd          
    unsigned int GL_FALSE   
    unsigned int GL_TRUE   
    unsigned int GL_BYTE   
    unsigned int GL_UNSIGNED_BYTE   
    unsigned int GL_SHORT   
    unsigned int GL_UNSIGNED_SHORT   
    unsigned int GL_INT   
    unsigned int GL_UNSIGNED_INT   
    unsigned int GL_FLOAT   
    unsigned int GL_DOUBLE   
    unsigned int GL_2_BYTES   
    unsigned int GL_3_BYTES   
    unsigned int GL_4_BYTES   
    unsigned int GL_POINTS   
    unsigned int GL_LINES   
    unsigned int GL_LINE_LOOP   
    unsigned int GL_LINE_STRIP   
    unsigned int GL_TRIANGLES   
    unsigned int GL_TRIANGLE_STRIP   
    unsigned int GL_TRIANGLE_FAN   
    unsigned int GL_QUADS   
    unsigned int GL_QUAD_STRIP   
    unsigned int GL_POLYGON   
    unsigned int GL_VERTEX_ARRAY   
    unsigned int GL_NORMAL_ARRAY   
    unsigned int GL_COLOR_ARRAY   
    unsigned int GL_INDEX_ARRAY   
    unsigned int GL_TEXTURE_COORD_ARRAY   
    unsigned int GL_EDGE_FLAG_ARRAY   
    unsigned int GL_VERTEX_ARRAY_SIZE   
    unsigned int GL_VERTEX_ARRAY_TYPE   
    unsigned int GL_VERTEX_ARRAY_STRIDE   
    unsigned int GL_NORMAL_ARRAY_TYPE   
    unsigned int GL_NORMAL_ARRAY_STRIDE   
    unsigned int GL_COLOR_ARRAY_SIZE   
    unsigned int GL_COLOR_ARRAY_TYPE   
    unsigned int GL_COLOR_ARRAY_STRIDE   
    unsigned int GL_INDEX_ARRAY_TYPE   
    unsigned int GL_INDEX_ARRAY_STRIDE   
    unsigned int GL_TEXTURE_COORD_ARRAY_SIZE   
    unsigned int GL_TEXTURE_COORD_ARRAY_TYPE   
    unsigned int GL_TEXTURE_COORD_ARRAY_STRIDE   
    unsigned int GL_EDGE_FLAG_ARRAY_STRIDE   
    unsigned int GL_VERTEX_ARRAY_POINTER   
    unsigned int GL_NORMAL_ARRAY_POINTER   
    unsigned int GL_COLOR_ARRAY_POINTER   
    unsigned int GL_INDEX_ARRAY_POINTER   
    unsigned int GL_TEXTURE_COORD_ARRAY_POINTER   
    unsigned int GL_EDGE_FLAG_ARRAY_POINTER   
    unsigned int GL_V2F   
    unsigned int GL_V3F   
    unsigned int GL_C4UB_V2F   
    unsigned int GL_C4UB_V3F   
    unsigned int GL_C3F_V3F   
    unsigned int GL_N3F_V3F   
    unsigned int GL_C4F_N3F_V3F   
    unsigned int GL_T2F_V3F   
    unsigned int GL_T4F_V4F   
    unsigned int GL_T2F_C4UB_V3F   
    unsigned int GL_T2F_C3F_V3F   
    unsigned int GL_T2F_N3F_V3F   
    unsigned int GL_T2F_C4F_N3F_V3F   
    unsigned int GL_T4F_C4F_N3F_V4F   
    unsigned int GL_MATRIX_MODE   
    unsigned int GL_MODELVIEW   
    unsigned int GL_PROJECTION   
    unsigned int GL_TEXTURE   
    unsigned int GL_POINT_SMOOTH   
    unsigned int GL_POINT_SIZE   
    unsigned int GL_POINT_SIZE_GRANULARITY   
    unsigned int GL_POINT_SIZE_RANGE   
    unsigned int GL_LINE_SMOOTH   
    unsigned int GL_LINE_STIPPLE   
    unsigned int GL_LINE_STIPPLE_PATTERN   
    unsigned int GL_LINE_STIPPLE_REPEAT   
    unsigned int GL_LINE_WIDTH   
    unsigned int GL_LINE_WIDTH_GRANULARITY   
    unsigned int GL_LINE_WIDTH_RANGE   
    unsigned int GL_POINT   
    unsigned int GL_LINE   
    unsigned int GL_FILL   
    unsigned int GL_CW   
    unsigned int GL_CCW   
    unsigned int GL_FRONT   
    unsigned int GL_BACK   
    unsigned int GL_POLYGON_MODE   
    unsigned int GL_POLYGON_SMOOTH   
    unsigned int GL_POLYGON_STIPPLE   
    unsigned int GL_EDGE_FLAG   
    unsigned int GL_CULL_FACE   
    unsigned int GL_CULL_FACE_MODE   
    unsigned int GL_FRONT_FACE   
    unsigned int GL_POLYGON_OFFSET_FACTOR   
    unsigned int GL_POLYGON_OFFSET_UNITS   
    unsigned int GL_POLYGON_OFFSET_POINT   
    unsigned int GL_POLYGON_OFFSET_LINE   
    unsigned int GL_POLYGON_OFFSET_FILL   
    unsigned int GL_COMPILE   
    unsigned int GL_COMPILE_AND_EXECUTE   
    unsigned int GL_LIST_BASE   
    unsigned int GL_LIST_INDEX   
    unsigned int GL_LIST_MODE   
    unsigned int GL_NEVER   
    unsigned int GL_LESS   
    unsigned int GL_EQUAL   
    unsigned int GL_LEQUAL   
    unsigned int GL_GREATER   
    unsigned int GL_NOTEQUAL   
    unsigned int GL_GEQUAL   
    unsigned int GL_ALWAYS   
    unsigned int GL_DEPTH_TEST   
    unsigned int GL_DEPTH_BITS   
    unsigned int GL_DEPTH_CLEAR_VALUE   
    unsigned int GL_DEPTH_FUNC   
    unsigned int GL_DEPTH_RANGE   
    unsigned int GL_DEPTH_WRITEMASK   
    unsigned int GL_DEPTH_COMPONENT   
    unsigned int GL_LIGHTING   
    unsigned int GL_LIGHT0   
    unsigned int GL_LIGHT1   
    unsigned int GL_LIGHT2   
    unsigned int GL_LIGHT3   
    unsigned int GL_LIGHT4   
    unsigned int GL_LIGHT5   
    unsigned int GL_LIGHT6   
    unsigned int GL_LIGHT7   
    unsigned int GL_SPOT_EXPONENT   
    unsigned int GL_SPOT_CUTOFF   
    unsigned int GL_CONSTANT_ATTENUATION   
    unsigned int GL_LINEAR_ATTENUATION   
    unsigned int GL_QUADRATIC_ATTENUATION   
    unsigned int GL_AMBIENT   
    unsigned int GL_DIFFUSE   
    unsigned int GL_SPECULAR   
    unsigned int GL_SHININESS   
    unsigned int GL_EMISSION   
    unsigned int GL_POSITION   
    unsigned int GL_SPOT_DIRECTION   
    unsigned int GL_AMBIENT_AND_DIFFUSE   
    unsigned int GL_COLOR_INDEXES   
    unsigned int GL_LIGHT_MODEL_TWO_SIDE   
    unsigned int GL_LIGHT_MODEL_LOCAL_VIEWER   
    unsigned int GL_LIGHT_MODEL_AMBIENT   
    unsigned int GL_FRONT_AND_BACK   
    unsigned int GL_SHADE_MODEL   
    unsigned int GL_FLAT   
    unsigned int GL_SMOOTH   
    unsigned int GL_COLOR_MATERIAL   
    unsigned int GL_COLOR_MATERIAL_FACE   
    unsigned int GL_COLOR_MATERIAL_PARAMETER   
    unsigned int GL_NORMALIZE   
    unsigned int GL_CLIP_PLANE0   
    unsigned int GL_CLIP_PLANE1   
    unsigned int GL_CLIP_PLANE2   
    unsigned int GL_CLIP_PLANE3   
    unsigned int GL_CLIP_PLANE4   
    unsigned int GL_CLIP_PLANE5   
    unsigned int GL_ACCUM_RED_BITS   
    unsigned int GL_ACCUM_GREEN_BITS   
    unsigned int GL_ACCUM_BLUE_BITS   
    unsigned int GL_ACCUM_ALPHA_BITS   
    unsigned int GL_ACCUM_CLEAR_VALUE   
    unsigned int GL_ACCUM   
    unsigned int GL_ADD   
    unsigned int GL_LOAD   
    unsigned int GL_MULT   
    unsigned int GL_RETURN   
    unsigned int GL_ALPHA_TEST   
    unsigned int GL_ALPHA_TEST_REF   
    unsigned int GL_ALPHA_TEST_FUNC   
    unsigned int GL_BLEND   
    unsigned int GL_BLEND_SRC   
    unsigned int GL_BLEND_DST   
    unsigned int GL_ZERO   
    unsigned int GL_ONE   
    unsigned int GL_SRC_COLOR   
    unsigned int GL_ONE_MINUS_SRC_COLOR   
    unsigned int GL_SRC_ALPHA   
    unsigned int GL_ONE_MINUS_SRC_ALPHA   
    unsigned int GL_DST_ALPHA   
    unsigned int GL_ONE_MINUS_DST_ALPHA   
    unsigned int GL_DST_COLOR   
    unsigned int GL_ONE_MINUS_DST_COLOR   
    unsigned int GL_SRC_ALPHA_SATURATE   
    unsigned int GL_FEEDBACK   
    unsigned int GL_RENDER   
    unsigned int GL_SELECT   
    unsigned int GL_2D   
    unsigned int GL_3D   
    unsigned int GL_3D_COLOR   
    unsigned int GL_3D_COLOR_TEXTURE   
    unsigned int GL_4D_COLOR_TEXTURE   
    unsigned int GL_POINT_TOKEN   
    unsigned int GL_LINE_TOKEN   
    unsigned int GL_LINE_RESET_TOKEN   
    unsigned int GL_POLYGON_TOKEN   
    unsigned int GL_BITMAP_TOKEN   
    unsigned int GL_DRAW_PIXEL_TOKEN   
    unsigned int GL_COPY_PIXEL_TOKEN   
    unsigned int GL_PASS_THROUGH_TOKEN   
    unsigned int GL_FEEDBACK_BUFFER_POINTER   
    unsigned int GL_FEEDBACK_BUFFER_SIZE   
    unsigned int GL_FEEDBACK_BUFFER_TYPE   
    unsigned int GL_SELECTION_BUFFER_POINTER   
    unsigned int GL_SELECTION_BUFFER_SIZE   
    unsigned int GL_FOG   
    unsigned int GL_FOG_MODE   
    unsigned int GL_FOG_DENSITY   
    unsigned int GL_FOG_COLOR   
    unsigned int GL_FOG_INDEX   
    unsigned int GL_FOG_START   
    unsigned int GL_FOG_END   
    unsigned int GL_LINEAR   
    unsigned int GL_EXP   
    unsigned int GL_EXP2   
    unsigned int GL_LOGIC_OP   
    unsigned int GL_INDEX_LOGIC_OP   
    unsigned int GL_COLOR_LOGIC_OP   
    unsigned int GL_LOGIC_OP_MODE   
    unsigned int GL_CLEAR   
    unsigned int GL_SET   
    unsigned int GL_COPY   
    unsigned int GL_COPY_INVERTED   
    unsigned int GL_NOOP   
    unsigned int GL_INVERT   
    unsigned int GL_AND   
    unsigned int GL_NAND   
    unsigned int GL_OR   
    unsigned int GL_NOR   
    unsigned int GL_XOR   
    unsigned int GL_EQUIV   
    unsigned int GL_AND_REVERSE   
    unsigned int GL_AND_INVERTED   
    unsigned int GL_OR_REVERSE   
    unsigned int GL_OR_INVERTED   
    unsigned int GL_STENCIL_TEST   
    unsigned int GL_STENCIL_WRITEMASK   
    unsigned int GL_STENCIL_BITS   
    unsigned int GL_STENCIL_FUNC   
    unsigned int GL_STENCIL_VALUE_MASK   
    unsigned int GL_STENCIL_REF   
    unsigned int GL_STENCIL_FAIL   
    unsigned int GL_STENCIL_PASS_DEPTH_PASS   
    unsigned int GL_STENCIL_PASS_DEPTH_FAIL   
    unsigned int GL_STENCIL_CLEAR_VALUE   
    unsigned int GL_STENCIL_INDEX   
    unsigned int GL_KEEP   
    unsigned int GL_REPLACE   
    unsigned int GL_INCR   
    unsigned int GL_DECR   
    unsigned int GL_NONE   
    unsigned int GL_LEFT   
    unsigned int GL_RIGHT   
    unsigned int GL_FRONT_LEFT   
    unsigned int GL_FRONT_RIGHT   
    unsigned int GL_BACK_LEFT   
    unsigned int GL_BACK_RIGHT   
    unsigned int GL_AUX0   
    unsigned int GL_AUX1   
    unsigned int GL_AUX2   
    unsigned int GL_AUX3   
    unsigned int GL_COLOR_INDEX   
    unsigned int GL_RED   
    unsigned int GL_GREEN   
    unsigned int GL_BLUE   
    unsigned int GL_ALPHA   
    unsigned int GL_LUMINANCE   
    unsigned int GL_LUMINANCE_ALPHA   
    unsigned int GL_ALPHA_BITS   
    unsigned int GL_RED_BITS   
    unsigned int GL_GREEN_BITS   
    unsigned int GL_BLUE_BITS   
    unsigned int GL_INDEX_BITS   
    unsigned int GL_SUBPIXEL_BITS   
    unsigned int GL_AUX_BUFFERS   
    unsigned int GL_READ_BUFFER   
    unsigned int GL_DRAW_BUFFER   
    unsigned int GL_DOUBLEBUFFER   
    unsigned int GL_STEREO   
    unsigned int GL_BITMAP   
    unsigned int GL_COLOR   
    unsigned int GL_DEPTH   
    unsigned int GL_STENCIL   
    unsigned int GL_DITHER   
    unsigned int GL_RGB   
    unsigned int GL_RGBA   
    unsigned int GL_MAX_LIST_NESTING   
    unsigned int GL_MAX_ATTRIB_STACK_DEPTH   
    unsigned int GL_MAX_MODELVIEW_STACK_DEPTH   
    unsigned int GL_MAX_NAME_STACK_DEPTH   
    unsigned int GL_MAX_PROJECTION_STACK_DEPTH   
    unsigned int GL_MAX_TEXTURE_STACK_DEPTH   
    unsigned int GL_MAX_EVAL_ORDER   
    unsigned int GL_MAX_LIGHTS   
    unsigned int GL_MAX_CLIP_PLANES   
    unsigned int GL_MAX_TEXTURE_SIZE   
    unsigned int GL_MAX_PIXEL_MAP_TABLE   
    unsigned int GL_MAX_VIEWPORT_DIMS   
    unsigned int GL_MAX_CLIENT_ATTRIB_STACK_DEPTH   
    unsigned int GL_ATTRIB_STACK_DEPTH   
    unsigned int GL_CLIENT_ATTRIB_STACK_DEPTH   
    unsigned int GL_COLOR_CLEAR_VALUE   
    unsigned int GL_COLOR_WRITEMASK   
    unsigned int GL_CURRENT_INDEX   
    unsigned int GL_CURRENT_COLOR   
    unsigned int GL_CURRENT_NORMAL   
    unsigned int GL_CURRENT_RASTER_COLOR   
    unsigned int GL_CURRENT_RASTER_DISTANCE   
    unsigned int GL_CURRENT_RASTER_INDEX   
    unsigned int GL_CURRENT_RASTER_POSITION   
    unsigned int GL_CURRENT_RASTER_TEXTURE_COORDS   
    unsigned int GL_CURRENT_RASTER_POSITION_VALID   
    unsigned int GL_CURRENT_TEXTURE_COORDS   
    unsigned int GL_INDEX_CLEAR_VALUE   
    unsigned int GL_INDEX_MODE   
    unsigned int GL_INDEX_WRITEMASK   
    unsigned int GL_MODELVIEW_MATRIX   
    unsigned int GL_MODELVIEW_STACK_DEPTH   
    unsigned int GL_NAME_STACK_DEPTH   
    unsigned int GL_PROJECTION_MATRIX   
    unsigned int GL_PROJECTION_STACK_DEPTH   
    unsigned int GL_RENDER_MODE   
    unsigned int GL_RGBA_MODE   
    unsigned int GL_TEXTURE_MATRIX   
    unsigned int GL_TEXTURE_STACK_DEPTH   
    unsigned int GL_VIEWPORT   
    unsigned int GL_AUTO_NORMAL   
    unsigned int GL_MAP1_COLOR_4   
    unsigned int GL_MAP1_GRID_DOMAIN   
    unsigned int GL_MAP1_GRID_SEGMENTS   
    unsigned int GL_MAP1_INDEX   
    unsigned int GL_MAP1_NORMAL   
    unsigned int GL_MAP1_TEXTURE_COORD_1   
    unsigned int GL_MAP1_TEXTURE_COORD_2   
    unsigned int GL_MAP1_TEXTURE_COORD_3   
    unsigned int GL_MAP1_TEXTURE_COORD_4   
    unsigned int GL_MAP1_VERTEX_3   
    unsigned int GL_MAP1_VERTEX_4   
    unsigned int GL_MAP2_COLOR_4   
    unsigned int GL_MAP2_GRID_DOMAIN   
    unsigned int GL_MAP2_GRID_SEGMENTS   
    unsigned int GL_MAP2_INDEX   
    unsigned int GL_MAP2_NORMAL   
    unsigned int GL_MAP2_TEXTURE_COORD_1   
    unsigned int GL_MAP2_TEXTURE_COORD_2   
    unsigned int GL_MAP2_TEXTURE_COORD_3   
    unsigned int GL_MAP2_TEXTURE_COORD_4   
    unsigned int GL_MAP2_VERTEX_3   
    unsigned int GL_MAP2_VERTEX_4   
    unsigned int GL_COEFF   
    unsigned int GL_DOMAIN   
    unsigned int GL_ORDER   
    unsigned int GL_FOG_HINT   
    unsigned int GL_LINE_SMOOTH_HINT   
    unsigned int GL_PERSPECTIVE_CORRECTION_HINT   
    unsigned int GL_POINT_SMOOTH_HINT   
    unsigned int GL_POLYGON_SMOOTH_HINT   
    unsigned int GL_DONT_CARE   
    unsigned int GL_FASTEST   
    unsigned int GL_NICEST   
    unsigned int GL_SCISSOR_TEST   
    unsigned int GL_SCISSOR_BOX   
    unsigned int GL_MAP_COLOR   
    unsigned int GL_MAP_STENCIL   
    unsigned int GL_INDEX_SHIFT   
    unsigned int GL_INDEX_OFFSET   
    unsigned int GL_RED_SCALE   
    unsigned int GL_RED_BIAS   
    unsigned int GL_GREEN_SCALE   
    unsigned int GL_GREEN_BIAS   
    unsigned int GL_BLUE_SCALE   
    unsigned int GL_BLUE_BIAS   
    unsigned int GL_ALPHA_SCALE   
    unsigned int GL_ALPHA_BIAS   
    unsigned int GL_DEPTH_SCALE   
    unsigned int GL_DEPTH_BIAS   
    unsigned int GL_PIXEL_MAP_S_TO_S_SIZE   
    unsigned int GL_PIXEL_MAP_I_TO_I_SIZE   
    unsigned int GL_PIXEL_MAP_I_TO_R_SIZE   
    unsigned int GL_PIXEL_MAP_I_TO_G_SIZE   
    unsigned int GL_PIXEL_MAP_I_TO_B_SIZE   
    unsigned int GL_PIXEL_MAP_I_TO_A_SIZE   
    unsigned int GL_PIXEL_MAP_R_TO_R_SIZE   
    unsigned int GL_PIXEL_MAP_G_TO_G_SIZE   
    unsigned int GL_PIXEL_MAP_B_TO_B_SIZE   
    unsigned int GL_PIXEL_MAP_A_TO_A_SIZE   
    unsigned int GL_PIXEL_MAP_S_TO_S   
    unsigned int GL_PIXEL_MAP_I_TO_I   
    unsigned int GL_PIXEL_MAP_I_TO_R   
    unsigned int GL_PIXEL_MAP_I_TO_G   
    unsigned int GL_PIXEL_MAP_I_TO_B   
    unsigned int GL_PIXEL_MAP_I_TO_A   
    unsigned int GL_PIXEL_MAP_R_TO_R   
    unsigned int GL_PIXEL_MAP_G_TO_G   
    unsigned int GL_PIXEL_MAP_B_TO_B   
    unsigned int GL_PIXEL_MAP_A_TO_A   
    unsigned int GL_PACK_ALIGNMENT   
    unsigned int GL_PACK_LSB_FIRST   
    unsigned int GL_PACK_ROW_LENGTH   
    unsigned int GL_PACK_SKIP_PIXELS   
    unsigned int GL_PACK_SKIP_ROWS   
    unsigned int GL_PACK_SWAP_BYTES   
    unsigned int GL_UNPACK_ALIGNMENT   
    unsigned int GL_UNPACK_LSB_FIRST   
    unsigned int GL_UNPACK_ROW_LENGTH   
    unsigned int GL_UNPACK_SKIP_PIXELS   
    unsigned int GL_UNPACK_SKIP_ROWS   
    unsigned int GL_UNPACK_SWAP_BYTES   
    unsigned int GL_ZOOM_X   
    unsigned int GL_ZOOM_Y   
    unsigned int GL_TEXTURE_ENV   
    unsigned int GL_TEXTURE_ENV_MODE   
    unsigned int GL_TEXTURE_1D   
    unsigned int GL_TEXTURE_2D   
    unsigned int GL_TEXTURE_WRAP_S   
    unsigned int GL_TEXTURE_WRAP_T   
    unsigned int GL_TEXTURE_MAG_FILTER   
    unsigned int GL_TEXTURE_MIN_FILTER   
    unsigned int GL_TEXTURE_ENV_COLOR   
    unsigned int GL_TEXTURE_GEN_S   
    unsigned int GL_TEXTURE_GEN_T   
    unsigned int GL_TEXTURE_GEN_MODE   
    unsigned int GL_TEXTURE_BORDER_COLOR   
    unsigned int GL_TEXTURE_WIDTH   
    unsigned int GL_TEXTURE_HEIGHT   
    unsigned int GL_TEXTURE_BORDER   
    unsigned int GL_TEXTURE_COMPONENTS   
    unsigned int GL_TEXTURE_RED_SIZE   
    unsigned int GL_TEXTURE_GREEN_SIZE   
    unsigned int GL_TEXTURE_BLUE_SIZE   
    unsigned int GL_TEXTURE_ALPHA_SIZE   
    unsigned int GL_TEXTURE_LUMINANCE_SIZE   
    unsigned int GL_TEXTURE_INTENSITY_SIZE   
    unsigned int GL_NEAREST_MIPMAP_NEAREST   
    unsigned int GL_NEAREST_MIPMAP_LINEAR   
    unsigned int GL_LINEAR_MIPMAP_NEAREST   
    unsigned int GL_LINEAR_MIPMAP_LINEAR   
    unsigned int GL_OBJECT_LINEAR   
    unsigned int GL_OBJECT_PLANE   
    unsigned int GL_EYE_LINEAR   
    unsigned int GL_EYE_PLANE   
    unsigned int GL_SPHERE_MAP   
    unsigned int GL_DECAL   
    unsigned int GL_MODULATE   
    unsigned int GL_NEAREST   
    unsigned int GL_REPEAT   
    unsigned int GL_CLAMP   
    unsigned int GL_S   
    unsigned int GL_T   
    unsigned int GL_R   
    unsigned int GL_Q   
    unsigned int GL_TEXTURE_GEN_R   
    unsigned int GL_TEXTURE_GEN_Q   
    unsigned int GL_VENDOR   
    unsigned int GL_RENDERER   
    unsigned int GL_VERSION   
    unsigned int GL_EXTENSIONS   
    unsigned int GL_NO_ERROR   
    unsigned int GL_INVALID_VALUE   
    unsigned int GL_INVALID_ENUM   
    unsigned int GL_INVALID_OPERATION   
    unsigned int GL_STACK_OVERFLOW   
    unsigned int GL_STACK_UNDERFLOW   
    unsigned int GL_OUT_OF_MEMORY   
    unsigned int GL_CURRENT_BIT   
    unsigned int GL_POINT_BIT   
    unsigned int GL_LINE_BIT   
    unsigned int GL_POLYGON_BIT   
    unsigned int GL_POLYGON_STIPPLE_BIT   
    unsigned int GL_PIXEL_MODE_BIT   
    unsigned int GL_LIGHTING_BIT   
    unsigned int GL_FOG_BIT   
    unsigned int GL_DEPTH_BUFFER_BIT   
    unsigned int GL_ACCUM_BUFFER_BIT   
    unsigned int GL_STENCIL_BUFFER_BIT   
    unsigned int GL_VIEWPORT_BIT   
    unsigned int GL_TRANSFORM_BIT   
    unsigned int GL_ENABLE_BIT   
    unsigned int GL_COLOR_BUFFER_BIT   
    unsigned int GL_HINT_BIT   
    unsigned int GL_EVAL_BIT   
    unsigned int GL_LIST_BIT   
    unsigned int GL_TEXTURE_BIT   
    unsigned int GL_SCISSOR_BIT   
    unsigned int GL_ALL_ATTRIB_BITS   
    unsigned int GL_PROXY_TEXTURE_1D   
    unsigned int GL_PROXY_TEXTURE_2D   
    unsigned int GL_TEXTURE_PRIORITY   
    unsigned int GL_TEXTURE_RESIDENT   
    unsigned int GL_TEXTURE_BINDING_1D   
    unsigned int GL_TEXTURE_BINDING_2D   
    unsigned int GL_TEXTURE_INTERNAL_FORMAT   
    unsigned int GL_ALPHA4   
    unsigned int GL_ALPHA8   
    unsigned int GL_ALPHA12   
    unsigned int GL_ALPHA16   
    unsigned int GL_LUMINANCE4   
    unsigned int GL_LUMINANCE8   
    unsigned int GL_LUMINANCE12   
    unsigned int GL_LUMINANCE16   
    unsigned int GL_LUMINANCE4_ALPHA4   
    unsigned int GL_LUMINANCE6_ALPHA2   
    unsigned int GL_LUMINANCE8_ALPHA8   
    unsigned int GL_LUMINANCE12_ALPHA4   
    unsigned int GL_LUMINANCE12_ALPHA12   
    unsigned int GL_LUMINANCE16_ALPHA16   
    unsigned int GL_INTENSITY   
    unsigned int GL_INTENSITY4   
    unsigned int GL_INTENSITY8   
    unsigned int GL_INTENSITY12   
    unsigned int GL_INTENSITY16   
    unsigned int GL_R3_G3_B2   
    unsigned int GL_RGB4   
    unsigned int GL_RGB5   
    unsigned int GL_RGB8   
    unsigned int GL_RGB10   
    unsigned int GL_RGB12   
    unsigned int GL_RGB16   
    unsigned int GL_RGBA2   
    unsigned int GL_RGBA4   
    unsigned int GL_RGB5_A1   
    unsigned int GL_RGBA8   
    unsigned int GL_RGB10_A2   
    unsigned int GL_RGBA12   
    unsigned int GL_RGBA16   
    unsigned int GL_CLIENT_PIXEL_STORE_BIT   
    unsigned int GL_CLIENT_VERTEX_ARRAY_BIT   
    unsigned int GL_ALL_CLIENT_ATTRIB_BITS   
    unsigned int GL_CLIENT_ALL_ATTRIB_BITS   
    unsigned int GL_TEXTURE_BINDING_3D   
    unsigned int GL_POST_COLOR_MATRIX_ALPHA_BIAS   
    void  glClearIndex( GLfloat c )   nogil
    void  glClearColor( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )   nogil
    void  glClear( GLbitfield mask )   nogil
    void  glIndexMask( GLuint mask )   nogil
    void  glColorMask( GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha )   nogil
    void  glAlphaFunc( GLenum func, GLclampf ref )   nogil
    void  glBlendFunc( GLenum sfactor, GLenum dfactor )   nogil
    void  glLogicOp( GLenum opcode )   nogil
    void  glCullFace( GLenum mode )   nogil
    void  glFrontFace( GLenum mode )   nogil
    void  glPointSize( GLfloat size )   nogil
    void  glLineWidth( GLfloat width )   nogil
    void  glLineStipple( GLint factor, GLushort pattern )   nogil
    void  glPolygonMode( GLenum face, GLenum mode )   nogil
    void  glPolygonOffset( GLfloat factor, GLfloat units )   nogil
    void  glPolygonStipple(  GLubyte *mask )   nogil
    void  glGetPolygonStipple( GLubyte *mask )   nogil
    void  glEdgeFlag( GLboolean flag )   nogil
    void  glEdgeFlagv(  GLboolean *flag )   nogil
    void  glScissor( GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    void  glClipPlane( GLenum plane,  GLdouble *equation )   nogil
    void  glGetClipPlane( GLenum plane, GLdouble *equation )   nogil
    void  glDrawBuffer( GLenum mode )   nogil
    void  glReadBuffer( GLenum mode )   nogil
    void  glEnable( GLenum cap )   nogil
    void  glDisable( GLenum cap )   nogil
    GLboolean  glIsEnabled( GLenum cap )   nogil
    void  glEnableClientState( GLenum cap )     nogil
    void  glDisableClientState( GLenum cap )     nogil
    void  glGetBooleanv( GLenum pname, GLboolean *params )   nogil
    void  glGetDoublev( GLenum pname, GLdouble *params )   nogil
    void  glGetFloatv( GLenum pname, GLfloat *params )   nogil
    void  glGetIntegerv( GLenum pname, GLint *params )   nogil
    void  glPushAttrib( GLbitfield mask )   nogil
    void  glPopAttrib()   nogil
    void  glPushClientAttrib( GLbitfield mask )     nogil
    void  glPopClientAttrib()     nogil
    GLint  glRenderMode( GLenum mode )   nogil
    GLenum  glGetError()   nogil
    GLubyte*  glGetString( GLenum name )   nogil
    void  glFinish()   nogil
    void  glFlush()   nogil
    void  glHint( GLenum target, GLenum mode )   nogil
    void  glClearDepth( GLclampd depth )   nogil
    void  glDepthFunc( GLenum func )   nogil
    void  glDepthMask( GLboolean flag )   nogil
    void  glDepthRange( GLclampd near_val, GLclampd far_val )   nogil
    void  glClearAccum( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )   nogil
    void  glAccum( GLenum op, GLfloat value )   nogil
    void  glMatrixMode( GLenum mode )   nogil
    void  glOrtho( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val )   nogil
    void  glFrustum( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val )   nogil
    void  glViewport( GLint x, GLint y, GLsizei width, GLsizei height )   nogil
    void  glPushMatrix()   nogil
    void  glPopMatrix()   nogil
    void  glLoadIdentity()   nogil
    void  glLoadMatrixd(  GLdouble *m )   nogil
    void  glLoadMatrixf(  GLfloat *m )   nogil
    void  glMultMatrixd(  GLdouble *m )   nogil
    void  glMultMatrixf(  GLfloat *m )   nogil
    void  glRotated( GLdouble angle, GLdouble x, GLdouble y, GLdouble z )   nogil
    void  glRotatef( GLfloat angle, GLfloat x, GLfloat y, GLfloat z )   nogil
    void  glScaled( GLdouble x, GLdouble y, GLdouble z )   nogil
    void  glScalef( GLfloat x, GLfloat y, GLfloat z )   nogil
    void  glTranslated( GLdouble x, GLdouble y, GLdouble z )   nogil
    void  glTranslatef( GLfloat x, GLfloat y, GLfloat z )   nogil
    GLboolean  glIsList( GLuint _list )   nogil
    void  glDeleteLists( GLuint _list, GLsizei _range )   nogil
    GLuint  glGenLists( GLsizei _range )   nogil
    void  glNewList( GLuint _list, GLenum mode )   nogil
    void  glEndList()   nogil
    void  glCallList( GLuint _list )   nogil
    void  glCallLists( GLsizei n, GLenum _type,  GLvoid *lists )   nogil
    void  glListBase( GLuint base )   nogil
    void  glBegin( GLenum mode )   nogil
    void  glEnd()   nogil
    void  glVertex2d( GLdouble x, GLdouble y )   nogil
    void  glVertex2f( GLfloat x, GLfloat y )   nogil
    void  glVertex2i( GLint x, GLint y )   nogil
    void  glVertex2s( GLshort x, GLshort y )   nogil
    void  glVertex3d( GLdouble x, GLdouble y, GLdouble z )   nogil
    void  glVertex3f( GLfloat x, GLfloat y, GLfloat z )   nogil
    void  glVertex3i( GLint x, GLint y, GLint z )   nogil
    void  glVertex3s( GLshort x, GLshort y, GLshort z )   nogil
    void  glVertex4d( GLdouble x, GLdouble y, GLdouble z, GLdouble w )   nogil
    void  glVertex4f( GLfloat x, GLfloat y, GLfloat z, GLfloat w )   nogil
    void  glVertex4i( GLint x, GLint y, GLint z, GLint w )   nogil
    void  glVertex4s( GLshort x, GLshort y, GLshort z, GLshort w )   nogil
    void  glVertex2dv(  GLdouble *v )   nogil
    void  glVertex2fv(  GLfloat *v )   nogil
    void  glVertex2iv(  GLint *v )   nogil
    void  glVertex2sv(  GLshort *v )   nogil
    void  glVertex3dv(  GLdouble *v )   nogil
    void  glVertex3fv(  GLfloat *v )   nogil
    void  glVertex3iv(  GLint *v )   nogil
    void  glVertex3sv(  GLshort *v )   nogil
    void  glVertex4dv(  GLdouble *v )   nogil
    void  glVertex4fv(  GLfloat *v )   nogil
    void  glVertex4iv(  GLint *v )   nogil
    void  glVertex4sv(  GLshort *v )   nogil
    void  glNormal3b( GLbyte nx, GLbyte ny, GLbyte nz )   nogil
    void  glNormal3d( GLdouble nx, GLdouble ny, GLdouble nz )   nogil
    void  glNormal3f( GLfloat nx, GLfloat ny, GLfloat nz )   nogil
    void  glNormal3i( GLint nx, GLint ny, GLint nz )   nogil
    void  glNormal3s( GLshort nx, GLshort ny, GLshort nz )   nogil
    void  glNormal3bv(  GLbyte *v )   nogil
    void  glNormal3dv(  GLdouble *v )   nogil
    void  glNormal3fv(  GLfloat *v )   nogil
    void  glNormal3iv(  GLint *v )   nogil
    void  glNormal3sv(  GLshort *v )   nogil
    void  glIndexd( GLdouble c )   nogil
    void  glIndexf( GLfloat c )   nogil
    void  glIndexi( GLint c )   nogil
    void  glIndexs( GLshort c )   nogil
    void  glIndexub( GLubyte c )     nogil
    void  glIndexdv(  GLdouble *c )   nogil
    void  glIndexfv(  GLfloat *c )   nogil
    void  glIndexiv(  GLint *c )   nogil
    void  glIndexsv(  GLshort *c )   nogil
    void  glIndexubv(  GLubyte *c )     nogil
    void  glColor3b( GLbyte red, GLbyte green, GLbyte blue )   nogil
    void  glColor3d( GLdouble red, GLdouble green, GLdouble blue )   nogil
    void  glColor3f( GLfloat red, GLfloat green, GLfloat blue )   nogil
    void  glColor3i( GLint red, GLint green, GLint blue )   nogil
    void  glColor3s( GLshort red, GLshort green, GLshort blue )   nogil
    void  glColor3ub( GLubyte red, GLubyte green, GLubyte blue )   nogil
    void  glColor3ui( GLuint red, GLuint green, GLuint blue )   nogil
    void  glColor3us( GLushort red, GLushort green, GLushort blue )   nogil
    void  glColor4b( GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha )   nogil
    void  glColor4d( GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha )   nogil
    void  glColor4f( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )   nogil
    void  glColor4i( GLint red, GLint green, GLint blue, GLint alpha )   nogil
    void  glColor4s( GLshort red, GLshort green, GLshort blue, GLshort alpha )   nogil
    void  glColor4ub( GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha )   nogil
    void  glColor4ui( GLuint red, GLuint green, GLuint blue, GLuint alpha )   nogil
    void  glColor4us( GLushort red, GLushort green, GLushort blue, GLushort alpha )   nogil
    void  glColor3bv(  GLbyte *v )   nogil
    void  glColor3dv(  GLdouble *v )   nogil
    void  glColor3fv(  GLfloat *v )   nogil
    void  glColor3iv(  GLint *v )   nogil
    void  glColor3sv(  GLshort *v )   nogil
    void  glColor3ubv(  GLubyte *v )   nogil
    void  glColor3uiv(  GLuint *v )   nogil
    void  glColor3usv(  GLushort *v )   nogil
    void  glColor4bv(  GLbyte *v )   nogil
    void  glColor4dv(  GLdouble *v )   nogil
    void  glColor4fv(  GLfloat *v )   nogil
    void  glColor4iv(  GLint *v )   nogil
    void  glColor4sv(  GLshort *v )   nogil
    void  glColor4ubv(  GLubyte *v )   nogil
    void  glColor4uiv(  GLuint *v )   nogil
    void  glColor4usv(  GLushort *v )   nogil
    void  glTexCoord1d( GLdouble s )   nogil
    void  glTexCoord1f( GLfloat s )   nogil
    void  glTexCoord1i( GLint s )   nogil
    void  glTexCoord1s( GLshort s )   nogil
    void  glTexCoord2d( GLdouble s, GLdouble t )   nogil
    void  glTexCoord2f( GLfloat s, GLfloat t )   nogil
    void  glTexCoord2i( GLint s, GLint t )   nogil
    void  glTexCoord2s( GLshort s, GLshort t )   nogil
    void  glTexCoord3d( GLdouble s, GLdouble t, GLdouble r )   nogil
    void  glTexCoord3f( GLfloat s, GLfloat t, GLfloat r )   nogil
    void  glTexCoord3i( GLint s, GLint t, GLint r )   nogil
    void  glTexCoord3s( GLshort s, GLshort t, GLshort r )   nogil
    void  glTexCoord4d( GLdouble s, GLdouble t, GLdouble r, GLdouble q )   nogil
    void  glTexCoord4f( GLfloat s, GLfloat t, GLfloat r, GLfloat q )   nogil
    void  glTexCoord4i( GLint s, GLint t, GLint r, GLint q )   nogil
    void  glTexCoord4s( GLshort s, GLshort t, GLshort r, GLshort q )   nogil
    void  glTexCoord1dv(  GLdouble *v )   nogil
    void  glTexCoord1fv(  GLfloat *v )   nogil
    void  glTexCoord1iv(  GLint *v )   nogil
    void  glTexCoord1sv(  GLshort *v )   nogil
    void  glTexCoord2dv(  GLdouble *v )   nogil
    void  glTexCoord2fv(  GLfloat *v )   nogil
    void  glTexCoord2iv(  GLint *v )   nogil
    void  glTexCoord2sv(  GLshort *v )   nogil
    void  glTexCoord3dv(  GLdouble *v )   nogil
    void  glTexCoord3fv(  GLfloat *v )   nogil
    void  glTexCoord3iv(  GLint *v )   nogil
    void  glTexCoord3sv(  GLshort *v )   nogil
    void  glTexCoord4dv(  GLdouble *v )   nogil
    void  glTexCoord4fv(  GLfloat *v )   nogil
    void  glTexCoord4iv(  GLint *v )   nogil
    void  glTexCoord4sv(  GLshort *v )   nogil
    void  glRasterPos2d( GLdouble x, GLdouble y )   nogil
    void  glRasterPos2f( GLfloat x, GLfloat y )   nogil
    void  glRasterPos2i( GLint x, GLint y )   nogil
    void  glRasterPos2s( GLshort x, GLshort y )   nogil
    void  glRasterPos3d( GLdouble x, GLdouble y, GLdouble z )   nogil
    void  glRasterPos3f( GLfloat x, GLfloat y, GLfloat z )   nogil
    void  glRasterPos3i( GLint x, GLint y, GLint z )   nogil
    void  glRasterPos3s( GLshort x, GLshort y, GLshort z )   nogil
    void  glRasterPos4d( GLdouble x, GLdouble y, GLdouble z, GLdouble w )   nogil
    void  glRasterPos4f( GLfloat x, GLfloat y, GLfloat z, GLfloat w )   nogil
    void  glRasterPos4i( GLint x, GLint y, GLint z, GLint w )   nogil
    void  glRasterPos4s( GLshort x, GLshort y, GLshort z, GLshort w )   nogil
    void  glRasterPos2dv(  GLdouble *v )   nogil
    void  glRasterPos2fv(  GLfloat *v )   nogil
    void  glRasterPos2iv(  GLint *v )   nogil
    void  glRasterPos2sv(  GLshort *v )   nogil
    void  glRasterPos3dv(  GLdouble *v )   nogil
    void  glRasterPos3fv(  GLfloat *v )   nogil
    void  glRasterPos3iv(  GLint *v )   nogil
    void  glRasterPos3sv(  GLshort *v )   nogil
    void  glRasterPos4dv(  GLdouble *v )   nogil
    void  glRasterPos4fv(  GLfloat *v )   nogil
    void  glRasterPos4iv(  GLint *v )   nogil
    void  glRasterPos4sv(  GLshort *v )   nogil
    void  glRectd( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 )   nogil
    void  glRectf( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 )   nogil
    void  glRecti( GLint x1, GLint y1, GLint x2, GLint y2 )   nogil
    void  glRects( GLshort x1, GLshort y1, GLshort x2, GLshort y2 )   nogil
    void  glRectdv(  GLdouble *v1,  GLdouble *v2 )   nogil
    void  glRectfv(  GLfloat *v1,  GLfloat *v2 )   nogil
    void  glRectiv(  GLint *v1,  GLint *v2 )   nogil
    void  glRectsv(  GLshort *v1,  GLshort *v2 )   nogil
    void  glShadeModel( GLenum mode )   nogil
    void  glLightf( GLenum light, GLenum pname, GLfloat param )   nogil
    void  glLighti( GLenum light, GLenum pname, GLint param )   nogil
    void  glLightfv( GLenum light, GLenum pname,  GLfloat *params )   nogil
    void  glLightiv( GLenum light, GLenum pname,  GLint *params )   nogil
    void  glGetLightfv( GLenum light, GLenum pname, GLfloat *params )   nogil
    void  glGetLightiv( GLenum light, GLenum pname, GLint *params )   nogil
    void  glLightModelf( GLenum pname, GLfloat param )   nogil
    void  glLightModeli( GLenum pname, GLint param )   nogil
    void  glLightModelfv( GLenum pname,  GLfloat *params )   nogil
    void  glLightModeliv( GLenum pname,  GLint *params )   nogil
    void  glMaterialf( GLenum face, GLenum pname, GLfloat param )   nogil
    void  glMateriali( GLenum face, GLenum pname, GLint param )   nogil
    void  glMaterialfv( GLenum face, GLenum pname,  GLfloat *params )   nogil
    void  glMaterialiv( GLenum face, GLenum pname,  GLint *params )   nogil
    void  glGetMaterialfv( GLenum face, GLenum pname, GLfloat *params )   nogil
    void  glGetMaterialiv( GLenum face, GLenum pname, GLint *params )   nogil
    void  glColorMaterial( GLenum face, GLenum mode )   nogil
    void  glPixelZoom( GLfloat xfactor, GLfloat yfactor )   nogil
    void  glPixelStoref( GLenum pname, GLfloat param )   nogil
    void  glPixelStorei( GLenum pname, GLint param )   nogil
    void  glPixelTransferf( GLenum pname, GLfloat param )   nogil
    void  glPixelTransferi( GLenum pname, GLint param )   nogil
    void  glPixelMapfv( GLenum _map, GLint mapsize,  GLfloat *values )   nogil
    void  glPixelMapuiv( GLenum _map, GLint mapsize,  GLuint *values )   nogil
    void  glPixelMapusv( GLenum _map, GLint mapsize,  GLushort *values )   nogil
    void  glGetPixelMapfv( GLenum _map, GLfloat *values )   nogil
    void  glGetPixelMapuiv( GLenum _map, GLuint *values )   nogil
    void  glGetPixelMapusv( GLenum _map, GLushort *values )   nogil
    void  glBitmap( GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove,  GLubyte *bitmap )   nogil
    void  glReadPixels( GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum _type, GLvoid *pixels )   nogil
    void  glDrawPixels( GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glCopyPixels( GLint x, GLint y, GLsizei width, GLsizei height, GLenum _type )   nogil
    void  glStencilFunc( GLenum func, GLint ref, GLuint mask )   nogil
    void  glStencilMask( GLuint mask )   nogil
    void  glStencilOp( GLenum fail, GLenum zfail, GLenum zpass )   nogil
    void  glClearStencil( GLint s )   nogil
    void  glTexGend( GLenum coord, GLenum pname, GLdouble param )   nogil
    void  glTexGenf( GLenum coord, GLenum pname, GLfloat param )   nogil
    void  glTexGeni( GLenum coord, GLenum pname, GLint param )   nogil
    void  glTexGendv( GLenum coord, GLenum pname,  GLdouble *params )   nogil
    void  glTexGenfv( GLenum coord, GLenum pname,  GLfloat *params )   nogil
    void  glTexGeniv( GLenum coord, GLenum pname,  GLint *params )   nogil
    void  glGetTexGendv( GLenum coord, GLenum pname, GLdouble *params )   nogil
    void  glGetTexGenfv( GLenum coord, GLenum pname, GLfloat *params )   nogil
    void  glGetTexGeniv( GLenum coord, GLenum pname, GLint *params )   nogil
    void  glTexEnvf( GLenum target, GLenum pname, GLfloat param )   nogil
    void  glTexEnvi( GLenum target, GLenum pname, GLint param )   nogil
    void  glTexEnvfv( GLenum target, GLenum pname,  GLfloat *params )   nogil
    void  glTexEnviv( GLenum target, GLenum pname,  GLint *params )   nogil
    void  glGetTexEnvfv( GLenum target, GLenum pname, GLfloat *params )   nogil
    void  glGetTexEnviv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glTexParameterf( GLenum target, GLenum pname, GLfloat param )   nogil
    void  glTexParameteri( GLenum target, GLenum pname, GLint param )   nogil
    void  glTexParameterfv( GLenum target, GLenum pname,  GLfloat *params )   nogil
    void  glTexParameteriv( GLenum target, GLenum pname,  GLint *params )   nogil
    void  glGetTexParameterfv( GLenum target, GLenum pname, GLfloat *params)   nogil
    void  glGetTexParameteriv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glGetTexLevelParameterfv( GLenum target, GLint level, GLenum pname, GLfloat *params )   nogil
    void  glGetTexLevelParameteriv( GLenum target, GLint level, GLenum pname, GLint *params )   nogil
    void  glTexImage1D( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glTexImage2D( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glGetTexImage( GLenum target, GLint level, GLenum format, GLenum _type, GLvoid *pixels )   nogil
    void  glMap1d( GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order,  GLdouble *points )   nogil
    void  glMap1f( GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order,  GLfloat *points )   nogil
    void  glMap2d( GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder,  GLdouble *points )   nogil
    void  glMap2f( GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder,  GLfloat *points )   nogil
    void  glGetMapdv( GLenum target, GLenum query, GLdouble *v )   nogil
    void  glGetMapfv( GLenum target, GLenum query, GLfloat *v )   nogil
    void  glGetMapiv( GLenum target, GLenum query, GLint *v )   nogil
    void  glEvalCoord1d( GLdouble u )   nogil
    void  glEvalCoord1f( GLfloat u )   nogil
    void  glEvalCoord1dv(  GLdouble *u )   nogil
    void  glEvalCoord1fv(  GLfloat *u )   nogil
    void  glEvalCoord2d( GLdouble u, GLdouble v )   nogil
    void  glEvalCoord2f( GLfloat u, GLfloat v )   nogil
    void  glEvalCoord2dv(  GLdouble *u )   nogil
    void  glEvalCoord2fv(  GLfloat *u )   nogil
    void  glMapGrid1d( GLint un, GLdouble u1, GLdouble u2 )   nogil
    void  glMapGrid1f( GLint un, GLfloat u1, GLfloat u2 )   nogil
    void  glMapGrid2d( GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2 )   nogil
    void  glMapGrid2f( GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2 )   nogil
    void  glEvalPoint1( GLint i )   nogil
    void  glEvalPoint2( GLint i, GLint j )   nogil
    void  glEvalMesh1( GLenum mode, GLint i1, GLint i2 )   nogil
    void  glEvalMesh2( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 )   nogil
    void  glFogf( GLenum pname, GLfloat param )   nogil
    void  glFogi( GLenum pname, GLint param )   nogil
    void  glFogfv( GLenum pname,  GLfloat *params )   nogil
    void  glFogiv( GLenum pname,  GLint *params )   nogil
    void  glFeedbackBuffer( GLsizei size, GLenum _type, GLfloat *_buffer )   nogil
    void  glPassThrough( GLfloat token )   nogil
    void  glSelectBuffer( GLsizei size, GLuint *_buffer )   nogil
    void  glInitNames()   nogil
    void  glLoadName( GLuint name )   nogil
    void  glPushName( GLuint name )   nogil
    void  glPopName()   nogil
    void  glGenTextures( GLsizei n, GLuint *textures )   nogil
    void  glDeleteTextures( GLsizei n,  GLuint *textures)   nogil
    void  glBindTexture( GLenum target, GLuint texture )   nogil
    void  glPrioritizeTextures( GLsizei n,  GLuint *textures,  GLclampf *priorities )   nogil
    GLboolean  glAreTexturesResident( GLsizei n,  GLuint *textures, GLboolean *residences )   nogil
    GLboolean  glIsTexture( GLuint texture )   nogil
    void  glTexSubImage1D( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glTexSubImage2D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glCopyTexImage1D( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border )   nogil
    void  glCopyTexImage2D( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border )   nogil
    void  glCopyTexSubImage1D( GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width )   nogil
    void  glCopyTexSubImage2D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height )   nogil
    void  glVertexPointer( GLint size, GLenum _type, GLsizei stride,  GLvoid *ptr )   nogil
    void  glNormalPointer( GLenum _type, GLsizei stride,  GLvoid *ptr )   nogil
    void  glColorPointer( GLint size, GLenum _type, GLsizei stride,  GLvoid *ptr )   nogil
    void  glIndexPointer( GLenum _type, GLsizei stride,  GLvoid *ptr )   nogil
    void  glTexCoordPointer( GLint size, GLenum _type, GLsizei stride,  GLvoid *ptr )   nogil
    void  glEdgeFlagPointer( GLsizei stride,  GLvoid *ptr )   nogil
    void  glGetPointerv( GLenum pname, GLvoid **params )   nogil
    void  glArrayElement( GLint i )   nogil
    void  glDrawArrays( GLenum mode, GLint first, GLsizei count )   nogil
    void  glDrawElements( GLenum mode, GLsizei count, GLenum _type,  GLvoid *indices )   nogil
    void  glInterleavedArrays( GLenum format, GLsizei stride,  GLvoid *pointer )   nogil
    void  glDrawRangeElements( GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum _type,  GLvoid *indices )   nogil
    void  glTexImage3D( GLenum target, GLint level, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum _type,  GLvoid *pixels )   nogil
    void  glTexSubImage3D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    void  glCopyTexSubImage3D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height )   nogil
    void  glColorTable( GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *table )   nogil
    void  glColorSubTable( GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum _type,  GLvoid *data )   nogil
    void  glColorTableParameteriv(GLenum target, GLenum pname,  GLint *params)   nogil
    void  glColorTableParameterfv(GLenum target, GLenum pname,  GLfloat *params)   nogil
    void  glCopyColorSubTable( GLenum target, GLsizei start, GLint x, GLint y, GLsizei width )   nogil
    void  glCopyColorTable( GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width )   nogil
    void  glGetColorTable( GLenum target, GLenum format, GLenum _type, GLvoid *table )   nogil
    void  glGetColorTableParameterfv( GLenum target, GLenum pname, GLfloat *params )   nogil
    void  glGetColorTableParameteriv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glBlendEquation( GLenum mode )   nogil
    void  glBlendColor( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )   nogil
    void  glHistogram( GLenum target, GLsizei width, GLenum internalformat, GLboolean sink )   nogil
    void  glResetHistogram( GLenum target )   nogil
    void  glGetHistogram( GLenum target, GLboolean reset, GLenum format, GLenum _type, GLvoid *values )   nogil
    void  glGetHistogramParameterfv( GLenum target, GLenum pname, GLfloat *params )   nogil
    void  glGetHistogramParameteriv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glMinmax( GLenum target, GLenum internalformat, GLboolean sink )   nogil
    void  glResetMinmax( GLenum target )   nogil
    void  glGetMinmax( GLenum target, GLboolean reset, GLenum format, GLenum types, GLvoid *values )   nogil
    void  glGetMinmaxParameterfv( GLenum target, GLenum pname, GLfloat *params )   nogil
    void  glGetMinmaxParameteriv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glConvolutionFilter1D( GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *image )   nogil
    void  glConvolutionFilter2D( GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *image )   nogil
    void  glConvolutionParameterf( GLenum target, GLenum pname, GLfloat params )   nogil
    void  glConvolutionParameterfv( GLenum target, GLenum pname,  GLfloat *params )   nogil
    void  glConvolutionParameteri( GLenum target, GLenum pname, GLint params )   nogil
    void  glConvolutionParameteriv( GLenum target, GLenum pname,  GLint *params )   nogil
    void  glCopyConvolutionFilter1D( GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width )   nogil
    void  glCopyConvolutionFilter2D( GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    void  glGetConvolutionFilter( GLenum target, GLenum format, GLenum _type, GLvoid *image )   nogil
    void  glGetConvolutionParameterfv( GLenum target, GLenum pname, GLfloat *params )   nogil
    void  glGetConvolutionParameteriv( GLenum target, GLenum pname, GLint *params )   nogil
    void  glSeparableFilter2D( GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *row,  GLvoid *column )   nogil
    void  glGetSeparableFilter( GLenum target, GLenum format, GLenum _type, GLvoid *row, GLvoid *column, GLvoid *span )   nogil
    #void  glActiveTexture( GLenum texture )   nogil
    # void  glClientActiveTexture( GLenum texture )   nogil
    void  glCompressedTexImage1D( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize,  GLvoid *data )   nogil
    void  glCompressedTexImage2D( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize,  GLvoid *data )   nogil
    void  glCompressedTexImage3D( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize,  GLvoid *data )   nogil
    void  glCompressedTexSubImage1D( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize,  GLvoid *data )   nogil
    void  glCompressedTexSubImage2D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize,  GLvoid *data )   nogil
    void  glCompressedTexSubImage3D( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize,  GLvoid *data )   nogil
    void  glGetCompressedTexImage( GLenum target, GLint lod, GLvoid *img )   nogil
    void  glMultiTexCoord1d( GLenum target, GLdouble s )   nogil
    void  glMultiTexCoord1dv( GLenum target,  GLdouble *v )   nogil
    void  glMultiTexCoord1f( GLenum target, GLfloat s )   nogil
    void  glMultiTexCoord1fv( GLenum target,  GLfloat *v )   nogil
    void  glMultiTexCoord1i( GLenum target, GLint s )   nogil
    void  glMultiTexCoord1iv( GLenum target,  GLint *v )   nogil
    void  glMultiTexCoord1s( GLenum target, GLshort s )   nogil
    void  glMultiTexCoord1sv( GLenum target,  GLshort *v )   nogil
    void  glMultiTexCoord2d( GLenum target, GLdouble s, GLdouble t )   nogil
    void  glMultiTexCoord2dv( GLenum target,  GLdouble *v )   nogil
    # void  glMultiTexCoord2f( GLenum target, GLfloat s, GLfloat t )   nogil
    void  glMultiTexCoord2fv( GLenum target,  GLfloat *v )   nogil
    void  glMultiTexCoord2i( GLenum target, GLint s, GLint t )   nogil
    void  glMultiTexCoord2iv( GLenum target,  GLint *v )   nogil
    void  glMultiTexCoord2s( GLenum target, GLshort s, GLshort t )   nogil
    void  glMultiTexCoord2sv( GLenum target,  GLshort *v )   nogil
    void  glMultiTexCoord3d( GLenum target, GLdouble s, GLdouble t, GLdouble r )   nogil
    void  glMultiTexCoord3dv( GLenum target,  GLdouble *v )   nogil
    void  glMultiTexCoord3f( GLenum target, GLfloat s, GLfloat t, GLfloat r )   nogil
    void  glMultiTexCoord3fv( GLenum target,  GLfloat *v )   nogil
    void  glMultiTexCoord3i( GLenum target, GLint s, GLint t, GLint r )   nogil
    void  glMultiTexCoord3iv( GLenum target,  GLint *v )   nogil
    void  glMultiTexCoord3s( GLenum target, GLshort s, GLshort t, GLshort r )   nogil
    void  glMultiTexCoord3sv( GLenum target,  GLshort *v )   nogil
    void  glMultiTexCoord4d( GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q )   nogil
    void  glMultiTexCoord4dv( GLenum target,  GLdouble *v )   nogil
    void  glMultiTexCoord4f( GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q )   nogil
    void  glMultiTexCoord4fv( GLenum target,  GLfloat *v )   nogil
    void  glMultiTexCoord4i( GLenum target, GLint s, GLint t, GLint r, GLint q )   nogil
    void  glMultiTexCoord4iv( GLenum target,  GLint *v )   nogil
    void  glMultiTexCoord4s( GLenum target, GLshort s, GLshort t, GLshort r, GLshort q )   nogil
    void  glMultiTexCoord4sv( GLenum target,  GLshort *v )   nogil
    void  glLoadTransposeMatrixd(  GLdouble m[16] )   nogil
    void  glLoadTransposeMatrixf(  GLfloat m[16] )   nogil
    void  glMultTransposeMatrixd(  GLdouble m[16] )   nogil
    void  glMultTransposeMatrixf(  GLfloat m[16] )   nogil
    void  glSampleCoverage( GLclampf value, GLboolean invert )   nogil
    void  glSamplePass( GLenum _pass )   nogil
    unsigned int GLU_FALSE   
    unsigned int GLU_TRUE   
    unsigned int GLU_VERSION_1_1   
    unsigned int GLU_VERSION_1_2   
    unsigned int GLU_VERSION   
    unsigned int GLU_EXTENSIONS   
    unsigned int GLU_INVALID_ENUM   
    unsigned int GLU_INVALID_VALUE   
    unsigned int GLU_OUT_OF_MEMORY   
    unsigned int GLU_INVALID_OPERATION   
    unsigned int GLU_OUTLINE_POLYGON   
    unsigned int GLU_OUTLINE_PATCH   
    unsigned int GLU_NURBS_ERROR1   
    unsigned int GLU_NURBS_ERROR2   
    unsigned int GLU_NURBS_ERROR3   
    unsigned int GLU_NURBS_ERROR4   
    unsigned int GLU_NURBS_ERROR5   
    unsigned int GLU_NURBS_ERROR6   
    unsigned int GLU_NURBS_ERROR7   
    unsigned int GLU_NURBS_ERROR8   
    unsigned int GLU_NURBS_ERROR9   
    unsigned int GLU_NURBS_ERROR10   
    unsigned int GLU_NURBS_ERROR11   
    unsigned int GLU_NURBS_ERROR12   
    unsigned int GLU_NURBS_ERROR13   
    unsigned int GLU_NURBS_ERROR14   
    unsigned int GLU_NURBS_ERROR15   
    unsigned int GLU_NURBS_ERROR16   
    unsigned int GLU_NURBS_ERROR17   
    unsigned int GLU_NURBS_ERROR18   
    unsigned int GLU_NURBS_ERROR19   
    unsigned int GLU_NURBS_ERROR20   
    unsigned int GLU_NURBS_ERROR21   
    unsigned int GLU_NURBS_ERROR22   
    unsigned int GLU_NURBS_ERROR23   
    unsigned int GLU_NURBS_ERROR24   
    unsigned int GLU_NURBS_ERROR25   
    unsigned int GLU_NURBS_ERROR26   
    unsigned int GLU_NURBS_ERROR27   
    unsigned int GLU_NURBS_ERROR28   
    unsigned int GLU_NURBS_ERROR29   
    unsigned int GLU_NURBS_ERROR30   
    unsigned int GLU_NURBS_ERROR31   
    unsigned int GLU_NURBS_ERROR32   
    unsigned int GLU_NURBS_ERROR33   
    unsigned int GLU_NURBS_ERROR34   
    unsigned int GLU_NURBS_ERROR35   
    unsigned int GLU_NURBS_ERROR36   
    unsigned int GLU_NURBS_ERROR37   
    unsigned int GLU_AUTO_LOAD_MATRIX   
    unsigned int GLU_CULLING   
    unsigned int GLU_SAMPLING_TOLERANCE   
    unsigned int GLU_DISPLAY_MODE   
    unsigned int GLU_PARAMETRIC_TOLERANCE   
    unsigned int GLU_SAMPLING_METHOD   
    unsigned int GLU_U_STEP   
    unsigned int GLU_V_STEP   
    unsigned int GLU_PATH_LENGTH   
    unsigned int GLU_PARAMETRIC_ERROR   
    unsigned int GLU_DOMAIN_DISTANCE   
    unsigned int GLU_MAP1_TRIM_2   
    unsigned int GLU_MAP1_TRIM_3   
    unsigned int GLU_POINT   
    unsigned int GLU_LINE   
    unsigned int GLU_FILL   
    unsigned int GLU_SILHOUETTE   
    unsigned int GLU_ERROR   
    unsigned int GLU_SMOOTH   
    unsigned int GLU_FLAT   
    unsigned int GLU_NONE   
    unsigned int GLU_OUTSIDE   
    unsigned int GLU_INSIDE   
    unsigned int GLU_TESS_BEGIN   
    unsigned int GLU_BEGIN   
    unsigned int GLU_TESS_VERTEX   
    unsigned int GLU_VERTEX   
    unsigned int GLU_TESS_END   
    unsigned int GLU_END   
    unsigned int GLU_TESS_ERROR   
    unsigned int GLU_TESS_EDGE_FLAG   
    unsigned int GLU_EDGE_FLAG   
    unsigned int GLU_TESS_COMBINE   
    unsigned int GLU_TESS_BEGIN_DATA   
    unsigned int GLU_TESS_VERTEX_DATA   
    unsigned int GLU_TESS_END_DATA   
    unsigned int GLU_TESS_ERROR_DATA   
    unsigned int GLU_TESS_EDGE_FLAG_DATA   
    unsigned int GLU_TESS_COMBINE_DATA   
    unsigned int GLU_CW   
    unsigned int GLU_CCW   
    unsigned int GLU_INTERIOR   
    unsigned int GLU_EXTERIOR   
    unsigned int GLU_UNKNOWN   
    unsigned int GLU_TESS_WINDING_RULE   
    unsigned int GLU_TESS_BOUNDARY_ONLY   
    unsigned int GLU_TESS_TOLERANCE   
    unsigned int GLU_TESS_ERROR1   
    unsigned int GLU_TESS_ERROR2   
    unsigned int GLU_TESS_ERROR3   
    unsigned int GLU_TESS_ERROR4   
    unsigned int GLU_TESS_ERROR5   
    unsigned int GLU_TESS_ERROR6   
    unsigned int GLU_TESS_ERROR7   
    unsigned int GLU_TESS_ERROR8   
    unsigned int GLU_TESS_MISSING_BEGIN_POLYGON   
    unsigned int GLU_TESS_MISSING_BEGIN_CONTOUR   
    unsigned int GLU_TESS_MISSING_END_POLYGON   
    unsigned int GLU_TESS_MISSING_END_CONTOUR   
    unsigned int GLU_TESS_COORD_TOO_LARGE   
    unsigned int GLU_TESS_NEED_COMBINE_CALLBACK   
    unsigned int GLU_TESS_WINDING_ODD   
    unsigned int GLU_TESS_WINDING_NONZERO   
    unsigned int GLU_TESS_WINDING_POSITIVE   
    unsigned int GLU_TESS_WINDING_NEGATIVE   
    unsigned int GLU_TESS_WINDING_ABS_GEQ_TWO   
    unsigned int GLU_INCOMPATIBLE_GL_VERSION   
    ctypedef   struct GLUnurbs:
                   pass  
    ctypedef   struct GLUquadric:
                   pass   
    ctypedef   struct GLUtesselator:
                   pass  
    ctypedef   GLUnurbs GLUnurbsObj   
    ctypedef   GLUquadric GLUquadricObj   
    ctypedef   GLUtesselator GLUtesselatorObj   
    ctypedef   GLUtesselator GLUtriangulatorObj   
    double GLU_TESS_MAX_COORD   
    ctypedef   void ( *_GLUfuncptr)()   nogil
    void  gluBeginCurve (GLUnurbs* nurb)   nogil
    void  gluBeginPolygon (GLUtesselator* tess)   nogil
    void  gluBeginSurface (GLUnurbs* nurb)   nogil
    void  gluBeginTrim (GLUnurbs* nurb)   nogil
    GLint  gluBuild1DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum _type,  void *data)   nogil
    GLint  gluBuild2DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  void *data)   nogil
    void  gluCylinder (GLUquadric* quad, GLdouble base, GLdouble top, GLdouble height, GLint slices, GLint stacks)   nogil
    void  gluDeleteNurbsRenderer (GLUnurbs* nurb)   nogil
    void  gluDeleteQuadric (GLUquadric* quad)   nogil
    void  gluDeleteTess (GLUtesselator* tess)   nogil
    void  gluDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops)   nogil
    void  gluEndCurve (GLUnurbs* nurb)   nogil
    void  gluEndPolygon (GLUtesselator* tess)   nogil
    void  gluEndSurface (GLUnurbs* nurb)   nogil
    void  gluEndTrim (GLUnurbs* nurb)   nogil
    GLubyte *  gluErrorString (GLenum error)   nogil
    wchar_t *  gluErrorUnicodeStringEXT (GLenum error)   nogil
    void  gluGetNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat* data)   nogil
    GLubyte *  gluGetString (GLenum name)   nogil
    void  gluGetTessProperty (GLUtesselator* tess, GLenum which, GLdouble* data)   nogil
    void  gluLoadSamplingMatrices (GLUnurbs* nurb,  GLfloat *model,  GLfloat *perspective,  GLint *view)   nogil
    void  gluLookAt (GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ)   nogil
    GLUnurbs*  gluNewNurbsRenderer ()   nogil
    GLUquadric*  gluNewQuadric ()   nogil
    GLUtesselator*  gluNewTess ()   nogil
    void  gluNextContour (GLUtesselator* tess, GLenum _type)   nogil
    void  gluNurbsCallback (GLUnurbs* nurb, GLenum which, _GLUfuncptr CallBackFunc)   nogil
    void  gluNurbsCurve (GLUnurbs* nurb, GLint knotCount, GLfloat *knots, GLint stride, GLfloat *control, GLint order, GLenum _type)   nogil
    void  gluNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat value)   nogil
    void  gluNurbsSurface (GLUnurbs* nurb, GLint sKnotCount, GLfloat* sKnots, GLint tKnotCount, GLfloat* tKnots, GLint sStride, GLint tStride, GLfloat* control, GLint sOrder, GLint tOrder, GLenum _type)   nogil
    void  gluOrtho2D (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top)   nogil
    void  gluPartialDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops, GLdouble start, GLdouble sweep)   nogil
    void  gluPerspective (GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar)   nogil
    void  gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, GLint *viewport)   nogil
    GLint  gluProject (GLdouble objX, GLdouble objY, GLdouble objZ,  GLdouble *model,  GLdouble *proj,  GLint *view, GLdouble* winX, GLdouble* winY, GLdouble* winZ)   nogil
    void  gluPwlCurve (GLUnurbs* nurb, GLint count, GLfloat* data, GLint stride, GLenum _type)   nogil
    void  gluQuadricCallback (GLUquadric* quad, GLenum which, _GLUfuncptr CallBackFunc)   nogil
    void  gluQuadricDrawStyle (GLUquadric* quad, GLenum draw)   nogil
    void  gluQuadricNormals (GLUquadric* quad, GLenum normal)   nogil
    void  gluQuadricOrientation (GLUquadric* quad, GLenum orientation)   nogil
    void  gluQuadricTexture (GLUquadric* quad, GLboolean texture)   nogil
    GLint  gluScaleImage (GLenum format, GLsizei wIn, GLsizei hIn, GLenum typeIn,  void *dataIn, GLsizei wOut, GLsizei hOut, GLenum typeOut, GLvoid* dataOut)   nogil
    void  gluSphere (GLUquadric* quad, GLdouble radius, GLint slices, GLint stacks)   nogil
    void  gluTessBeginContour (GLUtesselator* tess)   nogil
    void  gluTessBeginPolygon (GLUtesselator* tess, GLvoid* data)   nogil
    void  gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc)   nogil
    void  gluTessEndContour (GLUtesselator* tess)   nogil
    void  gluTessEndPolygon (GLUtesselator* tess)   nogil
    void  gluTessNormal (GLUtesselator* tess, GLdouble valueX, GLdouble valueY, GLdouble valueZ)   nogil
    void  gluTessProperty (GLUtesselator* tess, GLenum which, GLdouble data)   nogil
    void  gluTessVertex (GLUtesselator* tess, GLdouble *location, GLvoid* data)   nogil
    GLint  gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ,  GLdouble *model,  GLdouble *proj,  GLint *view, GLdouble* objX, GLdouble* objY, GLdouble* objZ)   nogil
    GLint  gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW,  GLdouble *model,  GLdouble *proj,  GLint *view, GLdouble nearVal, GLdouble farVal, GLdouble* objX, GLdouble* objY, GLdouble* objZ, GLdouble* objW)   nogil
    #TODO:   DEF   gluErrorStringWIN   =   gluErrorUnicodeStringEXT
    #TODO:   DEF   gluErrorStringWIN   =   gluErrorString
    unsigned int GL_GLEXT_VERSION   
    unsigned int GL_CONSTANT_COLOR   
    unsigned int GL_ONE_MINUS_CONSTANT_COLOR   
    unsigned int GL_CONSTANT_ALPHA   
    unsigned int GL_ONE_MINUS_CONSTANT_ALPHA   
    unsigned int GL_BLEND_COLOR   
    unsigned int GL_FUNC_ADD   
    unsigned int GL_MIN   
    unsigned int GL_MAX   
    unsigned int GL_BLEND_EQUATION   
    unsigned int GL_FUNC_SUBTRACT   
    unsigned int GL_FUNC_REVERSE_SUBTRACT   
    unsigned int GL_CONVOLUTION_1D   
    unsigned int GL_CONVOLUTION_2D   
    unsigned int GL_SEPARABLE_2D   
    unsigned int GL_CONVOLUTION_BORDER_MODE   
    unsigned int GL_CONVOLUTION_FILTER_SCALE   
    unsigned int GL_CONVOLUTION_FILTER_BIAS   
    unsigned int GL_REDUCE   
    unsigned int GL_CONVOLUTION_FORMAT   
    unsigned int GL_CONVOLUTION_WIDTH   
    unsigned int GL_CONVOLUTION_HEIGHT   
    unsigned int GL_MAX_CONVOLUTION_WIDTH   
    unsigned int GL_MAX_CONVOLUTION_HEIGHT   
    unsigned int GL_POST_CONVOLUTION_RED_SCALE   
    unsigned int GL_POST_CONVOLUTION_GREEN_SCALE   
    unsigned int GL_POST_CONVOLUTION_BLUE_SCALE   
    unsigned int GL_POST_CONVOLUTION_ALPHA_SCALE   
    unsigned int GL_POST_CONVOLUTION_RED_BIAS   
    unsigned int GL_POST_CONVOLUTION_GREEN_BIAS   
    unsigned int GL_POST_CONVOLUTION_BLUE_BIAS   
    unsigned int GL_POST_CONVOLUTION_ALPHA_BIAS   
    unsigned int GL_HISTOGRAM   
    unsigned int GL_PROXY_HISTOGRAM   
    unsigned int GL_HISTOGRAM_WIDTH   
    unsigned int GL_HISTOGRAM_FORMAT   
    unsigned int GL_HISTOGRAM_RED_SIZE   
    unsigned int GL_HISTOGRAM_GREEN_SIZE   
    unsigned int GL_HISTOGRAM_BLUE_SIZE   
    unsigned int GL_HISTOGRAM_ALPHA_SIZE   
    unsigned int GL_HISTOGRAM_LUMINANCE_SIZE   
    unsigned int GL_HISTOGRAM_SINK   
    unsigned int GL_MINMAX   
    unsigned int GL_MINMAX_FORMAT   
    unsigned int GL_MINMAX_SINK   
    unsigned int GL_TABLE_TOO_LARGE   
    unsigned int GL_UNSIGNED_BYTE_3_3_2   
    unsigned int GL_UNSIGNED_SHORT_4_4_4_4   
    unsigned int GL_UNSIGNED_SHORT_5_5_5_1   
    unsigned int GL_UNSIGNED_INT_8_8_8_8   
    unsigned int GL_UNSIGNED_INT_10_10_10_2   
    unsigned int GL_RESCALE_NORMAL   
    unsigned int GL_UNSIGNED_BYTE_2_3_3_REV   
    unsigned int GL_UNSIGNED_SHORT_5_6_5   
    unsigned int GL_UNSIGNED_SHORT_5_6_5_REV   
    unsigned int GL_UNSIGNED_SHORT_4_4_4_4_REV   
    unsigned int GL_UNSIGNED_SHORT_1_5_5_5_REV   
    unsigned int GL_UNSIGNED_INT_8_8_8_8_REV   
    unsigned int GL_UNSIGNED_INT_2_10_10_10_REV   
    unsigned int GL_COLOR_MATRIX   
    unsigned int GL_COLOR_MATRIX_STACK_DEPTH   
    unsigned int GL_MAX_COLOR_MATRIX_STACK_DEPTH   
    unsigned int GL_POST_COLOR_MATRIX_RED_SCALE   
    unsigned int GL_POST_COLOR_MATRIX_GREEN_SCALE   
    unsigned int GL_POST_COLOR_MATRIX_BLUE_SCALE   
    unsigned int GL_POST_COLOR_MATRIX_ALPHA_SCALE   
    unsigned int GL_POST_COLOR_MATRIX_RED_BIAS   
    unsigned int GL_POST_COLOR_MATRIX_GREEN_BIAS   
    unsigned int GL_POST_COLOR_MATRIX_BLUE_BIAS   
    unsigned int GL_COLOR_TABLE   
    unsigned int GL_POST_CONVOLUTION_COLOR_TABLE   
    unsigned int GL_POST_COLOR_MATRIX_COLOR_TABLE   
    unsigned int GL_PROXY_COLOR_TABLE   
    unsigned int GL_PROXY_POST_CONVOLUTION_COLOR_TABLE   
    unsigned int GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE   
    unsigned int GL_COLOR_TABLE_SCALE   
    unsigned int GL_COLOR_TABLE_BIAS   
    unsigned int GL_COLOR_TABLE_FORMAT   
    unsigned int GL_COLOR_TABLE_WIDTH   
    unsigned int GL_COLOR_TABLE_RED_SIZE   
    unsigned int GL_COLOR_TABLE_GREEN_SIZE   
    unsigned int GL_COLOR_TABLE_BLUE_SIZE   
    unsigned int GL_COLOR_TABLE_ALPHA_SIZE   
    unsigned int GL_COLOR_TABLE_LUMINANCE_SIZE   
    unsigned int GL_COLOR_TABLE_INTENSITY_SIZE   
    unsigned int GL_BGR   
    unsigned int GL_BGRA   
    unsigned int GL_MAX_ELEMENTS_VERTICES   
    unsigned int GL_MAX_ELEMENTS_INDICES   
    # unsigned int GL_CLAMP_TO_EDGE   
    unsigned int GL_TEXTURE_MIN_LOD   
    unsigned int GL_TEXTURE_MAX_LOD   
    unsigned int GL_TEXTURE_BASE_LEVEL   
    unsigned int GL_TEXTURE_MAX_LEVEL   
    unsigned int GL_IGNORE_BORDER   
    unsigned int GL_CONSTANT_BORDER   
    unsigned int GL_WRAP_BORDER   
    unsigned int GL_REPLICATE_BORDER   
    unsigned int GL_CONVOLUTION_BORDER_COLOR   
    unsigned int GL_LIGHT_MODEL_COLOR_CONTROL   
    unsigned int GL_SINGLE_COLOR   
    unsigned int GL_SEPARATE_SPECULAR_COLOR   
    unsigned int GL_SMOOTH_POINT_SIZE_RANGE   
    unsigned int GL_SMOOTH_POINT_SIZE_GRANULARITY   
    unsigned int GL_SMOOTH_LINE_WIDTH_RANGE   
    unsigned int GL_SMOOTH_LINE_WIDTH_GRANULARITY   
    unsigned int GL_ALIASED_POINT_SIZE_RANGE   
    unsigned int GL_ALIASED_LINE_WIDTH_RANGE   
    # unsigned int GL_TEXTURE0   
    # unsigned int GL_TEXTURE1   
    # unsigned int GL_TEXTURE2   
    # unsigned int GL_TEXTURE3   
    # unsigned int GL_TEXTURE4   
    # unsigned int GL_TEXTURE5   
    # unsigned int GL_TEXTURE6   
    unsigned int GL_TEXTURE7   
    unsigned int GL_TEXTURE8   
    unsigned int GL_TEXTURE9   
    unsigned int GL_TEXTURE10   
    unsigned int GL_TEXTURE11   
    unsigned int GL_TEXTURE12   
    unsigned int GL_TEXTURE13   
    unsigned int GL_TEXTURE14   
    unsigned int GL_TEXTURE15   
    unsigned int GL_TEXTURE16   
    unsigned int GL_TEXTURE17   
    unsigned int GL_TEXTURE18   
    unsigned int GL_TEXTURE19   
    unsigned int GL_TEXTURE20   
    unsigned int GL_TEXTURE21   
    unsigned int GL_TEXTURE22   
    unsigned int GL_TEXTURE23   
    unsigned int GL_TEXTURE24   
    unsigned int GL_TEXTURE25   
    unsigned int GL_TEXTURE26   
    unsigned int GL_TEXTURE27   
    unsigned int GL_TEXTURE28   
    unsigned int GL_TEXTURE29   
    unsigned int GL_TEXTURE30   
    unsigned int GL_TEXTURE31   
    unsigned int GL_ACTIVE_TEXTURE   
    unsigned int GL_CLIENT_ACTIVE_TEXTURE   
    unsigned int GL_MAX_TEXTURE_UNITS   
    unsigned int GL_TRANSPOSE_MODELVIEW_MATRIX   
    unsigned int GL_TRANSPOSE_PROJECTION_MATRIX   
    unsigned int GL_TRANSPOSE_TEXTURE_MATRIX   
    unsigned int GL_TRANSPOSE_COLOR_MATRIX   
    unsigned int GL_MULTISAMPLE   
    unsigned int GL_SAMPLE_ALPHA_TO_COVERAGE   
    unsigned int GL_SAMPLE_ALPHA_TO_ONE   
    unsigned int GL_SAMPLE_COVERAGE   
    unsigned int GL_SAMPLE_BUFFERS   
    unsigned int GL_SAMPLES   
    unsigned int GL_SAMPLE_COVERAGE_VALUE   
    unsigned int GL_SAMPLE_COVERAGE_INVERT   
    unsigned int GL_MULTISAMPLE_BIT   
    unsigned int GL_NORMAL_MAP   
    unsigned int GL_REFLECTION_MAP   
    unsigned int GL_TEXTURE_CUBE_MAP   
    unsigned int GL_TEXTURE_BINDING_CUBE_MAP   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_X   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_X   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Y   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Y   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Z   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Z   
    unsigned int GL_PROXY_TEXTURE_CUBE_MAP   
    unsigned int GL_MAX_CUBE_MAP_TEXTURE_SIZE   
    unsigned int GL_COMPRESSED_ALPHA   
    unsigned int GL_COMPRESSED_LUMINANCE   
    unsigned int GL_COMPRESSED_LUMINANCE_ALPHA   
    unsigned int GL_COMPRESSED_INTENSITY   
    unsigned int GL_COMPRESSED_RGB   
    unsigned int GL_COMPRESSED_RGBA   
    unsigned int GL_TEXTURE_COMPRESSION_HINT   
    unsigned int GL_TEXTURE_COMPRESSED_IMAGE_SIZE   
    unsigned int GL_TEXTURE_COMPRESSED   
    unsigned int GL_NUM_COMPRESSED_TEXTURE_FORMATS   
    unsigned int GL_COMPRESSED_TEXTURE_FORMATS   
    unsigned int GL_CLAMP_TO_BORDER   
    unsigned int GL_CLAMP_TO_BORDER_SGIS   
    unsigned int GL_COMBINE   
    unsigned int GL_COMBINE_RGB   
    unsigned int GL_COMBINE_ALPHA   
    unsigned int GL_SOURCE0_RGB   
    unsigned int GL_SOURCE1_RGB   
    unsigned int GL_SOURCE2_RGB   
    unsigned int GL_SOURCE0_ALPHA   
    unsigned int GL_SOURCE1_ALPHA   
    unsigned int GL_SOURCE2_ALPHA   
    unsigned int GL_OPERAND0_RGB   
    unsigned int GL_OPERAND1_RGB   
    unsigned int GL_OPERAND2_RGB   
    unsigned int GL_OPERAND0_ALPHA   
    unsigned int GL_OPERAND1_ALPHA   
    unsigned int GL_OPERAND2_ALPHA   
    unsigned int GL_RGB_SCALE   
    unsigned int GL_ADD_SIGNED   
    unsigned int GL_INTERPOLATE   
    unsigned int GL_SUBTRACT   
    unsigned int GL_CONSTANT   
    unsigned int GL_PRIMARY_COLOR   
    unsigned int GL_PREVIOUS   
    unsigned int GL_DOT3_RGB   
    unsigned int GL_DOT3_RGBA   
    unsigned int GL_TEXTURE0_ARB   
    unsigned int GL_TEXTURE1_ARB   
    unsigned int GL_TEXTURE2_ARB   
    unsigned int GL_TEXTURE3_ARB   
    unsigned int GL_TEXTURE4_ARB   
    unsigned int GL_TEXTURE5_ARB   
    unsigned int GL_TEXTURE6_ARB   
    unsigned int GL_TEXTURE7_ARB   
    unsigned int GL_TEXTURE8_ARB   
    unsigned int GL_TEXTURE9_ARB   
    unsigned int GL_TEXTURE10_ARB   
    unsigned int GL_TEXTURE11_ARB   
    unsigned int GL_TEXTURE12_ARB   
    unsigned int GL_TEXTURE13_ARB   
    unsigned int GL_TEXTURE14_ARB   
    unsigned int GL_TEXTURE15_ARB   
    unsigned int GL_TEXTURE16_ARB   
    unsigned int GL_TEXTURE17_ARB   
    unsigned int GL_TEXTURE18_ARB   
    unsigned int GL_TEXTURE19_ARB   
    unsigned int GL_TEXTURE20_ARB   
    unsigned int GL_TEXTURE21_ARB   
    unsigned int GL_TEXTURE22_ARB   
    unsigned int GL_TEXTURE23_ARB   
    unsigned int GL_TEXTURE24_ARB   
    unsigned int GL_TEXTURE25_ARB   
    unsigned int GL_TEXTURE26_ARB   
    unsigned int GL_TEXTURE27_ARB   
    unsigned int GL_TEXTURE28_ARB   
    unsigned int GL_TEXTURE29_ARB   
    unsigned int GL_TEXTURE30_ARB   
    unsigned int GL_TEXTURE31_ARB   
    unsigned int GL_ACTIVE_TEXTURE_ARB   
    unsigned int GL_CLIENT_ACTIVE_TEXTURE_ARB   
    unsigned int GL_MAX_TEXTURE_UNITS_ARB   
    unsigned int GL_TRANSPOSE_MODELVIEW_MATRIX_ARB   
    unsigned int GL_TRANSPOSE_PROJECTION_MATRIX_ARB   
    unsigned int GL_TRANSPOSE_TEXTURE_MATRIX_ARB   
    unsigned int GL_TRANSPOSE_COLOR_MATRIX_ARB   
    unsigned int GL_MULTISAMPLE_ARB   
    unsigned int GL_SAMPLE_ALPHA_TO_COVERAGE_ARB   
    unsigned int GL_SAMPLE_ALPHA_TO_ONE_ARB   
    unsigned int GL_SAMPLE_COVERAGE_ARB   
    unsigned int GL_SAMPLE_BUFFERS_ARB   
    unsigned int GL_SAMPLES_ARB   
    unsigned int GL_SAMPLE_COVERAGE_VALUE_ARB   
    unsigned int GL_SAMPLE_COVERAGE_INVERT_ARB   
    unsigned int GL_MULTISAMPLE_BIT_ARB   
    unsigned int GL_NORMAL_MAP_ARB   
    unsigned int GL_REFLECTION_MAP_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_ARB   
    unsigned int GL_TEXTURE_BINDING_CUBE_MAP_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB   
    unsigned int GL_PROXY_TEXTURE_CUBE_MAP_ARB   
    unsigned int GL_MAX_CUBE_MAP_TEXTURE_SIZE_ARB   
    unsigned int GL_COMPRESSED_ALPHA_ARB   
    unsigned int GL_COMPRESSED_LUMINANCE_ARB   
    unsigned int GL_COMPRESSED_LUMINANCE_ALPHA_ARB   
    unsigned int GL_COMPRESSED_INTENSITY_ARB   
    unsigned int GL_COMPRESSED_RGB_ARB   
    unsigned int GL_COMPRESSED_RGBA_ARB   
    unsigned int GL_TEXTURE_COMPRESSION_HINT_ARB   
    unsigned int GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB   
    unsigned int GL_TEXTURE_COMPRESSED_ARB   
    unsigned int GL_NUM_COMPRESSED_TEXTURE_FORMATS_ARB   
    unsigned int GL_COMPRESSED_TEXTURE_FORMATS_ARB   
    unsigned int GL_CLAMP_TO_BORDER_ARB   
    unsigned int GL_POINT_SIZE_MIN_ARB   
    unsigned int GL_POINT_SIZE_MIN_EXT   
    unsigned int GL_POINT_SIZE_MIN_SGIS   
    unsigned int GL_POINT_SIZE_MAX_ARB   
    unsigned int GL_POINT_SIZE_MAX_EXT   
    unsigned int GL_POINT_SIZE_MAX_SGIS   
    unsigned int GL_POINT_FADE_THRESHOLD_SIZE_ARB   
    unsigned int GL_POINT_FADE_THRESHOLD_SIZE_EXT   
    unsigned int GL_POINT_FADE_THRESHOLD_SIZE_SGIS   
    unsigned int GL_POINT_DISTANCE_ATTENUATION_ARB   
    unsigned int GL_DISTANCE_ATTENUATION_EXT   
    unsigned int GL_DISTANCE_ATTENUATION_SGIS   
    unsigned int GL_MAX_VERTEX_UNITS_ARB   
    unsigned int GL_ACTIVE_VERTEX_UNITS_ARB   
    unsigned int GL_WEIGHT_SUM_UNITY_ARB   
    unsigned int GL_VERTEX_BLEND_ARB   
    unsigned int GL_CURRENT_WEIGHT_ARB   
    unsigned int GL_WEIGHT_ARRAY_TYPE_ARB   
    unsigned int GL_WEIGHT_ARRAY_STRIDE_ARB   
    unsigned int GL_WEIGHT_ARRAY_SIZE_ARB   
    unsigned int GL_WEIGHT_ARRAY_POINTER_ARB   
    unsigned int GL_WEIGHT_ARRAY_ARB   
    unsigned int GL_MODELVIEW0_ARB   
    unsigned int GL_MODELVIEW1_ARB   
    unsigned int GL_MODELVIEW2_ARB   
    unsigned int GL_MODELVIEW3_ARB   
    unsigned int GL_MODELVIEW4_ARB   
    unsigned int GL_MODELVIEW5_ARB   
    unsigned int GL_MODELVIEW6_ARB   
    unsigned int GL_MODELVIEW7_ARB   
    unsigned int GL_MODELVIEW8_ARB   
    unsigned int GL_MODELVIEW9_ARB   
    unsigned int GL_MODELVIEW10_ARB   
    unsigned int GL_MODELVIEW11_ARB   
    unsigned int GL_MODELVIEW12_ARB   
    unsigned int GL_MODELVIEW13_ARB   
    unsigned int GL_MODELVIEW14_ARB   
    unsigned int GL_MODELVIEW15_ARB   
    unsigned int GL_MODELVIEW16_ARB   
    unsigned int GL_MODELVIEW17_ARB   
    unsigned int GL_MODELVIEW18_ARB   
    unsigned int GL_MODELVIEW19_ARB   
    unsigned int GL_MODELVIEW20_ARB   
    unsigned int GL_MODELVIEW21_ARB   
    unsigned int GL_MODELVIEW22_ARB   
    unsigned int GL_MODELVIEW23_ARB   
    unsigned int GL_MODELVIEW24_ARB   
    unsigned int GL_MODELVIEW25_ARB   
    unsigned int GL_MODELVIEW26_ARB   
    unsigned int GL_MODELVIEW27_ARB   
    unsigned int GL_MODELVIEW28_ARB   
    unsigned int GL_MODELVIEW29_ARB   
    unsigned int GL_MODELVIEW30_ARB   
    unsigned int GL_MODELVIEW31_ARB   
    unsigned int GL_MATRIX_PALETTE_ARB   
    unsigned int GL_MAX_MATRIX_PALETTE_STACK_DEPTH_ARB   
    unsigned int GL_MAX_PALETTE_MATRICES_ARB   
    unsigned int GL_CURRENT_PALETTE_MATRIX_ARB   
    unsigned int GL_MATRIX_INDEX_ARRAY_ARB   
    unsigned int GL_CURRENT_MATRIX_INDEX_ARB   
    unsigned int GL_MATRIX_INDEX_ARRAY_SIZE_ARB   
    unsigned int GL_MATRIX_INDEX_ARRAY_TYPE_ARB   
    unsigned int GL_MATRIX_INDEX_ARRAY_STRIDE_ARB   
    unsigned int GL_MATRIX_INDEX_ARRAY_POINTER_ARB   
    unsigned int GL_COMBINE_ARB   
    unsigned int GL_COMBINE_RGB_ARB   
    unsigned int GL_COMBINE_ALPHA_ARB   
    unsigned int GL_SOURCE0_RGB_ARB   
    unsigned int GL_SOURCE1_RGB_ARB   
    unsigned int GL_SOURCE2_RGB_ARB   
    unsigned int GL_SOURCE0_ALPHA_ARB   
    unsigned int GL_SOURCE1_ALPHA_ARB   
    unsigned int GL_SOURCE2_ALPHA_ARB   
    unsigned int GL_OPERAND0_RGB_ARB   
    unsigned int GL_OPERAND1_RGB_ARB   
    unsigned int GL_OPERAND2_RGB_ARB   
    unsigned int GL_OPERAND0_ALPHA_ARB   
    unsigned int GL_OPERAND1_ALPHA_ARB   
    unsigned int GL_OPERAND2_ALPHA_ARB   
    unsigned int GL_RGB_SCALE_ARB   
    unsigned int GL_ADD_SIGNED_ARB   
    unsigned int GL_INTERPOLATE_ARB   
    unsigned int GL_SUBTRACT_ARB   
    unsigned int GL_CONSTANT_ARB   
    unsigned int GL_PRIMARY_COLOR_ARB   
    unsigned int GL_PREVIOUS_ARB   
    unsigned int GL_DOT3_RGB_ARB   
    unsigned int GL_DOT3_RGB_EXT   
    unsigned int GL_DOT3_RGBA_ARB   
    unsigned int GL_DOT3_RGBA_EXT   
    unsigned int GL_MIRRORED_REPEAT_ARB   
    unsigned int GL_DEPTH_COMPONENT16_ARB   
    unsigned int GL_DEPTH_COMPONENT24_ARB   
    unsigned int GL_DEPTH_COMPONENT32_ARB   
    unsigned int GL_TEXTURE_DEPTH_SIZE_ARB   
    unsigned int GL_DEPTH_TEXTURE_MODE_ARB   
    unsigned int GL_TEXTURE_COMPARE_MODE_ARB   
    unsigned int GL_TEXTURE_COMPARE_FUNC_ARB   
    unsigned int GL_COMPARE_R_TO_TEXTURE_ARB   
    unsigned int GL_TEXTURE_COMPARE_FAIL_VALUE_ARB   
    unsigned int GL_ABGR_EXT   
    unsigned int GL_CONSTANT_COLOR_EXT   
    unsigned int GL_ONE_MINUS_CONSTANT_COLOR_EXT   
    unsigned int GL_CONSTANT_ALPHA_EXT   
    unsigned int GL_ONE_MINUS_CONSTANT_ALPHA_EXT   
    unsigned int GL_BLEND_COLOR_EXT   
    unsigned int GL_POLYGON_OFFSET_EXT   
    unsigned int GL_POLYGON_OFFSET_FACTOR_EXT   
    unsigned int GL_POLYGON_OFFSET_BIAS_EXT   
    unsigned int GL_ALPHA4_EXT   
    unsigned int GL_ALPHA8_EXT   
    unsigned int GL_ALPHA12_EXT   
    unsigned int GL_ALPHA16_EXT   
    unsigned int GL_LUMINANCE4_EXT   
    unsigned int GL_LUMINANCE8_EXT   
    unsigned int GL_LUMINANCE12_EXT   
    unsigned int GL_LUMINANCE16_EXT   
    unsigned int GL_LUMINANCE4_ALPHA4_EXT   
    unsigned int GL_LUMINANCE6_ALPHA2_EXT   
    unsigned int GL_LUMINANCE8_ALPHA8_EXT   
    unsigned int GL_LUMINANCE12_ALPHA4_EXT   
    unsigned int GL_LUMINANCE12_ALPHA12_EXT   
    unsigned int GL_LUMINANCE16_ALPHA16_EXT   
    unsigned int GL_INTENSITY_EXT   
    unsigned int GL_INTENSITY4_EXT   
    unsigned int GL_INTENSITY8_EXT   
    unsigned int GL_INTENSITY12_EXT   
    unsigned int GL_INTENSITY16_EXT   
    unsigned int GL_RGB2_EXT   
    unsigned int GL_RGB4_EXT   
    unsigned int GL_RGB5_EXT   
    unsigned int GL_RGB8_EXT   
    unsigned int GL_RGB10_EXT   
    unsigned int GL_RGB12_EXT   
    unsigned int GL_RGB16_EXT   
    unsigned int GL_RGBA2_EXT   
    unsigned int GL_RGBA4_EXT   
    unsigned int GL_RGB5_A1_EXT   
    unsigned int GL_RGBA8_EXT   
    unsigned int GL_RGB10_A2_EXT   
    unsigned int GL_RGBA12_EXT   
    unsigned int GL_RGBA16_EXT   
    unsigned int GL_TEXTURE_RED_SIZE_EXT   
    unsigned int GL_TEXTURE_GREEN_SIZE_EXT   
    unsigned int GL_TEXTURE_BLUE_SIZE_EXT   
    unsigned int GL_TEXTURE_ALPHA_SIZE_EXT   
    unsigned int GL_TEXTURE_LUMINANCE_SIZE_EXT   
    unsigned int GL_TEXTURE_INTENSITY_SIZE_EXT   
    unsigned int GL_REPLACE_EXT   
    unsigned int GL_PROXY_TEXTURE_1D_EXT   
    unsigned int GL_PROXY_TEXTURE_2D_EXT   
    unsigned int GL_TEXTURE_TOO_LARGE_EXT   
    unsigned int GL_PACK_SKIP_IMAGES   
    unsigned int GL_PACK_SKIP_IMAGES_EXT   
    unsigned int GL_PACK_IMAGE_HEIGHT   
    unsigned int GL_PACK_IMAGE_HEIGHT_EXT   
    unsigned int GL_UNPACK_SKIP_IMAGES   
    unsigned int GL_UNPACK_SKIP_IMAGES_EXT   
    unsigned int GL_UNPACK_IMAGE_HEIGHT   
    unsigned int GL_UNPACK_IMAGE_HEIGHT_EXT   
    unsigned int GL_TEXTURE_3D   
    unsigned int GL_TEXTURE_3D_EXT   
    unsigned int GL_PROXY_TEXTURE_3D   
    unsigned int GL_PROXY_TEXTURE_3D_EXT   
    unsigned int GL_TEXTURE_DEPTH   
    unsigned int GL_TEXTURE_DEPTH_EXT   
    unsigned int GL_TEXTURE_WRAP_R   
    unsigned int GL_TEXTURE_WRAP_R_EXT   
    unsigned int GL_MAX_3D_TEXTURE_SIZE   
    unsigned int GL_MAX_3D_TEXTURE_SIZE_EXT   
    unsigned int GL_FILTER4_SGIS   
    unsigned int GL_TEXTURE_FILTER4_SIZE_SGIS   
    unsigned int GL_HISTOGRAM_EXT   
    unsigned int GL_PROXY_HISTOGRAM_EXT   
    unsigned int GL_HISTOGRAM_WIDTH_EXT   
    unsigned int GL_HISTOGRAM_FORMAT_EXT   
    unsigned int GL_HISTOGRAM_RED_SIZE_EXT   
    unsigned int GL_HISTOGRAM_GREEN_SIZE_EXT   
    unsigned int GL_HISTOGRAM_BLUE_SIZE_EXT   
    unsigned int GL_HISTOGRAM_ALPHA_SIZE_EXT   
    unsigned int GL_HISTOGRAM_LUMINANCE_SIZE_EXT   
    unsigned int GL_HISTOGRAM_SINK_EXT   
    unsigned int GL_MINMAX_EXT   
    unsigned int GL_MINMAX_FORMAT_EXT   
    unsigned int GL_MINMAX_SINK_EXT   
    unsigned int GL_TABLE_TOO_LARGE_EXT   
    unsigned int GL_CONVOLUTION_1D_EXT   
    unsigned int GL_CONVOLUTION_2D_EXT   
    unsigned int GL_SEPARABLE_2D_EXT   
    unsigned int GL_CONVOLUTION_BORDER_MODE_EXT   
    unsigned int GL_CONVOLUTION_FILTER_SCALE_EXT   
    unsigned int GL_CONVOLUTION_FILTER_BIAS_EXT   
    unsigned int GL_REDUCE_EXT   
    unsigned int GL_CONVOLUTION_FORMAT_EXT   
    unsigned int GL_CONVOLUTION_WIDTH_EXT   
    unsigned int GL_CONVOLUTION_HEIGHT_EXT   
    unsigned int GL_MAX_CONVOLUTION_WIDTH_EXT   
    unsigned int GL_MAX_CONVOLUTION_HEIGHT_EXT   
    unsigned int GL_POST_CONVOLUTION_RED_SCALE_EXT   
    unsigned int GL_POST_CONVOLUTION_GREEN_SCALE_EXT   
    unsigned int GL_POST_CONVOLUTION_BLUE_SCALE_EXT   
    unsigned int GL_POST_CONVOLUTION_ALPHA_SCALE_EXT   
    unsigned int GL_POST_CONVOLUTION_RED_BIAS_EXT   
    unsigned int GL_POST_CONVOLUTION_GREEN_BIAS_EXT   
    unsigned int GL_POST_CONVOLUTION_BLUE_BIAS_EXT   
    unsigned int GL_POST_CONVOLUTION_ALPHA_BIAS_EXT   
    unsigned int GL_COLOR_MATRIX_SGI   
    unsigned int GL_COLOR_MATRIX_STACK_DEPTH_SGI   
    unsigned int GL_MAX_COLOR_MATRIX_STACK_DEPTH_SGI   
    unsigned int GL_POST_COLOR_MATRIX_RED_SCALE_SGI   
    unsigned int GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI   
    unsigned int GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI   
    unsigned int GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI   
    unsigned int GL_POST_COLOR_MATRIX_RED_BIAS_SGI   
    unsigned int GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI   
    unsigned int GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI   
    unsigned int GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI   
    unsigned int GL_COLOR_TABLE_SGI   
    unsigned int GL_POST_CONVOLUTION_COLOR_TABLE_SGI   
    unsigned int GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI   
    unsigned int GL_PROXY_COLOR_TABLE_SGI   
    unsigned int GL_PROXY_POST_CONVOLUTION_COLOR_TABLE_SGI   
    unsigned int GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE_SGI   
    unsigned int GL_COLOR_TABLE_SCALE_SGI   
    unsigned int GL_COLOR_TABLE_BIAS_SGI   
    unsigned int GL_COLOR_TABLE_FORMAT_SGI   
    unsigned int GL_COLOR_TABLE_WIDTH_SGI   
    unsigned int GL_COLOR_TABLE_RED_SIZE_SGI   
    unsigned int GL_COLOR_TABLE_GREEN_SIZE_SGI   
    unsigned int GL_COLOR_TABLE_BLUE_SIZE_SGI   
    unsigned int GL_COLOR_TABLE_ALPHA_SIZE_SGI   
    unsigned int GL_COLOR_TABLE_LUMINANCE_SIZE_SGI   
    unsigned int GL_COLOR_TABLE_INTENSITY_SIZE_SGI   
    unsigned int GL_PIXEL_TEXTURE_SGIS   
    unsigned int GL_PIXEL_FRAGMENT_RGB_SOURCE_SGIS   
    unsigned int GL_PIXEL_FRAGMENT_ALPHA_SOURCE_SGIS   
    unsigned int GL_PIXEL_GROUP_COLOR_SGIS   
    unsigned int GL_PIXEL_TEX_GEN_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_MODE_SGIX   
    unsigned int GL_PACK_SKIP_VOLUMES_SGIS   
    unsigned int GL_PACK_IMAGE_DEPTH_SGIS   
    unsigned int GL_UNPACK_SKIP_VOLUMES_SGIS   
    unsigned int GL_UNPACK_IMAGE_DEPTH_SGIS   
    unsigned int GL_TEXTURE_4D_SGIS   
    unsigned int GL_PROXY_TEXTURE_4D_SGIS   
    unsigned int GL_TEXTURE_4DSIZE_SGIS   
    unsigned int GL_TEXTURE_WRAP_Q_SGIS   
    unsigned int GL_MAX_4D_TEXTURE_SIZE_SGIS   
    unsigned int GL_TEXTURE_4D_BINDING_SGIS   
    unsigned int GL_TEXTURE_COLOR_TABLE_SGI   
    unsigned int GL_PROXY_TEXTURE_COLOR_TABLE_SGI   
    unsigned int GL_CMYK_EXT   
    unsigned int GL_CMYKA_EXT   
    unsigned int GL_PACK_CMYK_HINT_EXT   
    unsigned int GL_UNPACK_CMYK_HINT_EXT   
    unsigned int GL_TEXTURE_PRIORITY_EXT   
    unsigned int GL_TEXTURE_RESIDENT_EXT   
    unsigned int GL_TEXTURE_1D_BINDING_EXT   
    unsigned int GL_TEXTURE_2D_BINDING_EXT   
    unsigned int GL_TEXTURE_3D_BINDING_EXT   
    unsigned int GL_DETAIL_TEXTURE_2D_SGIS   
    unsigned int GL_DETAIL_TEXTURE_2D_BINDING_SGIS   
    unsigned int GL_LINEAR_DETAIL_SGIS   
    unsigned int GL_LINEAR_DETAIL_ALPHA_SGIS   
    unsigned int GL_LINEAR_DETAIL_COLOR_SGIS   
    unsigned int GL_DETAIL_TEXTURE_LEVEL_SGIS   
    unsigned int GL_DETAIL_TEXTURE_MODE_SGIS   
    unsigned int GL_DETAIL_TEXTURE_FUNC_POINTS_SGIS   
    unsigned int GL_LINEAR_SHARPEN_SGIS   
    unsigned int GL_LINEAR_SHARPEN_ALPHA_SGIS   
    unsigned int GL_LINEAR_SHARPEN_COLOR_SGIS   
    unsigned int GL_SHARPEN_TEXTURE_FUNC_POINTS_SGIS   
    unsigned int GL_UNSIGNED_BYTE_3_3_2_EXT   
    unsigned int GL_UNSIGNED_SHORT_4_4_4_4_EXT   
    unsigned int GL_UNSIGNED_SHORT_5_5_5_1_EXT   
    unsigned int GL_UNSIGNED_INT_8_8_8_8_EXT   
    unsigned int GL_UNSIGNED_INT_10_10_10_2_EXT   
    unsigned int GL_TEXTURE_MIN_LOD_SGIS   
    unsigned int GL_TEXTURE_MAX_LOD_SGIS   
    unsigned int GL_TEXTURE_BASE_LEVEL_SGIS   
    unsigned int GL_TEXTURE_MAX_LEVEL_SGIS   
    unsigned int GL_MULTISAMPLE_SGIS   
    unsigned int GL_SAMPLE_ALPHA_TO_MASK_SGIS   
    unsigned int GL_SAMPLE_ALPHA_TO_ONE_SGIS   
    unsigned int GL_SAMPLE_MASK_SGIS   
    unsigned int GL_1PASS_SGIS   
    unsigned int GL_2PASS_0_SGIS   
    unsigned int GL_2PASS_1_SGIS   
    unsigned int GL_4PASS_0_SGIS   
    unsigned int GL_4PASS_1_SGIS   
    unsigned int GL_4PASS_2_SGIS   
    unsigned int GL_4PASS_3_SGIS   
    unsigned int GL_SAMPLE_BUFFERS_SGIS   
    unsigned int GL_SAMPLES_SGIS   
    unsigned int GL_SAMPLE_MASK_VALUE_SGIS   
    unsigned int GL_SAMPLE_MASK_INVERT_SGIS   
    unsigned int GL_SAMPLE_PATTERN_SGIS   
    unsigned int GL_RESCALE_NORMAL_EXT   
    unsigned int GL_VERTEX_ARRAY_EXT   
    unsigned int GL_NORMAL_ARRAY_EXT   
    unsigned int GL_COLOR_ARRAY_EXT   
    unsigned int GL_INDEX_ARRAY_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_EXT   
    unsigned int GL_EDGE_FLAG_ARRAY_EXT   
    unsigned int GL_VERTEX_ARRAY_SIZE_EXT   
    unsigned int GL_VERTEX_ARRAY_TYPE_EXT   
    unsigned int GL_VERTEX_ARRAY_STRIDE_EXT   
    unsigned int GL_VERTEX_ARRAY_COUNT_EXT   
    unsigned int GL_NORMAL_ARRAY_TYPE_EXT   
    unsigned int GL_NORMAL_ARRAY_STRIDE_EXT   
    unsigned int GL_NORMAL_ARRAY_COUNT_EXT   
    unsigned int GL_COLOR_ARRAY_SIZE_EXT   
    unsigned int GL_COLOR_ARRAY_TYPE_EXT   
    unsigned int GL_COLOR_ARRAY_STRIDE_EXT   
    unsigned int GL_COLOR_ARRAY_COUNT_EXT   
    unsigned int GL_INDEX_ARRAY_TYPE_EXT   
    unsigned int GL_INDEX_ARRAY_STRIDE_EXT   
    unsigned int GL_INDEX_ARRAY_COUNT_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_SIZE_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_TYPE_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_STRIDE_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_COUNT_EXT   
    unsigned int GL_EDGE_FLAG_ARRAY_STRIDE_EXT   
    unsigned int GL_EDGE_FLAG_ARRAY_COUNT_EXT   
    unsigned int GL_VERTEX_ARRAY_POINTER_EXT   
    unsigned int GL_NORMAL_ARRAY_POINTER_EXT   
    unsigned int GL_COLOR_ARRAY_POINTER_EXT   
    unsigned int GL_INDEX_ARRAY_POINTER_EXT   
    unsigned int GL_TEXTURE_COORD_ARRAY_POINTER_EXT   
    unsigned int GL_EDGE_FLAG_ARRAY_POINTER_EXT   
    unsigned int GL_GENERATE_MIPMAP_SGIS   
    unsigned int GL_GENERATE_MIPMAP_HINT_SGIS   
    unsigned int GL_LINEAR_CLIPMAP_LINEAR_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_CENTER_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_FRAME_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_OFFSET_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_VIRTUAL_DEPTH_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_LOD_OFFSET_SGIX   
    unsigned int GL_TEXTURE_CLIPMAP_DEPTH_SGIX   
    unsigned int GL_MAX_CLIPMAP_DEPTH_SGIX   
    unsigned int GL_MAX_CLIPMAP_VIRTUAL_DEPTH_SGIX   
    unsigned int GL_NEAREST_CLIPMAP_NEAREST_SGIX   
    unsigned int GL_NEAREST_CLIPMAP_LINEAR_SGIX   
    unsigned int GL_LINEAR_CLIPMAP_NEAREST_SGIX   
    unsigned int GL_TEXTURE_COMPARE_SGIX   
    unsigned int GL_TEXTURE_COMPARE_OPERATOR_SGIX   
    unsigned int GL_TEXTURE_LEQUAL_R_SGIX   
    unsigned int GL_TEXTURE_GEQUAL_R_SGIX   
    unsigned int GL_CLAMP_TO_EDGE_SGIS   
    unsigned int GL_FUNC_ADD_EXT   
    unsigned int GL_MIN_EXT   
    unsigned int GL_MAX_EXT   
    unsigned int GL_BLEND_EQUATION_EXT   
    unsigned int GL_FUNC_SUBTRACT_EXT   
    unsigned int GL_FUNC_REVERSE_SUBTRACT_EXT   
    unsigned int GL_INTERLACE_SGIX   
    unsigned int GL_PIXEL_TILE_BEST_ALIGNMENT_SGIX   
    unsigned int GL_PIXEL_TILE_CACHE_INCREMENT_SGIX   
    unsigned int GL_PIXEL_TILE_WIDTH_SGIX   
    unsigned int GL_PIXEL_TILE_HEIGHT_SGIX   
    unsigned int GL_PIXEL_TILE_GRID_WIDTH_SGIX   
    unsigned int GL_PIXEL_TILE_GRID_HEIGHT_SGIX   
    unsigned int GL_PIXEL_TILE_GRID_DEPTH_SGIX   
    unsigned int GL_PIXEL_TILE_CACHE_SIZE_SGIX   
    unsigned int GL_DUAL_ALPHA4_SGIS   
    unsigned int GL_DUAL_ALPHA8_SGIS   
    unsigned int GL_DUAL_ALPHA12_SGIS   
    unsigned int GL_DUAL_ALPHA16_SGIS   
    unsigned int GL_DUAL_LUMINANCE4_SGIS   
    unsigned int GL_DUAL_LUMINANCE8_SGIS   
    unsigned int GL_DUAL_LUMINANCE12_SGIS   
    unsigned int GL_DUAL_LUMINANCE16_SGIS   
    unsigned int GL_DUAL_INTENSITY4_SGIS   
    unsigned int GL_DUAL_INTENSITY8_SGIS   
    unsigned int GL_DUAL_INTENSITY12_SGIS   
    unsigned int GL_DUAL_INTENSITY16_SGIS   
    unsigned int GL_DUAL_LUMINANCE_ALPHA4_SGIS   
    unsigned int GL_DUAL_LUMINANCE_ALPHA8_SGIS   
    unsigned int GL_QUAD_ALPHA4_SGIS   
    unsigned int GL_QUAD_ALPHA8_SGIS   
    unsigned int GL_QUAD_LUMINANCE4_SGIS   
    unsigned int GL_QUAD_LUMINANCE8_SGIS   
    unsigned int GL_QUAD_INTENSITY4_SGIS   
    unsigned int GL_QUAD_INTENSITY8_SGIS   
    unsigned int GL_DUAL_TEXTURE_SELECT_SGIS   
    unsigned int GL_QUAD_TEXTURE_SELECT_SGIS   
    unsigned int GL_SPRITE_SGIX   
    unsigned int GL_SPRITE_MODE_SGIX   
    unsigned int GL_SPRITE_AXIS_SGIX   
    unsigned int GL_SPRITE_TRANSLATION_SGIX   
    unsigned int GL_SPRITE_AXIAL_SGIX   
    unsigned int GL_SPRITE_OBJECT_ALIGNED_SGIX   
    unsigned int GL_SPRITE_EYE_ALIGNED_SGIX   
    unsigned int GL_TEXTURE_MULTI_BUFFER_HINT_SGIX   
    unsigned int GL_INSTRUMENT_BUFFER_POINTER_SGIX   
    unsigned int GL_INSTRUMENT_MEASUREMENTS_SGIX   
    unsigned int GL_POST_TEXTURE_FILTER_BIAS_SGIX   
    unsigned int GL_POST_TEXTURE_FILTER_SCALE_SGIX   
    unsigned int GL_POST_TEXTURE_FILTER_BIAS_RANGE_SGIX   
    unsigned int GL_POST_TEXTURE_FILTER_SCALE_RANGE_SGIX   
    unsigned int GL_FRAMEZOOM_SGIX   
    unsigned int GL_FRAMEZOOM_FACTOR_SGIX   
    unsigned int GL_MAX_FRAMEZOOM_FACTOR_SGIX   
    unsigned int GL_TEXTURE_DEFORMATION_BIT_SGIX   
    unsigned int GL_GEOMETRY_DEFORMATION_BIT_SGIX   
    unsigned int GL_GEOMETRY_DEFORMATION_SGIX   
    unsigned int GL_TEXTURE_DEFORMATION_SGIX   
    unsigned int GL_DEFORMATIONS_MASK_SGIX   
    unsigned int GL_MAX_DEFORMATION_ORDER_SGIX   
    unsigned int GL_REFERENCE_PLANE_SGIX   
    unsigned int GL_REFERENCE_PLANE_EQUATION_SGIX   
    unsigned int GL_DEPTH_COMPONENT16_SGIX   
    unsigned int GL_DEPTH_COMPONENT24_SGIX   
    unsigned int GL_DEPTH_COMPONENT32_SGIX   
    unsigned int GL_FOG_FUNC_SGIS   
    unsigned int GL_FOG_FUNC_POINTS_SGIS   
    unsigned int GL_MAX_FOG_FUNC_POINTS_SGIS   
    unsigned int GL_FOG_OFFSET_SGIX   
    unsigned int GL_FOG_OFFSET_VALUE_SGIX   
    unsigned int GL_IMAGE_SCALE_X_HP   
    unsigned int GL_IMAGE_SCALE_Y_HP   
    unsigned int GL_IMAGE_TRANSLATE_X_HP   
    unsigned int GL_IMAGE_TRANSLATE_Y_HP   
    unsigned int GL_IMAGE_ROTATE_ANGLE_HP   
    unsigned int GL_IMAGE_ROTATE_ORIGIN_X_HP   
    unsigned int GL_IMAGE_ROTATE_ORIGIN_Y_HP   
    unsigned int GL_IMAGE_MAG_FILTER_HP   
    unsigned int GL_IMAGE_MIN_FILTER_HP   
    unsigned int GL_IMAGE_CUBIC_WEIGHT_HP   
    unsigned int GL_CUBIC_HP   
    unsigned int GL_AVERAGE_HP   
    unsigned int GL_IMAGE_TRANSFORM_2D_HP   
    unsigned int GL_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP   
    unsigned int GL_PROXY_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP   
    unsigned int GL_IGNORE_BORDER_HP   
    unsigned int GL_CONSTANT_BORDER_HP   
    unsigned int GL_REPLICATE_BORDER_HP   
    unsigned int GL_CONVOLUTION_BORDER_COLOR_HP   
    unsigned int GL_TEXTURE_ENV_BIAS_SGIX   
    unsigned int GL_VERTEX_DATA_HINT_PGI   
    unsigned int GL_VERTEX_CONSISTENT_HINT_PGI   
    unsigned int GL_MATERIAL_SIDE_HINT_PGI   
    unsigned int GL_MAX_VERTEX_HINT_PGI   
    unsigned int GL_COLOR3_BIT_PGI   
    unsigned int GL_COLOR4_BIT_PGI   
    unsigned int GL_EDGEFLAG_BIT_PGI   
    unsigned int GL_INDEX_BIT_PGI   
    unsigned int GL_MAT_AMBIENT_BIT_PGI   
    unsigned int GL_MAT_AMBIENT_AND_DIFFUSE_BIT_PGI   
    unsigned int GL_MAT_DIFFUSE_BIT_PGI   
    unsigned int GL_MAT_EMISSION_BIT_PGI   
    unsigned int GL_MAT_COLOR_INDEXES_BIT_PGI   
    unsigned int GL_MAT_SHININESS_BIT_PGI   
    unsigned int GL_MAT_SPECULAR_BIT_PGI   
    unsigned int GL_NORMAL_BIT_PGI   
    unsigned int GL_TEXCOORD1_BIT_PGI   
    unsigned int GL_TEXCOORD2_BIT_PGI   
    unsigned int GL_TEXCOORD3_BIT_PGI   
    unsigned int GL_TEXCOORD4_BIT_PGI   
    unsigned int GL_VERTEX23_BIT_PGI   
    unsigned int GL_VERTEX4_BIT_PGI   
    unsigned int GL_PREFER_DOUBLEBUFFER_HINT_PGI   
    unsigned int GL_CONSERVE_MEMORY_HINT_PGI   
    unsigned int GL_RECLAIM_MEMORY_HINT_PGI   
    unsigned int GL_NATIVE_GRAPHICS_HANDLE_PGI   
    unsigned int GL_NATIVE_GRAPHICS_BEGIN_HINT_PGI   
    unsigned int GL_NATIVE_GRAPHICS_END_HINT_PGI   
    unsigned int GL_ALWAYS_FAST_HINT_PGI   
    unsigned int GL_ALWAYS_SOFT_HINT_PGI   
    unsigned int GL_ALLOW_DRAW_OBJ_HINT_PGI   
    unsigned int GL_ALLOW_DRAW_WIN_HINT_PGI   
    unsigned int GL_ALLOW_DRAW_FRG_HINT_PGI   
    unsigned int GL_ALLOW_DRAW_MEM_HINT_PGI   
    unsigned int GL_STRICT_DEPTHFUNC_HINT_PGI   
    unsigned int GL_STRICT_LIGHTING_HINT_PGI   
    unsigned int GL_STRICT_SCISSOR_HINT_PGI   
    unsigned int GL_FULL_STIPPLE_HINT_PGI   
    unsigned int GL_CLIP_NEAR_HINT_PGI   
    unsigned int GL_CLIP_FAR_HINT_PGI   
    unsigned int GL_WIDE_LINE_HINT_PGI   
    unsigned int GL_BACK_NORMALS_HINT_PGI   
    unsigned int GL_COLOR_INDEX1_EXT   
    unsigned int GL_COLOR_INDEX2_EXT   
    unsigned int GL_COLOR_INDEX4_EXT   
    unsigned int GL_COLOR_INDEX8_EXT   
    unsigned int GL_COLOR_INDEX12_EXT   
    unsigned int GL_COLOR_INDEX16_EXT   
    unsigned int GL_TEXTURE_INDEX_SIZE_EXT   
    unsigned int GL_CLIP_VOLUME_CLIPPING_HINT_EXT   
    unsigned int GL_LIST_PRIORITY_SGIX   
    unsigned int GL_IR_INSTRUMENT1_SGIX   
    unsigned int GL_CALLIGRAPHIC_FRAGMENT_SGIX   
    unsigned int GL_TEXTURE_LOD_BIAS_S_SGIX   
    unsigned int GL_TEXTURE_LOD_BIAS_T_SGIX   
    unsigned int GL_TEXTURE_LOD_BIAS_R_SGIX   
    unsigned int GL_SHADOW_AMBIENT_SGIX   
    unsigned int GL_INDEX_MATERIAL_EXT   
    unsigned int GL_INDEX_MATERIAL_PARAMETER_EXT   
    unsigned int GL_INDEX_MATERIAL_FACE_EXT   
    unsigned int GL_INDEX_TEST_EXT   
    unsigned int GL_INDEX_TEST_FUNC_EXT   
    unsigned int GL_INDEX_TEST_REF_EXT   
    unsigned int GL_IUI_V2F_EXT   
    unsigned int GL_IUI_V3F_EXT   
    unsigned int GL_IUI_N3F_V2F_EXT   
    unsigned int GL_IUI_N3F_V3F_EXT   
    unsigned int GL_T2F_IUI_V2F_EXT   
    unsigned int GL_T2F_IUI_V3F_EXT   
    unsigned int GL_T2F_IUI_N3F_V2F_EXT   
    unsigned int GL_T2F_IUI_N3F_V3F_EXT   
    unsigned int GL_ARRAY_ELEMENT_LOCK_FIRST_EXT   
    unsigned int GL_ARRAY_ELEMENT_LOCK_COUNT_EXT   
    unsigned int GL_CULL_VERTEX_EXT   
    unsigned int GL_CULL_VERTEX_EYE_POSITION_EXT   
    unsigned int GL_CULL_VERTEX_OBJECT_POSITION_EXT   
    unsigned int GL_YCRCB_422_SGIX   
    unsigned int GL_YCRCB_444_SGIX   
    unsigned int GL_FRAGMENT_LIGHTING_SGIX   
    unsigned int GL_FRAGMENT_COLOR_MATERIAL_SGIX   
    unsigned int GL_FRAGMENT_COLOR_MATERIAL_FACE_SGIX   
    unsigned int GL_FRAGMENT_COLOR_MATERIAL_PARAMETER_SGIX   
    unsigned int GL_MAX_FRAGMENT_LIGHTS_SGIX   
    unsigned int GL_MAX_ACTIVE_LIGHTS_SGIX   
    unsigned int GL_CURRENT_RASTER_NORMAL_SGIX   
    unsigned int GL_LIGHT_ENV_MODE_SGIX   
    unsigned int GL_FRAGMENT_LIGHT_MODEL_LOCAL_VIEWER_SGIX   
    unsigned int GL_FRAGMENT_LIGHT_MODEL_TWO_SIDE_SGIX   
    unsigned int GL_FRAGMENT_LIGHT_MODEL_AMBIENT_SGIX   
    unsigned int GL_FRAGMENT_LIGHT_MODEL_NORMAL_INTERPOLATION_SGIX   
    unsigned int GL_FRAGMENT_LIGHT0_SGIX   
    unsigned int GL_FRAGMENT_LIGHT1_SGIX   
    unsigned int GL_FRAGMENT_LIGHT2_SGIX   
    unsigned int GL_FRAGMENT_LIGHT3_SGIX   
    unsigned int GL_FRAGMENT_LIGHT4_SGIX   
    unsigned int GL_FRAGMENT_LIGHT5_SGIX   
    unsigned int GL_FRAGMENT_LIGHT6_SGIX   
    unsigned int GL_FRAGMENT_LIGHT7_SGIX   
    unsigned int GL_RASTER_POSITION_UNCLIPPED_IBM   
    unsigned int GL_TEXTURE_LIGHTING_MODE_HP   
    unsigned int GL_TEXTURE_POST_SPECULAR_HP   
    unsigned int GL_TEXTURE_PRE_SPECULAR_HP   
    unsigned int GL_MAX_ELEMENTS_VERTICES_EXT   
    unsigned int GL_MAX_ELEMENTS_INDICES_EXT   
    unsigned int GL_PHONG_WIN   
    unsigned int GL_PHONG_HINT_WIN   
    unsigned int GL_FOG_SPECULAR_TEXTURE_WIN   
    unsigned int GL_FRAGMENT_MATERIAL_EXT   
    unsigned int GL_FRAGMENT_NORMAL_EXT   
    unsigned int GL_FRAGMENT_COLOR_EXT   
    unsigned int GL_ATTENUATION_EXT   
    unsigned int GL_SHADOW_ATTENUATION_EXT   
    unsigned int GL_TEXTURE_APPLICATION_MODE_EXT   
    unsigned int GL_TEXTURE_LIGHT_EXT   
    unsigned int GL_TEXTURE_MATERIAL_FACE_EXT   
    unsigned int GL_TEXTURE_MATERIAL_PARAMETER_EXT   
    unsigned int GL_ALPHA_MIN_SGIX   
    unsigned int GL_ALPHA_MAX_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_Q_CEILING_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_Q_ROUND_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_Q_FLOOR_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_ALPHA_REPLACE_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_ALPHA_NO_REPLACE_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_ALPHA_LS_SGIX   
    unsigned int GL_PIXEL_TEX_GEN_ALPHA_MS_SGIX   
    unsigned int GL_BGR_EXT   
    unsigned int GL_BGRA_EXT   
    unsigned int GL_ASYNC_MARKER_SGIX   
    unsigned int GL_ASYNC_TEX_IMAGE_SGIX   
    unsigned int GL_ASYNC_DRAW_PIXELS_SGIX   
    unsigned int GL_ASYNC_READ_PIXELS_SGIX   
    unsigned int GL_MAX_ASYNC_TEX_IMAGE_SGIX   
    unsigned int GL_MAX_ASYNC_DRAW_PIXELS_SGIX   
    unsigned int GL_MAX_ASYNC_READ_PIXELS_SGIX   
    unsigned int GL_ASYNC_HISTOGRAM_SGIX   
    unsigned int GL_MAX_ASYNC_HISTOGRAM_SGIX   
    unsigned int GL_PARALLEL_ARRAYS_INTEL   
    unsigned int GL_VERTEX_ARRAY_PARALLEL_POINTERS_INTEL   
    unsigned int GL_NORMAL_ARRAY_PARALLEL_POINTERS_INTEL   
    unsigned int GL_COLOR_ARRAY_PARALLEL_POINTERS_INTEL   
    unsigned int GL_TEXTURE_COORD_ARRAY_PARALLEL_POINTERS_INTEL   
    unsigned int GL_OCCLUSION_TEST_HP   
    unsigned int GL_OCCLUSION_TEST_RESULT_HP   
    unsigned int GL_PIXEL_TRANSFORM_2D_EXT   
    unsigned int GL_PIXEL_MAG_FILTER_EXT   
    unsigned int GL_PIXEL_MIN_FILTER_EXT   
    unsigned int GL_PIXEL_CUBIC_WEIGHT_EXT   
    unsigned int GL_CUBIC_EXT   
    unsigned int GL_AVERAGE_EXT   
    unsigned int GL_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT   
    unsigned int GL_MAX_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT   
    unsigned int GL_PIXEL_TRANSFORM_2D_MATRIX_EXT   
    unsigned int GL_SHARED_TEXTURE_PALETTE_EXT   
    unsigned int GL_LIGHT_MODEL_COLOR_CONTROL_EXT   
    unsigned int GL_SINGLE_COLOR_EXT   
    unsigned int GL_SEPARATE_SPECULAR_COLOR_EXT   
    unsigned int GL_COLOR_SUM_EXT   
    unsigned int GL_CURRENT_SECONDARY_COLOR_EXT   
    unsigned int GL_SECONDARY_COLOR_ARRAY_SIZE_EXT   
    unsigned int GL_SECONDARY_COLOR_ARRAY_TYPE_EXT   
    unsigned int GL_SECONDARY_COLOR_ARRAY_STRIDE_EXT   
    unsigned int GL_SECONDARY_COLOR_ARRAY_POINTER_EXT   
    unsigned int GL_SECONDARY_COLOR_ARRAY_EXT   
    unsigned int GL_PERTURB_EXT   
    unsigned int GL_TEXTURE_NORMAL_EXT   
    unsigned int GL_FOG_COORDINATE_SOURCE_EXT   
    unsigned int GL_FOG_COORDINATE_EXT   
    unsigned int GL_FRAGMENT_DEPTH_EXT   
    unsigned int GL_CURRENT_FOG_COORDINATE_EXT   
    unsigned int GL_FOG_COORDINATE_ARRAY_TYPE_EXT   
    unsigned int GL_FOG_COORDINATE_ARRAY_STRIDE_EXT   
    unsigned int GL_FOG_COORDINATE_ARRAY_POINTER_EXT   
    unsigned int GL_FOG_COORDINATE_ARRAY_EXT   
    unsigned int GL_SCREEN_COORDINATES_REND   
    unsigned int GL_INVERTED_SCREEN_W_REND   
    unsigned int GL_TANGENT_ARRAY_EXT   
    unsigned int GL_BINORMAL_ARRAY_EXT   
    unsigned int GL_CURRENT_TANGENT_EXT   
    unsigned int GL_CURRENT_BINORMAL_EXT   
    unsigned int GL_TANGENT_ARRAY_TYPE_EXT   
    unsigned int GL_TANGENT_ARRAY_STRIDE_EXT   
    unsigned int GL_BINORMAL_ARRAY_TYPE_EXT   
    unsigned int GL_BINORMAL_ARRAY_STRIDE_EXT   
    unsigned int GL_TANGENT_ARRAY_POINTER_EXT   
    unsigned int GL_BINORMAL_ARRAY_POINTER_EXT   
    unsigned int GL_MAP1_TANGENT_EXT   
    unsigned int GL_MAP2_TANGENT_EXT   
    unsigned int GL_MAP1_BINORMAL_EXT   
    unsigned int GL_MAP2_BINORMAL_EXT   
    unsigned int GL_COMBINE_EXT   
    unsigned int GL_COMBINE_RGB_EXT   
    unsigned int GL_COMBINE_ALPHA_EXT   
    unsigned int GL_RGB_SCALE_EXT   
    unsigned int GL_ADD_SIGNED_EXT   
    unsigned int GL_INTERPOLATE_EXT   
    unsigned int GL_CONSTANT_EXT   
    unsigned int GL_PRIMARY_COLOR_EXT   
    unsigned int GL_PREVIOUS_EXT   
    unsigned int GL_SOURCE0_RGB_EXT   
    unsigned int GL_SOURCE1_RGB_EXT   
    unsigned int GL_SOURCE2_RGB_EXT   
    unsigned int GL_SOURCE0_ALPHA_EXT   
    unsigned int GL_SOURCE1_ALPHA_EXT   
    unsigned int GL_SOURCE2_ALPHA_EXT   
    unsigned int GL_OPERAND0_RGB_EXT   
    unsigned int GL_OPERAND1_RGB_EXT   
    unsigned int GL_OPERAND2_RGB_EXT   
    unsigned int GL_OPERAND0_ALPHA_EXT   
    unsigned int GL_OPERAND1_ALPHA_EXT   
    unsigned int GL_OPERAND2_ALPHA_EXT   
    unsigned int GL_LIGHT_MODEL_SPECULAR_VECTOR_APPLE   
    unsigned int GL_TRANSFORM_HINT_APPLE   
    unsigned int GL_FOG_SCALE_SGIX   
    unsigned int GL_FOG_SCALE_VALUE_SGIX   
    unsigned int GL_UNPACK_CONSTANT_DATA_SUNX   
    unsigned int GL_TEXTURE_CONSTANT_DATA_SUNX   
    unsigned int GL_GLOBAL_ALPHA_SUN   
    unsigned int GL_GLOBAL_ALPHA_FACTOR_SUN   
    unsigned int GL_RESTART_SUN   
    unsigned int GL_REPLACE_MIDDLE_SUN   
    unsigned int GL_REPLACE_OLDEST_SUN   
    unsigned int GL_TRIANGLE_LIST_SUN   
    unsigned int GL_REPLACEMENT_CODE_SUN   
    unsigned int GL_REPLACEMENT_CODE_ARRAY_SUN   
    unsigned int GL_REPLACEMENT_CODE_ARRAY_TYPE_SUN   
    unsigned int GL_REPLACEMENT_CODE_ARRAY_STRIDE_SUN   
    unsigned int GL_REPLACEMENT_CODE_ARRAY_POINTER_SUN   
    unsigned int GL_R1UI_V3F_SUN   
    unsigned int GL_R1UI_C4UB_V3F_SUN   
    unsigned int GL_R1UI_C3F_V3F_SUN   
    unsigned int GL_R1UI_N3F_V3F_SUN   
    unsigned int GL_R1UI_C4F_N3F_V3F_SUN   
    unsigned int GL_R1UI_T2F_V3F_SUN   
    unsigned int GL_R1UI_T2F_N3F_V3F_SUN   
    unsigned int GL_R1UI_T2F_C4F_N3F_V3F_SUN   
    unsigned int GL_BLEND_DST_RGB_EXT   
    unsigned int GL_BLEND_SRC_RGB_EXT   
    unsigned int GL_BLEND_DST_ALPHA_EXT   
    unsigned int GL_BLEND_SRC_ALPHA_EXT   
    unsigned int GL_RED_MIN_CLAMP_INGR   
    unsigned int GL_GREEN_MIN_CLAMP_INGR   
    unsigned int GL_BLUE_MIN_CLAMP_INGR   
    unsigned int GL_ALPHA_MIN_CLAMP_INGR   
    unsigned int GL_RED_MAX_CLAMP_INGR   
    unsigned int GL_GREEN_MAX_CLAMP_INGR   
    unsigned int GL_BLUE_MAX_CLAMP_INGR   
    unsigned int GL_ALPHA_MAX_CLAMP_INGR   
    unsigned int GL_INTERLACE_READ_INGR   
    unsigned int GL_INCR_WRAP_EXT   
    unsigned int GL_DECR_WRAP_EXT   
    unsigned int GL_422_EXT   
    unsigned int GL_422_REV_EXT   
    unsigned int GL_422_AVERAGE_EXT   
    unsigned int GL_422_REV_AVERAGE_EXT   
    unsigned int GL_NORMAL_MAP_NV   
    unsigned int GL_REFLECTION_MAP_NV   
    unsigned int GL_NORMAL_MAP_EXT   
    unsigned int GL_REFLECTION_MAP_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_EXT   
    unsigned int GL_TEXTURE_BINDING_CUBE_MAP_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT   
    unsigned int GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT   
    unsigned int GL_PROXY_TEXTURE_CUBE_MAP_EXT   
    unsigned int GL_MAX_CUBE_MAP_TEXTURE_SIZE_EXT   
    unsigned int GL_WRAP_BORDER_SUN   
    unsigned int GL_MAX_TEXTURE_LOD_BIAS_EXT   
    unsigned int GL_TEXTURE_FILTER_CONTROL_EXT   
    unsigned int GL_TEXTURE_LOD_BIAS_EXT   
    unsigned int GL_TEXTURE_MAX_ANISOTROPY_EXT   
    unsigned int GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT   
    unsigned int GL_MODELVIEW0_STACK_DEPTH_EXT
    unsigned int GL_MODELVIEW1_STACK_DEPTH_EXT   
    unsigned int GL_MODELVIEW0_MATRIX_EXT
    unsigned int GL_MODELVIEW1_MATRIX_EXT   
    unsigned int GL_VERTEX_WEIGHTING_EXT   
    unsigned int GL_MODELVIEW0_EXT
    unsigned int GL_MODELVIEW1_EXT   
    unsigned int GL_CURRENT_VERTEX_WEIGHT_EXT   
    unsigned int GL_VERTEX_WEIGHT_ARRAY_EXT   
    unsigned int GL_VERTEX_WEIGHT_ARRAY_SIZE_EXT   
    unsigned int GL_VERTEX_WEIGHT_ARRAY_TYPE_EXT   
    unsigned int GL_VERTEX_WEIGHT_ARRAY_STRIDE_EXT   
    unsigned int GL_VERTEX_WEIGHT_ARRAY_POINTER_EXT   
    unsigned int GL_MAX_SHININESS_NV   
    unsigned int GL_MAX_SPOT_EXPONENT_NV   
    unsigned int GL_VERTEX_ARRAY_RANGE_NV   
    unsigned int GL_VERTEX_ARRAY_RANGE_LENGTH_NV   
    unsigned int GL_VERTEX_ARRAY_RANGE_VALID_NV   
    unsigned int GL_MAX_VERTEX_ARRAY_RANGE_ELEMENT_NV   
    unsigned int GL_VERTEX_ARRAY_RANGE_POINTER_NV   
    unsigned int GL_REGISTER_COMBINERS_NV   
    unsigned int GL_VARIABLE_A_NV   
    unsigned int GL_VARIABLE_B_NV   
    unsigned int GL_VARIABLE_C_NV   
    unsigned int GL_VARIABLE_D_NV   
    unsigned int GL_VARIABLE_E_NV   
    unsigned int GL_VARIABLE_F_NV   
    unsigned int GL_VARIABLE_G_NV   
    unsigned int GL_CONSTANT_COLOR0_NV   
    unsigned int GL_CONSTANT_COLOR1_NV   
    unsigned int GL_PRIMARY_COLOR_NV   
    unsigned int GL_SECONDARY_COLOR_NV   
    unsigned int GL_SPARE0_NV   
    unsigned int GL_SPARE1_NV   
    unsigned int GL_DISCARD_NV   
    unsigned int GL_E_TIMES_F_NV   
    unsigned int GL_SPARE0_PLUS_SECONDARY_COLOR_NV   
    unsigned int GL_UNSIGNED_IDENTITY_NV   
    unsigned int GL_UNSIGNED_INVERT_NV   
    unsigned int GL_EXPAND_NORMAL_NV   
    unsigned int GL_EXPAND_NEGATE_NV   
    unsigned int GL_HALF_BIAS_NORMAL_NV   
    unsigned int GL_HALF_BIAS_NEGATE_NV   
    unsigned int GL_SIGNED_IDENTITY_NV   
    unsigned int GL_SIGNED_NEGATE_NV   
    unsigned int GL_SCALE_BY_TWO_NV   
    unsigned int GL_SCALE_BY_FOUR_NV   
    unsigned int GL_SCALE_BY_ONE_HALF_NV   
    unsigned int GL_BIAS_BY_NEGATIVE_ONE_HALF_NV   
    unsigned int GL_COMBINER_INPUT_NV   
    unsigned int GL_COMBINER_MAPPING_NV   
    unsigned int GL_COMBINER_COMPONENT_USAGE_NV   
    unsigned int GL_COMBINER_AB_DOT_PRODUCT_NV   
    unsigned int GL_COMBINER_CD_DOT_PRODUCT_NV   
    unsigned int GL_COMBINER_MUX_SUM_NV   
    unsigned int GL_COMBINER_SCALE_NV   
    unsigned int GL_COMBINER_BIAS_NV   
    unsigned int GL_COMBINER_AB_OUTPUT_NV   
    unsigned int GL_COMBINER_CD_OUTPUT_NV   
    unsigned int GL_COMBINER_SUM_OUTPUT_NV   
    unsigned int GL_MAX_GENERAL_COMBINERS_NV   
    unsigned int GL_NUM_GENERAL_COMBINERS_NV   
    unsigned int GL_COLOR_SUM_CLAMP_NV   
    unsigned int GL_COMBINER0_NV   
    unsigned int GL_COMBINER1_NV   
    unsigned int GL_COMBINER2_NV   
    unsigned int GL_COMBINER3_NV   
    unsigned int GL_COMBINER4_NV   
    unsigned int GL_COMBINER5_NV   
    unsigned int GL_COMBINER6_NV   
    unsigned int GL_COMBINER7_NV   
    unsigned int GL_FOG_DISTANCE_MODE_NV   
    unsigned int GL_EYE_RADIAL_NV   
    unsigned int GL_EYE_PLANE_ABSOLUTE_NV   
    unsigned int GL_EMBOSS_LIGHT_NV   
    unsigned int GL_EMBOSS_CONSTANT_NV   
    unsigned int GL_EMBOSS_MAP_NV   
    unsigned int GL_COMBINE4_NV   
    unsigned int GL_SOURCE3_RGB_NV   
    unsigned int GL_SOURCE3_ALPHA_NV   
    unsigned int GL_OPERAND3_RGB_NV   
    unsigned int GL_OPERAND3_ALPHA_NV   
    unsigned int GL_COMPRESSED_RGB_S3TC_DXT1_EXT   
    unsigned int GL_COMPRESSED_RGBA_S3TC_DXT1_EXT   
    unsigned int GL_COMPRESSED_RGBA_S3TC_DXT3_EXT   
    unsigned int GL_COMPRESSED_RGBA_S3TC_DXT5_EXT   
    unsigned int GL_CULL_VERTEX_IBM   
    unsigned int GL_VERTEX_ARRAY_LIST_IBM   
    unsigned int GL_NORMAL_ARRAY_LIST_IBM   
    unsigned int GL_COLOR_ARRAY_LIST_IBM   
    unsigned int GL_INDEX_ARRAY_LIST_IBM   
    unsigned int GL_TEXTURE_COORD_ARRAY_LIST_IBM   
    unsigned int GL_EDGE_FLAG_ARRAY_LIST_IBM   
    unsigned int GL_FOG_COORDINATE_ARRAY_LIST_IBM   
    unsigned int GL_SECONDARY_COLOR_ARRAY_LIST_IBM   
    unsigned int GL_VERTEX_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_NORMAL_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_COLOR_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_INDEX_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_TEXTURE_COORD_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_EDGE_FLAG_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_FOG_COORDINATE_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_SECONDARY_COLOR_ARRAY_LIST_STRIDE_IBM   
    unsigned int GL_PACK_SUBSAMPLE_RATE_SGIX   
    unsigned int GL_UNPACK_SUBSAMPLE_RATE_SGIX   
    unsigned int GL_PIXEL_SUBSAMPLE_4444_SGIX   
    unsigned int GL_PIXEL_SUBSAMPLE_2424_SGIX   
    unsigned int GL_PIXEL_SUBSAMPLE_4242_SGIX   
    unsigned int GL_YCRCB_SGIX   
    unsigned int GL_YCRCBA_SGIX   
    unsigned int GL_DEPTH_PASS_INSTRUMENT_SGIX   
    unsigned int GL_DEPTH_PASS_INSTRUMENT_COUNTERS_SGIX   
    unsigned int GL_DEPTH_PASS_INSTRUMENT_MAX_SGIX   
    unsigned int GL_COMPRESSED_RGB_FXT1_3DFX   
    unsigned int GL_COMPRESSED_RGBA_FXT1_3DFX   
    unsigned int GL_MULTISAMPLE_3DFX   
    unsigned int GL_SAMPLE_BUFFERS_3DFX   
    unsigned int GL_SAMPLES_3DFX   
    unsigned int GL_MULTISAMPLE_BIT_3DFX   
    unsigned int GL_MULTISAMPLE_EXT   
    unsigned int GL_SAMPLE_ALPHA_TO_MASK_EXT   
    unsigned int GL_SAMPLE_ALPHA_TO_ONE_EXT   
    unsigned int GL_SAMPLE_MASK_EXT   
    unsigned int GL_1PASS_EXT   
    unsigned int GL_2PASS_0_EXT   
    unsigned int GL_2PASS_1_EXT   
    unsigned int GL_4PASS_0_EXT   
    unsigned int GL_4PASS_1_EXT   
    unsigned int GL_4PASS_2_EXT   
    unsigned int GL_4PASS_3_EXT   
    unsigned int GL_SAMPLE_BUFFERS_EXT   
    unsigned int GL_SAMPLES_EXT   
    unsigned int GL_SAMPLE_MASK_VALUE_EXT   
    unsigned int GL_SAMPLE_MASK_INVERT_EXT   
    unsigned int GL_SAMPLE_PATTERN_EXT   
    unsigned int GL_MULTISAMPLE_BIT_EXT   
    unsigned int GL_VERTEX_PRECLIP_SGIX   
    unsigned int GL_VERTEX_PRECLIP_HINT_SGIX   
    unsigned int GL_CONVOLUTION_HINT_SGIX   
    unsigned int GL_PACK_RESAMPLE_SGIX   
    unsigned int GL_UNPACK_RESAMPLE_SGIX   
    unsigned int GL_RESAMPLE_REPLICATE_SGIX   
    unsigned int GL_RESAMPLE_ZERO_FILL_SGIX   
    unsigned int GL_RESAMPLE_DECIMATE_SGIX   
    unsigned int GL_EYE_DISTANCE_TO_POINT_SGIS   
    unsigned int GL_OBJECT_DISTANCE_TO_POINT_SGIS   
    unsigned int GL_EYE_DISTANCE_TO_LINE_SGIS   
    unsigned int GL_OBJECT_DISTANCE_TO_LINE_SGIS   
    unsigned int GL_EYE_POINT_SGIS   
    unsigned int GL_OBJECT_POINT_SGIS   
    unsigned int GL_EYE_LINE_SGIS   
    unsigned int GL_OBJECT_LINE_SGIS   
    unsigned int GL_TEXTURE_COLOR_WRITEMASK_SGIS   
    unsigned int GL_ALL_COMPLETED_NV   
    unsigned int GL_FENCE_STATUS_NV   
    unsigned int GL_FENCE_CONDITION_NV   
    unsigned int GL_MIRRORED_REPEAT_IBM   
    unsigned int GL_EVAL_2D_NV   
    unsigned int GL_EVAL_TRIANGULAR_2D_NV   
    unsigned int GL_MAP_TESSELLATION_NV   
    unsigned int GL_MAP_ATTRIB_U_ORDER_NV   
    unsigned int GL_MAP_ATTRIB_V_ORDER_NV   
    unsigned int GL_EVAL_FRACTIONAL_TESSELLATION_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB0_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB1_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB2_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB3_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB4_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB5_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB6_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB7_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB8_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB9_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB10_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB11_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB12_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB13_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB14_NV   
    unsigned int GL_EVAL_VERTEX_ATTRIB15_NV   
    unsigned int GL_MAX_MAP_TESSELLATION_NV   
    unsigned int GL_MAX_RATIONAL_EVAL_ORDER_NV   
    unsigned int GL_DEPTH_STENCIL_NV   
    unsigned int GL_UNSIGNED_INT_24_8_NV   
    unsigned int GL_PER_STAGE_CONSTANTS_NV   
    unsigned int GL_TEXTURE_RECTANGLE_NV   
    unsigned int GL_TEXTURE_BINDING_RECTANGLE_NV   
    unsigned int GL_PROXY_TEXTURE_RECTANGLE_NV   
    unsigned int GL_MAX_TEXTURE_RECTANGLE_SIZE_NV   
    unsigned int GL_OFFSET_TEXTURE_RECTANGLE_NV   
    unsigned int GL_OFFSET_TEXTURE_RECTANGLE_SCALE_NV   
    unsigned int GL_DOT_PRODUCT_TEXTURE_RECTANGLE_NV   
    unsigned int GL_RGBA_UNSIGNED_DOT_PRODUCT_MAPPING_NV   
    unsigned int GL_UNSIGNED_INT_S8_S8_8_8_NV   
    unsigned int GL_UNSIGNED_INT_8_8_S8_S8_REV_NV   
    unsigned int GL_DSDT_MAG_INTENSITY_NV   
    unsigned int GL_SHADER_CONSISTENT_NV   
    unsigned int GL_TEXTURE_SHADER_NV   
    unsigned int GL_SHADER_OPERATION_NV   
    unsigned int GL_CULL_MODES_NV   
    unsigned int GL_OFFSET_TEXTURE_MATRIX_NV   
    unsigned int GL_OFFSET_TEXTURE_SCALE_NV   
    unsigned int GL_OFFSET_TEXTURE_BIAS_NV   
    unsigned int GL_OFFSET_TEXTURE_2D_MATRIX_NV
    unsigned int GL_OFFSET_TEXTURE_2D_SCALE_NV 
    unsigned int GL_OFFSET_TEXTURE_2D_BIAS_NV
    unsigned int GL_PREVIOUS_TEXTURE_INPUT_NV   
    unsigned int GL_CONST_EYE_NV   
    unsigned int GL_PASS_THROUGH_NV   
    unsigned int GL_CULL_FRAGMENT_NV   
    unsigned int GL_OFFSET_TEXTURE_2D_NV   
    unsigned int GL_DEPENDENT_AR_TEXTURE_2D_NV   
    unsigned int GL_DEPENDENT_GB_TEXTURE_2D_NV   
    unsigned int GL_DOT_PRODUCT_NV   
    unsigned int GL_DOT_PRODUCT_DEPTH_REPLACE_NV   
    unsigned int GL_DOT_PRODUCT_TEXTURE_2D_NV   
    unsigned int GL_DOT_PRODUCT_TEXTURE_CUBE_MAP_NV   
    unsigned int GL_DOT_PRODUCT_DIFFUSE_CUBE_MAP_NV   
    unsigned int GL_DOT_PRODUCT_REFLECT_CUBE_MAP_NV   
    unsigned int GL_DOT_PRODUCT_CONST_EYE_REFLECT_CUBE_MAP_NV   
    unsigned int GL_HILO_NV   
    unsigned int GL_DSDT_NV   
    unsigned int GL_DSDT_MAG_NV   
    unsigned int GL_DSDT_MAG_VIB_NV   
    unsigned int GL_HILO16_NV   
    unsigned int GL_SIGNED_HILO_NV   
    unsigned int GL_SIGNED_HILO16_NV   
    unsigned int GL_SIGNED_RGBA_NV   
    unsigned int GL_SIGNED_RGBA8_NV   
    unsigned int GL_SIGNED_RGB_NV   
    unsigned int GL_SIGNED_RGB8_NV   
    unsigned int GL_SIGNED_LUMINANCE_NV   
    unsigned int GL_SIGNED_LUMINANCE8_NV   
    unsigned int GL_SIGNED_LUMINANCE_ALPHA_NV   
    unsigned int GL_SIGNED_LUMINANCE8_ALPHA8_NV   
    unsigned int GL_SIGNED_ALPHA_NV   
    unsigned int GL_SIGNED_ALPHA8_NV   
    unsigned int GL_SIGNED_INTENSITY_NV   
    unsigned int GL_SIGNED_INTENSITY8_NV   
    unsigned int GL_DSDT8_NV   
    unsigned int GL_DSDT8_MAG8_NV   
    unsigned int GL_DSDT8_MAG8_INTENSITY8_NV   
    unsigned int GL_SIGNED_RGB_UNSIGNED_ALPHA_NV   
    unsigned int GL_SIGNED_RGB8_UNSIGNED_ALPHA8_NV   
    unsigned int GL_HI_SCALE_NV   
    unsigned int GL_LO_SCALE_NV   
    unsigned int GL_DS_SCALE_NV   
    unsigned int GL_DT_SCALE_NV   
    unsigned int GL_MAGNITUDE_SCALE_NV   
    unsigned int GL_VIBRANCE_SCALE_NV   
    unsigned int GL_HI_BIAS_NV   
    unsigned int GL_LO_BIAS_NV   
    unsigned int GL_DS_BIAS_NV   
    unsigned int GL_DT_BIAS_NV   
    unsigned int GL_MAGNITUDE_BIAS_NV   
    unsigned int GL_VIBRANCE_BIAS_NV   
    unsigned int GL_TEXTURE_BORDER_VALUES_NV   
    unsigned int GL_TEXTURE_HI_SIZE_NV   
    unsigned int GL_TEXTURE_LO_SIZE_NV   
    unsigned int GL_TEXTURE_DS_SIZE_NV   
    unsigned int GL_TEXTURE_DT_SIZE_NV   
    unsigned int GL_TEXTURE_MAG_SIZE_NV   
    unsigned int GL_DOT_PRODUCT_TEXTURE_3D_NV   
    unsigned int GL_VERTEX_ARRAY_RANGE_WITHOUT_FLUSH_NV   
    unsigned int GL_VERTEX_PROGRAM_NV   
    unsigned int GL_VERTEX_STATE_PROGRAM_NV   
    unsigned int GL_ATTRIB_ARRAY_SIZE_NV   
    unsigned int GL_ATTRIB_ARRAY_STRIDE_NV   
    unsigned int GL_ATTRIB_ARRAY_TYPE_NV   
    unsigned int GL_CURRENT_ATTRIB_NV   
    unsigned int GL_PROGRAM_LENGTH_NV   
    unsigned int GL_PROGRAM_STRING_NV   
    unsigned int GL_MODELVIEW_PROJECTION_NV   
    unsigned int GL_IDENTITY_NV   
    unsigned int GL_INVERSE_NV   
    unsigned int GL_TRANSPOSE_NV   
    unsigned int GL_INVERSE_TRANSPOSE_NV   
    unsigned int GL_MAX_TRACK_MATRIX_STACK_DEPTH_NV   
    unsigned int GL_MAX_TRACK_MATRICES_NV   
    unsigned int GL_MATRIX0_NV   
    unsigned int GL_MATRIX1_NV   
    unsigned int GL_MATRIX2_NV   
    unsigned int GL_MATRIX3_NV   
    unsigned int GL_MATRIX4_NV   
    unsigned int GL_MATRIX5_NV   
    unsigned int GL_MATRIX6_NV   
    unsigned int GL_MATRIX7_NV   
    unsigned int GL_CURRENT_MATRIX_STACK_DEPTH_NV   
    unsigned int GL_CURRENT_MATRIX_NV   
    unsigned int GL_VERTEX_PROGRAM_POINT_SIZE_NV   
    unsigned int GL_VERTEX_PROGRAM_TWO_SIDE_NV   
    unsigned int GL_PROGRAM_PARAMETER_NV   
    unsigned int GL_ATTRIB_ARRAY_POINTER_NV   
    unsigned int GL_PROGRAM_TARGET_NV   
    unsigned int GL_PROGRAM_RESIDENT_NV   
    unsigned int GL_TRACK_MATRIX_NV   
    unsigned int GL_TRACK_MATRIX_TRANSFORM_NV   
    unsigned int GL_VERTEX_PROGRAM_BINDING_NV   
    unsigned int GL_PROGRAM_ERROR_POSITION_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY0_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY1_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY2_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY3_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY4_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY5_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY6_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY7_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY8_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY9_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY10_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY11_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY12_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY13_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY14_NV   
    unsigned int GL_VERTEX_ATTRIB_ARRAY15_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB0_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB1_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB2_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB3_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB4_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB5_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB6_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB7_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB8_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB9_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB10_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB11_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB12_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB13_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB14_4_NV   
    unsigned int GL_MAP1_VERTEX_ATTRIB15_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB0_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB1_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB2_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB3_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB4_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB5_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB6_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB7_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB8_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB9_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB10_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB11_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB12_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB13_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB14_4_NV   
    unsigned int GL_MAP2_VERTEX_ATTRIB15_4_NV   
    unsigned int GL_TEXTURE_MAX_CLAMP_S_SGIX   
    unsigned int GL_TEXTURE_MAX_CLAMP_T_SGIX   
    unsigned int GL_TEXTURE_MAX_CLAMP_R_SGIX   
    unsigned int GL_SCALEBIAS_HINT_SGIX   
    unsigned int GL_INTERLACE_OML   
    unsigned int GL_INTERLACE_READ_OML   
    unsigned int GL_FORMAT_SUBSAMPLE_24_24_OML   
    unsigned int GL_FORMAT_SUBSAMPLE_244_244_OML   
    unsigned int GL_PACK_RESAMPLE_OML   
    unsigned int GL_UNPACK_RESAMPLE_OML   
    unsigned int GL_RESAMPLE_REPLICATE_OML   
    unsigned int GL_RESAMPLE_ZERO_FILL_OML   
    unsigned int GL_RESAMPLE_AVERAGE_OML   
    unsigned int GL_RESAMPLE_DECIMATE_OML   
    unsigned int GL_DEPTH_STENCIL_TO_RGBA_NV   
    unsigned int GL_DEPTH_STENCIL_TO_BGRA_NV   
    unsigned int GL_BUMP_ROT_MATRIX_ATI   
    unsigned int GL_BUMP_ROT_MATRIX_SIZE_ATI   
    unsigned int GL_BUMP_NUM_TEX_UNITS_ATI   
    unsigned int GL_BUMP_TEX_UNITS_ATI   
    unsigned int GL_DUDV_ATI   
    unsigned int GL_DU8DV8_ATI   
    unsigned int GL_BUMP_ENVMAP_ATI   
    unsigned int GL_BUMP_TARGET_ATI   
    unsigned int GL_FRAGMENT_SHADER_ATI   
    unsigned int GL_REG_0_ATI   
    unsigned int GL_REG_1_ATI   
    unsigned int GL_REG_2_ATI   
    unsigned int GL_REG_3_ATI   
    unsigned int GL_REG_4_ATI   
    unsigned int GL_REG_5_ATI   
    unsigned int GL_REG_6_ATI   
    unsigned int GL_REG_7_ATI   
    unsigned int GL_REG_8_ATI   
    unsigned int GL_REG_9_ATI   
    unsigned int GL_REG_10_ATI   
    unsigned int GL_REG_11_ATI   
    unsigned int GL_REG_12_ATI   
    unsigned int GL_REG_13_ATI   
    unsigned int GL_REG_14_ATI   
    unsigned int GL_REG_15_ATI   
    unsigned int GL_REG_16_ATI   
    unsigned int GL_REG_17_ATI   
    unsigned int GL_REG_18_ATI   
    unsigned int GL_REG_19_ATI   
    unsigned int GL_REG_20_ATI   
    unsigned int GL_REG_21_ATI   
    unsigned int GL_REG_22_ATI   
    unsigned int GL_REG_23_ATI   
    unsigned int GL_REG_24_ATI   
    unsigned int GL_REG_25_ATI   
    unsigned int GL_REG_26_ATI   
    unsigned int GL_REG_27_ATI   
    unsigned int GL_REG_28_ATI   
    unsigned int GL_REG_29_ATI   
    unsigned int GL_REG_30_ATI   
    unsigned int GL_REG_31_ATI   
    unsigned int GL_CON_0_ATI   
    unsigned int GL_CON_1_ATI   
    unsigned int GL_CON_2_ATI   
    unsigned int GL_CON_3_ATI   
    unsigned int GL_CON_4_ATI   
    unsigned int GL_CON_5_ATI   
    unsigned int GL_CON_6_ATI   
    unsigned int GL_CON_7_ATI   
    unsigned int GL_CON_8_ATI   
    unsigned int GL_CON_9_ATI   
    unsigned int GL_CON_10_ATI   
    unsigned int GL_CON_11_ATI   
    unsigned int GL_CON_12_ATI   
    unsigned int GL_CON_13_ATI   
    unsigned int GL_CON_14_ATI   
    unsigned int GL_CON_15_ATI   
    unsigned int GL_CON_16_ATI   
    unsigned int GL_CON_17_ATI   
    unsigned int GL_CON_18_ATI   
    unsigned int GL_CON_19_ATI   
    unsigned int GL_CON_20_ATI   
    unsigned int GL_CON_21_ATI   
    unsigned int GL_CON_22_ATI   
    unsigned int GL_CON_23_ATI   
    unsigned int GL_CON_24_ATI   
    unsigned int GL_CON_25_ATI   
    unsigned int GL_CON_26_ATI   
    unsigned int GL_CON_27_ATI   
    unsigned int GL_CON_28_ATI   
    unsigned int GL_CON_29_ATI   
    unsigned int GL_CON_30_ATI   
    unsigned int GL_CON_31_ATI   
    unsigned int GL_MOV_ATI   
    unsigned int GL_ADD_ATI   
    unsigned int GL_MUL_ATI   
    unsigned int GL_SUB_ATI   
    unsigned int GL_DOT3_ATI   
    unsigned int GL_DOT4_ATI   
    unsigned int GL_MAD_ATI   
    unsigned int GL_LERP_ATI   
    unsigned int GL_CND_ATI   
    unsigned int GL_CND0_ATI   
    unsigned int GL_DOT2_ADD_ATI   
    unsigned int GL_SECONDARY_INTERPOLATOR_ATI   
    unsigned int GL_NUM_FRAGMENT_REGISTERS_ATI   
    unsigned int GL_NUM_FRAGMENT_CONSTANTS_ATI   
    unsigned int GL_NUM_PASSES_ATI   
    unsigned int GL_NUM_INSTRUCTIONS_PER_PASS_ATI   
    unsigned int GL_NUM_INSTRUCTIONS_TOTAL_ATI   
    unsigned int GL_NUM_INPUT_INTERPOLATOR_COMPONENTS_ATI   
    unsigned int GL_NUM_LOOPBACK_COMPONENTS_ATI   
    unsigned int GL_COLOR_ALPHA_PAIRING_ATI   
    unsigned int GL_SWIZZLE_STR_ATI   
    unsigned int GL_SWIZZLE_STQ_ATI   
    unsigned int GL_SWIZZLE_STR_DR_ATI   
    unsigned int GL_SWIZZLE_STQ_DQ_ATI   
    unsigned int GL_SWIZZLE_STRQ_ATI   
    unsigned int GL_SWIZZLE_STRQ_DQ_ATI   
    unsigned int GL_RED_BIT_ATI   
    unsigned int GL_GREEN_BIT_ATI   
    unsigned int GL_BLUE_BIT_ATI   
    unsigned int GL_2X_BIT_ATI   
    unsigned int GL_4X_BIT_ATI   
    unsigned int GL_8X_BIT_ATI   
    unsigned int GL_HALF_BIT_ATI   
    unsigned int GL_QUARTER_BIT_ATI   
    unsigned int GL_EIGHTH_BIT_ATI   
    unsigned int GL_SATURATE_BIT_ATI   
    unsigned int GL_COMP_BIT_ATI   
    unsigned int GL_NEGATE_BIT_ATI   
    unsigned int GL_BIAS_BIT_ATI   
    unsigned int GL_PN_TRIANGLES_ATI   
    unsigned int GL_MAX_PN_TRIANGLES_TESSELATION_LEVEL_ATI   
    unsigned int GL_PN_TRIANGLES_POINT_MODE_ATI   
    unsigned int GL_PN_TRIANGLES_NORMAL_MODE_ATI   
    unsigned int GL_PN_TRIANGLES_TESSELATION_LEVEL_ATI   
    unsigned int GL_PN_TRIANGLES_POINT_MODE_LINEAR_ATI   
    unsigned int GL_PN_TRIANGLES_POINT_MODE_CUBIC_ATI   
    unsigned int GL_PN_TRIANGLES_NORMAL_MODE_LINEAR_ATI   
    unsigned int GL_PN_TRIANGLES_NORMAL_MODE_QUADRATIC_ATI   
    unsigned int GL_STATIC_ATI   
    unsigned int GL_DYNAMIC_ATI   
    unsigned int GL_PRESERVE_ATI   
    unsigned int GL_DISCARD_ATI   
    unsigned int GL_OBJECT_BUFFER_SIZE_ATI   
    unsigned int GL_OBJECT_BUFFER_USAGE_ATI   
    unsigned int GL_ARRAY_OBJECT_BUFFER_ATI   
    unsigned int GL_ARRAY_OBJECT_OFFSET_ATI   
    unsigned int GL_VERTEX_SHADER_EXT   
    unsigned int GL_VERTEX_SHADER_BINDING_EXT   
    unsigned int GL_OP_INDEX_EXT   
    unsigned int GL_OP_NEGATE_EXT   
    unsigned int GL_OP_DOT3_EXT   
    unsigned int GL_OP_DOT4_EXT   
    unsigned int GL_OP_MUL_EXT   
    unsigned int GL_OP_ADD_EXT   
    unsigned int GL_OP_MADD_EXT   
    unsigned int GL_OP_FRAC_EXT   
    unsigned int GL_OP_MAX_EXT   
    unsigned int GL_OP_MIN_EXT   
    unsigned int GL_OP_SET_GE_EXT   
    unsigned int GL_OP_SET_LT_EXT   
    unsigned int GL_OP_CLAMP_EXT   
    unsigned int GL_OP_FLOOR_EXT   
    unsigned int GL_OP_ROUND_EXT   
    unsigned int GL_OP_EXP_BASE_2_EXT   
    unsigned int GL_OP_LOG_BASE_2_EXT   
    unsigned int GL_OP_POWER_EXT   
    unsigned int GL_OP_RECIP_EXT   
    unsigned int GL_OP_RECIP_SQRT_EXT   
    unsigned int GL_OP_SUB_EXT   
    unsigned int GL_OP_CROSS_PRODUCT_EXT   
    unsigned int GL_OP_MULTIPLY_MATRIX_EXT   
    unsigned int GL_OP_MOV_EXT   
    unsigned int GL_OUTPUT_VERTEX_EXT   
    unsigned int GL_OUTPUT_COLOR0_EXT   
    unsigned int GL_OUTPUT_COLOR1_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD0_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD1_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD2_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD3_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD4_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD5_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD6_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD7_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD8_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD9_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD10_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD11_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD12_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD13_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD14_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD15_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD16_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD17_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD18_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD19_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD20_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD21_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD22_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD23_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD24_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD25_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD26_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD27_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD28_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD29_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD30_EXT   
    unsigned int GL_OUTPUT_TEXTURE_COORD31_EXT   
    unsigned int GL_OUTPUT_FOG_EXT   
    unsigned int GL_SCALAR_EXT   
    unsigned int GL_VECTOR_EXT   
    unsigned int GL_MATRIX_EXT   
    unsigned int GL_VARIANT_EXT   
    unsigned int GL_INVARIANT_EXT   
    unsigned int GL_LOCAL_CONSTANT_EXT   
    unsigned int GL_LOCAL_EXT   
    unsigned int GL_MAX_VERTEX_SHADER_INSTRUCTIONS_EXT   
    unsigned int GL_MAX_VERTEX_SHADER_VARIANTS_EXT   
    unsigned int GL_MAX_VERTEX_SHADER_INVARIANTS_EXT   
    unsigned int GL_MAX_VERTEX_SHADER_LOCAL_CONSTANTS_EXT   
    unsigned int GL_MAX_VERTEX_SHADER_LOCALS_EXT   
    unsigned int GL_MAX_OPTIMIZED_VERTEX_SHADER_INSTRUCTIONS_EXT   
    unsigned int GL_MAX_OPTIMIZED_VERTEX_SHADER_VARIANTS_EXT   
    unsigned int GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCAL_CONSTANTS_EXT   
    unsigned int GL_MAX_OPTIMIZED_VERTEX_SHADER_INARIANTS_EXT   
    unsigned int GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCALS_EXT   
    unsigned int GL_VERTEX_SHADER_INSTRUCTIONS_EXT   
    unsigned int GL_VERTEX_SHADER_VARIANTS_EXT   
    unsigned int GL_VERTEX_SHADER_INVARIANTS_EXT   
    unsigned int GL_VERTEX_SHADER_LOCAL_CONSTANTS_EXT   
    unsigned int GL_VERTEX_SHADER_LOCALS_EXT   
    unsigned int GL_VERTEX_SHADER_OPTIMIZED_EXT   
    unsigned int GL_X_EXT   
    unsigned int GL_Y_EXT   
    unsigned int GL_Z_EXT   
    unsigned int GL_W_EXT   
    unsigned int GL_NEGATIVE_X_EXT   
    unsigned int GL_NEGATIVE_Y_EXT   
    unsigned int GL_NEGATIVE_Z_EXT   
    unsigned int GL_NEGATIVE_W_EXT   
    unsigned int GL_ZERO_EXT   
    unsigned int GL_ONE_EXT   
    unsigned int GL_NEGATIVE_ONE_EXT   
    unsigned int GL_NORMALIZED_RANGE_EXT   
    unsigned int GL_FULL_RANGE_EXT   
    unsigned int GL_CURRENT_VERTEX_EXT   
    unsigned int GL_MVP_MATRIX_EXT   
    unsigned int GL_VARIANT_VALUE_EXT   
    unsigned int GL_VARIANT_DATATYPE_EXT   
    unsigned int GL_VARIANT_ARRAY_STRIDE_EXT   
    unsigned int GL_VARIANT_ARRAY_TYPE_EXT   
    unsigned int GL_VARIANT_ARRAY_EXT   
    unsigned int GL_VARIANT_ARRAY_POINTER_EXT   
    unsigned int GL_INVARIANT_VALUE_EXT   
    unsigned int GL_INVARIANT_DATATYPE_EXT   
    unsigned int GL_LOCAL_CONSTANT_VALUE_EXT   
    unsigned int GL_LOCAL_CONSTANT_DATATYPE_EXT   
    unsigned int GL_MAX_VERTEX_STREAMS_ATI   
    unsigned int GL_VERTEX_STREAM0_ATI   
    unsigned int GL_VERTEX_STREAM1_ATI   
    unsigned int GL_VERTEX_STREAM2_ATI   
    unsigned int GL_VERTEX_STREAM3_ATI   
    unsigned int GL_VERTEX_STREAM4_ATI   
    unsigned int GL_VERTEX_STREAM5_ATI   
    unsigned int GL_VERTEX_STREAM6_ATI   
    unsigned int GL_VERTEX_STREAM7_ATI   
    unsigned int GL_VERTEX_SOURCE_ATI   
    unsigned int GL_ELEMENT_ARRAY_ATI   
    unsigned int GL_ELEMENT_ARRAY_TYPE_ATI   
    unsigned int GL_ELEMENT_ARRAY_POINTER_ATI   
    unsigned int GL_QUAD_MESH_SUN   
    unsigned int GL_TRIANGLE_MESH_SUN   
    unsigned int GL_SLICE_ACCUM_SUN   
    unsigned int GL_MULTISAMPLE_FILTER_HINT_NV   
    unsigned int GL_DEPTH_CLAMP_NV   
    unsigned int GL_PIXEL_COUNTER_BITS_NV   
    unsigned int GL_CURRENT_OCCLUSION_QUERY_ID_NV   
    unsigned int GL_PIXEL_COUNT_NV   
    unsigned int GL_PIXEL_COUNT_AVAILABLE_NV   
    unsigned int GL_POINT_SPRITE_NV   
    unsigned int GL_COORD_REPLACE_NV   
    unsigned int GL_POINT_SPRITE_R_MODE_NV   
    unsigned int GL_OFFSET_PROJECTIVE_TEXTURE_2D_NV   
    unsigned int GL_OFFSET_PROJECTIVE_TEXTURE_2D_SCALE_NV   
    unsigned int GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_NV   
    unsigned int GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_SCALE_NV   
    unsigned int GL_OFFSET_HILO_TEXTURE_2D_NV   
    unsigned int GL_OFFSET_HILO_TEXTURE_RECTANGLE_NV   
    unsigned int GL_OFFSET_HILO_PROJECTIVE_TEXTURE_2D_NV   
    unsigned int GL_OFFSET_HILO_PROJECTIVE_TEXTURE_RECTANGLE_NV   
    unsigned int GL_DEPENDENT_HILO_TEXTURE_2D_NV   
    unsigned int GL_DEPENDENT_RGB_TEXTURE_3D_NV   
    unsigned int GL_DEPENDENT_RGB_TEXTURE_CUBE_MAP_NV   
    unsigned int GL_DOT_PRODUCT_PASS_THROUGH_NV   
    unsigned int GL_DOT_PRODUCT_TEXTURE_1D_NV   
    unsigned int GL_DOT_PRODUCT_AFFINE_DEPTH_REPLACE_NV   
    unsigned int GL_HILO8_NV   
    unsigned int GL_SIGNED_HILO8_NV   
    unsigned int GL_FORCE_BLUE_TO_ONE_NV   
    unsigned int GL_VERSION_1_2   
    ctypedef   void ( * PFNGLBLENDCOLORPROC) (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)   nogil
    ctypedef   void ( * PFNGLBLENDEQUATIONPROC) (GLenum mode)   nogil
    ctypedef   void ( * PFNGLDRAWRANGEELEMENTSPROC) (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum _type,  GLvoid *indices)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEPROC) (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *table)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEPARAMETERFVPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEPARAMETERIVPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLCOPYCOLORTABLEPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *table)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERFVPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERIVPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLCOLORSUBTABLEPROC) (GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum _type,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOPYCOLORSUBTABLEPROC) (GLenum target, GLsizei start, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONFILTER1DPROC) (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *image)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONFILTER2DPROC) (GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *image)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERFPROC) (GLenum target, GLenum pname, GLfloat params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERFVPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERIPROC) (GLenum target, GLenum pname, GLint params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERIVPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLCOPYCONVOLUTIONFILTER1DPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLCOPYCONVOLUTIONFILTER2DPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONFILTERPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *image)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONPARAMETERFVPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONPARAMETERIVPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETSEPARABLEFILTERPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *row, GLvoid *column, GLvoid *span)   nogil
    ctypedef   void ( * PFNGLSEPARABLEFILTER2DPROC) (GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *row,  GLvoid *column)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMPROC) (GLenum target, GLboolean reset, GLenum format, GLenum _type, GLvoid *values)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMPARAMETERFVPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMPARAMETERIVPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETMINMAXPROC) (GLenum target, GLboolean reset, GLenum format, GLenum _type, GLvoid *values)   nogil
    ctypedef   void ( * PFNGLGETMINMAXPARAMETERFVPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETMINMAXPARAMETERIVPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLHISTOGRAMPROC) (GLenum target, GLsizei width, GLenum internalformat, GLboolean sink)   nogil
    ctypedef   void ( * PFNGLMINMAXPROC) (GLenum target, GLenum internalformat, GLboolean sink)   nogil
    ctypedef   void ( * PFNGLRESETHISTOGRAMPROC) (GLenum target)   nogil
    ctypedef   void ( * PFNGLRESETMINMAXPROC) (GLenum target)   nogil
    ctypedef   void ( * PFNGLTEXIMAGE3DPROC) (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    ctypedef   void ( * PFNGLTEXSUBIMAGE3DPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    ctypedef   void ( * PFNGLCOPYTEXSUBIMAGE3DPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    unsigned int GL_VERSION_1_3   
    ctypedef   void ( * PFNGLACTIVETEXTUREPROC) (GLenum texture)   nogil
    ctypedef   void ( * PFNGLCLIENTACTIVETEXTUREPROC) (GLenum texture)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1DPROC) (GLenum target, GLdouble s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1DVPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1FPROC) (GLenum target, GLfloat s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1FVPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1IPROC) (GLenum target, GLint s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1IVPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1SPROC) (GLenum target, GLshort s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1SVPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2DPROC) (GLenum target, GLdouble s, GLdouble t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2DVPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2FPROC) (GLenum target, GLfloat s, GLfloat t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2FVPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2IPROC) (GLenum target, GLint s, GLint t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2IVPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2SPROC) (GLenum target, GLshort s, GLshort t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2SVPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3DPROC) (GLenum target, GLdouble s, GLdouble t, GLdouble r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3DVPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3FPROC) (GLenum target, GLfloat s, GLfloat t, GLfloat r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3FVPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3IPROC) (GLenum target, GLint s, GLint t, GLint r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3IVPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3SPROC) (GLenum target, GLshort s, GLshort t, GLshort r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3SVPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4DPROC) (GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4DVPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4FPROC) (GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4FVPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4IPROC) (GLenum target, GLint s, GLint t, GLint r, GLint q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4IVPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4SPROC) (GLenum target, GLshort s, GLshort t, GLshort r, GLshort q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4SVPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLLOADTRANSPOSEMATRIXFPROC) ( GLfloat *m)   nogil
    ctypedef   void ( * PFNGLLOADTRANSPOSEMATRIXDPROC) ( GLdouble *m)   nogil
    ctypedef   void ( * PFNGLMULTTRANSPOSEMATRIXFPROC) ( GLfloat *m)   nogil
    ctypedef   void ( * PFNGLMULTTRANSPOSEMATRIXDPROC) ( GLdouble *m)   nogil
    ctypedef   void ( * PFNGLSAMPLECOVERAGEPROC) (GLclampf value, GLboolean invert)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE3DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE2DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE1DPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE1DPROC) (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLGETCOMPRESSEDTEXIMAGEPROC) (GLenum target, GLint level, void *img)   nogil
    unsigned int GL_ARB_multitexture   
    void  glActiveTextureARB (GLenum)   nogil
    void  glClientActiveTextureARB (GLenum)   nogil
    void  glMultiTexCoord1dARB (GLenum, GLdouble)   nogil
    void  glMultiTexCoord1dvARB (GLenum,  GLdouble *)   nogil
    void  glMultiTexCoord1fARB (GLenum, GLfloat)   nogil
    void  glMultiTexCoord1fvARB (GLenum,  GLfloat *)   nogil
    void  glMultiTexCoord1iARB (GLenum, GLint)   nogil
    void  glMultiTexCoord1ivARB (GLenum,  GLint *)   nogil
    void  glMultiTexCoord1sARB (GLenum, GLshort)   nogil
    void  glMultiTexCoord1svARB (GLenum,  GLshort *)   nogil
    void  glMultiTexCoord2dARB (GLenum, GLdouble, GLdouble)   nogil
    void  glMultiTexCoord2dvARB (GLenum,  GLdouble *)   nogil
    # void  glMultiTexCoord2fARB (GLenum, GLfloat, GLfloat)   nogil
    void  glMultiTexCoord2fvARB (GLenum,  GLfloat *)   nogil
    void  glMultiTexCoord2iARB (GLenum, GLint, GLint)   nogil
    void  glMultiTexCoord2ivARB (GLenum,  GLint *)   nogil
    void  glMultiTexCoord2sARB (GLenum, GLshort, GLshort)   nogil
    void  glMultiTexCoord2svARB (GLenum,  GLshort *)   nogil
    void  glMultiTexCoord3dARB (GLenum, GLdouble, GLdouble, GLdouble)   nogil
    void  glMultiTexCoord3dvARB (GLenum,  GLdouble *)   nogil
    void  glMultiTexCoord3fARB (GLenum, GLfloat, GLfloat, GLfloat)   nogil
    void  glMultiTexCoord3fvARB (GLenum,  GLfloat *)   nogil
    void  glMultiTexCoord3iARB (GLenum, GLint, GLint, GLint)   nogil
    void  glMultiTexCoord3ivARB (GLenum,  GLint *)   nogil
    void  glMultiTexCoord3sARB (GLenum, GLshort, GLshort, GLshort)   nogil
    void  glMultiTexCoord3svARB (GLenum,  GLshort *)   nogil
    void  glMultiTexCoord4dARB (GLenum, GLdouble, GLdouble, GLdouble, GLdouble)   nogil
    void  glMultiTexCoord4dvARB (GLenum,  GLdouble *)   nogil
    void  glMultiTexCoord4fARB (GLenum, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glMultiTexCoord4fvARB (GLenum,  GLfloat *)   nogil
    void  glMultiTexCoord4iARB (GLenum, GLint, GLint, GLint, GLint)   nogil
    void  glMultiTexCoord4ivARB (GLenum,  GLint *)   nogil
    void  glMultiTexCoord4sARB (GLenum, GLshort, GLshort, GLshort, GLshort)   nogil
    void  glMultiTexCoord4svARB (GLenum,  GLshort *)   nogil
    ctypedef   void ( * PFNGLACTIVETEXTUREARBPROC) (GLenum texture)   nogil
    ctypedef   void ( * PFNGLCLIENTACTIVETEXTUREARBPROC) (GLenum texture)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1DARBPROC) (GLenum target, GLdouble s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1DVARBPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1FARBPROC) (GLenum target, GLfloat s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1FVARBPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1IARBPROC) (GLenum target, GLint s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1IVARBPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1SARBPROC) (GLenum target, GLshort s)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD1SVARBPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2DARBPROC) (GLenum target, GLdouble s, GLdouble t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2DVARBPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2FARBPROC) (GLenum target, GLfloat s, GLfloat t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2FVARBPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2IARBPROC) (GLenum target, GLint s, GLint t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2IVARBPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2SARBPROC) (GLenum target, GLshort s, GLshort t)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD2SVARBPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3DARBPROC) (GLenum target, GLdouble s, GLdouble t, GLdouble r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3DVARBPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3FARBPROC) (GLenum target, GLfloat s, GLfloat t, GLfloat r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3FVARBPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3IARBPROC) (GLenum target, GLint s, GLint t, GLint r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3IVARBPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3SARBPROC) (GLenum target, GLshort s, GLshort t, GLshort r)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD3SVARBPROC) (GLenum target,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4DARBPROC) (GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4DVARBPROC) (GLenum target,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4FARBPROC) (GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4FVARBPROC) (GLenum target,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4IARBPROC) (GLenum target, GLint s, GLint t, GLint r, GLint q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4IVARBPROC) (GLenum target,  GLint *v)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4SARBPROC) (GLenum target, GLshort s, GLshort t, GLshort r, GLshort q)   nogil
    ctypedef   void ( * PFNGLMULTITEXCOORD4SVARBPROC) (GLenum target,  GLshort *v)   nogil
    unsigned int GL_ARB_transpose_matrix   
    void  glLoadTransposeMatrixfARB ( GLfloat *)   nogil
    void  glLoadTransposeMatrixdARB ( GLdouble *)   nogil
    void  glMultTransposeMatrixfARB ( GLfloat *)   nogil
    void  glMultTransposeMatrixdARB ( GLdouble *)   nogil
    ctypedef   void ( * PFNGLLOADTRANSPOSEMATRIXFARBPROC) ( GLfloat *m)   nogil
    ctypedef   void ( * PFNGLLOADTRANSPOSEMATRIXDARBPROC) ( GLdouble *m)   nogil
    ctypedef   void ( * PFNGLMULTTRANSPOSEMATRIXFARBPROC) ( GLfloat *m)   nogil
    ctypedef   void ( * PFNGLMULTTRANSPOSEMATRIXDARBPROC) ( GLdouble *m)   nogil
    unsigned int GL_ARB_multisample   
    void  glSampleCoverageARB (GLclampf, GLboolean)   nogil
    ctypedef   void ( * PFNGLSAMPLECOVERAGEARBPROC) (GLclampf value, GLboolean invert)   nogil
    unsigned int GL_ARB_texture_env_add   
    unsigned int GL_ARB_texture_cube_map   
    unsigned int GL_ARB_texture_compression   
    void  glCompressedTexImage3DARB (GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLsizei,  GLvoid *)   nogil
    void  glCompressedTexImage2DARB (GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei,  GLvoid *)   nogil
    void  glCompressedTexImage1DARB (GLenum, GLint, GLenum, GLsizei, GLint, GLsizei,  GLvoid *)   nogil
    void  glCompressedTexSubImage3DARB (GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLsizei,  GLvoid *)   nogil
    void  glCompressedTexSubImage2DARB (GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLsizei,  GLvoid *)   nogil
    void  glCompressedTexSubImage1DARB (GLenum, GLint, GLint, GLsizei, GLenum, GLsizei,  GLvoid *)   nogil
    void  glGetCompressedTexImageARB (GLenum, GLint, void *)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE3DARBPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE2DARBPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXIMAGE1DARBPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE3DARBPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE2DARBPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOMPRESSEDTEXSUBIMAGE1DARBPROC) (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLGETCOMPRESSEDTEXIMAGEARBPROC) (GLenum target, GLint level, void *img)   nogil
    unsigned int GL_ARB_texture_border_clamp   
    unsigned int GL_ARB_point_parameters   
    void  glPointParameterfARB (GLenum, GLfloat)   nogil
    void  glPointParameterfvARB (GLenum,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFARBPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFVARBPROC) (GLenum pname,  GLfloat *params)   nogil
    unsigned int GL_ARB_vertex_blend   
    void  glWeightbvARB (GLint,  GLbyte *)   nogil
    void  glWeightsvARB (GLint,  GLshort *)   nogil
    void  glWeightivARB (GLint,  GLint *)   nogil
    void  glWeightfvARB (GLint,  GLfloat *)   nogil
    void  glWeightdvARB (GLint,  GLdouble *)   nogil
    void  glWeightubvARB (GLint,  GLubyte *)   nogil
    void  glWeightusvARB (GLint,  GLushort *)   nogil
    void  glWeightuivARB (GLint,  GLuint *)   nogil
    void  glWeightPointerARB (GLint, GLenum, GLsizei,  GLvoid *)   nogil
    void  glVertexBlendARB (GLint)   nogil
    ctypedef   void ( * PFNGLWEIGHTBVARBPROC) (GLint size,  GLbyte *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTSVARBPROC) (GLint size,  GLshort *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTIVARBPROC) (GLint size,  GLint *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTFVARBPROC) (GLint size,  GLfloat *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTDVARBPROC) (GLint size,  GLdouble *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTUBVARBPROC) (GLint size,  GLubyte *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTUSVARBPROC) (GLint size,  GLushort *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTUIVARBPROC) (GLint size,  GLuint *weights)   nogil
    ctypedef   void ( * PFNGLWEIGHTPOINTERARBPROC) (GLint size, GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLVERTEXBLENDARBPROC) (GLint count)   nogil
    unsigned int GL_ARB_matrix_palette   
    void  glCurrentPaletteMatrixARB (GLint)   nogil
    void  glMatrixIndexubvARB (GLint,  GLubyte *)   nogil
    void  glMatrixIndexusvARB (GLint,  GLushort *)   nogil
    void  glMatrixIndexuivARB (GLint,  GLuint *)   nogil
    void  glMatrixIndexPointerARB (GLint, GLenum, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLCURRENTPALETTEMATRIXARBPROC) (GLint index)   nogil
    ctypedef   void ( * PFNGLMATRIXINDEXUBVARBPROC) (GLint size,  GLubyte *indices)   nogil
    ctypedef   void ( * PFNGLMATRIXINDEXUSVARBPROC) (GLint size,  GLushort *indices)   nogil
    ctypedef   void ( * PFNGLMATRIXINDEXUIVARBPROC) (GLint size,  GLuint *indices)   nogil
    ctypedef   void ( * PFNGLMATRIXINDEXPOINTERARBPROC) (GLint size, GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    unsigned int GL_ARB_texture_env_combine   
    unsigned int GL_ARB_texture_env_crossbar   
    unsigned int GL_ARB_texture_env_dot3   
    unsigned int GL_ARB_texture_mirror_repeat   
    unsigned int GL_ARB_depth_texture   
    unsigned int GL_ARB_shadow   
    unsigned int GL_ARB_shadow_ambient   
    unsigned int GL_ARB_window_pos   
    void  glWindowPos2dARB (GLdouble, GLdouble)   nogil
    void  glWindowPos2dvARB ( GLdouble *)   nogil
    void  glWindowPos2fARB (GLfloat, GLfloat)   nogil
    void  glWindowPos2fvARB ( GLfloat *)   nogil
    void  glWindowPos2iARB (GLint, GLint)   nogil
    void  glWindowPos2ivARB ( GLint *)   nogil
    void  glWindowPos2sARB (GLshort, GLshort)   nogil
    void  glWindowPos2svARB ( GLshort *)   nogil
    void  glWindowPos3dARB (GLdouble, GLdouble, GLdouble)   nogil
    void  glWindowPos3dvARB ( GLdouble *)   nogil
    void  glWindowPos3fARB (GLfloat, GLfloat, GLfloat)   nogil
    void  glWindowPos3fvARB ( GLfloat *)   nogil
    void  glWindowPos3iARB (GLint, GLint, GLint)   nogil
    void  glWindowPos3ivARB ( GLint *)   nogil
    void  glWindowPos3sARB (GLshort, GLshort, GLshort)   nogil
    void  glWindowPos3svARB ( GLshort *)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2DARBPROC) (GLdouble x, GLdouble y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2DVARBPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2FARBPROC) (GLfloat x, GLfloat y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2FVARBPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2IARBPROC) (GLint x, GLint y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2IVARBPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2SARBPROC) (GLshort x, GLshort y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2SVARBPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3DARBPROC) (GLdouble x, GLdouble y, GLdouble z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3DVARBPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3FARBPROC) (GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3FVARBPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3IARBPROC) (GLint x, GLint y, GLint z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3IVARBPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3SARBPROC) (GLshort x, GLshort y, GLshort z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3SVARBPROC) ( GLshort *v)   nogil
    unsigned int GL_EXT_abgr   
    unsigned int GL_EXT_blend_color   
    void  glBlendColorEXT (GLclampf, GLclampf, GLclampf, GLclampf)   nogil
    ctypedef   void ( * PFNGLBLENDCOLOREXTPROC) (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)   nogil
    unsigned int GL_EXT_polygon_offset   
    void  glPolygonOffsetEXT (GLfloat, GLfloat)   nogil
    ctypedef   void ( * PFNGLPOLYGONOFFSETEXTPROC) (GLfloat factor, GLfloat bias)   nogil
    unsigned int GL_EXT_texture   
    unsigned int GL_EXT_texture3D   
    void  glTexImage3DEXT (GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum,  GLvoid *)   nogil
    void  glTexSubImage3DEXT (GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLTEXIMAGE3DEXTPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    ctypedef   void ( * PFNGLTEXSUBIMAGE3DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    unsigned int GL_SGIS_texture_filter4   
    void  glGetTexFilterFuncSGIS (GLenum, GLenum, GLfloat *)   nogil
    void  glTexFilterFuncSGIS (GLenum, GLenum, GLsizei,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLGETTEXFILTERFUNCSGISPROC) (GLenum target, GLenum filter, GLfloat *weights)   nogil
    ctypedef   void ( * PFNGLTEXFILTERFUNCSGISPROC) (GLenum target, GLenum filter, GLsizei n,  GLfloat *weights)   nogil
    unsigned int GL_EXT_subtexture   
    void  glTexSubImage1DEXT (GLenum, GLint, GLint, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glTexSubImage2DEXT (GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLTEXSUBIMAGE1DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    ctypedef   void ( * PFNGLTEXSUBIMAGE2DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    unsigned int GL_EXT_copy_texture   
    void  glCopyTexImage1DEXT (GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLint)   nogil
    void  glCopyTexImage2DEXT (GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLsizei, GLint)   nogil
    void  glCopyTexSubImage1DEXT (GLenum, GLint, GLint, GLint, GLint, GLsizei)   nogil
    void  glCopyTexSubImage2DEXT (GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei)   nogil
    void  glCopyTexSubImage3DEXT (GLenum, GLint, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei)   nogil
    ctypedef   void ( * PFNGLCOPYTEXIMAGE1DEXTPROC) (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border)   nogil
    ctypedef   void ( * PFNGLCOPYTEXIMAGE2DEXTPROC) (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border)   nogil
    ctypedef   void ( * PFNGLCOPYTEXSUBIMAGE1DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLCOPYTEXSUBIMAGE2DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    ctypedef   void ( * PFNGLCOPYTEXSUBIMAGE3DEXTPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    unsigned int GL_EXT_histogram   
    void  glGetHistogramEXT (GLenum, GLboolean, GLenum, GLenum, GLvoid *)   nogil
    void  glGetHistogramParameterfvEXT (GLenum, GLenum, GLfloat *)   nogil
    void  glGetHistogramParameterivEXT (GLenum, GLenum, GLint *)   nogil
    void  glGetMinmaxEXT (GLenum, GLboolean, GLenum, GLenum, GLvoid *)   nogil
    void  glGetMinmaxParameterfvEXT (GLenum, GLenum, GLfloat *)   nogil
    void  glGetMinmaxParameterivEXT (GLenum, GLenum, GLint *)   nogil
    void  glHistogramEXT (GLenum, GLsizei, GLenum, GLboolean)   nogil
    void  glMinmaxEXT (GLenum, GLenum, GLboolean)   nogil
    void  glResetHistogramEXT (GLenum)   nogil
    void  glResetMinmaxEXT (GLenum)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMEXTPROC) (GLenum target, GLboolean reset, GLenum format, GLenum _type, GLvoid *values)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMPARAMETERFVEXTPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETHISTOGRAMPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETMINMAXEXTPROC) (GLenum target, GLboolean reset, GLenum format, GLenum _type, GLvoid *values)   nogil
    ctypedef   void ( * PFNGLGETMINMAXPARAMETERFVEXTPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETMINMAXPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLHISTOGRAMEXTPROC) (GLenum target, GLsizei width, GLenum internalformat, GLboolean sink)   nogil
    ctypedef   void ( * PFNGLMINMAXEXTPROC) (GLenum target, GLenum internalformat, GLboolean sink)   nogil
    ctypedef   void ( * PFNGLRESETHISTOGRAMEXTPROC) (GLenum target)   nogil
    ctypedef   void ( * PFNGLRESETMINMAXEXTPROC) (GLenum target)   nogil
    unsigned int GL_EXT_convolution   
    void  glConvolutionFilter1DEXT (GLenum, GLenum, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glConvolutionFilter2DEXT (GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glConvolutionParameterfEXT (GLenum, GLenum, GLfloat)   nogil
    void  glConvolutionParameterfvEXT (GLenum, GLenum,  GLfloat *)   nogil
    void  glConvolutionParameteriEXT (GLenum, GLenum, GLint)   nogil
    void  glConvolutionParameterivEXT (GLenum, GLenum,  GLint *)   nogil
    void  glCopyConvolutionFilter1DEXT (GLenum, GLenum, GLint, GLint, GLsizei)   nogil
    void  glCopyConvolutionFilter2DEXT (GLenum, GLenum, GLint, GLint, GLsizei, GLsizei)   nogil
    void  glGetConvolutionFilterEXT (GLenum, GLenum, GLenum, GLvoid *)   nogil
    void  glGetConvolutionParameterfvEXT (GLenum, GLenum, GLfloat *)   nogil
    void  glGetConvolutionParameterivEXT (GLenum, GLenum, GLint *)   nogil
    void  glGetSeparableFilterEXT (GLenum, GLenum, GLenum, GLvoid *, GLvoid *, GLvoid *)   nogil
    void  glSeparableFilter2DEXT (GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONFILTER1DEXTPROC) (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *image)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONFILTER2DEXTPROC) (GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *image)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERFEXTPROC) (GLenum target, GLenum pname, GLfloat params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERFVEXTPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERIEXTPROC) (GLenum target, GLenum pname, GLint params)   nogil
    ctypedef   void ( * PFNGLCONVOLUTIONPARAMETERIVEXTPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLCOPYCONVOLUTIONFILTER1DEXTPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLCOPYCONVOLUTIONFILTER2DEXTPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONFILTEREXTPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *image)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONPARAMETERFVEXTPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCONVOLUTIONPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETSEPARABLEFILTEREXTPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *row, GLvoid *column, GLvoid *span)   nogil
    ctypedef   void ( * PFNGLSEPARABLEFILTER2DEXTPROC) (GLenum target, GLenum internalformat, GLsizei width, GLsizei height, GLenum format, GLenum _type,  GLvoid *row,  GLvoid *column)   nogil
    unsigned int GL_EXT_color_matrix   
    unsigned int GL_SGI_color_table   
    void  glColorTableSGI (GLenum, GLenum, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glColorTableParameterfvSGI (GLenum, GLenum,  GLfloat *)   nogil
    void  glColorTableParameterivSGI (GLenum, GLenum,  GLint *)   nogil
    void  glCopyColorTableSGI (GLenum, GLenum, GLint, GLint, GLsizei)   nogil
    void  glGetColorTableSGI (GLenum, GLenum, GLenum, GLvoid *)   nogil
    void  glGetColorTableParameterfvSGI (GLenum, GLenum, GLfloat *)   nogil
    void  glGetColorTableParameterivSGI (GLenum, GLenum, GLint *)   nogil
    ctypedef   void ( * PFNGLCOLORTABLESGIPROC) (GLenum target, GLenum internalformat, GLsizei width, GLenum format, GLenum _type,  GLvoid *table)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEPARAMETERFVSGIPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEPARAMETERIVSGIPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLCOPYCOLORTABLESGIPROC) (GLenum target, GLenum internalformat, GLint x, GLint y, GLsizei width)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLESGIPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *table)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERFVSGIPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERIVSGIPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    unsigned int GL_SGIX_pixel_texture   
    void  glPixelTexGenSGIX (GLenum)   nogil
    ctypedef   void ( * PFNGLPIXELTEXGENSGIXPROC) (GLenum mode)   nogil
    unsigned int GL_SGIS_pixel_texture   
    void  glPixelTexGenParameteriSGIS (GLenum, GLint)   nogil
    void  glPixelTexGenParameterivSGIS (GLenum,  GLint *)   nogil
    void  glPixelTexGenParameterfSGIS (GLenum, GLfloat)   nogil
    void  glPixelTexGenParameterfvSGIS (GLenum,  GLfloat *)   nogil
    void  glGetPixelTexGenParameterivSGIS (GLenum, GLint *)   nogil
    void  glGetPixelTexGenParameterfvSGIS (GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLPIXELTEXGENPARAMETERISGISPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLPIXELTEXGENPARAMETERIVSGISPROC) (GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLPIXELTEXGENPARAMETERFSGISPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLPIXELTEXGENPARAMETERFVSGISPROC) (GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETPIXELTEXGENPARAMETERIVSGISPROC) (GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETPIXELTEXGENPARAMETERFVSGISPROC) (GLenum pname, GLfloat *params)   nogil
    unsigned int GL_SGIS_texture4D   
    void  glTexImage4DSGIS (GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum,  GLvoid *)   nogil
    void  glTexSubImage4DSGIS (GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLTEXIMAGE4DSGISPROC) (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLsizei size4d, GLint border, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    ctypedef   void ( * PFNGLTEXSUBIMAGE4DSGISPROC) (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint woffset, GLsizei width, GLsizei height, GLsizei depth, GLsizei size4d, GLenum format, GLenum _type,  GLvoid *pixels)   nogil
    unsigned int GL_SGI_texture_color_table   
    unsigned int GL_EXT_cmyka   
    unsigned int GL_EXT_texture_object   
    GLboolean  glAreTexturesResidentEXT (GLsizei,  GLuint *, GLboolean *)   nogil
    void  glBindTextureEXT (GLenum, GLuint)   nogil
    void  glDeleteTexturesEXT (GLsizei,  GLuint *)   nogil
    void  glGenTexturesEXT (GLsizei, GLuint *)   nogil
    GLboolean  glIsTextureEXT (GLuint)   nogil
    void  glPrioritizeTexturesEXT (GLsizei,  GLuint *,  GLclampf *)   nogil
    ctypedef   GLboolean ( * PFNGLARETEXTURESRESIDENTEXTPROC) (GLsizei n,  GLuint *textures, GLboolean *residences)   nogil
    ctypedef   void ( * PFNGLBINDTEXTUREEXTPROC) (GLenum target, GLuint texture)   nogil
    ctypedef   void ( * PFNGLDELETETEXTURESEXTPROC) (GLsizei n,  GLuint *textures)   nogil
    ctypedef   void ( * PFNGLGENTEXTURESEXTPROC) (GLsizei n, GLuint *textures)   nogil
    ctypedef   GLboolean ( * PFNGLISTEXTUREEXTPROC) (GLuint texture)   nogil
    ctypedef   void ( * PFNGLPRIORITIZETEXTURESEXTPROC) (GLsizei n,  GLuint *textures,  GLclampf *priorities)   nogil
    unsigned int GL_SGIS_detail_texture   
    void  glDetailTexFuncSGIS (GLenum, GLsizei,  GLfloat *)   nogil
    void  glGetDetailTexFuncSGIS (GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLDETAILTEXFUNCSGISPROC) (GLenum target, GLsizei n,  GLfloat *points)   nogil
    ctypedef   void ( * PFNGLGETDETAILTEXFUNCSGISPROC) (GLenum target, GLfloat *points)   nogil
    unsigned int GL_SGIS_sharpen_texture   
    void  glSharpenTexFuncSGIS (GLenum, GLsizei,  GLfloat *)   nogil
    void  glGetSharpenTexFuncSGIS (GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLSHARPENTEXFUNCSGISPROC) (GLenum target, GLsizei n,  GLfloat *points)   nogil
    ctypedef   void ( * PFNGLGETSHARPENTEXFUNCSGISPROC) (GLenum target, GLfloat *points)   nogil
    unsigned int GL_EXT_packed_pixels   
    unsigned int GL_SGIS_texture_lod   
    unsigned int GL_SGIS_multisample   
    void  glSampleMaskSGIS (GLclampf, GLboolean)   nogil
    void  glSamplePatternSGIS (GLenum)   nogil
    ctypedef   void ( * PFNGLSAMPLEMASKSGISPROC) (GLclampf value, GLboolean invert)   nogil
    ctypedef   void ( * PFNGLSAMPLEPATTERNSGISPROC) (GLenum pattern)   nogil
    unsigned int GL_EXT_rescale_normal   
    unsigned int GL_EXT_vertex_array   
    void  glArrayElementEXT (GLint)   nogil
    void  glColorPointerEXT (GLint, GLenum, GLsizei, GLsizei,  GLvoid *)   nogil
    void  glDrawArraysEXT (GLenum, GLint, GLsizei)   nogil
    void  glEdgeFlagPointerEXT (GLsizei, GLsizei,  GLboolean *)   nogil
    void  glGetPointervEXT (GLenum, GLvoid* *)   nogil
    void  glIndexPointerEXT (GLenum, GLsizei, GLsizei,  GLvoid *)   nogil
    void  glNormalPointerEXT (GLenum, GLsizei, GLsizei,  GLvoid *)   nogil
    void  glTexCoordPointerEXT (GLint, GLenum, GLsizei, GLsizei,  GLvoid *)   nogil
    void  glVertexPointerEXT (GLint, GLenum, GLsizei, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLARRAYELEMENTEXTPROC) (GLint i)   nogil
    ctypedef   void ( * PFNGLCOLORPOINTEREXTPROC) (GLint size, GLenum _type, GLsizei stride, GLsizei count,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLDRAWARRAYSEXTPROC) (GLenum mode, GLint first, GLsizei count)   nogil
    ctypedef   void ( * PFNGLEDGEFLAGPOINTEREXTPROC) (GLsizei stride, GLsizei count,  GLboolean *pointer)   nogil
    ctypedef   void ( * PFNGLGETPOINTERVEXTPROC) (GLenum pname, GLvoid* *params)   nogil
    ctypedef   void ( * PFNGLINDEXPOINTEREXTPROC) (GLenum _type, GLsizei stride, GLsizei count,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLNORMALPOINTEREXTPROC) (GLenum _type, GLsizei stride, GLsizei count,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLTEXCOORDPOINTEREXTPROC) (GLint size, GLenum _type, GLsizei stride, GLsizei count,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLVERTEXPOINTEREXTPROC) (GLint size, GLenum _type, GLsizei stride, GLsizei count,  GLvoid *pointer)   nogil
    unsigned int GL_EXT_misc_attribute   
    unsigned int GL_SGIS_generate_mipmap   
    unsigned int GL_SGIX_clipmap   
    unsigned int GL_SGIX_shadow   
    unsigned int GL_SGIS_texture_edge_clamp   
    unsigned int GL_SGIS_texture_border_clamp   
    unsigned int GL_EXT_blend_minmax   
    void  glBlendEquationEXT (GLenum)   nogil
    ctypedef   void ( * PFNGLBLENDEQUATIONEXTPROC) (GLenum mode)   nogil
    unsigned int GL_EXT_blend_subtract   
    unsigned int GL_EXT_blend_logic_op   
    unsigned int GL_SGIX_interlace   
    unsigned int GL_SGIX_pixel_tiles   
    unsigned int GL_SGIX_texture_select   
    unsigned int GL_SGIX_sprite   
    void  glSpriteParameterfSGIX (GLenum, GLfloat)   nogil
    void  glSpriteParameterfvSGIX (GLenum,  GLfloat *)   nogil
    void  glSpriteParameteriSGIX (GLenum, GLint)   nogil
    void  glSpriteParameterivSGIX (GLenum,  GLint *)   nogil
    ctypedef   void ( * PFNGLSPRITEPARAMETERFSGIXPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLSPRITEPARAMETERFVSGIXPROC) (GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLSPRITEPARAMETERISGIXPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLSPRITEPARAMETERIVSGIXPROC) (GLenum pname,  GLint *params)   nogil
    unsigned int GL_SGIX_texture_multi_buffer   
    unsigned int GL_EXT_point_parameters   
    void  glPointParameterfEXT (GLenum, GLfloat)   nogil
    void  glPointParameterfvEXT (GLenum,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFEXTPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFVEXTPROC) (GLenum pname,  GLfloat *params)   nogil
    unsigned int GL_SGIS_point_parameters   
    void  glPointParameterfSGIS (GLenum, GLfloat)   nogil
    void  glPointParameterfvSGIS (GLenum,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFSGISPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERFVSGISPROC) (GLenum pname,  GLfloat *params)   nogil
    unsigned int GL_SGIX_instruments   
    GLint  glGetInstrumentsSGIX ()   nogil
    void  glInstrumentsBufferSGIX (GLsizei, GLint *)   nogil
    GLint  glPollInstrumentsSGIX (GLint *)   nogil
    void  glReadInstrumentsSGIX (GLint)   nogil
    void  glStartInstrumentsSGIX ()   nogil
    void  glStopInstrumentsSGIX (GLint)   nogil
    ctypedef   GLint ( * PFNGLGETINSTRUMENTSSGIXPROC) ()   nogil
    ctypedef   void ( * PFNGLINSTRUMENTSBUFFERSGIXPROC) (GLsizei size, GLint *_buffer)   nogil
    ctypedef   GLint ( * PFNGLPOLLINSTRUMENTSSGIXPROC) (GLint *marker_p)   nogil
    ctypedef   void ( * PFNGLREADINSTRUMENTSSGIXPROC) (GLint marker)   nogil
    ctypedef   void ( * PFNGLSTARTINSTRUMENTSSGIXPROC) ()   nogil
    ctypedef   void ( * PFNGLSTOPINSTRUMENTSSGIXPROC) (GLint marker)   nogil
    unsigned int GL_SGIX_texture_scale_bias   
    unsigned int GL_SGIX_framezoom   
    void  glFrameZoomSGIX (GLint)   nogil
    ctypedef   void ( * PFNGLFRAMEZOOMSGIXPROC) (GLint factor)   nogil
    unsigned int GL_SGIX_tag_sample_buffer   
    void  glTagSampleBufferSGIX ()   nogil
    ctypedef   void ( * PFNGLTAGSAMPLEBUFFERSGIXPROC) ()   nogil
    unsigned int GL_SGIX_polynomial_ffd   
    void  glDeformationMap3dSGIX (GLenum, GLdouble, GLdouble, GLint, GLint, GLdouble, GLdouble, GLint, GLint, GLdouble, GLdouble, GLint, GLint,  GLdouble *)   nogil
    void  glDeformationMap3fSGIX (GLenum, GLfloat, GLfloat, GLint, GLint, GLfloat, GLfloat, GLint, GLint, GLfloat, GLfloat, GLint, GLint,  GLfloat *)   nogil
    void  glDeformSGIX (GLbitfield)   nogil
    void  glLoadIdentityDeformationMapSGIX (GLbitfield)   nogil
    ctypedef   void ( * PFNGLDEFORMATIONMAP3DSGIXPROC) (GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, GLdouble w1, GLdouble w2, GLint wstride, GLint worder,  GLdouble *points)   nogil
    ctypedef   void ( * PFNGLDEFORMATIONMAP3FSGIXPROC) (GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, GLfloat w1, GLfloat w2, GLint wstride, GLint worder,  GLfloat *points)   nogil
    ctypedef   void ( * PFNGLDEFORMSGIXPROC) (GLbitfield mask)   nogil
    ctypedef   void ( * PFNGLLOADIDENTITYDEFORMATIONMAPSGIXPROC) (GLbitfield mask)   nogil
    unsigned int GL_SGIX_reference_plane   
    void  glReferencePlaneSGIX ( GLdouble *)   nogil
    ctypedef   void ( * PFNGLREFERENCEPLANESGIXPROC) ( GLdouble *equation)   nogil
    unsigned int GL_SGIX_flush_raster   
    void  glFlushRasterSGIX ()   nogil
    ctypedef   void ( * PFNGLFLUSHRASTERSGIXPROC) ()   nogil
    unsigned int GL_SGIX_depth_texture   
    unsigned int GL_SGIS_fog_function   
    void  glFogFuncSGIS (GLsizei,  GLfloat *)   nogil
    void  glGetFogFuncSGIS (GLfloat *)   nogil
    ctypedef   void ( * PFNGLFOGFUNCSGISPROC) (GLsizei n,  GLfloat *points)   nogil
    ctypedef   void ( * PFNGLGETFOGFUNCSGISPROC) (GLfloat *points)   nogil
    unsigned int GL_SGIX_fog_offset   
    unsigned int GL_HP_image_transform   
    void  glImageTransformParameteriHP (GLenum, GLenum, GLint)   nogil
    void  glImageTransformParameterfHP (GLenum, GLenum, GLfloat)   nogil
    void  glImageTransformParameterivHP (GLenum, GLenum,  GLint *)   nogil
    void  glImageTransformParameterfvHP (GLenum, GLenum,  GLfloat *)   nogil
    void  glGetImageTransformParameterivHP (GLenum, GLenum, GLint *)   nogil
    void  glGetImageTransformParameterfvHP (GLenum, GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLIMAGETRANSFORMPARAMETERIHPPROC) (GLenum target, GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLIMAGETRANSFORMPARAMETERFHPPROC) (GLenum target, GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLIMAGETRANSFORMPARAMETERIVHPPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLIMAGETRANSFORMPARAMETERFVHPPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETIMAGETRANSFORMPARAMETERIVHPPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETIMAGETRANSFORMPARAMETERFVHPPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    unsigned int GL_HP_convolution_border_modes   
    unsigned int GL_SGIX_texture_add_env   
    unsigned int GL_EXT_color_subtable   
    void  glColorSubTableEXT (GLenum, GLsizei, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glCopyColorSubTableEXT (GLenum, GLsizei, GLint, GLint, GLsizei)   nogil
    ctypedef   void ( * PFNGLCOLORSUBTABLEEXTPROC) (GLenum target, GLsizei start, GLsizei count, GLenum format, GLenum _type,  GLvoid *data)   nogil
    ctypedef   void ( * PFNGLCOPYCOLORSUBTABLEEXTPROC) (GLenum target, GLsizei start, GLint x, GLint y, GLsizei width)   nogil
    unsigned int GL_PGI_vertex_hints   
    unsigned int GL_PGI_misc_hints   
    void  glHintPGI (GLenum, GLint)   nogil
    ctypedef   void ( * PFNGLHINTPGIPROC) (GLenum target, GLint mode)   nogil
    unsigned int GL_EXT_paletted_texture   
    void  glColorTableEXT (GLenum, GLenum, GLsizei, GLenum, GLenum,  GLvoid *)   nogil
    void  glGetColorTableEXT (GLenum, GLenum, GLenum, GLvoid *)   nogil
    void  glGetColorTableParameterivEXT (GLenum, GLenum, GLint *)   nogil
    void  glGetColorTableParameterfvEXT (GLenum, GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLCOLORTABLEEXTPROC) (GLenum target, GLenum internalFormat, GLsizei width, GLenum format, GLenum _type,  GLvoid *table)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEEXTPROC) (GLenum target, GLenum format, GLenum _type, GLvoid *data)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERIVEXTPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETCOLORTABLEPARAMETERFVEXTPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    unsigned int GL_EXT_clip_volume_hint   
    unsigned int GL_SGIX_list_priority   
    void  glGetListParameterfvSGIX (GLuint, GLenum, GLfloat *)   nogil
    void  glGetListParameterivSGIX (GLuint, GLenum, GLint *)   nogil
    void  glListParameterfSGIX (GLuint, GLenum, GLfloat)   nogil
    void  glListParameterfvSGIX (GLuint, GLenum,  GLfloat *)   nogil
    void  glListParameteriSGIX (GLuint, GLenum, GLint)   nogil
    void  glListParameterivSGIX (GLuint, GLenum,  GLint *)   nogil
    ctypedef   void ( * PFNGLGETLISTPARAMETERFVSGIXPROC) (GLuint _list, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETLISTPARAMETERIVSGIXPROC) (GLuint _list, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLLISTPARAMETERFSGIXPROC) (GLuint _list, GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLLISTPARAMETERFVSGIXPROC) (GLuint _list, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLLISTPARAMETERISGIXPROC) (GLuint _list, GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLLISTPARAMETERIVSGIXPROC) (GLuint _list, GLenum pname,  GLint *params)   nogil
    unsigned int GL_SGIX_ir_instrument1   
    unsigned int GL_SGIX_calligraphic_fragment   
    unsigned int GL_SGIX_texture_lod_bias   
    unsigned int GL_SGIX_shadow_ambient   
    unsigned int GL_EXT_index_texture   
    unsigned int GL_EXT_index_material   
    void  glIndexMaterialEXT (GLenum, GLenum)   nogil
    ctypedef   void ( * PFNGLINDEXMATERIALEXTPROC) (GLenum face, GLenum mode)   nogil
    unsigned int GL_EXT_index_func   
    void  glIndexFuncEXT (GLenum, GLclampf)   nogil
    ctypedef   void ( * PFNGLINDEXFUNCEXTPROC) (GLenum func, GLclampf ref)   nogil
    unsigned int GL_EXT_index_array_formats   
    unsigned int GL_EXT_compiled_vertex_array   
    void  glLockArraysEXT (GLint, GLsizei)   nogil
    void  glUnlockArraysEXT ()   nogil
    ctypedef   void ( * PFNGLLOCKARRAYSEXTPROC) (GLint first, GLsizei count)   nogil
    ctypedef   void ( * PFNGLUNLOCKARRAYSEXTPROC) ()   nogil
    unsigned int GL_EXT_cull_vertex   
    void  glCullParameterdvEXT (GLenum, GLdouble *)   nogil
    void  glCullParameterfvEXT (GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLCULLPARAMETERDVEXTPROC) (GLenum pname, GLdouble *params)   nogil
    ctypedef   void ( * PFNGLCULLPARAMETERFVEXTPROC) (GLenum pname, GLfloat *params)   nogil
    unsigned int GL_SGIX_ycrcb   
    unsigned int GL_SGIX_fragment_lighting   
    void  glFragmentColorMaterialSGIX (GLenum, GLenum)   nogil
    void  glFragmentLightfSGIX (GLenum, GLenum, GLfloat)   nogil
    void  glFragmentLightfvSGIX (GLenum, GLenum,  GLfloat *)   nogil
    void  glFragmentLightiSGIX (GLenum, GLenum, GLint)   nogil
    void  glFragmentLightivSGIX (GLenum, GLenum,  GLint *)   nogil
    void  glFragmentLightModelfSGIX (GLenum, GLfloat)   nogil
    void  glFragmentLightModelfvSGIX (GLenum,  GLfloat *)   nogil
    void  glFragmentLightModeliSGIX (GLenum, GLint)   nogil
    void  glFragmentLightModelivSGIX (GLenum,  GLint *)   nogil
    void  glFragmentMaterialfSGIX (GLenum, GLenum, GLfloat)   nogil
    void  glFragmentMaterialfvSGIX (GLenum, GLenum,  GLfloat *)   nogil
    void  glFragmentMaterialiSGIX (GLenum, GLenum, GLint)   nogil
    void  glFragmentMaterialivSGIX (GLenum, GLenum,  GLint *)   nogil
    void  glGetFragmentLightfvSGIX (GLenum, GLenum, GLfloat *)   nogil
    void  glGetFragmentLightivSGIX (GLenum, GLenum, GLint *)   nogil
    void  glGetFragmentMaterialfvSGIX (GLenum, GLenum, GLfloat *)   nogil
    void  glGetFragmentMaterialivSGIX (GLenum, GLenum, GLint *)   nogil
    void  glLightEnviSGIX (GLenum, GLint)   nogil
    ctypedef   void ( * PFNGLFRAGMENTCOLORMATERIALSGIXPROC) (GLenum face, GLenum mode)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTFSGIXPROC) (GLenum light, GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTFVSGIXPROC) (GLenum light, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTISGIXPROC) (GLenum light, GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTIVSGIXPROC) (GLenum light, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTMODELFSGIXPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTMODELFVSGIXPROC) (GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTMODELISGIXPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTLIGHTMODELIVSGIXPROC) (GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLFRAGMENTMATERIALFSGIXPROC) (GLenum face, GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTMATERIALFVSGIXPROC) (GLenum face, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLFRAGMENTMATERIALISGIXPROC) (GLenum face, GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLFRAGMENTMATERIALIVSGIXPROC) (GLenum face, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLGETFRAGMENTLIGHTFVSGIXPROC) (GLenum light, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETFRAGMENTLIGHTIVSGIXPROC) (GLenum light, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETFRAGMENTMATERIALFVSGIXPROC) (GLenum face, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETFRAGMENTMATERIALIVSGIXPROC) (GLenum face, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLLIGHTENVISGIXPROC) (GLenum pname, GLint param)   nogil
    unsigned int GL_IBM_rasterpos_clip   
    unsigned int GL_HP_texture_lighting   
    unsigned int GL_EXT_draw_range_elements   
    void  glDrawRangeElementsEXT (GLenum, GLuint, GLuint, GLsizei, GLenum,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLDRAWRANGEELEMENTSEXTPROC) (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum _type,  GLvoid *indices)   nogil
    unsigned int GL_WIN_phong_shading   
    unsigned int GL_WIN_specular_fog   
    unsigned int GL_EXT_light_texture   
    void  glApplyTextureEXT (GLenum)   nogil
    void  glTextureLightEXT (GLenum)   nogil
    void  glTextureMaterialEXT (GLenum, GLenum)   nogil
    ctypedef   void ( * PFNGLAPPLYTEXTUREEXTPROC) (GLenum mode)   nogil
    ctypedef   void ( * PFNGLTEXTURELIGHTEXTPROC) (GLenum pname)   nogil
    ctypedef   void ( * PFNGLTEXTUREMATERIALEXTPROC) (GLenum face, GLenum mode)   nogil
    unsigned int GL_SGIX_blend_alpha_minmax   
    unsigned int GL_EXT_bgra   
    unsigned int GL_SGIX_async   
    void  glAsyncMarkerSGIX (GLuint)   nogil
    GLint  glFinishAsyncSGIX (GLuint *)   nogil
    GLint  glPollAsyncSGIX (GLuint *)   nogil
    GLuint  glGenAsyncMarkersSGIX (GLsizei)   nogil
    void  glDeleteAsyncMarkersSGIX (GLuint, GLsizei)   nogil
    GLboolean  glIsAsyncMarkerSGIX (GLuint)   nogil
    ctypedef   void ( * PFNGLASYNCMARKERSGIXPROC) (GLuint marker)   nogil
    ctypedef   GLint ( * PFNGLFINISHASYNCSGIXPROC) (GLuint *markerp)   nogil
    ctypedef   GLint ( * PFNGLPOLLASYNCSGIXPROC) (GLuint *markerp)   nogil
    ctypedef   GLuint ( * PFNGLGENASYNCMARKERSSGIXPROC) (GLsizei _range)   nogil
    ctypedef   void ( * PFNGLDELETEASYNCMARKERSSGIXPROC) (GLuint marker, GLsizei _range)   nogil
    ctypedef   GLboolean ( * PFNGLISASYNCMARKERSGIXPROC) (GLuint marker)   nogil
    unsigned int GL_SGIX_async_pixel   
    unsigned int GL_SGIX_async_histogram   
    unsigned int GL_INTEL_parallel_arrays   
    void  glVertexPointervINTEL (GLint, GLenum,  GLvoid* *)   nogil
    void  glNormalPointervINTEL (GLenum,  GLvoid* *)   nogil
    void  glColorPointervINTEL (GLint, GLenum,  GLvoid* *)   nogil
    void  glTexCoordPointervINTEL (GLint, GLenum,  GLvoid* *)   nogil
    ctypedef   void ( * PFNGLVERTEXPOINTERVINTELPROC) (GLint size, GLenum _type,  GLvoid* *pointer)   nogil
    ctypedef   void ( * PFNGLNORMALPOINTERVINTELPROC) (GLenum _type,  GLvoid* *pointer)   nogil
    ctypedef   void ( * PFNGLCOLORPOINTERVINTELPROC) (GLint size, GLenum _type,  GLvoid* *pointer)   nogil
    ctypedef   void ( * PFNGLTEXCOORDPOINTERVINTELPROC) (GLint size, GLenum _type,  GLvoid* *pointer)   nogil
    unsigned int GL_HP_occlusion_test   
    unsigned int GL_EXT_pixel_transform   
    void  glPixelTransformParameteriEXT (GLenum, GLenum, GLint)   nogil
    void  glPixelTransformParameterfEXT (GLenum, GLenum, GLfloat)   nogil
    void  glPixelTransformParameterivEXT (GLenum, GLenum,  GLint *)   nogil
    void  glPixelTransformParameterfvEXT (GLenum, GLenum,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLPIXELTRANSFORMPARAMETERIEXTPROC) (GLenum target, GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLPIXELTRANSFORMPARAMETERFEXTPROC) (GLenum target, GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLPIXELTRANSFORMPARAMETERIVEXTPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLPIXELTRANSFORMPARAMETERFVEXTPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    unsigned int GL_EXT_pixel_transform_color_table   
    unsigned int GL_EXT_shared_texture_palette   
    unsigned int GL_EXT_separate_specular_color   
    unsigned int GL_EXT_secondary_color   
    void  glSecondaryColor3bEXT (GLbyte, GLbyte, GLbyte)   nogil
    void  glSecondaryColor3bvEXT ( GLbyte *)   nogil
    void  glSecondaryColor3dEXT (GLdouble, GLdouble, GLdouble)   nogil
    void  glSecondaryColor3dvEXT ( GLdouble *)   nogil
    void  glSecondaryColor3fEXT (GLfloat, GLfloat, GLfloat)   nogil
    void  glSecondaryColor3fvEXT ( GLfloat *)   nogil
    void  glSecondaryColor3iEXT (GLint, GLint, GLint)   nogil
    void  glSecondaryColor3ivEXT ( GLint *)   nogil
    void  glSecondaryColor3sEXT (GLshort, GLshort, GLshort)   nogil
    void  glSecondaryColor3svEXT ( GLshort *)   nogil
    void  glSecondaryColor3ubEXT (GLubyte, GLubyte, GLubyte)   nogil
    void  glSecondaryColor3ubvEXT ( GLubyte *)   nogil
    void  glSecondaryColor3uiEXT (GLuint, GLuint, GLuint)   nogil
    void  glSecondaryColor3uivEXT ( GLuint *)   nogil
    void  glSecondaryColor3usEXT (GLushort, GLushort, GLushort)   nogil
    void  glSecondaryColor3usvEXT ( GLushort *)   nogil
    void  glSecondaryColorPointerEXT (GLint, GLenum, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3BEXTPROC) (GLbyte red, GLbyte green, GLbyte blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3BVEXTPROC) ( GLbyte *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3DEXTPROC) (GLdouble red, GLdouble green, GLdouble blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3DVEXTPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3FEXTPROC) (GLfloat red, GLfloat green, GLfloat blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3FVEXTPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3IEXTPROC) (GLint red, GLint green, GLint blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3IVEXTPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3SEXTPROC) (GLshort red, GLshort green, GLshort blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3SVEXTPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3UBEXTPROC) (GLubyte red, GLubyte green, GLubyte blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3UBVEXTPROC) ( GLubyte *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3UIEXTPROC) (GLuint red, GLuint green, GLuint blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3UIVEXTPROC) ( GLuint *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3USEXTPROC) (GLushort red, GLushort green, GLushort blue)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLOR3USVEXTPROC) ( GLushort *v)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLORPOINTEREXTPROC) (GLint size, GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    unsigned int GL_EXT_texture_perturb_normal   
    void  glTextureNormalEXT (GLenum)   nogil
    ctypedef   void ( * PFNGLTEXTURENORMALEXTPROC) (GLenum mode)   nogil
    unsigned int GL_EXT_multi_draw_arrays   
    void  glMultiDrawArraysEXT (GLenum, GLint *, GLsizei *, GLsizei)   nogil
    void  glMultiDrawElementsEXT (GLenum,  GLsizei *, GLenum,  GLvoid* *, GLsizei)   nogil
    ctypedef   void ( * PFNGLMULTIDRAWARRAYSEXTPROC) (GLenum mode, GLint *first, GLsizei *count, GLsizei primcount)   nogil
    ctypedef   void ( * PFNGLMULTIDRAWELEMENTSEXTPROC) (GLenum mode,  GLsizei *count, GLenum _type,  GLvoid* *indices, GLsizei primcount)   nogil
    unsigned int GL_EXT_fog_coord   
    void  glFogCoordfEXT (GLfloat)   nogil
    void  glFogCoordfvEXT ( GLfloat *)   nogil
    void  glFogCoorddEXT (GLdouble)   nogil
    void  glFogCoorddvEXT ( GLdouble *)   nogil
    void  glFogCoordPointerEXT (GLenum, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLFOGCOORDFEXTPROC) (GLfloat coord)   nogil
    ctypedef   void ( * PFNGLFOGCOORDFVEXTPROC) ( GLfloat *coord)   nogil
    ctypedef   void ( * PFNGLFOGCOORDDEXTPROC) (GLdouble coord)   nogil
    ctypedef   void ( * PFNGLFOGCOORDDVEXTPROC) ( GLdouble *coord)   nogil
    ctypedef   void ( * PFNGLFOGCOORDPOINTEREXTPROC) (GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    unsigned int GL_REND_screen_coordinates   
    unsigned int GL_EXT_coordinate_frame   
    void  glTangent3bEXT (GLbyte, GLbyte, GLbyte)   nogil
    void  glTangent3bvEXT ( GLbyte *)   nogil
    void  glTangent3dEXT (GLdouble, GLdouble, GLdouble)   nogil
    void  glTangent3dvEXT ( GLdouble *)   nogil
    void  glTangent3fEXT (GLfloat, GLfloat, GLfloat)   nogil
    void  glTangent3fvEXT ( GLfloat *)   nogil
    void  glTangent3iEXT (GLint, GLint, GLint)   nogil
    void  glTangent3ivEXT ( GLint *)   nogil
    void  glTangent3sEXT (GLshort, GLshort, GLshort)   nogil
    void  glTangent3svEXT ( GLshort *)   nogil
    void  glBinormal3bEXT (GLbyte, GLbyte, GLbyte)   nogil
    void  glBinormal3bvEXT ( GLbyte *)   nogil
    void  glBinormal3dEXT (GLdouble, GLdouble, GLdouble)   nogil
    void  glBinormal3dvEXT ( GLdouble *)   nogil
    void  glBinormal3fEXT (GLfloat, GLfloat, GLfloat)   nogil
    void  glBinormal3fvEXT ( GLfloat *)   nogil
    void  glBinormal3iEXT (GLint, GLint, GLint)   nogil
    void  glBinormal3ivEXT ( GLint *)   nogil
    void  glBinormal3sEXT (GLshort, GLshort, GLshort)   nogil
    void  glBinormal3svEXT ( GLshort *)   nogil
    void  glTangentPointerEXT (GLenum, GLsizei,  GLvoid *)   nogil
    void  glBinormalPointerEXT (GLenum, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLTANGENT3BEXTPROC) (GLbyte tx, GLbyte ty, GLbyte tz)   nogil
    ctypedef   void ( * PFNGLTANGENT3BVEXTPROC) ( GLbyte *v)   nogil
    ctypedef   void ( * PFNGLTANGENT3DEXTPROC) (GLdouble tx, GLdouble ty, GLdouble tz)   nogil
    ctypedef   void ( * PFNGLTANGENT3DVEXTPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLTANGENT3FEXTPROC) (GLfloat tx, GLfloat ty, GLfloat tz)   nogil
    ctypedef   void ( * PFNGLTANGENT3FVEXTPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTANGENT3IEXTPROC) (GLint tx, GLint ty, GLint tz)   nogil
    ctypedef   void ( * PFNGLTANGENT3IVEXTPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLTANGENT3SEXTPROC) (GLshort tx, GLshort ty, GLshort tz)   nogil
    ctypedef   void ( * PFNGLTANGENT3SVEXTPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLBINORMAL3BEXTPROC) (GLbyte bx, GLbyte _by, GLbyte bz)   nogil
    ctypedef   void ( * PFNGLBINORMAL3BVEXTPROC) ( GLbyte *v)   nogil
    ctypedef   void ( * PFNGLBINORMAL3DEXTPROC) (GLdouble bx, GLdouble _by, GLdouble bz)   nogil
    ctypedef   void ( * PFNGLBINORMAL3DVEXTPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLBINORMAL3FEXTPROC) (GLfloat bx, GLfloat _by, GLfloat bz)   nogil
    ctypedef   void ( * PFNGLBINORMAL3FVEXTPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLBINORMAL3IEXTPROC) (GLint bx, GLint _by, GLint bz)   nogil
    ctypedef   void ( * PFNGLBINORMAL3IVEXTPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLBINORMAL3SEXTPROC) (GLshort bx, GLshort _by, GLshort bz)   nogil
    ctypedef   void ( * PFNGLBINORMAL3SVEXTPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLTANGENTPOINTEREXTPROC) (GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLBINORMALPOINTEREXTPROC) (GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    unsigned int GL_EXT_texture_env_combine   
    unsigned int GL_APPLE_specular_vector   
    unsigned int GL_APPLE_transform_hint   
    unsigned int GL_SGIX_fog_scale   
    unsigned int GL_SUNX_constant_data   
    void  glFinishTextureSUNX ()   nogil
    ctypedef   void ( * PFNGLFINISHTEXTURESUNXPROC) ()   nogil
    unsigned int GL_SUN_global_alpha   
    void  glGlobalAlphaFactorbSUN (GLbyte)   nogil
    void  glGlobalAlphaFactorsSUN (GLshort)   nogil
    void  glGlobalAlphaFactoriSUN (GLint)   nogil
    void  glGlobalAlphaFactorfSUN (GLfloat)   nogil
    void  glGlobalAlphaFactordSUN (GLdouble)   nogil
    void  glGlobalAlphaFactorubSUN (GLubyte)   nogil
    void  glGlobalAlphaFactorusSUN (GLushort)   nogil
    void  glGlobalAlphaFactoruiSUN (GLuint)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORBSUNPROC) (GLbyte factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORSSUNPROC) (GLshort factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORISUNPROC) (GLint factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORFSUNPROC) (GLfloat factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORDSUNPROC) (GLdouble factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORUBSUNPROC) (GLubyte factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORUSSUNPROC) (GLushort factor)   nogil
    ctypedef   void ( * PFNGLGLOBALALPHAFACTORUISUNPROC) (GLuint factor)   nogil
    unsigned int GL_SUN_triangle_list   
    void  glReplacementCodeuiSUN (GLuint)   nogil
    void  glReplacementCodeusSUN (GLushort)   nogil
    void  glReplacementCodeubSUN (GLubyte)   nogil
    void  glReplacementCodeuivSUN ( GLuint *)   nogil
    void  glReplacementCodeusvSUN ( GLushort *)   nogil
    void  glReplacementCodeubvSUN ( GLubyte *)   nogil
    void  glReplacementCodePointerSUN (GLenum, GLsizei,  GLvoid* *)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUISUNPROC) (GLuint code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUSSUNPROC) (GLushort code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUBSUNPROC) (GLubyte code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUIVSUNPROC) ( GLuint *code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUSVSUNPROC) ( GLushort *code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUBVSUNPROC) ( GLubyte *code)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEPOINTERSUNPROC) (GLenum _type, GLsizei stride,  GLvoid* *pointer)   nogil
    unsigned int GL_SUN_vertex   
    void  glColor4ubVertex2fSUN (GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat)   nogil
    void  glColor4ubVertex2fvSUN ( GLubyte *,  GLfloat *)   nogil
    void  glColor4ubVertex3fSUN (GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat)   nogil
    void  glColor4ubVertex3fvSUN ( GLubyte *,  GLfloat *)   nogil
    void  glColor3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glColor3fVertex3fvSUN ( GLfloat *,  GLfloat *)   nogil
    void  glNormal3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glNormal3fVertex3fvSUN ( GLfloat *,  GLfloat *)   nogil
    void  glColor4fNormal3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glColor4fNormal3fVertex3fvSUN ( GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glTexCoord2fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord2fVertex3fvSUN ( GLfloat *,  GLfloat *)   nogil
    void  glTexCoord4fVertex4fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord4fVertex4fvSUN ( GLfloat *,  GLfloat *)   nogil
    void  glTexCoord2fColor4ubVertex3fSUN (GLfloat, GLfloat, GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord2fColor4ubVertex3fvSUN ( GLfloat *,  GLubyte *,  GLfloat *)   nogil
    void  glTexCoord2fColor3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord2fColor3fVertex3fvSUN ( GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glTexCoord2fNormal3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord2fNormal3fVertex3fvSUN ( GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glTexCoord2fColor4fNormal3fVertex3fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord2fColor4fNormal3fVertex3fvSUN ( GLfloat *,  GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glTexCoord4fColor4fNormal3fVertex4fSUN (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glTexCoord4fColor4fNormal3fVertex4fvSUN ( GLfloat *,  GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiVertex3fvSUN ( GLenum *,  GLfloat *)   nogil
    void  glReplacementCodeuiColor4ubVertex3fSUN (GLenum, GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiColor4ubVertex3fvSUN ( GLenum *,  GLubyte *,  GLfloat *)   nogil
    void  glReplacementCodeuiColor3fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiColor3fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiNormal3fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiNormal3fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiColor4fNormal3fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiColor4fNormal3fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiTexCoord2fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiTexCoord2fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *,  GLfloat *)   nogil
    void  glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN (GLenum, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN ( GLenum *,  GLfloat *,  GLfloat *,  GLfloat *,  GLfloat *)   nogil
    ctypedef   void ( * PFNGLCOLOR4UBVERTEX2FSUNPROC) (GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat x, GLfloat y)   nogil
    ctypedef   void ( * PFNGLCOLOR4UBVERTEX2FVSUNPROC) ( GLubyte *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLCOLOR4UBVERTEX3FSUNPROC) (GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLCOLOR4UBVERTEX3FVSUNPROC) ( GLubyte *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLCOLOR3FVERTEX3FSUNPROC) (GLfloat r, GLfloat g, GLfloat b, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLCOLOR3FVERTEX3FVSUNPROC) ( GLfloat *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLNORMAL3FVERTEX3FSUNPROC) (GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLNORMAL3FVERTEX3FVSUNPROC) ( GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLCOLOR4FNORMAL3FVERTEX3FSUNPROC) (GLfloat r, GLfloat g, GLfloat b, GLfloat a, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLCOLOR4FNORMAL3FVERTEX3FVSUNPROC) ( GLfloat *c,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FVERTEX3FSUNPROC) (GLfloat s, GLfloat t, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FVERTEX3FVSUNPROC) ( GLfloat *tc,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD4FVERTEX4FSUNPROC) (GLfloat s, GLfloat t, GLfloat p, GLfloat q, GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLTEXCOORD4FVERTEX4FVSUNPROC) ( GLfloat *tc,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR4UBVERTEX3FSUNPROC) (GLfloat s, GLfloat t, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR4UBVERTEX3FVSUNPROC) ( GLfloat *tc,  GLubyte *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR3FVERTEX3FSUNPROC) (GLfloat s, GLfloat t, GLfloat r, GLfloat g, GLfloat b, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR3FVERTEX3FVSUNPROC) ( GLfloat *tc,  GLfloat *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FNORMAL3FVERTEX3FSUNPROC) (GLfloat s, GLfloat t, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FNORMAL3FVERTEX3FVSUNPROC) ( GLfloat *tc,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR4FNORMAL3FVERTEX3FSUNPROC) (GLfloat s, GLfloat t, GLfloat r, GLfloat g, GLfloat b, GLfloat a, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLTEXCOORD2FCOLOR4FNORMAL3FVERTEX3FVSUNPROC) ( GLfloat *tc,  GLfloat *c,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLTEXCOORD4FCOLOR4FNORMAL3FVERTEX4FSUNPROC) (GLfloat s, GLfloat t, GLfloat p, GLfloat q, GLfloat r, GLfloat g, GLfloat b, GLfloat a, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLTEXCOORD4FCOLOR4FNORMAL3FVERTEX4FVSUNPROC) ( GLfloat *tc,  GLfloat *c,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUIVERTEX3FSUNPROC) (GLenum rc, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUIVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR4UBVERTEX3FSUNPROC) (GLenum rc, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR4UBVERTEX3FVSUNPROC) ( GLenum *rc,  GLubyte *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR3FVERTEX3FSUNPROC) (GLenum rc, GLfloat r, GLfloat g, GLfloat b, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR3FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *c,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUINORMAL3FVERTEX3FSUNPROC) (GLenum rc, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUINORMAL3FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR4FNORMAL3FVERTEX3FSUNPROC) (GLenum rc, GLfloat r, GLfloat g, GLfloat b, GLfloat a, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUICOLOR4FNORMAL3FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *c,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FVERTEX3FSUNPROC) (GLenum rc, GLfloat s, GLfloat t, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *tc,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FNORMAL3FVERTEX3FSUNPROC) (GLenum rc, GLfloat s, GLfloat t, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FNORMAL3FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *tc,  GLfloat *n,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FCOLOR4FNORMAL3FVERTEX3FSUNPROC) (GLenum rc, GLfloat s, GLfloat t, GLfloat r, GLfloat g, GLfloat b, GLfloat a, GLfloat nx, GLfloat ny, GLfloat nz, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLREPLACEMENTCODEUITEXCOORD2FCOLOR4FNORMAL3FVERTEX3FVSUNPROC) ( GLenum *rc,  GLfloat *tc,  GLfloat *c,  GLfloat *n,  GLfloat *v)   nogil
    unsigned int GL_EXT_blend_func_separate   
    void  glBlendFuncSeparateEXT (GLenum, GLenum, GLenum, GLenum)   nogil
    void  glBlendFuncSeparateINGR (GLenum, GLenum, GLenum, GLenum)   nogil
    ctypedef   void ( * PFNGLBLENDFUNCSEPARATEEXTPROC) (GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha)   nogil
    ctypedef   void ( * PFNGLBLENDFUNCSEPARATEINGRPROC) (GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha)   nogil
    unsigned int GL_INGR_color_clamp   
    unsigned int GL_INGR_interlace_read   
    unsigned int GL_EXT_stencil_wrap   
    unsigned int GL_EXT_422_pixels   
    unsigned int GL_NV_texgen_reflection   
    unsigned int GL_SUN_convolution_border_modes   
    unsigned int GL_EXT_texture_env_add   
    unsigned int GL_EXT_texture_lod_bias   
    unsigned int GL_EXT_texture_filter_anisotropic   
    unsigned int GL_EXT_vertex_weighting   
    void  glVertexWeightfEXT (GLfloat)   nogil
    void  glVertexWeightfvEXT ( GLfloat *)   nogil
    void  glVertexWeightPointerEXT (GLsizei, GLenum, GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLVERTEXWEIGHTFEXTPROC) (GLfloat weight)   nogil
    ctypedef   void ( * PFNGLVERTEXWEIGHTFVEXTPROC) ( GLfloat *weight)   nogil
    ctypedef   void ( * PFNGLVERTEXWEIGHTPOINTEREXTPROC) (GLsizei size, GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    unsigned int GL_NV_light_max_exponent   
    unsigned int GL_NV_vertex_array_range   
    void  glFlushVertexArrayRangeNV ()   nogil
    void  glVertexArrayRangeNV (GLsizei,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLFLUSHVERTEXARRAYRANGENVPROC) ()   nogil
    ctypedef   void ( * PFNGLVERTEXARRAYRANGENVPROC) (GLsizei length,  GLvoid *pointer)   nogil
    unsigned int GL_NV_register_combiners   
    void  glCombinerParameterfvNV (GLenum,  GLfloat *)   nogil
    void  glCombinerParameterfNV (GLenum, GLfloat)   nogil
    void  glCombinerParameterivNV (GLenum,  GLint *)   nogil
    void  glCombinerParameteriNV (GLenum, GLint)   nogil
    void  glCombinerInputNV (GLenum, GLenum, GLenum, GLenum, GLenum, GLenum)   nogil
    void  glCombinerOutputNV (GLenum, GLenum, GLenum, GLenum, GLenum, GLenum, GLenum, GLboolean, GLboolean, GLboolean)   nogil
    void  glFinalCombinerInputNV (GLenum, GLenum, GLenum, GLenum)   nogil
    void  glGetCombinerInputParameterfvNV (GLenum, GLenum, GLenum, GLenum, GLfloat *)   nogil
    void  glGetCombinerInputParameterivNV (GLenum, GLenum, GLenum, GLenum, GLint *)   nogil
    void  glGetCombinerOutputParameterfvNV (GLenum, GLenum, GLenum, GLfloat *)   nogil
    void  glGetCombinerOutputParameterivNV (GLenum, GLenum, GLenum, GLint *)   nogil
    void  glGetFinalCombinerInputParameterfvNV (GLenum, GLenum, GLfloat *)   nogil
    void  glGetFinalCombinerInputParameterivNV (GLenum, GLenum, GLint *)   nogil
    ctypedef   void ( * PFNGLCOMBINERPARAMETERFVNVPROC) (GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLCOMBINERPARAMETERFNVPROC) (GLenum pname, GLfloat param)   nogil
    ctypedef   void ( * PFNGLCOMBINERPARAMETERIVNVPROC) (GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLCOMBINERPARAMETERINVPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLCOMBINERINPUTNVPROC) (GLenum stage, GLenum portion, GLenum variable, GLenum _input, GLenum mapping, GLenum componentUsage)   nogil
    ctypedef   void ( * PFNGLCOMBINEROUTPUTNVPROC) (GLenum stage, GLenum portion, GLenum abOutput, GLenum cdOutput, GLenum sumOutput, GLenum scale, GLenum bias, GLboolean abDotProduct, GLboolean cdDotProduct, GLboolean muxSum)   nogil
    ctypedef   void ( * PFNGLFINALCOMBINERINPUTNVPROC) (GLenum variable, GLenum _input, GLenum mapping, GLenum componentUsage)   nogil
    ctypedef   void ( * PFNGLGETCOMBINERINPUTPARAMETERFVNVPROC) (GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCOMBINERINPUTPARAMETERIVNVPROC) (GLenum stage, GLenum portion, GLenum variable, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETCOMBINEROUTPUTPARAMETERFVNVPROC) (GLenum stage, GLenum portion, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCOMBINEROUTPUTPARAMETERIVNVPROC) (GLenum stage, GLenum portion, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETFINALCOMBINERINPUTPARAMETERFVNVPROC) (GLenum variable, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETFINALCOMBINERINPUTPARAMETERIVNVPROC) (GLenum variable, GLenum pname, GLint *params)   nogil
    unsigned int GL_NV_fog_distance   
    unsigned int GL_NV_texgen_emboss   
    unsigned int GL_NV_blend_square   
    unsigned int GL_NV_texture_env_combine4   
    unsigned int GL_MESA_resize_buffers   
    void  glResizeBuffersMESA ()   nogil
    ctypedef   void ( * PFNGLRESIZEBUFFERSMESAPROC) ()   nogil
    unsigned int GL_MESA_window_pos   
    void  glWindowPos2dMESA (GLdouble, GLdouble)   nogil
    void  glWindowPos2dvMESA ( GLdouble *)   nogil
    void  glWindowPos2fMESA (GLfloat, GLfloat)   nogil
    void  glWindowPos2fvMESA ( GLfloat *)   nogil
    void  glWindowPos2iMESA (GLint, GLint)   nogil
    void  glWindowPos2ivMESA ( GLint *)   nogil
    void  glWindowPos2sMESA (GLshort, GLshort)   nogil
    void  glWindowPos2svMESA ( GLshort *)   nogil
    void  glWindowPos3dMESA (GLdouble, GLdouble, GLdouble)   nogil
    void  glWindowPos3dvMESA ( GLdouble *)   nogil
    void  glWindowPos3fMESA (GLfloat, GLfloat, GLfloat)   nogil
    void  glWindowPos3fvMESA ( GLfloat *)   nogil
    void  glWindowPos3iMESA (GLint, GLint, GLint)   nogil
    void  glWindowPos3ivMESA ( GLint *)   nogil
    void  glWindowPos3sMESA (GLshort, GLshort, GLshort)   nogil
    void  glWindowPos3svMESA ( GLshort *)   nogil
    void  glWindowPos4dMESA (GLdouble, GLdouble, GLdouble, GLdouble)   nogil
    void  glWindowPos4dvMESA ( GLdouble *)   nogil
    void  glWindowPos4fMESA (GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glWindowPos4fvMESA ( GLfloat *)   nogil
    void  glWindowPos4iMESA (GLint, GLint, GLint, GLint)   nogil
    void  glWindowPos4ivMESA ( GLint *)   nogil
    void  glWindowPos4sMESA (GLshort, GLshort, GLshort, GLshort)   nogil
    void  glWindowPos4svMESA ( GLshort *)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2DMESAPROC) (GLdouble x, GLdouble y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2DVMESAPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2FMESAPROC) (GLfloat x, GLfloat y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2FVMESAPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2IMESAPROC) (GLint x, GLint y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2IVMESAPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2SMESAPROC) (GLshort x, GLshort y)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS2SVMESAPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3DMESAPROC) (GLdouble x, GLdouble y, GLdouble z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3DVMESAPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3FMESAPROC) (GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3FVMESAPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3IMESAPROC) (GLint x, GLint y, GLint z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3IVMESAPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3SMESAPROC) (GLshort x, GLshort y, GLshort z)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS3SVMESAPROC) ( GLshort *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4DMESAPROC) (GLdouble x, GLdouble y, GLdouble z, GLdouble w)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4DVMESAPROC) ( GLdouble *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4FMESAPROC) (GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4FVMESAPROC) ( GLfloat *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4IMESAPROC) (GLint x, GLint y, GLint z, GLint w)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4IVMESAPROC) ( GLint *v)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4SMESAPROC) (GLshort x, GLshort y, GLshort z, GLshort w)   nogil
    ctypedef   void ( * PFNGLWINDOWPOS4SVMESAPROC) ( GLshort *v)   nogil
    unsigned int GL_IBM_cull_vertex   
    unsigned int GL_IBM_multimode_draw_arrays   
    void  glMultiModeDrawArraysIBM (GLenum,  GLint *,  GLsizei *, GLsizei, GLint)   nogil
    void  glMultiModeDrawElementsIBM ( GLenum *,  GLsizei *, GLenum,  GLvoid* *, GLsizei, GLint)   nogil
    ctypedef   void ( * PFNGLMULTIMODEDRAWARRAYSIBMPROC) (GLenum mode,  GLint *first,  GLsizei *count, GLsizei primcount, GLint modestride)   nogil
    ctypedef   void ( * PFNGLMULTIMODEDRAWELEMENTSIBMPROC) ( GLenum *mode,  GLsizei *count, GLenum _type,  GLvoid* *indices, GLsizei primcount, GLint modestride)   nogil
    unsigned int GL_IBM_vertex_array_lists   
    void  glColorPointerListIBM (GLint, GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glSecondaryColorPointerListIBM (GLint, GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glEdgeFlagPointerListIBM (GLint,  GLboolean* *, GLint)   nogil
    void  glFogCoordPointerListIBM (GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glIndexPointerListIBM (GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glNormalPointerListIBM (GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glTexCoordPointerListIBM (GLint, GLenum, GLint,  GLvoid* *, GLint)   nogil
    void  glVertexPointerListIBM (GLint, GLenum, GLint,  GLvoid* *, GLint)   nogil
    ctypedef   void ( * PFNGLCOLORPOINTERLISTIBMPROC) (GLint size, GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLSECONDARYCOLORPOINTERLISTIBMPROC) (GLint size, GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLEDGEFLAGPOINTERLISTIBMPROC) (GLint stride,  GLboolean* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLFOGCOORDPOINTERLISTIBMPROC) (GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLINDEXPOINTERLISTIBMPROC) (GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLNORMALPOINTERLISTIBMPROC) (GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLTEXCOORDPOINTERLISTIBMPROC) (GLint size, GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    ctypedef   void ( * PFNGLVERTEXPOINTERLISTIBMPROC) (GLint size, GLenum _type, GLint stride,  GLvoid* *pointer, GLint ptrstride)   nogil
    unsigned int GL_SGIX_subsample   
    unsigned int GL_SGIX_ycrcba   
    unsigned int GL_SGIX_ycrcb_subsample   
    unsigned int GL_SGIX_depth_pass_instrument   
    unsigned int GL_3DFX_texture_compression_FXT1   
    unsigned int GL_3DFX_multisample   
    unsigned int GL_3DFX_tbuffer   
    void  glTbufferMask3DFX (GLuint)   nogil
    ctypedef   void ( * PFNGLTBUFFERMASK3DFXPROC) (GLuint mask)   nogil
    unsigned int GL_EXT_multisample   
    void  glSampleMaskEXT (GLclampf, GLboolean)   nogil
    void  glSamplePatternEXT (GLenum)   nogil
    ctypedef   void ( * PFNGLSAMPLEMASKEXTPROC) (GLclampf value, GLboolean invert)   nogil
    ctypedef   void ( * PFNGLSAMPLEPATTERNEXTPROC) (GLenum pattern)   nogil
    unsigned int GL_SGIX_vertex_preclip   
    unsigned int GL_SGIX_convolution_accuracy   
    unsigned int GL_SGIX_resample   
    unsigned int GL_SGIS_point_line_texgen   
    unsigned int GL_SGIS_texture_color_mask   
    void  glTextureColorMaskSGIS (GLboolean, GLboolean, GLboolean, GLboolean)   nogil
    ctypedef   void ( * PFNGLTEXTURECOLORMASKSGISPROC) (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)   nogil
    unsigned int GL_SGIX_igloo_interface   
    void  glIglooInterfaceSGIX (GLenum,  GLvoid *)   nogil
    ctypedef   void ( * PFNGLIGLOOINTERFACESGIXPROC) (GLenum pname,  GLvoid *params)   nogil
    unsigned int GL_NV_fence   
    void  glDeleteFencesNV (GLsizei,  GLuint *)   nogil
    void  glGenFencesNV (GLsizei, GLuint *)   nogil
    GLboolean  glIsFenceNV (GLuint)   nogil
    GLboolean  glTestFenceNV (GLuint)   nogil
    void  glGetFenceivNV (GLuint, GLenum, GLint *)   nogil
    void  glFinishFenceNV (GLuint)   nogil
    void  glSetFenceNV (GLuint, GLenum)   nogil
    ctypedef   void ( * PFNGLDELETEFENCESNVPROC) (GLsizei n,  GLuint *fences)   nogil
    ctypedef   void ( * PFNGLGENFENCESNVPROC) (GLsizei n, GLuint *fences)   nogil
    ctypedef   GLboolean ( * PFNGLISFENCENVPROC) (GLuint fence)   nogil
    ctypedef   GLboolean ( * PFNGLTESTFENCENVPROC) (GLuint fence)   nogil
    ctypedef   void ( * PFNGLGETFENCEIVNVPROC) (GLuint fence, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLFINISHFENCENVPROC) (GLuint fence)   nogil
    ctypedef   void ( * PFNGLSETFENCENVPROC) (GLuint fence, GLenum condition)   nogil
    unsigned int GL_NV_evaluators   
    void  glMapControlPointsNV (GLenum, GLuint, GLenum, GLsizei, GLsizei, GLint, GLint, GLboolean,  GLvoid *)   nogil
    void  glMapParameterivNV (GLenum, GLenum,  GLint *)   nogil
    void  glMapParameterfvNV (GLenum, GLenum,  GLfloat *)   nogil
    void  glGetMapControlPointsNV (GLenum, GLuint, GLenum, GLsizei, GLsizei, GLboolean, GLvoid *)   nogil
    void  glGetMapParameterivNV (GLenum, GLenum, GLint *)   nogil
    void  glGetMapParameterfvNV (GLenum, GLenum, GLfloat *)   nogil
    void  glGetMapAttribParameterivNV (GLenum, GLuint, GLenum, GLint *)   nogil
    void  glGetMapAttribParameterfvNV (GLenum, GLuint, GLenum, GLfloat *)   nogil
    void  glEvalMapsNV (GLenum, GLenum)   nogil
    ctypedef   void ( * PFNGLMAPCONTROLPOINTSNVPROC) (GLenum target, GLuint index, GLenum _type, GLsizei ustride, GLsizei vstride, GLint uorder, GLint vorder, GLboolean packed,  GLvoid *points)   nogil
    ctypedef   void ( * PFNGLMAPPARAMETERIVNVPROC) (GLenum target, GLenum pname,  GLint *params)   nogil
    ctypedef   void ( * PFNGLMAPPARAMETERFVNVPROC) (GLenum target, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETMAPCONTROLPOINTSNVPROC) (GLenum target, GLuint index, GLenum _type, GLsizei ustride, GLsizei vstride, GLboolean packed, GLvoid *points)   nogil
    ctypedef   void ( * PFNGLGETMAPPARAMETERIVNVPROC) (GLenum target, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETMAPPARAMETERFVNVPROC) (GLenum target, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETMAPATTRIBPARAMETERIVNVPROC) (GLenum target, GLuint index, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETMAPATTRIBPARAMETERFVNVPROC) (GLenum target, GLuint index, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLEVALMAPSNVPROC) (GLenum target, GLenum mode)   nogil
    unsigned int GL_NV_packed_depth_stencil   
    unsigned int GL_NV_register_combiners2   
    void  glCombinerStageParameterfvNV (GLenum, GLenum,  GLfloat *)   nogil
    void  glGetCombinerStageParameterfvNV (GLenum, GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLCOMBINERSTAGEPARAMETERFVNVPROC) (GLenum stage, GLenum pname,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETCOMBINERSTAGEPARAMETERFVNVPROC) (GLenum stage, GLenum pname, GLfloat *params)   nogil
    unsigned int GL_NV_texture_compression_vtc   
    unsigned int GL_NV_texture_rectangle   
    unsigned int GL_NV_texture_shader   
    unsigned int GL_NV_texture_shader2   
    unsigned int GL_NV_vertex_array_range2   
    unsigned int GL_NV_vertex_program   
    GLboolean  glAreProgramsResidentNV (GLsizei,  GLuint *, GLboolean *)   nogil
    void  glBindProgramNV (GLenum, GLuint)   nogil
    void  glDeleteProgramsNV (GLsizei,  GLuint *)   nogil
    void  glExecuteProgramNV (GLenum, GLuint,  GLfloat *)   nogil
    void  glGenProgramsNV (GLsizei, GLuint *)   nogil
    void  glGetProgramParameterdvNV (GLenum, GLuint, GLenum, GLdouble *)   nogil
    void  glGetProgramParameterfvNV (GLenum, GLuint, GLenum, GLfloat *)   nogil
    void  glGetProgramivNV (GLuint, GLenum, GLint *)   nogil
    void  glGetProgramStringNV (GLuint, GLenum, GLubyte *)   nogil
    void  glGetTrackMatrixivNV (GLenum, GLuint, GLenum, GLint *)   nogil
    void  glGetVertexAttribdvNV (GLuint, GLenum, GLdouble *)   nogil
    void  glGetVertexAttribfvNV (GLuint, GLenum, GLfloat *)   nogil
    void  glGetVertexAttribivNV (GLuint, GLenum, GLint *)   nogil
    void  glGetVertexAttribPointervNV (GLuint, GLenum, GLvoid* *)   nogil
    GLboolean  glIsProgramNV (GLuint)   nogil
    void  glLoadProgramNV (GLenum, GLuint, GLsizei,  GLubyte *)   nogil
    void  glProgramParameter4dNV (GLenum, GLuint, GLdouble, GLdouble, GLdouble, GLdouble)   nogil
    void  glProgramParameter4dvNV (GLenum, GLuint,  GLdouble *)   nogil
    void  glProgramParameter4fNV (GLenum, GLuint, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glProgramParameter4fvNV (GLenum, GLuint,  GLfloat *)   nogil
    void  glProgramParameters4dvNV (GLenum, GLuint, GLuint,  GLdouble *)   nogil
    void  glProgramParameters4fvNV (GLenum, GLuint, GLuint,  GLfloat *)   nogil
    void  glRequestResidentProgramsNV (GLsizei,  GLuint *)   nogil
    void  glTrackMatrixNV (GLenum, GLuint, GLenum, GLenum)   nogil
    void  glVertexAttribPointerNV (GLuint, GLint, GLenum, GLsizei,  GLvoid *)   nogil
    void  glVertexAttrib1dNV (GLuint, GLdouble)   nogil
    void  glVertexAttrib1dvNV (GLuint,  GLdouble *)   nogil
    void  glVertexAttrib1fNV (GLuint, GLfloat)   nogil
    void  glVertexAttrib1fvNV (GLuint,  GLfloat *)   nogil
    void  glVertexAttrib1sNV (GLuint, GLshort)   nogil
    void  glVertexAttrib1svNV (GLuint,  GLshort *)   nogil
    void  glVertexAttrib2dNV (GLuint, GLdouble, GLdouble)   nogil
    void  glVertexAttrib2dvNV (GLuint,  GLdouble *)   nogil
    void  glVertexAttrib2fNV (GLuint, GLfloat, GLfloat)   nogil
    void  glVertexAttrib2fvNV (GLuint,  GLfloat *)   nogil
    void  glVertexAttrib2sNV (GLuint, GLshort, GLshort)   nogil
    void  glVertexAttrib2svNV (GLuint,  GLshort *)   nogil
    void  glVertexAttrib3dNV (GLuint, GLdouble, GLdouble, GLdouble)   nogil
    void  glVertexAttrib3dvNV (GLuint,  GLdouble *)   nogil
    void  glVertexAttrib3fNV (GLuint, GLfloat, GLfloat, GLfloat)   nogil
    void  glVertexAttrib3fvNV (GLuint,  GLfloat *)   nogil
    void  glVertexAttrib3sNV (GLuint, GLshort, GLshort, GLshort)   nogil
    void  glVertexAttrib3svNV (GLuint,  GLshort *)   nogil
    void  glVertexAttrib4dNV (GLuint, GLdouble, GLdouble, GLdouble, GLdouble)   nogil
    void  glVertexAttrib4dvNV (GLuint,  GLdouble *)   nogil
    void  glVertexAttrib4fNV (GLuint, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glVertexAttrib4fvNV (GLuint,  GLfloat *)   nogil
    void  glVertexAttrib4sNV (GLuint, GLshort, GLshort, GLshort, GLshort)   nogil
    void  glVertexAttrib4svNV (GLuint,  GLshort *)   nogil
    void  glVertexAttrib4ubNV (GLuint, GLubyte, GLubyte, GLubyte, GLubyte)   nogil
    void  glVertexAttrib4ubvNV (GLuint,  GLubyte *)   nogil
    void  glVertexAttribs1dvNV (GLuint, GLsizei,  GLdouble *)   nogil
    void  glVertexAttribs1fvNV (GLuint, GLsizei,  GLfloat *)   nogil
    void  glVertexAttribs1svNV (GLuint, GLsizei,  GLshort *)   nogil
    void  glVertexAttribs2dvNV (GLuint, GLsizei,  GLdouble *)   nogil
    void  glVertexAttribs2fvNV (GLuint, GLsizei,  GLfloat *)   nogil
    void  glVertexAttribs2svNV (GLuint, GLsizei,  GLshort *)   nogil
    void  glVertexAttribs3dvNV (GLuint, GLsizei,  GLdouble *)   nogil
    void  glVertexAttribs3fvNV (GLuint, GLsizei,  GLfloat *)   nogil
    void  glVertexAttribs3svNV (GLuint, GLsizei,  GLshort *)   nogil
    void  glVertexAttribs4dvNV (GLuint, GLsizei,  GLdouble *)   nogil
    void  glVertexAttribs4fvNV (GLuint, GLsizei,  GLfloat *)   nogil
    void  glVertexAttribs4svNV (GLuint, GLsizei,  GLshort *)   nogil
    void  glVertexAttribs4ubvNV (GLuint, GLsizei,  GLubyte *)   nogil
    ctypedef   GLboolean ( * PFNGLAREPROGRAMSRESIDENTNVPROC) (GLsizei n,  GLuint *programs, GLboolean *residences)   nogil
    ctypedef   void ( * PFNGLBINDPROGRAMNVPROC) (GLenum target, GLuint _id)   nogil
    ctypedef   void ( * PFNGLDELETEPROGRAMSNVPROC) (GLsizei n,  GLuint *programs)   nogil
    ctypedef   void ( * PFNGLEXECUTEPROGRAMNVPROC) (GLenum target, GLuint _id,  GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGENPROGRAMSNVPROC) (GLsizei n, GLuint *programs)   nogil
    ctypedef   void ( * PFNGLGETPROGRAMPARAMETERDVNVPROC) (GLenum target, GLuint index, GLenum pname, GLdouble *params)   nogil
    ctypedef   void ( * PFNGLGETPROGRAMPARAMETERFVNVPROC) (GLenum target, GLuint index, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETPROGRAMIVNVPROC) (GLuint _id, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETPROGRAMSTRINGNVPROC) (GLuint _id, GLenum pname, GLubyte *program)   nogil
    ctypedef   void ( * PFNGLGETTRACKMATRIXIVNVPROC) (GLenum target, GLuint address, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETVERTEXATTRIBDVNVPROC) (GLuint index, GLenum pname, GLdouble *params)   nogil
    ctypedef   void ( * PFNGLGETVERTEXATTRIBFVNVPROC) (GLuint index, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETVERTEXATTRIBIVNVPROC) (GLuint index, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETVERTEXATTRIBPOINTERVNVPROC) (GLuint index, GLenum pname, GLvoid* *pointer)   nogil
    ctypedef   GLboolean ( * PFNGLISPROGRAMNVPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLLOADPROGRAMNVPROC) (GLenum target, GLuint _id, GLsizei len,  GLubyte *program)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETER4DNVPROC) (GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETER4DVNVPROC) (GLenum target, GLuint index,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETER4FNVPROC) (GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETER4FVNVPROC) (GLenum target, GLuint index,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETERS4DVNVPROC) (GLenum target, GLuint index, GLuint count,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLPROGRAMPARAMETERS4FVNVPROC) (GLenum target, GLuint index, GLuint count,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLREQUESTRESIDENTPROGRAMSNVPROC) (GLsizei n,  GLuint *programs)   nogil
    ctypedef   void ( * PFNGLTRACKMATRIXNVPROC) (GLenum target, GLuint address, GLenum matrix, GLenum transform)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBPOINTERNVPROC) (GLuint index, GLint fsize, GLenum _type, GLsizei stride,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1DNVPROC) (GLuint index, GLdouble x)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1DVNVPROC) (GLuint index,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1FNVPROC) (GLuint index, GLfloat x)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1FVNVPROC) (GLuint index,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1SNVPROC) (GLuint index, GLshort x)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB1SVNVPROC) (GLuint index,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2DNVPROC) (GLuint index, GLdouble x, GLdouble y)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2DVNVPROC) (GLuint index,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2FNVPROC) (GLuint index, GLfloat x, GLfloat y)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2FVNVPROC) (GLuint index,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2SNVPROC) (GLuint index, GLshort x, GLshort y)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB2SVNVPROC) (GLuint index,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3DNVPROC) (GLuint index, GLdouble x, GLdouble y, GLdouble z)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3DVNVPROC) (GLuint index,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3FNVPROC) (GLuint index, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3FVNVPROC) (GLuint index,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3SNVPROC) (GLuint index, GLshort x, GLshort y, GLshort z)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB3SVNVPROC) (GLuint index,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4DNVPROC) (GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4DVNVPROC) (GLuint index,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4FNVPROC) (GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4FVNVPROC) (GLuint index,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4SNVPROC) (GLuint index, GLshort x, GLshort y, GLshort z, GLshort w)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4SVNVPROC) (GLuint index,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4UBNVPROC) (GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIB4UBVNVPROC) (GLuint index,  GLubyte *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS1DVNVPROC) (GLuint index, GLsizei count,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS1FVNVPROC) (GLuint index, GLsizei count,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS1SVNVPROC) (GLuint index, GLsizei count,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS2DVNVPROC) (GLuint index, GLsizei count,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS2FVNVPROC) (GLuint index, GLsizei count,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS2SVNVPROC) (GLuint index, GLsizei count,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS3DVNVPROC) (GLuint index, GLsizei count,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS3FVNVPROC) (GLuint index, GLsizei count,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS3SVNVPROC) (GLuint index, GLsizei count,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS4DVNVPROC) (GLuint index, GLsizei count,  GLdouble *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS4FVNVPROC) (GLuint index, GLsizei count,  GLfloat *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS4SVNVPROC) (GLuint index, GLsizei count,  GLshort *v)   nogil
    ctypedef   void ( * PFNGLVERTEXATTRIBS4UBVNVPROC) (GLuint index, GLsizei count,  GLubyte *v)   nogil
    unsigned int GL_SGIX_texture_coordinate_clamp   
    unsigned int GL_SGIX_scalebias_hint   
    unsigned int GL_OML_interlace   
    unsigned int GL_OML_subsample   
    unsigned int GL_OML_resample   
    unsigned int GL_NV_copy_depth_to_color   
    unsigned int GL_ATI_envmap_bumpmap   
    void  glTexBumpParameterivATI (GLenum,  GLint *)   nogil
    void  glTexBumpParameterfvATI (GLenum,  GLfloat *)   nogil
    void  glGetTexBumpParameterivATI (GLenum, GLint *)   nogil
    void  glGetTexBumpParameterfvATI (GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLTEXBUMPPARAMETERIVATIPROC) (GLenum pname,  GLint *param)   nogil
    ctypedef   void ( * PFNGLTEXBUMPPARAMETERFVATIPROC) (GLenum pname,  GLfloat *param)   nogil
    ctypedef   void ( * PFNGLGETTEXBUMPPARAMETERIVATIPROC) (GLenum pname, GLint *param)   nogil
    ctypedef   void ( * PFNGLGETTEXBUMPPARAMETERFVATIPROC) (GLenum pname, GLfloat *param)   nogil
    unsigned int GL_ATI_fragment_shader   
    GLuint  glGenFragmentShadersATI (GLuint)   nogil
    void  glBindFragmentShaderATI (GLuint)   nogil
    void  glDeleteFragmentShaderATI (GLuint)   nogil
    void  glBeginFragmentShaderATI ()   nogil
    void  glEndFragmentShaderATI ()   nogil
    void  glPassTexCoordATI (GLuint, GLuint, GLenum)   nogil
    void  glSampleMapATI (GLuint, GLuint, GLenum)   nogil
    void  glColorFragmentOp1ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glColorFragmentOp2ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glColorFragmentOp3ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glAlphaFragmentOp1ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glAlphaFragmentOp2ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glAlphaFragmentOp3ATI (GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glSetFragmentShaderConstantATI (GLuint,  GLfloat *)   nogil
    ctypedef   GLuint ( * PFNGLGENFRAGMENTSHADERSATIPROC) (GLuint _range)   nogil
    ctypedef   void ( * PFNGLBINDFRAGMENTSHADERATIPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLDELETEFRAGMENTSHADERATIPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLBEGINFRAGMENTSHADERATIPROC) ()   nogil
    ctypedef   void ( * PFNGLENDFRAGMENTSHADERATIPROC) ()   nogil
    ctypedef   void ( * PFNGLPASSTEXCOORDATIPROC) (GLuint dst, GLuint coord, GLenum swizzle)   nogil
    ctypedef   void ( * PFNGLSAMPLEMAPATIPROC) (GLuint dst, GLuint interp, GLenum swizzle)   nogil
    ctypedef   void ( * PFNGLCOLORFRAGMENTOP1ATIPROC) (GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod)   nogil
    ctypedef   void ( * PFNGLCOLORFRAGMENTOP2ATIPROC) (GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod)   nogil
    ctypedef   void ( * PFNGLCOLORFRAGMENTOP3ATIPROC) (GLenum op, GLuint dst, GLuint dstMask, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod)   nogil
    ctypedef   void ( * PFNGLALPHAFRAGMENTOP1ATIPROC) (GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod)   nogil
    ctypedef   void ( * PFNGLALPHAFRAGMENTOP2ATIPROC) (GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod)   nogil
    ctypedef   void ( * PFNGLALPHAFRAGMENTOP3ATIPROC) (GLenum op, GLuint dst, GLuint dstMod, GLuint arg1, GLuint arg1Rep, GLuint arg1Mod, GLuint arg2, GLuint arg2Rep, GLuint arg2Mod, GLuint arg3, GLuint arg3Rep, GLuint arg3Mod)   nogil
    ctypedef   void ( * PFNGLSETFRAGMENTSHADERCONSTANTATIPROC) (GLuint dst,  GLfloat *value)   nogil
    unsigned int GL_ATI_pn_triangles   
    void  glPNTrianglesiATI (GLenum, GLint)   nogil
    void  glPNTrianglesfATI (GLenum, GLfloat)   nogil
    ctypedef   void ( * PFNGLPNTRIANGLESIATIPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLPNTRIANGLESFATIPROC) (GLenum pname, GLfloat param)   nogil
    unsigned int GL_ATI_vertex_array_object   
    GLuint  glNewObjectBufferATI (GLsizei,  GLvoid *, GLenum)   nogil
    GLboolean  glIsObjectBufferATI (GLuint)   nogil
    void  glUpdateObjectBufferATI (GLuint, GLuint, GLsizei,  GLvoid *, GLenum)   nogil
    void  glGetObjectBufferfvATI (GLuint, GLenum, GLfloat *)   nogil
    void  glGetObjectBufferivATI (GLuint, GLenum, GLint *)   nogil
    void  glDeleteObjectBufferATI (GLuint)   nogil
    void  glArrayObjectATI (GLenum, GLint, GLenum, GLsizei, GLuint, GLuint)   nogil
    void  glGetArrayObjectfvATI (GLenum, GLenum, GLfloat *)   nogil
    void  glGetArrayObjectivATI (GLenum, GLenum, GLint *)   nogil
    void  glVariantArrayObjectATI (GLuint, GLenum, GLsizei, GLuint, GLuint)   nogil
    void  glGetVariantArrayObjectfvATI (GLuint, GLenum, GLfloat *)   nogil
    void  glGetVariantArrayObjectivATI (GLuint, GLenum, GLint *)   nogil
    ctypedef   GLuint ( * PFNGLNEWOBJECTBUFFERATIPROC) (GLsizei size,  GLvoid *pointer, GLenum usage)   nogil
    ctypedef   GLboolean ( * PFNGLISOBJECTBUFFERATIPROC) (GLuint _buffer)   nogil
    ctypedef   void ( * PFNGLUPDATEOBJECTBUFFERATIPROC) (GLuint _buffer, GLuint offset, GLsizei size,  GLvoid *pointer, GLenum preserve)   nogil
    ctypedef   void ( * PFNGLGETOBJECTBUFFERFVATIPROC) (GLuint _buffer, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETOBJECTBUFFERIVATIPROC) (GLuint _buffer, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLDELETEOBJECTBUFFERATIPROC) (GLuint _buffer)   nogil
    ctypedef   void ( * PFNGLARRAYOBJECTATIPROC) (GLenum array, GLint size, GLenum _type, GLsizei stride, GLuint _buffer, GLuint offset)   nogil
    ctypedef   void ( * PFNGLGETARRAYOBJECTFVATIPROC) (GLenum array, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETARRAYOBJECTIVATIPROC) (GLenum array, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLVARIANTARRAYOBJECTATIPROC) (GLuint _id, GLenum _type, GLsizei stride, GLuint _buffer, GLuint offset)   nogil
    ctypedef   void ( * PFNGLGETVARIANTARRAYOBJECTFVATIPROC) (GLuint _id, GLenum pname, GLfloat *params)   nogil
    ctypedef   void ( * PFNGLGETVARIANTARRAYOBJECTIVATIPROC) (GLuint _id, GLenum pname, GLint *params)   nogil
    unsigned int GL_EXT_vertex_shader   
    void  glBeginVertexShaderEXT ()   nogil
    void  glEndVertexShaderEXT ()   nogil
    void  glBindVertexShaderEXT (GLuint)   nogil
    GLuint  glGenVertexShadersEXT (GLuint)   nogil
    void  glDeleteVertexShaderEXT (GLuint)   nogil
    void  glShaderOp1EXT (GLenum, GLuint, GLuint)   nogil
    void  glShaderOp2EXT (GLenum, GLuint, GLuint, GLuint)   nogil
    void  glShaderOp3EXT (GLenum, GLuint, GLuint, GLuint, GLuint)   nogil
    void  glSwizzleEXT (GLuint, GLuint, GLenum, GLenum, GLenum, GLenum)   nogil
    void  glWriteMaskEXT (GLuint, GLuint, GLenum, GLenum, GLenum, GLenum)   nogil
    void  glInsertComponentEXT (GLuint, GLuint, GLuint)   nogil
    void  glExtractComponentEXT (GLuint, GLuint, GLuint)   nogil
    GLuint  glGenSymbolsEXT (GLenum, GLenum, GLenum, GLuint)   nogil
    void  glSetInvariantEXT (GLuint, GLenum,  void *)   nogil
    void  glSetLocalConstantEXT (GLuint, GLenum,  void *)   nogil
    void  glVariantbvEXT (GLuint,  GLbyte *)   nogil
    void  glVariantsvEXT (GLuint,  GLshort *)   nogil
    void  glVariantivEXT (GLuint,  GLint *)   nogil
    void  glVariantfvEXT (GLuint,  GLfloat *)   nogil
    void  glVariantdvEXT (GLuint,  GLdouble *)   nogil
    void  glVariantubvEXT (GLuint,  GLubyte *)   nogil
    void  glVariantusvEXT (GLuint,  GLushort *)   nogil
    void  glVariantuivEXT (GLuint,  GLuint *)   nogil
    void  glVariantPointerEXT (GLuint, GLenum, GLuint,  void *)   nogil
    void  glEnableVariantClientStateEXT (GLuint)   nogil
    void  glDisableVariantClientStateEXT (GLuint)   nogil
    GLuint  glBindLightParameterEXT (GLenum, GLenum)   nogil
    GLuint  glBindMaterialParameterEXT (GLenum, GLenum)   nogil
    GLuint  glBindTexGenParameterEXT (GLenum, GLenum, GLenum)   nogil
    GLuint  glBindTextureUnitParameterEXT (GLenum, GLenum)   nogil
    GLuint  glBindParameterEXT (GLenum)   nogil
    GLboolean  glIsVariantEnabledEXT (GLuint, GLenum)   nogil
    void  glGetVariantBooleanvEXT (GLuint, GLenum, GLboolean *)   nogil
    void  glGetVariantIntegervEXT (GLuint, GLenum, GLint *)   nogil
    void  glGetVariantFloatvEXT (GLuint, GLenum, GLfloat *)   nogil
    void  glGetVariantPointervEXT (GLuint, GLenum, GLvoid* *)   nogil
    void  glGetInvariantBooleanvEXT (GLuint, GLenum, GLboolean *)   nogil
    void  glGetInvariantIntegervEXT (GLuint, GLenum, GLint *)   nogil
    void  glGetInvariantFloatvEXT (GLuint, GLenum, GLfloat *)   nogil
    void  glGetLocalConstantBooleanvEXT (GLuint, GLenum, GLboolean *)   nogil
    void  glGetLocalConstantIntegervEXT (GLuint, GLenum, GLint *)   nogil
    void  glGetLocalConstantFloatvEXT (GLuint, GLenum, GLfloat *)   nogil
    ctypedef   void ( * PFNGLBEGINVERTEXSHADEREXTPROC) ()   nogil
    ctypedef   void ( * PFNGLENDVERTEXSHADEREXTPROC) ()   nogil
    ctypedef   void ( * PFNGLBINDVERTEXSHADEREXTPROC) (GLuint _id)   nogil
    ctypedef   GLuint ( * PFNGLGENVERTEXSHADERSEXTPROC) (GLuint _range)   nogil
    ctypedef   void ( * PFNGLDELETEVERTEXSHADEREXTPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLSHADEROP1EXTPROC) (GLenum op, GLuint res, GLuint arg1)   nogil
    ctypedef   void ( * PFNGLSHADEROP2EXTPROC) (GLenum op, GLuint res, GLuint arg1, GLuint arg2)   nogil
    ctypedef   void ( * PFNGLSHADEROP3EXTPROC) (GLenum op, GLuint res, GLuint arg1, GLuint arg2, GLuint arg3)   nogil
    ctypedef   void ( * PFNGLSWIZZLEEXTPROC) (GLuint res, GLuint _in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW)   nogil
    ctypedef   void ( * PFNGLWRITEMASKEXTPROC) (GLuint res, GLuint _in, GLenum outX, GLenum outY, GLenum outZ, GLenum outW)   nogil
    ctypedef   void ( * PFNGLINSERTCOMPONENTEXTPROC) (GLuint res, GLuint src, GLuint num)   nogil
    ctypedef   void ( * PFNGLEXTRACTCOMPONENTEXTPROC) (GLuint res, GLuint src, GLuint num)   nogil
    ctypedef   GLuint ( * PFNGLGENSYMBOLSEXTPROC) (GLenum datatype, GLenum storagetype, GLenum _range, GLuint components)   nogil
    ctypedef   void ( * PFNGLSETINVARIANTEXTPROC) (GLuint _id, GLenum _type,  void *addr)   nogil
    ctypedef   void ( * PFNGLSETLOCALCONSTANTEXTPROC) (GLuint _id, GLenum _type,  void *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTBVEXTPROC) (GLuint _id,  GLbyte *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTSVEXTPROC) (GLuint _id,  GLshort *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTIVEXTPROC) (GLuint _id,  GLint *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTFVEXTPROC) (GLuint _id,  GLfloat *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTDVEXTPROC) (GLuint _id,  GLdouble *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTUBVEXTPROC) (GLuint _id,  GLubyte *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTUSVEXTPROC) (GLuint _id,  GLushort *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTUIVEXTPROC) (GLuint _id,  GLuint *addr)   nogil
    ctypedef   void ( * PFNGLVARIANTPOINTEREXTPROC) (GLuint _id, GLenum _type, GLuint stride,  void *addr)   nogil
    ctypedef   void ( * PFNGLENABLEVARIANTCLIENTSTATEEXTPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLDISABLEVARIANTCLIENTSTATEEXTPROC) (GLuint _id)   nogil
    ctypedef   GLuint ( * PFNGLBINDLIGHTPARAMETEREXTPROC) (GLenum light, GLenum value)   nogil
    ctypedef   GLuint ( * PFNGLBINDMATERIALPARAMETEREXTPROC) (GLenum face, GLenum value)   nogil
    ctypedef   GLuint ( * PFNGLBINDTEXGENPARAMETEREXTPROC) (GLenum unit, GLenum coord, GLenum value)   nogil
    ctypedef   GLuint ( * PFNGLBINDTEXTUREUNITPARAMETEREXTPROC) (GLenum unit, GLenum value)   nogil
    ctypedef   GLuint ( * PFNGLBINDPARAMETEREXTPROC) (GLenum value)   nogil
    ctypedef   GLboolean ( * PFNGLISVARIANTENABLEDEXTPROC) (GLuint _id, GLenum cap)   nogil
    ctypedef   void ( * PFNGLGETVARIANTBOOLEANVEXTPROC) (GLuint _id, GLenum value, GLboolean *data)   nogil
    ctypedef   void ( * PFNGLGETVARIANTINTEGERVEXTPROC) (GLuint _id, GLenum value, GLint *data)   nogil
    ctypedef   void ( * PFNGLGETVARIANTFLOATVEXTPROC) (GLuint _id, GLenum value, GLfloat *data)   nogil
    ctypedef   void ( * PFNGLGETVARIANTPOINTERVEXTPROC) (GLuint _id, GLenum value, GLvoid* *data)   nogil
    ctypedef   void ( * PFNGLGETINVARIANTBOOLEANVEXTPROC) (GLuint _id, GLenum value, GLboolean *data)   nogil
    ctypedef   void ( * PFNGLGETINVARIANTINTEGERVEXTPROC) (GLuint _id, GLenum value, GLint *data)   nogil
    ctypedef   void ( * PFNGLGETINVARIANTFLOATVEXTPROC) (GLuint _id, GLenum value, GLfloat *data)   nogil
    ctypedef   void ( * PFNGLGETLOCALCONSTANTBOOLEANVEXTPROC) (GLuint _id, GLenum value, GLboolean *data)   nogil
    ctypedef   void ( * PFNGLGETLOCALCONSTANTINTEGERVEXTPROC) (GLuint _id, GLenum value, GLint *data)   nogil
    ctypedef   void ( * PFNGLGETLOCALCONSTANTFLOATVEXTPROC) (GLuint _id, GLenum value, GLfloat *data)   nogil
    unsigned int GL_ATI_vertex_streams   
    void  glVertexStream1sATI (GLenum, GLshort)   nogil
    void  glVertexStream1svATI (GLenum,  GLshort *)   nogil
    void  glVertexStream1iATI (GLenum, GLint)   nogil
    void  glVertexStream1ivATI (GLenum,  GLint *)   nogil
    void  glVertexStream1fATI (GLenum, GLfloat)   nogil
    void  glVertexStream1fvATI (GLenum,  GLfloat *)   nogil
    void  glVertexStream1dATI (GLenum, GLdouble)   nogil
    void  glVertexStream1dvATI (GLenum,  GLdouble *)   nogil
    void  glVertexStream2sATI (GLenum, GLshort, GLshort)   nogil
    void  glVertexStream2svATI (GLenum,  GLshort *)   nogil
    void  glVertexStream2iATI (GLenum, GLint, GLint)   nogil
    void  glVertexStream2ivATI (GLenum,  GLint *)   nogil
    void  glVertexStream2fATI (GLenum, GLfloat, GLfloat)   nogil
    void  glVertexStream2fvATI (GLenum,  GLfloat *)   nogil
    void  glVertexStream2dATI (GLenum, GLdouble, GLdouble)   nogil
    void  glVertexStream2dvATI (GLenum,  GLdouble *)   nogil
    void  glVertexStream3sATI (GLenum, GLshort, GLshort, GLshort)   nogil
    void  glVertexStream3svATI (GLenum,  GLshort *)   nogil
    void  glVertexStream3iATI (GLenum, GLint, GLint, GLint)   nogil
    void  glVertexStream3ivATI (GLenum,  GLint *)   nogil
    void  glVertexStream3fATI (GLenum, GLfloat, GLfloat, GLfloat)   nogil
    void  glVertexStream3fvATI (GLenum,  GLfloat *)   nogil
    void  glVertexStream3dATI (GLenum, GLdouble, GLdouble, GLdouble)   nogil
    void  glVertexStream3dvATI (GLenum,  GLdouble *)   nogil
    void  glVertexStream4sATI (GLenum, GLshort, GLshort, GLshort, GLshort)   nogil
    void  glVertexStream4svATI (GLenum,  GLshort *)   nogil
    void  glVertexStream4iATI (GLenum, GLint, GLint, GLint, GLint)   nogil
    void  glVertexStream4ivATI (GLenum,  GLint *)   nogil
    void  glVertexStream4fATI (GLenum, GLfloat, GLfloat, GLfloat, GLfloat)   nogil
    void  glVertexStream4fvATI (GLenum,  GLfloat *)   nogil
    void  glVertexStream4dATI (GLenum, GLdouble, GLdouble, GLdouble, GLdouble)   nogil
    void  glVertexStream4dvATI (GLenum,  GLdouble *)   nogil
    void  glNormalStream3bATI (GLenum, GLbyte, GLbyte, GLbyte)   nogil
    void  glNormalStream3bvATI (GLenum,  GLbyte *)   nogil
    void  glNormalStream3sATI (GLenum, GLshort, GLshort, GLshort)   nogil
    void  glNormalStream3svATI (GLenum,  GLshort *)   nogil
    void  glNormalStream3iATI (GLenum, GLint, GLint, GLint)   nogil
    void  glNormalStream3ivATI (GLenum,  GLint *)   nogil
    void  glNormalStream3fATI (GLenum, GLfloat, GLfloat, GLfloat)   nogil
    void  glNormalStream3fvATI (GLenum,  GLfloat *)   nogil
    void  glNormalStream3dATI (GLenum, GLdouble, GLdouble, GLdouble)   nogil
    void  glNormalStream3dvATI (GLenum,  GLdouble *)   nogil
    void  glClientActiveVertexStreamATI (GLenum)   nogil
    void  glVertexBlendEnviATI (GLenum, GLint)   nogil
    void  glVertexBlendEnvfATI (GLenum, GLfloat)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1SATIPROC) (GLenum stream, GLshort x)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1SVATIPROC) (GLenum stream,  GLshort *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1IATIPROC) (GLenum stream, GLint x)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1IVATIPROC) (GLenum stream,  GLint *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1FATIPROC) (GLenum stream, GLfloat x)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1FVATIPROC) (GLenum stream,  GLfloat *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1DATIPROC) (GLenum stream, GLdouble x)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM1DVATIPROC) (GLenum stream,  GLdouble *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2SATIPROC) (GLenum stream, GLshort x, GLshort y)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2SVATIPROC) (GLenum stream,  GLshort *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2IATIPROC) (GLenum stream, GLint x, GLint y)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2IVATIPROC) (GLenum stream,  GLint *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2FATIPROC) (GLenum stream, GLfloat x, GLfloat y)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2FVATIPROC) (GLenum stream,  GLfloat *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2DATIPROC) (GLenum stream, GLdouble x, GLdouble y)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM2DVATIPROC) (GLenum stream,  GLdouble *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3SATIPROC) (GLenum stream, GLshort x, GLshort y, GLshort z)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3SVATIPROC) (GLenum stream,  GLshort *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3IATIPROC) (GLenum stream, GLint x, GLint y, GLint z)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3IVATIPROC) (GLenum stream,  GLint *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3FATIPROC) (GLenum stream, GLfloat x, GLfloat y, GLfloat z)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3FVATIPROC) (GLenum stream,  GLfloat *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3DATIPROC) (GLenum stream, GLdouble x, GLdouble y, GLdouble z)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM3DVATIPROC) (GLenum stream,  GLdouble *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4SATIPROC) (GLenum stream, GLshort x, GLshort y, GLshort z, GLshort w)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4SVATIPROC) (GLenum stream,  GLshort *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4IATIPROC) (GLenum stream, GLint x, GLint y, GLint z, GLint w)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4IVATIPROC) (GLenum stream,  GLint *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4FATIPROC) (GLenum stream, GLfloat x, GLfloat y, GLfloat z, GLfloat w)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4FVATIPROC) (GLenum stream,  GLfloat *coords)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4DATIPROC) (GLenum stream, GLdouble x, GLdouble y, GLdouble z, GLdouble w)   nogil
    ctypedef   void ( * PFNGLVERTEXSTREAM4DVATIPROC) (GLenum stream,  GLdouble *coords)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3BATIPROC) (GLenum stream, GLbyte nx, GLbyte ny, GLbyte nz)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3BVATIPROC) (GLenum stream,  GLbyte *coords)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3SATIPROC) (GLenum stream, GLshort nx, GLshort ny, GLshort nz)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3SVATIPROC) (GLenum stream,  GLshort *coords)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3IATIPROC) (GLenum stream, GLint nx, GLint ny, GLint nz)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3IVATIPROC) (GLenum stream,  GLint *coords)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3FATIPROC) (GLenum stream, GLfloat nx, GLfloat ny, GLfloat nz)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3FVATIPROC) (GLenum stream,  GLfloat *coords)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3DATIPROC) (GLenum stream, GLdouble nx, GLdouble ny, GLdouble nz)   nogil
    ctypedef   void ( * PFNGLNORMALSTREAM3DVATIPROC) (GLenum stream,  GLdouble *coords)   nogil
    ctypedef   void ( * PFNGLCLIENTACTIVEVERTEXSTREAMATIPROC) (GLenum stream)   nogil
    ctypedef   void ( * PFNGLVERTEXBLENDENVIATIPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLVERTEXBLENDENVFATIPROC) (GLenum pname, GLfloat param)   nogil
    unsigned int GL_ATI_element_array   
    void  glElementPointerATI (GLenum,  GLvoid *)   nogil
    void  glDrawElementArrayATI (GLenum, GLsizei)   nogil
    void  glDrawRangeElementArrayATI (GLenum, GLuint, GLuint, GLsizei)   nogil
    ctypedef   void ( * PFNGLELEMENTPOINTERATIPROC) (GLenum _type,  GLvoid *pointer)   nogil
    ctypedef   void ( * PFNGLDRAWELEMENTARRAYATIPROC) (GLenum mode, GLsizei count)   nogil
    ctypedef   void ( * PFNGLDRAWRANGEELEMENTARRAYATIPROC) (GLenum mode, GLuint start, GLuint end, GLsizei count)   nogil
    unsigned int GL_SUN_mesh_array   
    void  glDrawMeshArraysSUN (GLenum, GLint, GLsizei, GLsizei)   nogil
    ctypedef   void ( * PFNGLDRAWMESHARRAYSSUNPROC) (GLenum mode, GLint first, GLsizei count, GLsizei width)   nogil
    unsigned int GL_SUN_slice_accum   
    unsigned int GL_NV_multisample_filter_hint   
    unsigned int GL_NV_depth_clamp   
    unsigned int GL_NV_occlusion_query   
    void  glGenOcclusionQueriesNV (GLsizei, GLuint *)   nogil
    void  glDeleteOcclusionQueriesNV (GLsizei,  GLuint *)   nogil
    GLboolean  glIsOcclusionQueryNV (GLuint)   nogil
    void  glBeginOcclusionQueryNV (GLuint)   nogil
    void  glEndOcclusionQueryNV ()   nogil
    void  glGetOcclusionQueryivNV (GLuint, GLenum, GLint *)   nogil
    void  glGetOcclusionQueryuivNV (GLuint, GLenum, GLuint *)   nogil
    ctypedef   void ( * PFNGLGENOCCLUSIONQUERIESNVPROC) (GLsizei n, GLuint *ids)   nogil
    ctypedef   void ( * PFNGLDELETEOCCLUSIONQUERIESNVPROC) (GLsizei n,  GLuint *ids)   nogil
    ctypedef   GLboolean ( * PFNGLISOCCLUSIONQUERYNVPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLBEGINOCCLUSIONQUERYNVPROC) (GLuint _id)   nogil
    ctypedef   void ( * PFNGLENDOCCLUSIONQUERYNVPROC) ()   nogil
    ctypedef   void ( * PFNGLGETOCCLUSIONQUERYIVNVPROC) (GLuint _id, GLenum pname, GLint *params)   nogil
    ctypedef   void ( * PFNGLGETOCCLUSIONQUERYUIVNVPROC) (GLuint _id, GLenum pname, GLuint *params)   nogil
    unsigned int GL_NV_point_sprite   
    void  glPointParameteriNV (GLenum, GLint)   nogil
    void  glPointParameterivNV (GLenum,  GLint *)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERINVPROC) (GLenum pname, GLint param)   nogil
    ctypedef   void ( * PFNGLPOINTPARAMETERIVNVPROC) (GLenum pname,  GLint *params)   nogil
    unsigned int GL_NV_texture_shader3   
    unsigned int GL_NV_vertex_program1_1   


