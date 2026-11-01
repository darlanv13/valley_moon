#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uWindIntensity;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;

    // Foliage sway is amplified towards the canopy top (lower UV Y coordinate)
    float heightWeight = clamp(1.0 - uv.y, 0.0, 1.0);
    float swayX = sin(uTime * 3.2 + uv.x * 6.0) * 0.018 * uWindIntensity * heightWeight;
    float swayY = cos(uTime * 1.8 + uv.y * 4.0) * 0.007 * uWindIntensity * heightWeight;

    vec2 swayedUv = clamp(uv + vec2(swayX, swayY), 0.0, 1.0);
    vec4 color = texture(uTexture, swayedUv);

    fragColor = color;
}
