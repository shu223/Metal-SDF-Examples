//
//  GradSDF.metal
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/05/10.
//

#include <metal_stdlib>
using namespace metal;

#include "CommonScene.h"

// 法線の計算
// 拡散光の計算に必要

float3 gradSDF(float3 p, SceneSDF sceneSDF) {
    float eps = 0.001;
    return normalize(float3(
                            sceneSDF(p + float3(eps, 0.0, 0.0)) - sceneSDF(p - float3(eps, 0.0, 0.0)),
                            sceneSDF(p + float3(0.0, eps, 0.0)) - sceneSDF(p - float3(0.0, eps, 0.0)),
                            sceneSDF(p + float3(0.0, 0.0, eps)) - sceneSDF(p - float3(0.0, 0.0, eps))
                            ));
}

float3 gradSDF(float3 p, float time, SceneSDFWithTime sceneSDF) {
    float eps = 0.001;
    return normalize(float3(
                            sceneSDF(p + float3(eps, 0.0, 0.0), time) - sceneSDF(p - float3(eps, 0.0, 0.0), time),
                            sceneSDF(p + float3(0.0, eps, 0.0), time) - sceneSDF(p - float3(0.0, eps, 0.0), time),
                            sceneSDF(p + float3(0.0, 0.0, eps), time) - sceneSDF(p - float3(0.0, 0.0, eps), time)
                            ));
}

