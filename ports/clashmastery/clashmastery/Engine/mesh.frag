#define MAX_NUM_LIGHTS 12
struct Light {
    vec3 position;
    float intensity;
    bool isActive;
    vec3 color;
    float constant;
    float linear;
    float quadratic;
    float botanic;
};
uniform Light lights[MAX_NUM_LIGHTS];
uniform float ambientLighting;
varying vec3 vertexNormal_out; // given from the vertex shader
varying vec3 fragPos; // given from vertex shader
vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(tex, vec2(texcoord.x, 1.0-texcoord.y));
    if (texcolor.a == 0.0) { discard; }

    vec3 norm = normalize(vertexNormal_out);
    vec3 currentLighting = vec3(ambientLighting, ambientLighting, ambientLighting);
    for (int i = 0; i < MAX_NUM_LIGHTS; i++) {
        Light currentLight = lights[i];
        vec3 lightDir = normalize(currentLight.position - fragPos);
        float diffuseLight = max(dot(norm, lightDir), 0.0);
        float dist = length(currentLight.position - fragPos);
        float isActive = float(currentLight.isActive);
        float attenuation = 1.0 / (currentLight.constant + currentLight.linear * dist + currentLight.quadratic * dist * dist);
        currentLighting += diffuseLight * isActive * currentLight.intensity * currentLight.color * attenuation;
    }
    // We could make the lighting more stylized if we gave discrete levels to it
    // currentLighting = step(0.5, currentLighting) + ambientStrength;
    // currentLighting = floor(currentLighting / 0.5) * 0.5 + ambientStrength;
    // if (length(currentLighting) > 0.6) {
        // currentLighting = floor(currentLighting / 0.15) * 0.15;
    // }
    vec4 currentLightingVec = vec4(currentLighting, 1.0);
    return vec4(texcolor)*color*currentLightingVec;
}
