attribute vec4 aPosition;
attribute vec3 aNormal;

varying vec4 DestinationColor;

// light
uniform vec4 uLightAmbient;
uniform vec4 uLightDiffuse;
uniform vec4 uLightSpecular;
uniform vec3 uLightPos;

// material
uniform vec4 uMaterialAmbient;
uniform vec4 uMaterialDiffuse;
uniform vec4 uMaterialSpecular;
uniform float uMaterialShininess;

uniform mat4 uPMatrix; // projection
uniform mat4 uMMatrix; // modelview

uniform mat4 uNormalMatrix; // gyakutenti

void main(void) { // 4

    // environment
    vec4 ambient = uLightAmbient * uMaterialAmbient;

    // diffuse
    vec3 P = vec3(uMMatrix * aPosition);
    vec3 L = normalize(uLightPos - P);
    vec3 N = normalize(mat3(uNormalMatrix) * aNormal);
    vec4 diffuseP = vec4(max(dot(L,N), 0.0));
    vec4 diffuse = diffuseP * uLightDiffuse * uMaterialDiffuse;

    // specular
    vec3 S = normalize(L+vec3(0.0, 0.0, 1.0));
    float specularP = pow(max(dot(N,S), 0.0), uMaterialShininess);
    vec4 specular = specularP * uLightSpecular * uMaterialSpecular;

    // fragment color
    DestinationColor = ambient + diffuse + specular;

    gl_Position = uPMatrix * uMMatrix * aPosition;
}
