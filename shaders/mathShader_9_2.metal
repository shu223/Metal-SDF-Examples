//
//  Metal-SDF-Examples
//
//  Created by Shuichi Tsutsumi on 2024/03/19.
//
//  The original GLSL code: https://github.com/yutannihilation/math_of_realtime_graphics_wgsl_version

#include <metal_stdlib>
using namespace metal;

#include "CommonFunctions.h"
#include "RotateFunctions.h"
#include "SDF.h"
#include "GradSDF.h"

constant float PI = 3.14159265359;

float sceneSDF_9_2(float3 p, float time) {
    float t = 0.5 * time;
    // 回転
    p = euler(p, float3(t));

    // 6個の球の和集合のSDF
    float d1 = 1.0;
    for (float i = 0.0; i < 6.0; i++) {
        // 円周上に球を配置（球の中心を決めている）
        float3 cent = float3(cos(PI * i / 3.0), sin(PI * i / 3.0), 0.0);
        // 和集合を取っていく
        d1 = min(d1, sphereSDF(p, cent, 0.2));
    }

    // 原点を中心とした球のSDF
    float d2 = sphereSDF(p, float3(0.0), 1.);

    // ブレンド係数の計算
    // mod(t, 2.0) によりtは0〜2.0を周期的に繰り返す
    // abs(... - 1.0) により0から1の範囲に押し込まれる
    float a = abs(mod(t, 2.0) - 1.0);

    // 2つのSDFの補間
    // aに応じてd1とd2がブレンドされる
    return mix(d1, d2, a);
}

[[ stitchable ]] half4 mathGraphicsShader_9_2(float2 position,
                                              half4 color,
                                              float4 boundingRect,
                                              float time)
{
    float2 p = (position.xy * 2.0 - boundingRect.zw) / min(boundingRect.z, boundingRect.w);

    // カメラの位置
    float3 cPos = float3(0.0, 0.0, 2.5);

    // カメラの向き
    float3 cDir = float3(0.0, 0.0, -1.0);

    // カメラの上方向
    float3 cUp = float3(0.0, -1.0, 0.0);

    float3 cSide = cross(cDir, cUp);

    // スクリーンのz座標
    float targetDepth = 1.0;

    // 平行光の方向
    float3 lDir = float3(0.0, 0.0, 1.0);

    // カメラからスクリーンのマス目へ向かうベクトル
    float3 ray = cSide * p.x + cUp * p.y + cDir * targetDepth;
    ray = normalize(ray);

    float3 rPos = ray + cPos;

    half3 rgb = half3(0.0);
    // レイを進めるループ
    for(int i = 0; i < 50; i ++ ) {
        if (sceneSDF_9_2(rPos, time) > 0.001) { // 球にぶつかる前
            // レイをさらに進める
            rPos += sceneSDF_9_2(rPos, time) * ray;
        } else { // レイが球にぶつかったところで接平面でのライティングを計算
            // 環境光の強さ
            float amb = 0.1;
            // 平行光による拡散光の強さの計算
            // 平行光と法線の内積を取る（法線と同じ角度で入社すると一番強い）
            float diff = 0.9 * max(dot(normalize(lDir), gradSDF(rPos, time, sceneSDF_9_2)), 0.0);
            // 光の色
            half3 col = half3(1.0);
            // 拡散光と環境光の和によって光の強さが決まる。これに光の色をかけて色が決まる。
            col *= diff + amb;
            rgb = col;
            break;
        }
    }

    return half4(rgb, 1);
}
