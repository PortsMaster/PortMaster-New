varying vec3 lightVec;
varying vec3 viewVec;
varying float distf;



uniform float mindist;
uniform vec3 tangent;
uniform float factor;

void main(void)
{
  gl_Position = ftransform();
  gl_TexCoord[0] = gl_MultiTexCoord0;

  vec3 n = normalize(gl_NormalMatrix * gl_Normal);
  vec3 t = normalize(gl_NormalMatrix * tangent.xyz);
  vec3 b = cross(n, t);

  vec3 v;
  vec3 vVertex = vec3(gl_ModelViewMatrix * gl_Vertex);
  int i;
 
    vec3 lVec = gl_LightSource[0].position.xyz - vVertex;
    v.x = dot(lVec, t);
    v.y = dot(lVec, b);
    v.z = dot(lVec, n);
    lightVec = v;
  

  vec3 vVec = -vVertex;
  v.x = dot(vVec, t);
  v.y = dot(vVec, b);
  v.z = dot(vVec, n);
  viewVec = v;

  if (gl_Position.z<mindist) distf=1.0; else distf=mindist/gl_Position.z;
  distf=distf*factor;
}

