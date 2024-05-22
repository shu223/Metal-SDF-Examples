//
//  SDFShaders.metal
//  MSLSandbox
//
//  Created by Shuichi Tsutsumi on 2024/03/08.
//  Copyright © 2024 Shuichi Tsutsumi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float circleSDF(float2 p, float2 c, float r){
    return length(p - c) - r;
}

// 球のSDF
// c: 球の中心, r: 半径(radius)
float sphereSDF(float3 p, float3 c, float r){
    return length(p - c) - r;
}

float sphereSDF(float3 p){
    return sphereSDF(p, float3(0), 1.0);
}

float planeSDF(float3 p, float3 n, float s){
    return dot(normalize(n), p) - s;
}

float boxSDF(float3 p, float3 c, float3 d, float s){
    p = abs(p - c);
    return length(max(p - d, float3(0.0))) + min(max(max(p.x - d.x, p.y - d.y), p.z - d.z), 0.0) - s;
}

float octaSDF(float3 p, float s){
    return planeSDF(abs(p), float3(1.0), s);
}
