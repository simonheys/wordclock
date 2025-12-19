//
//  WordClockShaders.metal
//  Placeholder Metal shader set for WordClock migration.
//

#include <metal_stdlib>
using namespace metal;

struct WordVertexIn {
    float2 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
    float4 color [[attribute(2)]];
};

struct VSUniforms {
    float4x4 projection;
};

struct WordVertexOut {
    float4 position [[position]];
    float2 uv;
    float4 color;
};

vertex WordVertexOut wordclock_vertex(WordVertexIn in [[stage_in]],
                                      constant VSUniforms& uniforms [[buffer(1)]]) {
    WordVertexOut out;
    float4 pos = float4(in.position, 0.0, 1.0);
    out.position = uniforms.projection * pos;
    out.uv = in.uv;
    out.color = in.color;
    return out;
}

fragment float4 wordclock_fragment(WordVertexOut in [[stage_in]],
                                   texture2d<float> tex [[texture(0)]],
                                   sampler samp [[sampler(0)]]) {
    float4 sample = tex.sample(samp, in.uv);
    return sample * in.color;
}
