#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uDistortionStrength;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    
    // Wave ripples across water tiles
    float waveX = sin(uv.y * 24.0 + uTime * 2.8) * 0.006 * uDistortionStrength;
    float waveY = cos(uv.x * 18.0 + uTime * 2.2) * 0.006 * uDistortionStrength;
    vec2 distortedUv = clamp(uv + vec2(waveX, waveY), 0.0, 1.0);

    vec4 color = texture(uTexture, distortedUv);

    // Soft water shimmer reflection
    float crest = sin((distortedUv.x + distortedUv.y) * 20.0 + uTime * 3.2);
    if (crest > 0.82) {
        color.rgb += vec3(0.10, 0.15, 0.22) * (crest - 0.82) * 3.5;
    }

    fragColor = color;
}

