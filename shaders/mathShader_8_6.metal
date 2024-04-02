//
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//
//  The original GLSL code: https://github.com/yutannihilation/math_of_realtime_graphics_wgsl_version

#include <metal_stdlib>
using namespace metal;

#include "SDF.h"

float sceneSDF_8_6(float3 p) {
    return sphereSDF(p, float3(0), 1.0);
}

// 法線の計算
// 拡散光の計算に必要
float3 gradSDF_8_6(float3 p) {
    float eps = 0.001;
    // 勾配を正規化
    return normalize(float3(
                            sceneSDF_8_6(p + float3(eps, 0.0, 0.0)) - sceneSDF_8_6(p - float3(eps, 0.0, 0.0)),
                            sceneSDF_8_6(p + float3(0.0, eps, 0.0)) - sceneSDF_8_6(p - float3(0.0, eps, 0.0)),
                            sceneSDF_8_6(p + float3(0.0, 0.0, eps)) - sceneSDF_8_6(p - float3(0.0, 0.0, eps))
                            ));
}

[[ stitchable ]] half4 mathGraphicsShader_8_6(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    // カメラの位置
    float3 cPos = float3(0.0, 0.0, 2.0);

    // カメラの向き
    float3 cDir = float3(0.0, 0.0, -1.0);

    // カメラの上方向
    float3 cUp = float3(0.0, -1.0, 0.0);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 lPos = float3(2.0);
    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_8_6(rPos) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_8_6(rPos) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lPos - rPos), gradSDF_8_6(rPos)), 0.0);
            // 光の色
            half3 col = half3(0.0, 1.0, 1.0);
            // 拡散光と環境光の和によって光の強さが決まる。これに光の色をかけて色が決まる。
            col *= diff + amb;
            rgb = col;
            break;
        }
    }

    return half4(rgb, 1);
}