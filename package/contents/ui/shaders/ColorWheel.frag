#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
} ubuf;

vec4 hsv2rgb(vec4 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
    return vec4(c.z * mix(vec3(1.0), rgb, c.y), c.w);
}

void main() {
    vec2 p = qt_TexCoord0 * 2.0 - 1.0;
    float r = length(p);
    float a = atan(p.y, p.x) / (3.1415926535 * 2.0) + 0.5;
    if (r <= 1.0) {
        fragColor = hsv2rgb(vec4(a, r, 1.0, ubuf.qt_Opacity));
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}