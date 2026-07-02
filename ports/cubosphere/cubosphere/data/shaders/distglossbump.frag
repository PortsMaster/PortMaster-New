varying vec3 lightVec;
varying vec3 viewVec;
varying float distf;
//uniform float specfactor;

const float bright=0.5;
const float specfactor=1.5;

uniform sampler2D base;
uniform sampler2D normalMap;
uniform sampler2D glossMap;
void main (void)
{
  vec2 uv = gl_TexCoord[0].st ;
  vec4 base = texture2D(base, uv);
  vec4 final_color = bright*base;
  vec3 vVec = normalize(viewVec);
  vec3 bump =
     normalize(texture2D(normalMap, uv).xyz * 2.0 - 1.0);
  vec3 R = reflect(-vVec, bump);
  
  {
    vec3 lVec = normalize(lightVec);
    float diffuse = max(dot(lVec, bump), 0.0);
    vec4 vDiffuse =
       gl_FrontLightProduct[0].diffuse *
       diffuse * base;
    final_color += vDiffuse;

    float specular =
      pow(clamp(dot(R, lVec), 0.0, 1.0),
            gl_FrontMaterial.shininess);
    //vec4 vSpecular =
     // gl_FrontLightProduct[0].specular *
      vec4 vSpecular = texture2D(glossMap,uv)*
      specular *distf;
    final_color += vSpecular*specfactor;
  }
  //final_color= gl_FrontLightProduct[0].ambient*base;
  //final_color=gl_FrontLightProduct[0].ambient;
  gl_FragColor = final_color;
}
