//
//  Textures.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"

float text(float2 st) {
    return mod(floor(st.x) + floor(st.y), 2.0);
}

// パーリンノイズ生成に使用する
//start hash
constant uint3 k = uint3(0x456789abu, 0x6789ab45u, 0x89ab4567u);
constant uint3 u = uint3(1, 2, 3);

uint uhash11(uint n) {
    n ^= (n << u.x);
    n ^= (n >> u.x);
    n *= k.x;
    n ^= (n << u.x);
    return n * k.x;
}
uint2 uhash22(uint2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;
}
uint3 uhash33(uint3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;
}
float hash11(float p) {
    uint n = as_type<uint>(p);
    return float(uhash11(n)) / float(UINT_MAX);
}
float hash21(float2 p) {
    uint2 n = as_type<uint2>(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}
float hash31(float3 p) {
    uint3 n = as_type<uint3>(p);
    return float(uhash33(n).x) / float(UINT_MAX);
}
float2 hash22(float2 p) {
    uint2 n = as_type<uint2>(p);
    return float2(uhash22(n)) / float2(UINT_MAX);
}
float3 hash33(float3 p) {
    uint3 n = as_type<uint3>(p);
    return float3(uhash33(n)) / float3(UINT_MAX);
}
//end hash

// パーリンノイズ生成
// 4_4が初出
//start pnoise
float gtable2(float2 lattice, float2 p) {
    uint2 n = as_type<uint2>(lattice);
    uint ind = uhash22(n).x >> 29;
    float u = 0.92387953 * (ind < 4u ? p.x : p.y);  //0.92387953 = cos(pi/8)
    float v = 0.38268343 * (ind < 4u ? p.y : p.x);  //0.38268343 = sin(pi/8)
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u? v : -v);
}

float pnoise21(float2 p) {
    float2 n = floor(p);
    float2 f = fract(p);
    float v[4];
    for (int j = 0; j < 2; j ++) {
        for (int i = 0; i < 2; i++) {
            v[i+2*j] = gtable2(n + float2(i, j), f - float2(i, j));
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]) + 0.5;
}

float gtable3(float3 lattice, float3 p) {
    uint3 n = as_type<uint3>(lattice);
    uint ind = uhash33(n).x >> 28;
    float u = ind < 8u ? p.x : p.y;
    float v = ind < 4u ? p.y : ind == 12u || ind == 14u ? p.x : p.z;
    return ((ind & 1u) == 0u? u: -u) + ((ind & 2u) == 0u? v : -v);
}

float pnoise31(float3 p) {
    float3 n = floor(p);
    float3 f = fract(p);
    float v[8];
    for (int k = 0; k < 2; k++ ) {
        for (int j = 0; j < 2; j++ ) {
            for (int i = 0; i < 2; i++) {
                v[i+2*j+4*k] = gtable3(n + float3(i, j, k), f - float3(i, j, k)) * 0.70710678;
            }

        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float w[2];
    for (int i = 0; i < 2; i++) {
        w[i] = mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);
    }
    return 0.5 * mix(w[0], w[1], f[2]) + 0.5;
}
//end pnoise
