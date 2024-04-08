//
//  CommonScene.metal
//  Metal-SDF-Examples
//

#include <metal_stdlib>
using namespace metal;

#include "SDF.h"

// 球が1つあるだけのシーンのSDF
float sphereSceneSDF(float3 p) {
    return sphereSDF(p);
}

// 球が1つあるだけのシーンの法線の計算
// 拡散光の計算に必要
float3 sphereSceneGradSDF(float3 p) {
    float eps = 0.001;
    // 勾配を正規化
    return normalize(float3(
                            sphereSceneSDF(p + float3(eps, 0.0, 0.0)) - sphereSceneSDF(p - float3(eps, 0.0, 0.0)),
                            sphereSceneSDF(p + float3(0.0, eps, 0.0)) - sphereSceneSDF(p - float3(0.0, eps, 0.0)),
                            sphereSceneSDF(p + float3(0.0, 0.0, eps)) - sphereSceneSDF(p - float3(0.0, 0.0, eps))
                            ));
}
