//
//  RotateFunctions.metal
//
//  Created by Shuichi Tsutsumi on 2024/03/08.
//  Copyright © 2024 Shuichi Tsutsumi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// p.63 にある、2次元ベクトルを角θ回転させる式をコードに落とし込んだもの
float2 rot2(float2 p, float t){
    return float2(cos(t) * p.x -sin(t) * p.y, sin(t) * p.x + cos(t) * p.y);
}

float3 rotX(float3 p, float t){
    return float3(p.x, rot2(p.yz, t));
}

float3 rotY(float3 p, float t){
    return float3(p.y, rot2(p.zx, t)).zxy;
}

float3 rotZ(float3 p, float t){
    return float3(rot2(p.xy, t), p.z);
}

// オイラー角を使った回転
// 3つの軸に関する回転を合成して、3次元的に回転させている
float3 euler(float3 p, float3 t){
    return rotZ(rotY(rotX(p, t.x), t.y), t.z);
}

